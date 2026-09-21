import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { CoursesService } from './courses.service';
import { CompanyUsersService } from '../company-users/company-users.service';
import { CompaniesService } from '../services/companies.service';
import { AuthService } from '../../../core/auth.service';
import { resolveMediaUrl } from '../../../core/media-url.util';


@Component({
  selector: 'app-course-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, FormsModule, RouterModule],
  templateUrl: './course-form.html',
  styleUrls: ['./course-form.scss']
})
export class CourseForm implements OnInit {
  form: FormGroup;


  loading = false;
  submitting = false;
  error = '';


  isEdit = false;
  courseId: string | null = null;


  categories: { id: string; name: string }[] = [];
  instructors: { id: string; name: string }[] = [];
  companies: { id: string; name: string }[] = [];
  thumbnailUrl: string | null = null;
  thumbnailUploading = false;

  // Holds the file the user picked before the course exists yet (create
  // mode). It gets uploaded automatically right after the course is saved
  // and a real courseId becomes available.
  pendingThumbnailFile: File | null = null;
  pendingThumbnailPreview: string | null = null;


  get isSuperAdmin(): boolean {
    return (this.authService.getCurrentUser()?.email || '').toLowerCase() === 'admin@blute.co.in';
  }


  onThumbnailSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;


    if (this.courseId) {
      // Edit mode - course already exists, upload immediately as before.
      this.uploadThumbnail(file);
    } else {
      // Create mode - course doesn't exist yet. Stash the file and show a
      // local preview; it gets uploaded right after the course is created.
      this.pendingThumbnailFile = file;
      const reader = new FileReader();
      reader.onload = () => {
        this.pendingThumbnailPreview = reader.result as string;
        this.cdr.detectChanges();
      };
      reader.readAsDataURL(file);
    }
  }


  uploadThumbnail(file: File): void {
    if (!this.courseId) return;


    this.thumbnailUploading = true;
    this.coursesService.uploadThumbnail(this.courseId, file).subscribe({
      next: (res) => {
        this.thumbnailUrl = resolveMediaUrl(res?.data || res);
        this.thumbnailUploading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.error = err?.error?.message || 'Failed to upload thumbnail.';
        this.thumbnailUploading = false;
        this.cdr.detectChanges();
      }
    });
  }


  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private coursesService: CoursesService,
    private companyUsersService: CompanyUsersService,
    private companiesService: CompaniesService,
    private authService: AuthService,
    private cdr: ChangeDetectorRef
  ) {
    this.form = this.fb.group({
      title: ['', [Validators.required, Validators.minLength(3)]],
      description: [''],
      shortDescription: [''],
      categoryId: ['', Validators.required],
      instructorId: [''],
      companyId: [''],
      level: ['BEGINNER', Validators.required],
      status: ['DRAFT', Validators.required],
      isPaid: [false],
      featured: [false],
      price: [0],
      language: ['English'],
      durationMinutes: [null],
      tags: [''],
      prerequisites: [''],
      learningOutcomes: ['']
    });
  }


  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('id');
    this.isEdit = !!this.courseId;
    this.loadCategories();
    this.loadInstructors();
    if (this.isSuperAdmin) {
      this.companiesService.getCompanies().subscribe({
        next: (companies) => {
          this.companies = (companies || []).map((c: any) => ({ id: c.id, name: c.name }));
          this.cdr.detectChanges();
        }
      });
    }


    if (this.isEdit && this.courseId) {
      this.loadCourse(this.courseId);
    }
  }


  loadCategories(): void {
    this.coursesService.getCategories().subscribe({
      next: (res) => {
        this.categories = res?.data || res || [];
        this.cdr.detectChanges();
      },
      error: () => {
        this.categories = [];
        this.cdr.detectChanges();
      }
    });
  }


  loadInstructors(): void {
    this.companyUsersService.getUsers().subscribe({
      next: (users) => {
        // Only company users with the "Tutor" role can be assigned as a
        // course instructor - learners and company admins are deliberately
        // excluded from this list.
        this.instructors = (users || [])
          .filter(u => (u.role || '').toUpperCase() === 'TUTOR')
          .map(u => ({ id: u.userId, name: u.name }));
        this.cdr.detectChanges();
      },
      error: () => {
        this.instructors = [];
      }
    });
  }


  loadCourse(id: string): void {
    this.loading = true;
    this.error = '';


    this.coursesService.getCourseById(id).subscribe({
      next: (res) => {
        const c = res?.data || res;
        this.thumbnailUrl = resolveMediaUrl(c?.thumbnailUrl);
        this.form.patchValue({
          title: c?.title || '',
          description: c?.description || '',
          shortDescription: c?.shortDescription || '',
          categoryId: c?.categoryId || '',
          instructorId: c?.instructorId || '',
          companyId: c?.companyId || '',
          level: c?.level || 'BEGINNER',
          status: c?.status || 'DRAFT',
          // NOTE: the backend serializes this boolean field as "paid", not
          // "isPaid" (a Lombok/Jackson quirk on boolean fields prefixed
          // with "is"). Reading the wrong key here silently produced
          // "false" for every course, making the Paid toggle look broken.
          isPaid: c?.paid || false,
          featured: c?.featured || false,
          price: c?.price || 0,
          language: c?.language || 'English',
          durationMinutes: c?.durationMinutes || null,
          tags: Array.isArray(c?.tags) ? c.tags.join(', ') : '',
          prerequisites: Array.isArray(c?.prerequisites) ? c.prerequisites.join(', ') : '',
          learningOutcomes: Array.isArray(c?.learningOutcomes) ? c.learningOutcomes.join(', ') : ''
        });
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.error = err?.error?.message || 'Failed to load course details.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }


  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.submitting = true;
    this.error = '';


    const payload = {
      title: this.form.value.title,
      description: this.form.value.description,
      shortDescription: this.form.value.shortDescription,
      categoryId: this.form.value.categoryId,
      instructorId: this.form.value.instructorId || null,
      companyId: this.form.value.companyId || null,
      level: this.form.value.level,
      status: this.form.value.status,
      // See the loadCourse() note above - backend expects "paid", not "isPaid".
      paid: this.form.value.isPaid,
      featured: this.form.value.featured,
      price: this.form.value.price,
      language: this.form.value.language,
      durationMinutes: this.form.value.durationMinutes,
      tags: this.parseCsv(this.form.value.tags),
      prerequisites: this.parseCsv(this.form.value.prerequisites),
      learningOutcomes: this.parseCsv(this.form.value.learningOutcomes)
    };


    const request = this.isEdit && this.courseId
      ? this.coursesService.updateCourse(this.courseId, payload)
      : this.coursesService.createCourse(payload);


    request.subscribe({
      next: (res) => {
        const savedCourseId = res?.data?.id || res?.id || this.courseId;
        this.submitting = false;


        const isBrandNewCourse = !!savedCourseId && !this.courseId;


        if (isBrandNewCourse && this.pendingThumbnailFile && savedCourseId) {
          // A thumbnail was picked during create - upload it now that the
          // course finally has a real ID, then move on to content.
          this.coursesService.uploadThumbnail(savedCourseId, this.pendingThumbnailFile).subscribe({
            next: () => {
              this.router.navigate(['/admin/courses', savedCourseId, 'content']);
            },
            error: () => {
              // Course itself saved fine - don't block navigation just
              // because the thumbnail upload failed. The user can add it
              // later from the edit screen.
              this.router.navigate(['/admin/courses', savedCourseId, 'content']);
            }
          });
          return;
        }


        this.cdr.detectChanges();


        if (isBrandNewCourse) {
          // Brand new course - the natural next step is building out its
          // content, not sitting on this metadata form.
          this.router.navigate(['/admin/courses', savedCourseId, 'content']);
        } else {
          this.router.navigate(['/admin/courses']);
        }
      },
      error: (err) => {
        this.error = err?.error?.message || 'Failed to save course.';
        this.submitting = false;
        this.cdr.detectChanges();
      }
    });
  }


  private parseCsv(value: any): string[] {
    if (!value || typeof value !== 'string') return [];
    return value.split(',').map((v: string) => v.trim()).filter(Boolean);
  }


  get f() {
    return this.form.controls;
  }
}
