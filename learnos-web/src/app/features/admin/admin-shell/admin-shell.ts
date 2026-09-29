import {
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  NavigationEnd,
  Router,
  RouterModule
} from '@angular/router';
import { filter } from 'rxjs';

import {
  AuthService
} from '../../../core/auth.service';

import {
  SubscriptionService
} from '../subscription/subscription.service';

@Component({
  selector: 'app-admin-shell',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './admin-shell.html',
  styleUrl: './admin-shell.scss'
})
export class AdminShell implements OnInit {
  showActionButton = false;
  actionLabel = '';
  actionRoute = '';

  companyName = 'Company';
  companyLogoUrl = '';
  userRole = '';
  userName = '';
  pageTitle = 'Dashboard';

  subscriptionLoading = false;

  navItems = [
    {
      section: 'Overview',
      items: [
        {
          label: 'Dashboard',
          route: '/admin/dashboard',
          exact: true
        }
      ]
    },
    {
      section: 'Administration',
      superAdminOnly: true,
      items: [
        {
          label: 'Roles',
          route: '/admin/roles',
          exact: true
        }
      ]
    },
    {
      section: 'Courses',
      items: [
        {
          label: 'All courses',
          route: '/admin/courses',
          exact: true
        },
        {
          label: 'Course builder',
          route: '/admin/courses/new',
          exact: true
        },
        {
          label: 'Live classes',
          route: '/admin/live-classes',
          exact: true
        },
        {
          label: 'My Live Classes',
          route: '/admin/tutor-live-classes',
          exact: true
        },
        {
          label: 'Content library',
          route: '/admin/content-library',
          exact: false
        },
        {
          label: 'Categories',
          route: '/admin/courses/categories',
          exact: true
        }
      ]
    },
    {
      section: 'Learners',
      items: [
        {
          label: 'Learners',
          route: '/admin/learners',
          exact: true
        },
        {
          label: 'Batches & groups',
          route: '/admin/batches',
          exact: false
        }
      ]
    },
    {
      section: 'Assess',
      items: [
        {
          label: 'Tests & quizzes',
          route: '/admin/tests',
          exact: false
        },
        {
          label: 'Certifications',
          route: '/admin/certifications',
          exact: false
        }
      ]
    },
    {
      section: 'Business',
      items: [
        {
          label: 'Plans',
          route: '/admin/payments',
          exact: false
        }
      ]
    },
    {
      section: 'Companies',
      adminOnly: true,
      items: [
        {
          label: 'Companies',
          route: '/admin/companies',
          exact: true
        },
        {
          label: 'Company users',
          route: '/admin/companies/users',
          exact: true
        }
      ]
    },
    {
      section: 'Analytics',
      items: [
        {
          label: 'Analytics',
          route: '/admin/analytics',
          exact: false
        }
      ]
    }
  ];

  constructor(
    public router: Router,
    private readonly authService: AuthService,
    private readonly subscriptionService: SubscriptionService
  ) {
    if (this.authService.isLearner()) {
      this.router.navigateByUrl('/learn/courses');
      return;
    }

    this.updateTopAction();
    this.updatePageTitle();

    this.router.events
      .pipe(
        filter(event => event instanceof NavigationEnd)
      )
      .subscribe(() => {
        this.updateTopAction();
        this.updatePageTitle();
        this.loadCurrentUser();
      });
  }

  ngOnInit(): void {
    this.loadCurrentUser();
    this.loadSubscriptionStatus();
  }

  get canViewCompanyManagement(): boolean {
    const role = this.getResolvedRole();

    const email = (
      this.authService.getCurrentUser()?.email || ''
    )
      .trim()
      .toLowerCase();

    return role === 'ADMIN'
      || email === 'admin@blute.co.in';
  }

  get canViewRoles(): boolean {
    return this.authService.isSuperAdmin();
  }

  get canViewMyLiveClasses(): boolean {
    return this.getResolvedRole() === 'TUTOR';
  }

  get isPendingCompanyAdmin(): boolean {
    return this.authService.isCompanyAdmin()
      && !this.authService.isSubscriptionActive();
  }

shouldShowNavItem(label: string): boolean {
  if (label === 'Roles') {
    return this.canViewRoles;
  }

  if (this.isPendingCompanyAdmin) {
    return label === 'Plans';
  }

  if (this.authService.isSuperAdmin()) {
    return true;
  }

  if (this.getResolvedRole() === 'ADMIN') {
    return true;
  }

  // keep the existing permissionByLabel code below

  const permissionByLabel: Record<string, string> = {
    'All courses': 'COURSES_VIEW',
    'Course builder': 'COURSES_UPDATE',
    'Content library': 'CONTENT_LIBRARY_MANAGE',
    'Categories': 'COURSES_VIEW',
    'Live classes': 'LIVE_CLASSES_VIEW',
    'My Live Classes': 'LIVE_CLASSES_VIEW',
    'Learners': 'LEARNERS_VIEW',
    'Batches & groups': 'BATCHES_VIEW',
    'Tests & quizzes': 'QUIZZES_VIEW',
    'Certifications': 'CERTIFICATES_VIEW',
    'Analytics': 'ANALYTICS_VIEW',
    'Company users': 'COMPANY_USERS_VIEW',
    'Companies': 'COMPANIES_VIEW',
    'Plans': 'PLANS_VIEW'
  };

  const permission = permissionByLabel[label];

  return permission
    ? this.authService.hasPermission(permission)
    : false;
}

  getNavRoute(label: string): string {
    if (label === 'Plans') {
      return this.authService.isSuperAdmin()
        ? '/admin/payments'
        : '/admin/subscription';
    }

    return '';
  }

  onCompanyLogoError(): void {
    this.companyLogoUrl = '';
  }

