
import { CommonModule } from '@angular/common';
import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { ActivatedRoute, RouterModule } from '@angular/router';

import { CoursesService } from '../courses.service';
import {
  ContentLibraryItem,
  ContentLibraryItemType,
  ContentLibraryService
} from '../../content-library/content-library.service';

type LessonType =
  | 'VIDEO'
  | 'AUDIO'
  | 'PDF'
  | 'SLIDES'
  | 'TEXT';

type LessonSource = 'UPLOAD' | 'LIBRARY';

@Component({
  selector: 'app-course-content',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    RouterModule
  ],
  templateUrl: './course-content.html',
  styleUrls: ['./course-content.scss']
})
export class CourseContent implements OnInit {
  courseId = '';
  courseTitle = '';

  moduleForm: FormGroup;
  lessonForm: FormGroup;

  modules: any[] = [];
  loading = true;
  error = '';

  moduleSubmitting = false;
  lessonSubmitting = false;

  showModuleForm = false;
  editingModuleId: string | null = null;

  lessonFormModuleId: string | null = null;
  editingLessonId: string | null = null;

  selectedLessonFile: File | null = null;
  currentLessonFileName = '';

  lessonSource: LessonSource = 'UPLOAD';

  libraryItems: ContentLibraryItem[] = [];
  libraryLoading = false;
  libraryError = '';
  librarySearchTerm = '';
  librarySelectedType: ContentLibraryItemType | '' = '';
  selectedLibraryItem: ContentLibraryItem | null = null;

  lessonTypes: LessonType[] = [
    'VIDEO',
    'AUDIO',
    'PDF',
    'SLIDES',
    'TEXT'
  ];

  libraryTypes: ContentLibraryItemType[] = [
    'VIDEO',
    'AUDIO',
    'PDF',
    'SLIDES',
    'DOCUMENT',
    'IMAGE',
    'LINK'
  ];

  showFileUpload = true;
  showTextContent = false;
  showExternalUrl = false;

