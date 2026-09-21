import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs';

import {
  ContentLibraryItem,
  ContentLibraryItemType,
  ContentLibraryPayload,
  ContentLibraryService,
  ContentLibraryStatus
} from './content-library.service';

type ContentTypeOption = {
  value: ContentLibraryItemType;
  label: string;
};

@Component({
  selector: 'app-content-library',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule
  ],
  templateUrl: './content-library.html',
  styleUrl: './content-library.scss'
})
export class ContentLibrary implements OnInit {
  private service = inject(ContentLibraryService);
  private cd = inject(ChangeDetectorRef);

  readonly contentTypes: ContentTypeOption[] = [
    { value: 'VIDEO', label: 'Video' },
    { value: 'AUDIO', label: 'Audio' },
    { value: 'PDF', label: 'PDF' },
    { value: 'SLIDES', label: 'Slides' },
    { value: 'DOCUMENT', label: 'Document' },
    { value: 'IMAGE', label: 'Image' },
    { value: 'LINK', label: 'Link' }
  ];

  items: ContentLibraryItem[] = [];
  readonly Math = Math;

  loading = true;
  saving = false;
  uploading = false;
  error = '';
  formError = '';

  searchTerm = '';
  selectedType: ContentLibraryItemType | '' = '';
  selectedStatus: ContentLibraryStatus | '' = 'ACTIVE';

  page = 0;
  pageSize = 12;
  totalElements = 0;
  totalPages = 0;

  showForm = false;
  editingItem: ContentLibraryItem | null = null;
  selectedFile: File | null = null;
  selectedFileName = '';

  form = this.emptyForm();

  ngOnInit(): void {
    this.loadItems();
  }

