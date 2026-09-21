import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { forkJoin } from 'rxjs';

import {
  Batch,
  BatchDeliveryMode,
  BatchMember,
  BatchRequest,
  BatchStatus,
  CourseEnrollment,
  BatchesService
} from './batches.service';

type CourseOption = {
  id: string;
  title: string;
  companyId?: string | null;
  companyName?: string | null;
  status?: string | null;
};

type EligibleBatchLearner = {
  learnerId: string;
  learnerName: string;
  learnerEmail: string;
  progressPercent: number;
};

@Component({
  selector: 'app-batches',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ],
  templateUrl: './batches.html',
  styleUrl: './batches.scss'
})
export class Batches implements OnInit {
  batches: Batch[] = [];
  courses: CourseOption[] = [];
  members: BatchMember[] = [];
  enrolledCourseLearners: EligibleBatchLearner[] = [];

  selectedBatch: Batch | null = null;

  loading = true;
  saving = false;
  loadingMembers = false;
  loadingEligibleLearners = false;
  addingMember = false;

  error = '';
  memberError = '';

  showCreateForm = false;
  showEditForm = false;

  newMemberId = '';

  form: BatchRequest = this.emptyForm();

  readonly batchStatuses: BatchStatus[] = [
    'DRAFT',
    'SCHEDULED',
    'ACTIVE',
    'COMPLETED',
    'ARCHIVED'
  ];

  readonly deliveryModes: BatchDeliveryMode[] = [
    'SELF_PACED',
    'LIVE_ONLINE',
    'BLENDED'
  ];

  constructor(
    private batchesService: BatchesService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadInitialData();
  }

