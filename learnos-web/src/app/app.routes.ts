import {
  Routes
} from '@angular/router';
import {
  inject
} from '@angular/core';
import {
  Router
} from '@angular/router';
import {
  catchError,
  map,
  of
} from 'rxjs';

import {
  AuthService
} from './core/auth.service';

import {
  SubscriptionService
} from './features/admin/subscription/subscription.service';

const authGuard = () => {
  const router = inject(Router);

  if (
    localStorage.getItem('accessToken')
  ) {
    return true;
  }

  return router.createUrlTree([
    '/login'
  ]);
};

const adminOnlyGuard = () => {
  const router = inject(Router);
  const authService = inject(AuthService);

  if (
    !localStorage.getItem('accessToken')
  ) {
    return router.createUrlTree([
      '/login'
    ]);
  }

  if (authService.isLearner()) {
    return router.createUrlTree([
      '/learn/courses'
    ]);
  }

  return true;
};

const pendingCompanyAdminGuard = () => {
  const router = inject(Router);
  const authService = inject(AuthService);
  const subscriptionService =
    inject(SubscriptionService);

  if (
    !localStorage.getItem('accessToken')
  ) {
    return router.createUrlTree([
      '/login'
    ]);
  }

  if (authService.isLearner()) {
    return router.createUrlTree([
      '/learn/courses'
    ]);
  }

  if (
    authService.isSuperAdmin()
    || !authService.isCompanyAdmin()
  ) {
    return true;
  }

  return subscriptionService
    .getMySubscription()
    .pipe(
      map(subscription => {
        authService.setSubscriptionStatus(
          subscription.status
        );

        if (
          subscription.status
            === 'PENDING_PAYMENT'
          && !router.url.startsWith(
            '/admin/subscription'
          )
        ) {
          return router.createUrlTree([
            '/admin/subscription'
          ]);
        }

        return true;
      }),
      catchError(() => {
        authService.setSubscriptionStatus(
          'PENDING_PAYMENT'
        );

        if (
          !router.url.startsWith(
            '/admin/subscription'
          )
        ) {
          return of(
            router.createUrlTree([
              '/admin/subscription'
            ])
          );
        }

        return of(true);
      })
    );
};

const superAdminOnlyGuard = () => {
  const router = inject(Router);
  const authService = inject(AuthService);

  if (
    !localStorage.getItem('accessToken')
  ) {
    return router.createUrlTree([
      '/login'
    ]);
  }

  if (authService.isSuperAdmin()) {
    return true;
  }

  if (authService.isLearner()) {
    return router.createUrlTree([
      '/learn/courses'
    ]);
  }

  return router.createUrlTree([
    '/admin/dashboard'
  ]);
};

const tutorOnlyGuard = () => {
  const router = inject(Router);
  const authService = inject(AuthService);

  if (
    !localStorage.getItem('accessToken')
  ) {
    return router.createUrlTree([
      '/login'
    ]);
  }

  if (
    authService.getUserRole()
    === 'TUTOR'
  ) {
    return true;
  }

  if (authService.isLearner()) {
    return router.createUrlTree([
      '/learn/courses'
    ]);
  }

  return router.createUrlTree([
    '/admin/dashboard'
  ]);
};

