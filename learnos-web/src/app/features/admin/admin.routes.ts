import { Routes } from '@angular/router';

export const ADMIN_ROUTES: Routes = [
  {
    path: 'courses',
    loadComponent: () => import('./courses/courses').then(m => m.Courses)
  },
  {
    path: 'courses/new',
    loadComponent: () => import('./courses/course-form').then(m => m.CourseForm)
  },
  {
    path: 'courses/:id/edit',
    loadComponent: () => import('./courses/course-form').then(m => m.CourseForm)
  },
  { path: '', redirectTo: 'courses', pathMatch: 'full' }
];