  acceptTypes = '.mp4,.mov,.webm';

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private coursesService: CoursesService,
    private contentLibraryService: ContentLibraryService,
    private cdr: ChangeDetectorRef
  ) {
    this.moduleForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(3)]],
      description: [''],
      displayOrder: [0],
      isPreview: [false]
    });

    this.lessonForm = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(3)]],
      description: [''],
      type: ['VIDEO', Validators.required],
      durationMinutes: [null],
      displayOrder: [0],
      isPreview: [false],
      isPublished: [true],
      downloadable: [false],
      streamingUrl: [''],
      thumbnailUrl: [''],
      contentUrl: [''],
      textContent: ['']
    });
  }

  ngOnInit(): void {
    this.courseId =
      this.route.snapshot.paramMap.get('id') || '';

    if (!this.courseId) {
      this.error = 'Course ID is missing.';
      this.loading = false;
      return;
    }

    this.loadCourseTitle();
    this.loadModules();
  }

  get selectedLessonType(): LessonType {
    return this.lessonForm.value.type as LessonType;
  }

  get lessonTypeHint(): string {
    if (this.lessonSource === 'LIBRARY') {
      return 'Select a reusable content item from your active Content Library. Its file URL is copied into this course lesson.';
    }

    switch (this.selectedLessonType) {
      case 'VIDEO':
        return 'Upload MP4, MOV, or WebM video. Use VIDEO only for playable video files or video URLs.';
      case 'AUDIO':
        return 'Upload MP3, WAV, or M4A audio. Use AUDIO only for playable audio files.';
      case 'PDF':
        return 'Upload a PDF document. Learners can open or download it on web and mobile.';
      case 'SLIDES':
        return 'Upload a PDF export of a presentation. PowerPoint files must be converted to PDF.';
      case 'TEXT':
        return 'Enter written lesson content below. Do not upload a file for a TEXT lesson.';
      default:
        return '';
    }
  }

  loadCourseTitle(): void {
    this.coursesService.getCourseById(this.courseId).subscribe({
      next: res => {
        this.courseTitle = (res?.data || res)?.title || '';
        this.cdr.detectChanges();
      },
      error: () => {
        this.courseTitle = 'Course Content';
        this.cdr.detectChanges();
      }
    });
  }

  loadModules(): void {
    this.loading = true;
    this.error = '';

    this.coursesService.getModules(this.courseId).subscribe({
      next: res => {
        const rawModules = Array.isArray(res?.data)
          ? res.data
          : Array.isArray(res)
            ? res
            : [];

        this.modules = rawModules
          .sort(
            (a: any, b: any) =>
              (a.displayOrder ?? 0) -
              (b.displayOrder ?? 0)
          )
          .map((module: any) => ({
            ...module,
            expanded: false,
            lessons: [],
            lessonsLoaded: false
          }));

        this.loading = false;
        this.cdr.detectChanges();

        this.modules.forEach(module => {
          this.loadLessonsForModule(module);
        });
      },
      error: err => {
        this.error =
          err?.error?.message ||
          'Failed to load modules.';
        this.modules = [];
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  private loadLessonsForModule(module: any): void {
    this.coursesService
      .getLessonsByModule(this.courseId, module.id)
      .subscribe({
        next: lessonRes => {
          const lessons = Array.isArray(lessonRes?.data)
            ? lessonRes.data
            : Array.isArray(lessonRes)
              ? lessonRes
              : [];

          module.lessons = lessons.sort(
            (a: any, b: any) =>
              (a.displayOrder ?? a.order ?? 0) -
              (b.displayOrder ?? b.order ?? 0)
          );

          module.lessonsLoaded = true;
          this.cdr.detectChanges();
        },
        error: () => {
          module.lessons = [];
          module.lessonsLoaded = true;
          this.cdr.detectChanges();
        }
      });
  }

  toggleModule(module: any): void {
    module.expanded = !module.expanded;

    if (module.expanded && !module.lessonsLoaded) {
      this.loadLessonsForModule(module);
    }
  }

  openNewModuleForm(): void {
    this.editingModuleId = null;

    this.moduleForm.reset({
      title: '',
      description: '',
      displayOrder: this.modules.length,
      isPreview: false
    });

    this.showModuleForm = true;
  }

  startEditModule(module: any, event: Event): void {
    event.stopPropagation();

    this.editingModuleId = module.id;

    this.moduleForm.patchValue({
      title: module.title || '',
      description: module.description || '',
      displayOrder: module.displayOrder || 0,
      isPreview: !!(
        module.preview ??
        module.isPreview
      )
    });

    this.showModuleForm = true;
    this.cdr.detectChanges();
  }

  cancelModuleForm(): void {
    this.showModuleForm = false;
    this.editingModuleId = null;
  }

  submitModules(): void {
    if (this.moduleForm.invalid) {
      this.moduleForm.markAllAsTouched();
      return;
    }

    this.moduleSubmitting = true;
    this.error = '';

    const payload = {
      title: this.moduleForm.value.title,
      description:
        this.moduleForm.value.description || '',
      displayOrder:
        Number(this.moduleForm.value.displayOrder) || 0,
      preview: !!this.moduleForm.value.isPreview
    };

    const request = this.editingModuleId
      ? this.coursesService.updateModule(
          this.courseId,
          this.editingModuleId,
          payload
        )
      : this.coursesService.addModule(
          this.courseId,
          payload
        );

    request.subscribe({
      next: () => {
        this.moduleSubmitting = false;
        this.showModuleForm = false;
        this.editingModuleId = null;
        this.loadModules();
      },
      error: err => {
        this.error =
          err?.error?.message ||
          'Failed to save module.';
        this.moduleSubmitting = false;
        this.cdr.detectChanges();
      }
    });
  }

  deleteModule(module: any, event: Event): void {
    event.stopPropagation();

    const confirmed = confirm(
      `Delete module "${module.title}"? This will remove its lessons too.`
    );

    if (!confirmed) {
      return;
    }

    this.coursesService
      .deleteModule(this.courseId, module.id)
      .subscribe({
        next: () => this.loadModules(),
        error: err => {
          this.error =
            err?.error?.message ||
            'Failed to delete module.';
          this.cdr.detectChanges();
        }
      });
  }

  openNewLessonForm(module: any, event: Event): void {
    event.stopPropagation();

    this.editingLessonId = null;
    this.selectedLessonFile = null;
    this.currentLessonFileName = '';
    this.lessonSource = 'UPLOAD';
    this.selectedLibraryItem = null;
    this.librarySearchTerm = '';
    this.librarySelectedType = '';
    this.libraryItems = [];
    this.libraryError = '';

    this.lessonForm.reset({
      title: '',
      description: '',
      type: 'VIDEO',
      durationMinutes: null,
      displayOrder: (module.lessons || []).length,
      isPreview: false,
      isPublished: true,
      downloadable: false,
      streamingUrl: '',
      thumbnailUrl: '',
      contentUrl: '',
      textContent: ''
    });

    this.onTypeChange('VIDEO');
    this.lessonFormModuleId = module.id;

    if (!module.expanded) {
      this.toggleModule(module);
    }
  }

  startEditLesson(
    module: any,
    lesson: any,
    event: Event
  ): void {
    event.stopPropagation();

    const type = this.normaliseLessonType(
      lesson.type
    );

    this.currentLessonFileName =
      lesson.originalFileName || '';
    this.selectedLessonFile = null;
    this.lessonSource = 'UPLOAD';
    this.selectedLibraryItem = null;
    this.libraryItems = [];
    this.libraryError = '';

    this.lessonForm.patchValue({
      title: lesson.title || '',
      description: lesson.description || '',
      type,
      durationMinutes:
        lesson.durationSeconds != null
          ? Math.ceil(
              Number(lesson.durationSeconds) / 60
            )
          : null,
      displayOrder:
        lesson.displayOrder ??
        lesson.order ??
        0,
      isPreview: !!(
        lesson.preview ??
        lesson.isPreview
      ),
      isPublished:
        lesson.published ??
        lesson.isPublished ??
        true,
      downloadable:
        lesson.downloadable === true ||
        lesson.isDownloadable === true,
      streamingUrl: lesson.streamingUrl || '',
      thumbnailUrl: lesson.thumbnailUrl || '',
      contentUrl: lesson.contentUrl || '',
      textContent: lesson.textContent || ''
    });

    this.onTypeChange(type);

    this.editingLessonId = lesson.id;
    this.lessonFormModuleId = module.id;

    if (!module.expanded) {
      module.expanded = true;
    }

    this.cdr.detectChanges();
  }

  cancelLessonForm(): void {
    this.lessonFormModuleId = null;
    this.editingLessonId = null;
    this.selectedLessonFile = null;
    this.currentLessonFileName = '';
    this.lessonSource = 'UPLOAD';
    this.selectedLibraryItem = null;
    this.libraryItems = [];
    this.libraryError = '';
  }

  setLessonSource(source: LessonSource): void {
    if (
      this.editingLessonId &&
      source === 'LIBRARY'
    ) {
      this.error =
        'To keep existing lesson content safe, library selection is available when creating a new lesson. Create a new lesson or edit the current lesson details directly.';
      this.cdr.detectChanges();
      return;
    }

    this.error = '';
    this.lessonSource = source;

    if (source === 'UPLOAD') {
      this.selectedLibraryItem = null;
      this.libraryItems = [];
      this.libraryError = '';

      this.lessonForm.patchValue({
        contentUrl: '',
        streamingUrl: '',
        thumbnailUrl: ''
      });

      this.onTypeChange(
        this.selectedLessonType
      );
    } else {
      this.selectedLessonFile = null;
      this.currentLessonFileName = '';
      this.showFileUpload = false;
      this.showTextContent = false;

      this.lessonForm.patchValue({
        textContent: ''
      });

      this.loadLibraryItems();
    }

    this.cdr.detectChanges();
  }

  loadLibraryItems(): void {
    if (this.lessonSource !== 'LIBRARY') {
      return;
    }

    this.libraryLoading = true;
    this.libraryError = '';

    this.contentLibraryService.getItems({
      q: this.librarySearchTerm,
      type: this.librarySelectedType,
      status: 'ACTIVE',
      page: 0,
      size: 50,
      sortBy: 'createdAt',
      direction: 'DESC'
    }).subscribe({
      next: response => {
        const data = response?.data || response || {};

        this.libraryItems = Array.isArray(data.content)
          ? data.content
          : [];

        this.libraryLoading = false;
        this.cdr.detectChanges();
      },
      error: err => {
        this.libraryItems = [];
        this.libraryLoading = false;
        this.libraryError =
          err?.error?.message ||
          err?.error?.error ||
          'Could not load the Content Library.';
        this.cdr.detectChanges();
      }
    });
  }

  onLibrarySearchChange(): void {
    this.loadLibraryItems();
  }

  onLibraryTypeChange(): void {
    this.loadLibraryItems();
  }

  selectLibraryItem(item: ContentLibraryItem): void {
    const lessonType = this.libraryTypeToLessonType(
      item.type
    );

    if (!lessonType) {
      this.error =
        `${this.libraryTypeLabel(item.type)} items cannot be used as course lessons yet. Choose VIDEO, AUDIO, PDF, or SLIDES content.`;
      this.cdr.detectChanges();
      return;
    }

    if (!item.contentUrl && !item.streamingUrl) {
      this.error =
        'This library item does not have an uploaded file or content URL yet.';
      this.cdr.detectChanges();
      return;
    }

    this.error = '';
    this.selectedLibraryItem = item;
    this.selectedLessonFile = null;
    this.currentLessonFileName =
      item.originalFileName || '';

    this.lessonForm.patchValue({
      title: item.title || '',
      description: item.description || '',
      type: lessonType,
      durationMinutes:
        item.durationSeconds != null &&
        item.durationSeconds > 0
          ? Math.ceil(item.durationSeconds / 60)
          : null,
      streamingUrl: item.streamingUrl || '',
      thumbnailUrl: item.thumbnailUrl || '',
      contentUrl: item.contentUrl || '',
      textContent: ''
    });

    this.showFileUpload = false;
    this.showTextContent = false;
    this.showExternalUrl = false;

    this.cdr.detectChanges();
  }

  clearLibrarySelection(): void {
    this.selectedLibraryItem = null;
    this.currentLessonFileName = '';

    this.lessonForm.patchValue({
      contentUrl: '',
      streamingUrl: '',
      thumbnailUrl: ''
    });

    this.loadLibraryItems();
    this.cdr.detectChanges();
  }

  libraryTypeLabel(
    type: ContentLibraryItemType
  ): string {
    switch (type) {
      case 'VIDEO': return 'Video';
      case 'AUDIO': return 'Audio';
      case 'PDF': return 'PDF';
      case 'SLIDES': return 'Slides';
      case 'DOCUMENT': return 'Document';
      case 'IMAGE': return 'Image';
      case 'LINK': return 'Link';
      default: return type;
    }
  }

  libraryTypeIcon(
    type: ContentLibraryItemType
  ): string {
    switch (type) {
      case 'VIDEO': return '▶';
      case 'AUDIO': return '♪';
      case 'PDF': return '▤';
      case 'SLIDES': return '▣';
      case 'DOCUMENT': return '▤';
      case 'IMAGE': return '▧';
      case 'LINK': return '↗';
      default: return '•';
    }
  }

  onTypeChange(type: string): void {
    const lessonType = this.normaliseLessonType(type);

    this.lessonForm.patchValue(
      { type: lessonType },
      { emitEvent: false }
    );

    this.showTextContent = lessonType === 'TEXT';
    this.showExternalUrl = false;

    this.showFileUpload = this.lessonSource === 'UPLOAD'
      && [
        'VIDEO',
        'AUDIO',
        'PDF',
        'SLIDES'
      ].includes(lessonType);

    if (lessonType === 'TEXT') {
      this.selectedLessonFile = null;
      this.currentLessonFileName = '';

      this.lessonForm.patchValue({
        contentUrl: '',
        streamingUrl: ''
      });
    }

    if (lessonType === 'VIDEO') {
      this.acceptTypes =
        '.mp4,.mov,.webm,.m4v';
    } else if (lessonType === 'AUDIO') {
      this.acceptTypes =
        '.mp3,.wav,.m4a,.aac,.ogg';
    } else if (
      lessonType === 'PDF' ||
      lessonType === 'SLIDES'
    ) {
      this.acceptTypes = '.pdf';
    } else {
      this.acceptTypes = '';
    }
  }

  onLessonFileChange(event: Event): void {
    const input = event.target as HTMLInputElement;

    const file =
      input.files && input.files.length > 0
        ? input.files[0]
        : null;

    this.selectedLessonFile = file;

    if (!file) {
      return;
    }

    const selectedType = this.selectedLessonType;

    if (
      selectedType === 'SLIDES' &&
      /\.(ppt|pptx)$/i.test(file.name)
    ) {
      this.error =
        'PowerPoint files (.ppt, .pptx) cannot be displayed reliably in the learner web and mobile apps. Please export the presentation as a PDF, select SLIDES, and upload the PDF file.';
      this.selectedLessonFile = null;
      input.value = '';
      this.cdr.detectChanges();
      return;
    }

    if (selectedType === 'TEXT') {
      this.error =
        'TEXT lessons cannot contain uploaded files. Choose VIDEO, AUDIO, PDF, or SLIDES instead.';
      this.selectedLessonFile = null;
      input.value = '';
      this.cdr.detectChanges();
      return;
    }

    const detectedType = this.detectLessonTypeFromFile(
      file
    );

    if (!detectedType) {
      this.error =
        'Unsupported file type. Use MP4/MOV/WebM for video, MP3/WAV/M4A for audio, and PDF for documents or slides.';
      this.selectedLessonFile = null;
      input.value = '';
      this.cdr.detectChanges();
      return;
    }

    if (detectedType !== selectedType) {
      this.lessonForm.patchValue({
        type: detectedType
      });

      this.onTypeChange(detectedType);

      this.error =
        `Lesson type was changed to ${detectedType} to match the selected file.`;
    } else {
      this.error = '';
    }

    this.currentLessonFileName = file.name;
    this.cdr.detectChanges();
  }

  submitLesson(): void {
    if (!this.lessonFormModuleId) {
      return;
    }

    if (this.lessonForm.invalid) {
      this.lessonForm.markAllAsTouched();
      return;
    }

    const lessonType = this.selectedLessonType;

    const textContent = String(
      this.lessonForm.value.textContent || ''
    ).trim();

    if (lessonType === 'TEXT' && !textContent) {
      this.error =
        'Enter text content before saving a TEXT lesson.';
      this.cdr.detectChanges();
      return;
    }

    if (
      this.lessonSource === 'LIBRARY' &&
      !this.selectedLibraryItem
    ) {
      this.error =
        'Select a Content Library item before saving this lesson.';
      this.cdr.detectChanges();
      return;
    }

    const streamingUrl = String(
      this.lessonForm.value.streamingUrl || ''
    ).trim();

    const contentUrl = String(
      this.lessonForm.value.contentUrl || ''
    ).trim();

    if (
      lessonType === 'VIDEO' &&
      streamingUrl &&
      !this.isValidHttpUrl(streamingUrl)
    ) {
      this.error =
        'Enter a valid video URL beginning with http:// or https://.';
      this.cdr.detectChanges();
      return;
    }

    const hasVideoUrl =
      lessonType === 'VIDEO' &&
      streamingUrl.length > 0;

    if (
      this.lessonSource === 'UPLOAD' &&
      lessonType !== 'TEXT' &&
      !this.selectedLessonFile &&
      !this.currentLessonFileName &&
      !contentUrl &&
      !hasVideoUrl
    ) {
      this.error =
        `Add a ${lessonType} file or paste a video URL before saving this lesson.`;
      this.cdr.detectChanges();
      return;
    }

    if (
      this.lessonSource === 'LIBRARY' &&
      lessonType !== 'TEXT' &&
      !String(
        this.lessonForm.value.contentUrl || ''
      ).trim() &&
      !String(
        this.lessonForm.value.streamingUrl || ''
      ).trim()
    ) {
      this.error =
        'The selected library item has no usable content URL.';
      this.cdr.detectChanges();
      return;
    }

    const moduleId = this.lessonFormModuleId;

    this.lessonSubmitting = true;
    this.error = '';

    const payload = {
      title: this.lessonForm.value.title,
      description:
        this.lessonForm.value.description || '',
      type: lessonType,
      durationSeconds:
        this.lessonForm.value.durationMinutes != null
          ? Math.max(
              0,
              Math.round(
                Number(
                  this.lessonForm.value.durationMinutes
                ) * 60
              )
            )
          : null,
      displayOrder:
        Number(this.lessonForm.value.displayOrder) || 0,
      preview: !!this.lessonForm.value.isPreview,
      published: !!this.lessonForm.value.isPublished,
      downloadable:
        this.lessonForm.value.downloadable === true,
      streamingUrl: lessonType === 'VIDEO'
        ? String(
            this.lessonForm.value.streamingUrl || ''
          ).trim()
        : '',
      thumbnailUrl: String(
        this.lessonForm.value.thumbnailUrl || ''
      ).trim(),
      contentUrl: lessonType === 'TEXT'
        ? ''
        : String(
            this.lessonForm.value.contentUrl || ''
          ).trim(),
      textContent: lessonType === 'TEXT'
        ? textContent
        : ''
    };

    const request = this.editingLessonId
      ? this.coursesService.updateLesson(
          this.courseId,
          moduleId,
          this.editingLessonId,
          payload
        )
      : this.coursesService.addLesson(
          this.courseId,
          moduleId,
          payload
        );

    request.subscribe({
      next: res => {
        const lessonId = res?.data?.id || res?.id;

        this.lessonSubmitting = false;

        const fileToUpload = this.selectedLessonFile;
        const shouldUploadFile =
          this.lessonSource === 'UPLOAD' &&
          !!fileToUpload;

        this.cancelLessonForm();
        this.reloadLessons(moduleId);

        if (
          lessonId &&
          fileToUpload &&
          shouldUploadFile
        ) {
          this.uploadLessonFile(
            lessonId,
            moduleId,
            fileToUpload
          );
        }
      },
      error: err => {
        this.error =
          err?.error?.message ||
          'Failed to save lesson.';
        this.lessonSubmitting = false;
        this.cdr.detectChanges();
      }
    });
  }

  deleteLesson(
    module: any,
    lesson: any,
    event: Event
  ): void {
    event.stopPropagation();

    const confirmed = confirm(
      `Delete lesson "${lesson.title}"?`
    );

    if (!confirmed) {
      return;
    }

    this.coursesService
      .deleteLesson(
        this.courseId,
        module.id,
        lesson.id
      )
      .subscribe({
        next: () => this.reloadLessons(module.id),
        error: err => {
          this.error =
            err?.error?.message ||
            'Failed to delete lesson.';
          this.cdr.detectChanges();
        }
      });
  }

  private uploadLessonFile(
    lessonId: string,
    moduleId: string,
    file: File
  ): void {
    this.coursesService
      .uploadLessonContent(lessonId, file)
      .subscribe({
        next: () => {
          this.selectedLessonFile = null;
          this.currentLessonFileName = '';
          this.reloadLessons(moduleId);
        },
        error: err => {
          this.error =
            err?.error?.message ||
            'Lesson was saved, but its file upload failed.';
          this.cdr.detectChanges();
        }
      });
  }

  private reloadLessons(moduleId: string): void {
    const module = this.modules.find(
      item => String(item.id) === String(moduleId)
    );

    if (!module) {
      return;
    }

    this.loadLessonsForModule(module);
    module.expanded = true;
  }

  private libraryTypeToLessonType(
    type: ContentLibraryItemType
  ): LessonType | null {
    switch (type) {
      case 'VIDEO': return 'VIDEO';
      case 'AUDIO': return 'AUDIO';
      case 'PDF': return 'PDF';
      case 'SLIDES': return 'SLIDES';
      default: return null;
    }
  }

  private normaliseLessonType(type: any): LessonType {
    const value = String(type || 'VIDEO')
      .trim()
      .toUpperCase();

    if (
      this.lessonTypes.includes(value as LessonType)
    ) {
      return value as LessonType;
    }

    return 'VIDEO';
  }

  private detectLessonTypeFromFile(
    file: File
  ): LessonType | null {
    const name = file.name.toLowerCase();
    const mime = (file.type || '').toLowerCase();

    if (
      mime.startsWith('video/') ||
      /\.(mp4|mov|webm|m4v)$/i.test(name)
    ) {
      return 'VIDEO';
    }

    if (
      mime.startsWith('audio/') ||
      /\.(mp3|wav|m4a|aac|ogg)$/i.test(name)
    ) {
      return 'AUDIO';
    }

    if (
      mime === 'application/pdf' ||
      /\.pdf$/i.test(name)
    ) {
      return 'PDF';
    }

    if (
      mime.includes('presentation') ||
      mime.includes('powerpoint') ||
      /\.(ppt|pptx)$/i.test(name)
    ) {
      return 'SLIDES';
    }

    return null;
  }

  private isValidHttpUrl(value: string): boolean {
    try {
      const url = new URL(value);

      return (
        url.protocol === 'http:' ||
        url.protocol === 'https:'
      );
    } catch {
      return false;
    }
  }

  get mf() {
    return this.moduleForm.controls;
  }

  get lf() {
    return this.lessonForm.controls;
  }
}