const homeRedirectGuard = () => {
  const router = inject(Router);
  const authService = inject(AuthService);

  if (
    !localStorage.getItem('accessToken')
  ) {
    return router.createUrlTree([
      '/login'
    ]);
  }

  return router.createUrlTree([
    authService.homeRoute()
  ]);
};

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login/login')
        .then(m => m.Login)
  },
  {
    path: 'forgot-password',
    loadComponent: () =>
      import(
        './features/auth/forgot-password/forgot-password'
      ).then(m => m.ForgotPassword)
  },
  {
    path: 'verify-certificate',
    loadComponent: () =>
      import(
        './features/public/verify-certificate/verify-certificate'
      ).then(m => m.VerifyCertificate)
  },
  {
    path: 'learn',
    canActivate: [authGuard],
    loadComponent: () =>
      import(
        './features/learn/learn-shell/learn-shell'
      ).then(m => m.LearnShell),
    children: [
      {
        path: 'courses',
        loadComponent: () =>
          import(
            './features/learn/browse-courses/browse-courses'
          ).then(m => m.BrowseCourses)
      },
      {
        path: 'courses/:id',
        loadComponent: () =>
          import(
            './features/learn/course-detail/course-detail'
          ).then(m => m.LearnCourseDetail)
      },
      {
        path: 'my-courses',
        loadComponent: () =>
          import(
            './features/learn/my-courses/my-courses'
          ).then(m => m.MyCourses)
      },
      {
        path: 'certificates',
        loadComponent: () =>
          import(
            './features/learn/certificates/my-certificates'
          ).then(m => m.MyCertificates)
      },
      {
        path: 'payment-history',
        loadComponent: () =>
          import(
            './features/learn/payment-history/payment-history'
          ).then(m => m.PaymentHistory)
      },
      {
        path: 'quiz/:quizId',
        loadComponent: () =>
          import(
            './features/learn/quizzes/quiz-take'
          ).then(m => m.QuizTake)
      },
      {
        path: 'live-classes',
        loadComponent: () =>
          import(
            './features/learn/live-classes/live-classes'
          ).then(m => m.LearnerLiveClasses)
      },
      {
        path: 'live-classes/:id',
        loadComponent: () =>
          import(
            './features/learn/live-class-detail/live-class-detail'
          ).then(m => m.LiveClassDetail)
      },
      {
        path: '',
        redirectTo: 'courses',
        pathMatch: 'full'
      }
    ]
  },
  {
    path: 'tutor/live-classes',
    canActivate: [tutorOnlyGuard],
    loadComponent: () =>
      import(
        './features/tutor/live-classes/tutor-live-classes'
      ).then(m => m.TutorLiveClasses)
  },
  {
    path: 'admin',
    canActivate: [adminOnlyGuard],
    loadComponent: () =>
      import(
        './features/admin/admin-shell/admin-shell'
      ).then(m => m.AdminShell),
    children: [
      {
        path: 'dashboard',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/dashboard/dashboard'
          ).then(m => m.Dashboard)
      },
      {
        path: 'companies',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/companies/companies-list'
          ).then(m => m.CompaniesList)
      },
      {
        path: 'companies/new',
        canActivate: [
          pendingCompanyAdminGuard,
          superAdminOnlyGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/companies/company-form'
          ).then(m => m.CompanyForm)
      },
      {
        path: 'companies/:id/edit',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/companies/company-form'
          ).then(m => m.CompanyForm)
      },
      {
        path: 'companies/users',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/company-users/company-users-list'
          ).then(m => m.CompanyUsersList)
      },
      {
        path: 'companies/users/new',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/company-users/company-user-form'
          ).then(m => m.CompanyUserForm)
      },
      {
        path: 'companies/users/:id/edit',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/company-users/company-user-form'
          ).then(m => m.CompanyUserForm)
      },
      {
        path: 'courses',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/courses'
          ).then(m => m.Courses)
      },
      {
        path: 'courses/new',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/course-form'
          ).then(m => m.CourseForm)
      },
      {
        path: 'courses/:id/edit',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/course-form'
          ).then(m => m.CourseForm)
      },
      {
        path: 'courses/:id/content',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/course-content/course-content'
          ).then(m => m.CourseContent)
      },
      {
        path: 'courses/:id/preview',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/course-preview/course-preview'
          ).then(m => m.CoursePreview)
      },
      {
        path: 'courses/:id/enrollments',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/course-enrollments/course-enrollments'
          ).then(m => m.CourseEnrollments)
      },
      {
        path: 'courses/categories',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/categories-list.component'
          ).then(m => m.CategoriesListComponent)
      },
      {
        path: 'courses/categories/new',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/category-form'
          ).then(m => m.CategoryForm)
      },
      {
        path: 'courses/categories/:id/edit',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/courses/category-form'
          ).then(m => m.CategoryForm)
      },
      {
        path: 'content-library',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/content-library/content-library'
          ).then(m => m.ContentLibrary)
      },
      {
        path: 'live-classes',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/live-classes/live-classes'
          ).then(m => m.LiveClasses)
      },
      {
        path: 'live-classes/new',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/live-classes/live-class-form'
          ).then(m => m.LiveClassForm)
      },
      {
        path: 'live-classes/:id/edit',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/live-classes/live-class-form'
          ).then(m => m.LiveClassForm)
      },
      {
        path: 'tutor-live-classes',
        canActivate: [
          pendingCompanyAdminGuard,
          tutorOnlyGuard
        ],
        loadComponent: () =>
          import(
            './features/tutor/live-classes/tutor-live-classes'
          ).then(m => m.TutorLiveClasses)
      },
      {
        path: 'learners',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/learners/learners'
          ).then(m => m.Learners)
      },
      {
        path: 'learners/:userId/enrollments',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/learners/learner-enrollments/learner-enrollments'
          ).then(m => m.LearnerEnrollments)
      },
      {
        path: 'batches',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/batches/batches'
          ).then(m => m.Batches)
      },
      {
        path: 'tests',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/assessments/assessments'
          ).then(m => m.Assessments)
      },
      {
        path: 'certifications',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/certifications/certifications'
          ).then(m => m.Certifications)
      },
      {
        path: 'payments',
        canActivate: [
          superAdminOnlyGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/payments/plans'
          ).then(m => m.PlansComponent)
      },
      {
        path: 'subscription',
        canActivate: [
          adminOnlyGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/subscription/subscription'
          ).then(m => m.SubscriptionComponent)
      },
      {
        path: 'analytics',
        canActivate: [
          pendingCompanyAdminGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/analytics/analytics'
          ).then(m => m.Analytics)
      },
      {
        path: 'roles',
        canActivate: [
          pendingCompanyAdminGuard,
          superAdminOnlyGuard
        ],
        loadComponent: () =>
          import(
            './features/admin/roles/roles-page.component'
          ).then(m => m.RolesPageComponent)
      },
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full'
      }
    ]
  },
  {
    path: '',
    canActivate: [homeRedirectGuard],
    loadComponent: () =>
      import(
        './features/auth/login/login'
      ).then(m => m.Login)
  },
  {
    path: '**',
    canActivate: [homeRedirectGuard],
    loadComponent: () =>
      import(
        './features/auth/login/login'
      ).then(m => m.Login)
  }
];