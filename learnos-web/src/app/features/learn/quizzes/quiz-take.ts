import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { LearnerQuizService } from '../services/learner-quiz.service';

interface QuizOption {
  id: string;
  text: string;
}

interface QuizQuestion {
  id: string;
  text: string;
  type: string;
  options: QuizOption[];
}

interface QuizTakeModel {
  id: string;
  title: string;
  durationMinutes: number;
  passPercent: number;
  totalQuestions: number;
  questions: QuizQuestion[];
}

interface AttemptResult {
  id: string;
  quizId: string;
  quizTitle: string;
  totalQuestions: number;
  correctCount: number;
  scorePercent: number;
  passed: boolean;
}

@Component({
  selector: 'app-quiz-take',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './quiz-take.html',
  styleUrl: './quiz-take.scss'
})
export class QuizTake implements OnInit {
  quizId = '';
  quiz: QuizTakeModel | null = null;

  currentIndex = 0;
  answers: Record<string, string> = {};

  loading = true;
  submitting = false;
  errorMessage = '';

  result: AttemptResult | null = null;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private service: LearnerQuizService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.quizId = this.route.snapshot.paramMap.get('quizId') || '';
    this.load();
  }

  load(): void {
    this.loading = true;
    this.submitting = false;
    this.errorMessage = '';
    this.result = null;
    this.currentIndex = 0;
    this.answers = {};

    this.service.getQuizToTake(this.quizId).subscribe({
      next: (res) => {
        this.quiz = res?.data || res;
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.errorMessage =
          err?.error?.error ||
          err?.error?.message ||
          'This quiz is not currently available.';

        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  get currentQuestion(): QuizQuestion | null {
    if (!this.quiz || this.quiz.questions.length === 0) {
      return null;
    }

    return this.quiz.questions[this.currentIndex];
  }

  get isLastQuestion(): boolean {
    return !!this.quiz && this.currentIndex === this.quiz.questions.length - 1;
  }

  get answeredCount(): number {
    return Object.keys(this.answers).length;
  }

  selectAnswer(questionId: string, optionId: string): void {
    if (this.submitting || this.result) {
      return;
    }

    this.answers[questionId] = optionId;
  }

  isSelected(questionId: string, optionId: string): boolean {
    return this.answers[questionId] === optionId;
  }

  previousQuestion(): void {
    if (this.submitting || this.result) {
      return;
    }

    if (this.currentIndex > 0) {
      this.currentIndex--;
    }
  }

  nextQuestion(): void {
    if (this.submitting || this.result) {
      return;
    }

    if (this.quiz && this.currentIndex < this.quiz.questions.length - 1) {
      this.currentIndex++;
    }
  }

  submit(): void {
    if (!this.quiz || this.submitting || this.result) {
      return;
    }

    this.submitting = true;
    this.errorMessage = '';

    this.service.submitAttempt(this.quiz.id, { ...this.answers }).subscribe({
      next: (res) => {
        this.result = res?.data || res;
        this.submitting = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.errorMessage =
          err?.error?.error ||
          err?.error?.message ||
          'Could not submit this attempt.';

        this.submitting = false;
        this.cdr.detectChanges();
      }
    });
  }

  close(): void {
    this.router.navigate(['/learn/courses']);
  }
}