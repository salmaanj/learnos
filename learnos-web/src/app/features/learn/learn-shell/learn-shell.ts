import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  Router,
  RouterLink,
  RouterLinkActive,
  RouterOutlet
} from '@angular/router';
import { AuthService } from '../../../core/auth.service';

@Component({
  selector: 'app-learn-shell',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './learn-shell.html',
  styleUrl: './learn-shell.scss'
})
export class LearnShell {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  get userName(): string {
    return this.authService.getUserName();
  }

  get companyName(): string {
    return this.authService.getCompanyName();
  }

  get companyLogoUrl(): string {
    return this.authService.getCompanyLogoUrl();
  }

  onCompanyLogoError(): void {
    // The getter reads from AuthService/local storage. Removing this saved
    // broken URL lets the existing header continue without the company logo.
    localStorage.removeItem('companyLogoUrl');
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}