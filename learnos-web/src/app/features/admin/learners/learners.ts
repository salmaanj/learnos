import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  Learner,
  LearnerEnrollment,
  LearnersService
} from '../services/learners.service';
import { CompanyUsersService } from '../company-users/company-users.service';

type LearnerRow = Learner & {
  initials: string;
  avatarClass: string;
  lastActiveLabel: string;
};

type SortColumn =
  | 'name'
  | 'companyName'
  | 'coursesEnrolled'
  | 'avgProgressPercent'
  | 'lastActive'
  | 'status';

type SortDirection = 'asc' | 'desc';

@Component({
  selector: 'app-learners',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    FormsModule
  ],
  templateUrl: './learners.html',
  styleUrl: './learners.scss'
})
export class Learners implements OnInit {
  learners: LearnerRow[] = [];
  filteredLearners: LearnerRow[] = [];

  selectedLearner: LearnerRow | null = null;
  learnerEnrollments: LearnerEnrollment[] = [];

  searchTerm = '';
  loading = true;
  loadingEnrollments = false;
  errorMessage = '';
  enrollmentError = '';

  sortColumn: SortColumn = 'name';
  sortDirection: SortDirection = 'asc';

  private readonly avatarClasses = [
    'avatar-pu',
    'avatar-te',
    'avatar-am',
    'avatar-co'
  ];

  constructor(
    private service: LearnersService,
    private companyUsersService: CompanyUsersService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadLearners();
  }