  loadInitialData(): void {
    this.loading = true;
    this.error = '';

    forkJoin({
      batchesResponse: this.batchesService.getBatches(),
      coursesResponse: this.batchesService.getCourses()
    }).subscribe({
      next: ({
        batchesResponse,
        coursesResponse
      }) => {
        this.batches = this.extractArray(batchesResponse)
          .map((batch: any) => this.mapBatch(batch))
          .sort((left, right) => {
            return this.toDate(right.createdAt) -
              this.toDate(left.createdAt);
          });

        this.courses = this.extractCourses(coursesResponse);

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to load batches', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to load batches. Please try again.';

        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  openCreateForm(): void {
    this.form = this.emptyForm();
    this.showCreateForm = true;
    this.showEditForm = false;
    this.selectedBatch = null;
    this.members = [];
    this.enrolledCourseLearners = [];
    this.memberError = '';
    this.error = '';
  }

  cancelCreateForm(): void {
    this.showCreateForm = false;
    this.form = this.emptyForm();
    this.error = '';
  }

  createBatch(): void {
    if (this.saving) {
      return;
    }

    const validationError = this.validateForm();

    if (validationError) {
      this.error = validationError;
      return;
    }

    this.saving = true;
    this.error = '';

    this.batchesService.createBatch(
      this.normalizedForm()
    ).subscribe({
      next: response => {
        const batch = this.mapBatch(response?.data ?? response);

        this.batches = [
          batch,
          ...this.batches.filter(item => item.id !== batch.id)
        ];

        this.showCreateForm = false;
        this.form = this.emptyForm();
        this.saving = false;

        this.selectBatch(batch);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to create batch', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to create the batch.';

        this.saving = false;
        this.cdr.detectChanges();
      }
    });
  }

  selectBatch(batch: Batch): void {
    this.selectedBatch = batch;
    this.showCreateForm = false;
    this.showEditForm = false;
    this.members = [];
    this.enrolledCourseLearners = [];
    this.newMemberId = '';
    this.memberError = '';
    this.error = '';

    this.loadBatchData(batch);
  }

  closeSelectedBatch(): void {
    this.selectedBatch = null;
    this.members = [];
    this.enrolledCourseLearners = [];
    this.memberError = '';
    this.newMemberId = '';
    this.showEditForm = false;
    this.form = this.emptyForm();
  }

  openEditForm(): void {
    if (!this.selectedBatch || this.saving) {
      return;
    }

    const batch = this.selectedBatch;

    this.form = {
      name: batch.name || '',
      code: batch.code || '',
      description: batch.description || '',
      courseId: batch.courseId || '',
      companyId: batch.companyId || null,
      instructorId: batch.instructorId || null,
      deliveryMode: batch.deliveryMode || 'SELF_PACED',
      status: batch.status || 'DRAFT',
      startDate: this.toInputDate(batch.startDate),
      endDate: this.toInputDate(batch.endDate),
      maxLearners: Number(batch.maxLearners) || 100
    };

    this.error = '';
    this.showEditForm = true;
  }

  cancelEditForm(): void {
    this.showEditForm = false;
    this.form = this.emptyForm();
    this.error = '';
  }

  updateBatch(): void {
    if (!this.selectedBatch || this.saving) {
      return;
    }

    const validationError = this.validateForm();

    if (validationError) {
      this.error = validationError;
      return;
    }

    this.saving = true;
    this.error = '';

    this.batchesService.updateBatch(
      this.selectedBatch.id,
      this.normalizedForm()
    ).subscribe({
      next: response => {
        const updated = this.mapBatch(response?.data ?? response);

        this.replaceBatch(updated);
        this.selectedBatch = updated;
        this.showEditForm = false;
        this.form = this.emptyForm();
        this.saving = false;

        this.loadBatchData(updated);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to update batch', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to update the batch.';

        this.saving = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadBatchData(batch: Batch): void {
    this.loadBatchMembers(batch.id);
    this.loadEligibleCourseLearners(batch.courseId);
  }

  loadBatchMembers(batchId: string): void {
    this.loadingMembers = true;
    this.memberError = '';

    this.batchesService.getBatchMembers(batchId).subscribe({
      next: response => {
        this.members = this.extractArray(response)
          .map((member: any) => this.mapMember(member))
          .sort((left, right) =>
            left.learnerName.localeCompare(right.learnerName)
          );

        this.loadingMembers = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to load batch members', err);

        this.memberError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to load batch members.';

        this.members = [];
        this.loadingMembers = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadEligibleCourseLearners(courseId: string): void {
    if (!courseId) {
      this.enrolledCourseLearners = [];
      this.loadingEligibleLearners = false;
      return;
    }

    this.loadingEligibleLearners = true;

    this.batchesService.getCourseEnrollments(courseId).subscribe({
      next: response => {
        const enrollments = this.extractArray(response)
          .map((item: any) => this.mapCourseEnrollment(item));

        this.enrolledCourseLearners = enrollments
          .filter(enrollment =>
            String(enrollment.status || '').toUpperCase() === 'ACTIVE'
          )
          .map((enrollment): EligibleBatchLearner => ({
            learnerId: enrollment.learnerId,
            learnerName: enrollment.learnerName,
            learnerEmail: enrollment.learnerEmail,
            progressPercent: enrollment.progressPercent
          }))
          .sort((left, right) =>
            left.learnerName.localeCompare(right.learnerName)
          );

        this.loadingEligibleLearners = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to load course enrollments', err);

        this.enrolledCourseLearners = [];
        this.loadingEligibleLearners = false;

        this.memberError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to load learners enrolled in this course.';

        this.cdr.detectChanges();
      }
    });
  }

  addLearnerToBatch(): void {
    if (
      !this.selectedBatch ||
      !this.newMemberId ||
      this.addingMember
    ) {
      return;
    }

    const learner = this.availableLearners.find(
      item => item.learnerId === this.newMemberId
    );

    if (!learner?.learnerId) {
      this.memberError =
        'Select a learner who is enrolled in this course.';
      return;
    }

    this.addingMember = true;
    this.memberError = '';

    this.batchesService.addMember(
      this.selectedBatch.id,
      learner.learnerId
    ).subscribe({
      next: response => {
        const member = this.mapMember(response?.data ?? response);

        this.members = [
          ...this.members.filter(
            item => item.learnerId !== member.learnerId
          ),
          member
        ].sort((left, right) =>
          left.learnerName.localeCompare(right.learnerName)
        );

        this.newMemberId = '';
        this.addingMember = false;

        this.refreshBatch(this.selectedBatch!.id);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to add learner to batch', err);

        this.memberError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to add this learner to the batch.';

        this.addingMember = false;
        this.cdr.detectChanges();
      }
    });
  }

  removeLearnerFromBatch(member: BatchMember): void {
    if (!this.selectedBatch) {
      return;
    }

    const confirmed = confirm(
      `Remove "${member.learnerName}" from "${this.selectedBatch.name}"?`
    );

    if (!confirmed) {
      return;
    }

    this.memberError = '';

    this.batchesService.removeMember(
      this.selectedBatch.id,
      member.learnerId
    ).subscribe({
      next: () => {
        this.members = this.members.filter(
          item => item.learnerId !== member.learnerId
        );

        this.refreshBatch(this.selectedBatch!.id);
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to remove learner from batch', err);

        this.memberError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to remove this learner from the batch.';

        this.cdr.detectChanges();
      }
    });
  }

  archiveSelectedBatch(): void {
    if (!this.selectedBatch) {
      return;
    }

    if (this.selectedBatch.status === 'ARCHIVED') {
      return;
    }

    const confirmed = confirm(
      `Archive "${this.selectedBatch.name}"? You will not be able to add new learners afterward.`
    );

    if (!confirmed) {
      return;
    }

    this.error = '';

    this.batchesService.archiveBatch(
      this.selectedBatch.id
    ).subscribe({
      next: response => {
        const updated = this.mapBatch(response?.data ?? response);

        this.replaceBatch(updated);
        this.selectedBatch = updated;
        this.showEditForm = false;

        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to archive batch', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to archive this batch.';

        this.cdr.detectChanges();
      }
    });
  }

  get availableLearners(): EligibleBatchLearner[] {
    if (!this.selectedBatch) {
      return [];
    }

    const existingUserIds = new Set(
      this.members.map(member => member.learnerId)
    );

    return this.enrolledCourseLearners.filter(
      learner =>
        Boolean(learner.learnerId) &&
        !existingUserIds.has(learner.learnerId)
    );
  }

  get canChangeSelectedBatchCourse(): boolean {
    return !this.selectedBatch || this.members.length === 0;
  }

  get activeBatchCount(): number {
    return this.batches.filter(
      batch =>
        batch.status === 'ACTIVE' ||
        batch.status === 'SCHEDULED'
    ).length;
  }

  get archivedBatchCount(): number {
    return this.batches.filter(
      batch => batch.status === 'ARCHIVED'
    ).length;
  }

  get totalBatchMembers(): number {
    return this.batches.reduce(
      (total, batch) => total + batch.learnerCount,
      0
    );
  }

  statusLabel(status: BatchStatus): string {
    return String(status || '')
      .toLowerCase()
      .split('_')
      .map(
        part => part.charAt(0).toUpperCase() + part.slice(1)
      )
      .join(' ');
  }

  deliveryModeLabel(mode: BatchDeliveryMode): string {
    switch (mode) {
      case 'LIVE_ONLINE':
        return 'Live online';
      case 'BLENDED':
        return 'Blended';
      case 'SELF_PACED':
      default:
        return 'Self-paced';
    }
  }

  statusClass(status: BatchStatus): string {
    switch (status) {
      case 'ACTIVE':
        return 'status-active';
      case 'SCHEDULED':
        return 'status-scheduled';
      case 'COMPLETED':
        return 'status-completed';
      case 'ARCHIVED':
        return 'status-archived';
      case 'DRAFT':
      default:
        return 'status-draft';
    }
  }

  progressClass(index: number): string {
    const styles = [
      'progress-blue',
      'progress-green',
      'progress-orange',
      'progress-purple'
    ];

    return styles[index % styles.length];
  }

  formatDate(value?: string | null): string {
    if (!value) {
      return 'Not set';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return value;
    }

    return date.toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  }

  trackByBatchId(_: number, batch: Batch): string {
    return batch.id;
  }

  trackByMemberId(_: number, member: BatchMember): string {
    return member.membershipId;
  }

  private refreshBatch(batchId: string): void {
    this.batchesService.getBatch(batchId).subscribe({
      next: response => {
        const updated = this.mapBatch(response?.data ?? response);

        this.replaceBatch(updated);

        if (this.selectedBatch?.id === updated.id) {
          this.selectedBatch = updated;
        }

        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to refresh batch details', err);
      }
    });
  }

  private replaceBatch(updated: Batch): void {
    this.batches = this.batches.map(batch =>
      batch.id === updated.id ? updated : batch
    );
  }

  private validateForm(): string {
    if (!this.form.name.trim()) {
      return 'Enter a batch name.';
    }

    if (!this.form.code.trim()) {
      return 'Enter a batch code.';
    }

    if (!this.form.courseId) {
      return 'Select a course for this batch.';
    }

    if (this.form.maxLearners < 1) {
      return 'Maximum learners must be at least 1.';
    }

    if (
      this.form.startDate &&
      this.form.endDate &&
      this.form.endDate < this.form.startDate
    ) {
      return 'The end date cannot be before the start date.';
    }

    return '';
  }

  private normalizedForm(): BatchRequest {
    return {
      name: this.form.name.trim(),
      code: this.form.code.trim().toUpperCase(),
      description: this.form.description?.trim() || null,
      courseId: this.form.courseId,
      companyId: this.form.companyId || null,
      instructorId: this.form.instructorId || null,
      deliveryMode: this.form.deliveryMode,
      status: this.form.status,
      startDate: this.form.startDate || null,
      endDate: this.form.endDate || null,
      maxLearners: Number(this.form.maxLearners) || 1
    };
  }

  private emptyForm(): BatchRequest {
    return {
      name: '',
      code: '',
      description: '',
      courseId: '',
      companyId: null,
      instructorId: null,
      deliveryMode: 'SELF_PACED',
      status: 'DRAFT',
      startDate: null,
      endDate: null,
      maxLearners: 100
    };
  }

  private extractCourses(response: any): CourseOption[] {
    const rawCourses = this.extractArray(response);

    return rawCourses
      .map((course: any) => ({
        id: String(course?.id || ''),
        title: String(course?.title || 'Untitled course'),
        companyId: course?.companyId ?? null,
        companyName: course?.companyName ?? null,
        status: course?.status ?? null
      }))
      .filter(course => Boolean(course.id));
  }

  private extractArray(response: any): any[] {
    if (Array.isArray(response?.data?.content)) {
      return response.data.content;
    }

    if (Array.isArray(response?.content)) {
      return response.content;
    }

    if (Array.isArray(response?.data)) {
      return response.data;
    }

    if (Array.isArray(response)) {
      return response;
    }

    return [];
  }

  private mapBatch(batch: any): Batch {
    return {
      id: String(batch?.id || ''),
      name: String(batch?.name || 'Untitled batch'),
      code: String(batch?.code || ''),
      description: batch?.description ?? null,
      courseId: String(batch?.courseId || ''),
      courseTitle: String(batch?.courseTitle || 'Course'),
      companyId: batch?.companyId ?? null,
      companyName: batch?.companyName ?? null,
      instructorId: batch?.instructorId ?? null,
      instructorName: batch?.instructorName ?? null,
      deliveryMode: String(
        batch?.deliveryMode || 'SELF_PACED'
      ).toUpperCase() as BatchDeliveryMode,
      status: String(
        batch?.status || 'DRAFT'
      ).toUpperCase() as BatchStatus,
      startDate: batch?.startDate ?? null,
      endDate: batch?.endDate ?? null,
      maxLearners: Number(batch?.maxLearners ?? 100),
      learnerCount: Number(batch?.learnerCount ?? 0),
      averageProgressPercent: Number(
        batch?.averageProgressPercent ?? 0
      ),
      completedLearnerCount: Number(
        batch?.completedLearnerCount ?? 0
      ),
      createdAt: batch?.createdAt ?? null,
      updatedAt: batch?.updatedAt ?? null
    };
  }

  private mapMember(member: any): BatchMember {
    return {
      membershipId: String(member?.membershipId || ''),
      learnerId: String(member?.learnerId || ''),
      learnerName: String(member?.learnerName || 'Learner'),
      learnerEmail: String(member?.learnerEmail || ''),
      companyName: member?.companyName ?? null,
      status: String(
        member?.status || 'ACTIVE'
      ).toUpperCase() as any,
      courseProgressPercent: Number(
        member?.courseProgressPercent ?? 0
      ),
      joinedAt: member?.joinedAt ?? null,
      completedAt: member?.completedAt ?? null
    };
  }

  private mapCourseEnrollment(
    enrollment: any
  ): CourseEnrollment {
    return {
      enrollmentId: String(enrollment?.enrollmentId || ''),
      learnerId: String(enrollment?.learnerId || ''),
      learnerName: String(enrollment?.learnerName || 'Learner'),
      learnerEmail: String(enrollment?.learnerEmail || ''),
      courseId: String(enrollment?.courseId || ''),
      courseTitle: String(enrollment?.courseTitle || ''),
      status: String(enrollment?.status || 'ACTIVE'),
      progressPercent: Number(
        enrollment?.progressPercent ?? 0
      ),
      enrolledAt: enrollment?.enrolledAt ?? null,
      completedAt: enrollment?.completedAt ?? null
    };
  }

  private toInputDate(value?: string | null): string | null {
    if (!value) {
      return null;
    }

    return String(value).slice(0, 10);
  }

  private toDate(value?: string | null): number {
    const date = new Date(value || 0).getTime();

    return Number.isNaN(date) ? 0 : date;
  }
}