  private loadSubscriptionStatus(): void {
    if (
      this.authService.isSuperAdmin()
      || this.authService.isLearner()
      || !this.authService.isCompanyAdmin()
    ) {
      return;
    }

    this.subscriptionLoading = true;

    this.subscriptionService
      .getMySubscription()
      .subscribe({
        next: subscription => {
          this.authService.setSubscriptionStatus(
            subscription.status
          );

          this.subscriptionLoading = false;
        },
        error: err => {
          this.authService.setSubscriptionStatus(
            'PENDING_PAYMENT'
          );

          this.subscriptionLoading = false;

          console.error(
            'Failed to load subscription status',
            err
          );
        }
      });
  }

  private getResolvedRole(): string {
    const currentUserRole =
      this.authService.getCurrentUser()?.role;

    const storedRole =
      this.authService.getUserRole();

    return (
      currentUserRole
      || storedRole
      || this.userRole
      || ''
    )
      .trim()
      .toUpperCase()
      .replace(/[- ]/g, '_');
  }

  private loadCurrentUser(): void {
    const currentUser =
      this.authService.getCurrentUser();

    this.companyName =
      currentUser?.companyName
      || this.authService.getCompanyName()
      || 'Company';

    this.companyLogoUrl =
      this.authService.getCompanyLogoUrl();

    this.userRole = (
      currentUser?.role
      || this.authService.getUserRole()
      || ''
    )
      .trim()
      .toUpperCase()
      .replace(/[- ]/g, '_');

    this.userName =
      this.authService.getUserName();
  }

  private isLearnerFormRoute(url: string): boolean {
    return url.startsWith(
      '/admin/companies/users/'
    ) && url.includes('role=LEARNER');
  }

  private updateTopAction(): void {
    const url = this.router.url;

    if (this.isLearnerFormRoute(url)) {
      this.clearTopAction();
      return;
    }

    if (url.startsWith('/admin/roles')) {
      this.clearTopAction();
      return;
    }

    if (url.startsWith('/admin/companies/users')) {
      if (this.canViewCompanyManagement) {
        this.showActionButton = true;
        this.actionLabel = '+ New User';
        this.actionRoute = '/admin/companies/users/new';
      } else {
        this.clearTopAction();
      }

      return;
    }

    if (
      url.startsWith('/admin/companies')
      && !url.startsWith('/admin/companies/users')
    ) {
      if (this.authService.isSuperAdmin()) {
        this.showActionButton = true;
        this.actionLabel = '+ New Company';
        this.actionRoute = '/admin/companies/new';
      } else {
        this.clearTopAction();
      }

      return;
    }

    if (url.startsWith('/admin/batches')) {
      this.showActionButton = true;
      this.actionLabel = '+ New Batch';
      this.actionRoute = '/admin/batches';
      return;
    }

    if (url.startsWith('/admin/courses/categories')) {
      this.showActionButton = true;
      this.actionLabel = '+ New Category';
      this.actionRoute = '/admin/courses/categories/new';
      return;
    }

    if (url.startsWith('/admin/courses')) {
      this.showActionButton = true;
      this.actionLabel = '+ New Course';
      this.actionRoute = '/admin/courses/new';
      return;
    }

    this.clearTopAction();
  }

  private clearTopAction(): void {
    this.showActionButton = false;
    this.actionLabel = '';
    this.actionRoute = '';
  }

  private updatePageTitle(): void {
    const url = this.router.url;

    if (url.startsWith('/admin/roles')) {
      this.pageTitle = 'Roles';
      return;
    }

    if (url.startsWith('/admin/tutor-live-classes')) {
      this.pageTitle = 'My Live Classes';
      return;
    }

    if (this.isLearnerFormRoute(url)) {
      this.pageTitle = 'Learners';
      return;
    }

    if (url.startsWith('/admin/companies/users')) {
      this.pageTitle = 'Company Users';
      return;
    }

    if (url.startsWith('/admin/companies')) {
      this.pageTitle = 'Companies';
      return;
    }

    if (url.startsWith('/admin/courses/categories')) {
      this.pageTitle = 'Categories';
      return;
    }

    if (
      url.startsWith('/admin/courses')
      && url.includes('/content')
    ) {
      this.pageTitle = 'Course Builder';
      return;
    }

    if (
      url.startsWith('/admin/courses/new')
      || /\/admin\/courses\/[^/]+\/edit$/.test(url)
    ) {
      this.pageTitle = 'Course Builder';
      return;
    }

    if (url.startsWith('/admin/courses')) {
      this.pageTitle = 'All Courses';
      return;
    }

    if (url.startsWith('/admin/live-classes')) {
      this.pageTitle = 'Live Classes';
      return;
    }

    if (url.startsWith('/admin/content-library')) {
      this.pageTitle = 'Content Library';
      return;
    }

    if (url.startsWith('/admin/batches')) {
      this.pageTitle = 'Batches & Groups';
      return;
    }

    if (url.startsWith('/admin/learners')) {
      this.pageTitle = 'Learners';
      return;
    }

    if (url.startsWith('/admin/certifications')) {
      this.pageTitle = 'Certifications';
      return;
    }

    if (url.startsWith('/admin/tests')) {
      this.pageTitle = 'Tests & Quizzes';
      return;
    }

    if (
      url.startsWith('/admin/payments')
      || url.startsWith('/admin/subscription')
    ) {
      this.pageTitle = 'Subscription & Payments';
      return;
    }

    if (url.startsWith('/admin/analytics')) {
      this.pageTitle = 'Analytics';
      return;
    }

    if (url.startsWith('/admin/dashboard')) {
      this.pageTitle = 'Dashboard';
      return;
    }

    this.pageTitle = 'Dashboard';
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}