  loadItems(resetPage = false): void {
    if (resetPage) {
      this.page = 0;
    }

    this.loading = true;
    this.error = '';

    this.service
      .getItems({
        q: this.searchTerm,
        type: this.selectedType,
        status: this.selectedStatus,
        page: this.page,
        size: this.pageSize,
        sortBy: 'createdAt',
        direction: 'DESC'
      })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          const data = response?.data || response || {};

          this.items = Array.isArray(data.content)
            ? data.content
            : [];

          this.totalElements = Number(
            data.totalElements ?? this.items.length
          );

          this.totalPages = Number(
            data.totalPages ??
            (this.totalElements > 0 ? 1 : 0)
          );

          this.page = Number(data.number ?? this.page);

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.items = [];
          this.totalElements = 0;
          this.totalPages = 0;

          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load the content library.';

          this.cd.detectChanges();
        }
      });
  }

  onSearchChange(): void {
    this.loadItems(true);
  }

  onFilterChange(): void {
    this.loadItems(true);
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.selectedType = '';
    this.selectedStatus = 'ACTIVE';
    this.loadItems(true);
  }

  previousPage(): void {
    if (this.page <= 0 || this.loading) {
      return;
    }

    this.page -= 1;
    this.loadItems();
  }

  nextPage(): void {
    if (
      this.loading ||
      this.totalPages === 0 ||
      this.page >= this.totalPages - 1
    ) {
      return;
    }

    this.page += 1;
    this.loadItems();
  }

  openCreateForm(): void {
    this.showForm = true;
    this.editingItem = null;
    this.selectedFile = null;
    this.selectedFileName = '';
    this.formError = '';
    this.form = this.emptyForm();
    this.cd.detectChanges();
  }

  openEditForm(item: ContentLibraryItem): void {
    this.showForm = true;
    this.editingItem = item;
    this.selectedFile = null;
    this.selectedFileName = '';
    this.formError = '';

    this.form = {
        title: item.title || '',
        description: item.description || '',
        type: item.type,
        contentUrl: item.contentUrl || '',
        streamingUrl: item.streamingUrl || '',
        thumbnailUrl: item.thumbnailUrl || '',
        tags: item.tags || '',
        durationSeconds:
            item.durationSeconds !== null &&
            item.durationSeconds !== undefined
            ? String(item.durationSeconds)
            : '',
        fileSizeBytes:
            item.fileSizeBytes !== null &&
            item.fileSizeBytes !== undefined
            ? item.fileSizeBytes
            : null,
        originalFileName:
            item.originalFileName || '',
        status: item.status || 'ACTIVE'
    };

    this.cd.detectChanges();
  }

  closeForm(force = false): void {
  if (!force && (this.saving || this.uploading)) {
    return;
  }

  this.showForm = false;
  this.editingItem = null;
  this.selectedFile = null;
  this.selectedFileName = '';
  this.formError = '';
  this.form = this.emptyForm();

  this.cd.detectChanges();
}
onFileSelected(event: Event): void {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0] || null;

  this.selectedFile = file;
  this.selectedFileName = file?.name || '';

  if (file) {
    this.form.originalFileName = file.name;
    this.form.fileSizeBytes = file.size;
  } else {
    this.form.originalFileName = '';
    this.form.fileSizeBytes = null;
  }

  this.formError = '';
  this.cd.detectChanges();
}
    saveItem(): void {
  this.formError = '';

  const title = this.form.title.trim();

  if (!title) {
    this.formError = 'Please enter a title.';
    return;
  }

  const hasFile =
    this.selectedFile !== null &&
    this.selectedFile !== undefined;

  const hasContentUrl =
    this.form.contentUrl.trim().length > 0;

  const hasStreamingUrl =
    this.form.streamingUrl.trim().length > 0;

  if (
    !this.editingItem &&
    !hasFile &&
    !hasContentUrl &&
    !hasStreamingUrl
  ) {
    this.formError =
      'Choose a file or provide a content/streaming URL.';
    return;
  }

  if (
    this.form.type === 'LINK' &&
    !hasContentUrl
  ) {
    this.formError =
      'A content URL is required for link items.';
    return;
  }

  this.saving = true;
  this.formError = '';
  this.cd.detectChanges();

  const payload = this.buildPayload();

  const request = this.editingItem
    ? this.service.updateItem(
        this.editingItem.id,
        payload
      )
    : this.service.createItem(payload);

  request.subscribe({
    next: (response: any) => {
      const savedItem = (
        response?.data || response
      ) as ContentLibraryItem;

      this.saving = false;

      if (hasFile && savedItem?.id) {
        this.uploadSelectedFile(savedItem.id);
        return;
      }

      this.closeForm(true);
      this.loadItems(true);
      this.cd.detectChanges();
    },
    error: (err: any) => {
      this.saving = false;

      this.formError =
        err?.error?.message ||
        err?.error?.error ||
        'Could not save this content item.';

      this.cd.detectChanges();
    }
  });
}

  archiveItem(item: ContentLibraryItem): void {
    const accepted = window.confirm(
      `Archive "${item.title}"? It will be hidden from the active library but can be restored later.`
    );

    if (!accepted) {
      return;
    }

    this.service.archiveItem(item.id).subscribe({
      next: () => this.loadItems(),
      error: (err: any) => {
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Could not archive this item.';

        this.cd.detectChanges();
      }
    });
  }

  restoreItem(item: ContentLibraryItem): void {
    this.service.restoreItem(item.id).subscribe({
      next: () => this.loadItems(),
      error: (err: any) => {
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Could not restore this item.';

        this.cd.detectChanges();
      }
    });
  }

  deleteItem(item: ContentLibraryItem): void {
    const accepted = window.confirm(
      `Delete "${item.title}" permanently? This cannot be undone.`
    );

    if (!accepted) {
      return;
    }

    this.service.deleteItem(item.id).subscribe({
      next: () => {
        if (
          this.items.length === 1 &&
          this.page > 0
        ) {
          this.page -= 1;
        }

        this.loadItems();
      },
      error: (err: any) => {
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Could not delete this item.';

        this.cd.detectChanges();
      }
    });
  }

  typeLabel(type: ContentLibraryItemType): string {
    return (
      this.contentTypes.find(
        item => item.value === type
      )?.label || type
    );
  }

  typeIcon(type: ContentLibraryItemType): string {
  switch (type) {
    case 'VIDEO':
      return '▶';

    case 'AUDIO':
      return '♪';

    case 'PDF':
      return '▤';

    case 'SLIDES':
      return '▣';

    case 'DOCUMENT':
      return '▤';

    case 'IMAGE':
      return '▧';

    case 'LINK':
      return '↗';

    default:
      return '•';
  }
}

  formatBytes(bytes: number | null): string {
    if (!bytes || bytes <= 0) {
      return '—';
    }

    const units = ['B', 'KB', 'MB', 'GB'];
    const exponent = Math.min(
      Math.floor(Math.log(bytes) / Math.log(1024)),
      units.length - 1
    );

    const value = bytes / Math.pow(1024, exponent);

    return `${value.toFixed(
      exponent === 0 ? 0 : 1
    )} ${units[exponent]}`;
  }

  formatDuration(seconds: number | null): string {
    if (!seconds || seconds <= 0) {
      return '';
    }

    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;

    if (minutes === 0) {
      return `${remainingSeconds}s`;
    }

    if (remainingSeconds === 0) {
      return `${minutes} min`;
    }

    return `${minutes}m ${remainingSeconds}s`;
  }

  trackById(
    _: number,
    item: ContentLibraryItem
  ): string {
    return item.id;
  }

  private uploadSelectedFile(itemId: string): void {
  if (!this.selectedFile) {
    this.closeForm(true);
    this.loadItems(true);
    this.cd.detectChanges();
    return;
  }

  const fileToUpload = this.selectedFile;

  this.uploading = true;
  this.formError = '';
  this.cd.detectChanges();

  this.service
    .uploadFile(itemId, fileToUpload)
    .pipe(
      finalize(() => {
        this.uploading = false;
        this.cd.detectChanges();
      })
    )
    .subscribe({
      next: () => {
        this.closeForm(true);
        this.loadItems(true);
        this.cd.detectChanges();
      },
      error: (err: any) => {
        this.formError =
          err?.error?.message ||
          err?.error?.error ||
          'The content item was saved, but the file upload failed. You can edit the item and upload the file again.';

        this.editingItem = {
          id: itemId
        } as ContentLibraryItem;

        this.cd.detectChanges();
      }
    });
}

  private buildPayload(): ContentLibraryPayload {
    const contentUrl = this.form.contentUrl.trim();
    const streamingUrl = this.form.streamingUrl.trim();
    const thumbnailUrl = this.form.thumbnailUrl.trim();
    const description = this.form.description.trim();
    const tags = this.form.tags.trim();

    return {
      title: this.form.title.trim(),
      description: description || null,
      type: this.form.type,
      contentUrl: contentUrl || null,
      streamingUrl: streamingUrl || null,
      thumbnailUrl: thumbnailUrl || null,
      tags: tags || null,
      durationSeconds: this.toNullableNumber(
        this.form.durationSeconds
      ),
      fileSizeBytes: this.form.fileSizeBytes,
      originalFileName:
        this.form.originalFileName || null,
      status: this.editingItem
        ? this.form.status
        : undefined,
      companyId: null
    };
  }

  private toNullableNumber(
    value: string
  ): number | null {
    const parsed = Number(value);

    if (!value || !Number.isFinite(parsed) || parsed < 0) {
      return null;
    }

    return Math.floor(parsed);
  }

  private emptyForm(): {
    title: string;
    description: string;
    type: ContentLibraryItemType;
    contentUrl: string;
    streamingUrl: string;
    thumbnailUrl: string;
    tags: string;
    durationSeconds: string;
    fileSizeBytes: number | null;
    originalFileName: string;
    status: ContentLibraryStatus;
  } {
    return {
      title: '',
      description: '',
      type: 'VIDEO',
      contentUrl: '',
      streamingUrl: '',
      thumbnailUrl: '',
      tags: '',
      durationSeconds: '',
      fileSizeBytes: null,
      originalFileName: '',
      status: 'ACTIVE'
    };
  }
}