  loadLearners(): void {
    this.loading = true;
    this.errorMessage = '';

    this.service.getLearners().subscribe({
      next: (data: Learner[]) => {
        this.learners = data.map((learner, index) => ({
          ...learner,
          initials: this.getInitials(learner.name),
          avatarClass:
            this.avatarClasses[index % this.avatarClasses.length],
          lastActiveLabel: this.formatLastActive(
            learner.lastActive
          )
        }));

        this.applyFiltersAndSort();

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Learners API error', err);

        this.learners = [];
        this.filteredLearners = [];
        this.errorMessage =
          'Could not load learners. Please try again.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  selectLearner(
    learner: LearnerRow,
    event?: Event
  ): void {
    event?.preventDefault();

    const learnerUserId = this.getLearnerUserId(learner);

    if (!learnerUserId) {
      this.enrollmentError =
        'This learner does not have a valid user account ID.';
      this.selectedLearner = learner;
      this.learnerEnrollments = [];
      return;
    }

    if (
      this.selectedLearner?.id === learner.id &&
      !this.loadingEnrollments
    ) {
      this.closeLearnerDetails();
      return;
    }

    this.selectedLearner = learner;
    this.learnerEnrollments = [];
    this.enrollmentError = '';
    this.loadingEnrollments = true;

    this.service.getLearnerEnrollments(learnerUserId).subscribe({
      next: (enrollments: LearnerEnrollment[]) => {
        this.learnerEnrollments = Array.isArray(enrollments)
          ? [...enrollments].sort((left, right) =>
              left.courseTitle.localeCompare(right.courseTitle)
            )
          : [];

        this.loadingEnrollments = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Learner enrollment API error', err);

        this.learnerEnrollments = [];
        this.enrollmentError =
          err?.error?.message ||
          err?.error?.error ||
          'Could not load this learner’s enrolled courses.';

        this.loadingEnrollments = false;
        this.cdr.detectChanges();
      }
    });
  }

  closeLearnerDetails(): void {
    this.selectedLearner = null;
    this.learnerEnrollments = [];
    this.enrollmentError = '';
    this.loadingEnrollments = false;
  }

  onSearchChange(): void {
    this.applyFiltersAndSort();
  }

  sortBy(column: SortColumn): void {
    if (this.sortColumn === column) {
      this.sortDirection =
        this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column;
      this.sortDirection = 'asc';
    }

    this.applyFiltersAndSort();
  }

  sortIndicator(column: SortColumn): string {
    if (this.sortColumn !== column) {
      return '↕';
    }

    return this.sortDirection === 'asc' ? '↑' : '↓';
  }

  getStatusClass(status: Learner['status']): string {
  if (
    status === 'Active' ||
    status === 'Completed' ||
    status === 'Certified'
  ) {
    return 'badge-gr';
  }

  if (status === 'At risk') {
    return 'badge-am';
  }

  return 'badge-co';
}

  getProgressColor(status: Learner['status']): string {
    if (status === 'At risk') {
      return 'var(--am)';
    }

    if (status === 'Inactive') {
      return 'var(--co)';
    }

    return 'var(--gr)';
  }

  enrollmentStatusLabel(status: string): string {
  const normalized = String(status || '')
    .trim()
    .toUpperCase();

  if (normalized === 'CERTIFIED') {
    return 'Certified';
  }

  if (normalized === 'COMPLETED') {
    return 'Completed';
  }

  if (
    normalized === 'IN PROGRESS' ||
    normalized === 'ACTIVE'
  ) {
    return 'In progress';
  }

  if (normalized === 'CANCELLED') {
    return 'Cancelled';
  }

  return status || 'Unknown';
}

enrollmentStatusClass(status: string): string {
  const normalized = String(status || '')
    .trim()
    .toUpperCase();

  if (normalized === 'CERTIFIED') {
    return 'enrollment-certified';
  }

  if (normalized === 'COMPLETED') {
    return 'enrollment-completed';
  }

  if (
    normalized === 'IN PROGRESS' ||
    normalized === 'ACTIVE'
  ) {
    return 'enrollment-active';
  }

  return 'enrollment-other';
}

  formatEnrollmentDate(
    value: string | null | undefined
  ): string {
    if (!value) {
      return '—';
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

  exportCsv(): void {
    const header = [
      'Name',
      'Email',
      'Company',
      'Courses',
      'Progress %',
      'Last Active',
      'Status'
    ];

    const rows = this.filteredLearners.map(learner => [
      learner.name ?? '',
      learner.email ?? '',
      learner.companyName ?? '',
      String(learner.coursesEnrolled ?? 0),
      String(learner.avgProgressPercent ?? 0),
      learner.lastActiveLabel,
      learner.status
    ]);

    const csvContent = [header, ...rows]
      .map(row =>
        row
          .map(cell => `"${String(cell).replace(/"/g, '""')}"`)
          .join(',')
      )
      .join('\n');

    const blob = new Blob(
      [csvContent],
      { type: 'text/csv;charset=utf-8;' }
    );

    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');

    link.href = url;
    link.download =
      `learners-${new Date().toISOString().slice(0, 10)}.csv`;

    link.click();
    URL.revokeObjectURL(url);
  }

  trackByLearnerId(
    _: number,
    learner: LearnerRow
  ): string {
    return learner.id;
  }

  trackByEnrollmentId(
    _: number,
    enrollment: LearnerEnrollment
  ): string {
    return enrollment.enrollmentId;
  }

  deleteLearner(
    learner: LearnerRow,
    event: Event
  ): void {
    event.stopPropagation();

    if (
      !confirm(
        `Remove "${learner.name}" from this company? This cannot be undone.`
      )
    ) {
      return;
    }

    this.companyUsersService.deleteUser(learner.id).subscribe({
      next: () => {
        if (this.selectedLearner?.id === learner.id) {
          this.closeLearnerDetails();
        }

        this.loadLearners();
      },
      error: err =>
        alert(
          err?.error?.error ||
          'Could not remove this learner.'
        )
    });
  }

  private applyFiltersAndSort(): void {
  const rawTerm = this.searchTerm.trim().toLowerCase();
  const phoneTerm = this.normalizePhone(this.searchTerm);

  const filtered = !rawTerm
    ? [...this.learners]
    : this.learners.filter(learner => {
        const textMatches = [
          learner.name,
          learner.email,
          learner.phone,
          learner.companyName,
          learner.status
        ]
          .filter(Boolean)
          .some(value =>
            String(value).toLowerCase().includes(rawTerm)
          );

        const phoneMatches =
          phoneTerm.length > 0 &&
          this.normalizePhone(learner.phone).includes(phoneTerm);

        return textMatches || phoneMatches;
      });

  this.filteredLearners = filtered.sort((left, right) => {
    const leftValue = this.getSortValue(
      left,
      this.sortColumn
    );

    const rightValue = this.getSortValue(
      right,
      this.sortColumn
    );

    const result = leftValue.localeCompare(
      rightValue,
      undefined,
      {
        numeric: true,
        sensitivity: 'base'
      }
    );

    return this.sortDirection === 'asc'
      ? result
      : -result;
  });
}

  private getSortValue(
    learner: LearnerRow,
    column: SortColumn
  ): string {
    switch (column) {
      case 'coursesEnrolled':
        return String(
          learner.coursesEnrolled ?? 0
        ).padStart(12, '0');

      case 'avgProgressPercent':
        return String(
          learner.avgProgressPercent ?? 0
        ).padStart(12, '0');

      case 'lastActive':
        return learner.lastActive
          ? new Date(learner.lastActive).getTime().toString()
          : '0';

      case 'name':
      case 'companyName':
      case 'status':
        return String(learner[column] ?? '');

      default:
        return '';
    }
  }

  private getLearnerUserId(
    learner: LearnerRow
  ): string {
    return String(
      learner.userId || learner.id || ''
    ).trim();
  }
  private normalizePhone(
      value: string | null | undefined
    ): string {
      return String(value || '').replace(/\D/g, '');
    }
  private getInitials(name: string | null): string {
    if (!name) {
      return '??';
    }

    const parts = name.trim().split(/\s+/);

    if (parts.length === 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }

    return (
      parts[0][0] +
      parts[parts.length - 1][0]
    ).toUpperCase();
  }

  private formatLastActive(
    lastActive: string | null
  ): string {
    if (!lastActive) {
      return 'Never';
    }

    const date = new Date(lastActive);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(
      diffMs / (1000 * 60 * 60 * 24)
    );

    if (diffDays <= 0) {
      return 'Today';
    }

    if (diffDays === 1) {
      return 'Yesterday';
    }

    if (diffDays < 7) {
      return `${diffDays} days ago`;
    }

    return date.toLocaleDateString();
  }
}