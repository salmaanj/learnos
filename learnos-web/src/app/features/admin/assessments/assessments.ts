import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs';
import {
  QuizService,
  Quiz,
  QuizQuestion,
  QuizOption,
  QuizResults
} from '../services/quiz.service';
import { CoursesService } from '../courses/courses.service';

interface CourseOption {
  id: string;
  title: string;
}

interface QuestionFormState {
  text: string;
  type: 'MCQ' | 'TRUE_FALSE';
  options: QuizOption[];
}

@Component({
  selector: 'app-assessments',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './assessments.html',
  styleUrl: './assessments.scss'
})
export class Assessments implements OnInit {
  activeTab: 'builder' | 'results' = 'builder';

  quizzes: Quiz[] = [];
  courses: CourseOption[] = [];
  selectedQuiz: Quiz | null = null;
  results: QuizResults | null = null;

  loading = true;
  errorMessage = '';

  searchTerm = '';

  showNewQuizForm = false;
  newQuiz = {
    title: '',
    courseId: '',
    durationMinutes: 30,
    passPercent: 60
  };

  showEditQuizForm = false;
  editQuiz = {
    title: '',
    courseId: '',
    durationMinutes: 30,
    passPercent: 60
  };

  showQuestionForm = false;
  editingQuestionId: string | null = null;
  questionForm: QuestionFormState = this.emptyQuestionForm();

  constructor(
    private quizService: QuizService,
    private coursesService: CoursesService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadCourses();
    this.loadQuizzes();
  }

  get displayedQuizzes(): Quiz[] {
    const term = this.searchTerm.trim().toLowerCase();

    if (!term) {
      return this.quizzes;
    }

    return this.quizzes.filter(quiz => {
      const courseTitle = this.getCourseTitle(quiz.courseId);

      return [quiz.title, quiz.status, courseTitle]
        .filter(Boolean)
        .some(value => String(value).toLowerCase().includes(term));
    });
  }

  getCourseTitle(courseId?: string | null): string {
    if (!courseId) {
      return 'Standalone';
    }

    return this.courses.find(course => course.id === courseId)?.title || '';
  }

  loadQuizzes(): void {
    this.loading = true;
    this.errorMessage = '';

    this.quizService
      .getAllQuizzes()
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cdr.detectChanges();
        })
      )
      .subscribe({
        next: (data) => {
          this.quizzes = data;

          if (!this.selectedQuiz && data.length > 0) {
            this.selectQuiz(data[0]);
          }
        },
        error: (err) => {
          this.errorMessage = this.getErrorMessage(
            err,
            'Could not load quizzes. Please try again.'
          );
        }
      });
  }

  loadCourses(): void {
    this.coursesService.getCourses().subscribe({
      next: (response: any) => {
        const items = Array.isArray(response?.data?.content)
          ? response.data.content
          : Array.isArray(response?.content)
            ? response.content
            : [];

        this.courses = items.map((course: any) => ({
          id: course.id,
          title: course.title
        }));

        this.cdr.detectChanges();
      },
      error: () => {
        // Course dropdown is optional; fail silently.
      }
    });
  }

  selectQuiz(quiz: Quiz): void {
    this.quizService.getQuiz(quiz.id).subscribe({
      next: (full) => {
        this.selectedQuiz = full;

        if (this.activeTab === 'results') {
          this.loadResults();
        }

        this.cdr.detectChanges();
      }
    });
  }

  setTab(tab: 'builder' | 'results'): void {
    this.activeTab = tab;

    if (tab === 'results' && this.selectedQuiz) {
      this.loadResults();
    }
  }

  toggleNewQuizForm(): void {
    this.showNewQuizForm = !this.showNewQuizForm;
    this.newQuiz = {
      title: '',
      courseId: '',
      durationMinutes: 30,
      passPercent: 60
    };
  }

  openEditQuiz(): void {
    if (!this.selectedQuiz) return;

    this.editQuiz = {
      title: this.selectedQuiz.title,
      courseId: this.selectedQuiz.courseId || '',
      durationMinutes: this.selectedQuiz.durationMinutes,
      passPercent: this.selectedQuiz.passPercent
    };

    this.showEditQuizForm = true;
  }

  cancelEditQuiz(): void {
    this.showEditQuizForm = false;
  }

  saveQuizSettings(): void {
    if (!this.selectedQuiz || !this.editQuiz.title.trim()) return;

    this.quizService
      .updateQuiz(this.selectedQuiz.id, {
        title: this.editQuiz.title.trim(),
        courseId: this.editQuiz.courseId || null,
        durationMinutes: this.editQuiz.durationMinutes,
        passPercent: this.editQuiz.passPercent
      })
      .subscribe({
        next: (quiz) => {
          this.selectedQuiz = quiz;
          this.showEditQuizForm = false;
          this.loadQuizzes();
          this.cdr.detectChanges();
        },
        error: (err) => {
          this.errorMessage = this.getErrorMessage(
            err,
            'Could not save quiz settings.'
          );
        }
      });
  }

  createQuiz(): void {
    if (!this.newQuiz.title.trim()) return;

    this.quizService
      .createQuiz({
        title: this.newQuiz.title.trim(),
        courseId: this.newQuiz.courseId || null,
        durationMinutes: this.newQuiz.durationMinutes,
        passPercent: this.newQuiz.passPercent
      })
      .subscribe({
        next: (quiz) => {
          this.showNewQuizForm = false;
          this.loadQuizzes();
          this.selectedQuiz = quiz;
          this.cdr.detectChanges();
        },
        error: (err) => {
          this.errorMessage = this.getErrorMessage(
            err,
            'Could not create the quiz.'
          );
        }
      });
  }

  deleteQuiz(quiz: Quiz, event: Event): void {
    event.stopPropagation();

    if (!confirm(`Delete "${quiz.title}"? This cannot be undone.`)) {
      return;
    }

    this.quizService.deleteQuiz(quiz.id).subscribe({
      next: () => {
        if (this.selectedQuiz?.id === quiz.id) {
          this.selectedQuiz = null;
        }

        this.loadQuizzes();
      },
      error: (err) => {
        this.errorMessage = this.getErrorMessage(
          err,
          'Could not delete the quiz.'
        );
      }
    });
  }

  publishQuiz(): void {
    if (!this.selectedQuiz) return;

    this.quizService.publishQuiz(this.selectedQuiz.id).subscribe({
      next: (quiz) => {
        this.selectedQuiz = quiz;
        this.loadQuizzes();
      },
      error: (err) => {
        this.errorMessage = this.getErrorMessage(
          err,
          'Could not publish. Add at least one question first.'
        );
      }
    });
  }

  openAddQuestion(): void {
    this.editingQuestionId = null;
    this.questionForm = this.emptyQuestionForm();
    this.showQuestionForm = true;
  }

  openEditQuestion(question: QuizQuestion): void {
    this.editingQuestionId = question.id ?? null;
    this.questionForm = {
      text: question.text,
      type: question.type,
      options: question.options.map(option => ({ ...option }))
    };

    this.showQuestionForm = true;
  }

  cancelQuestionForm(): void {
    this.showQuestionForm = false;
    this.editingQuestionId = null;
  }

  onQuestionTypeChange(): void {
    if (this.questionForm.type === 'TRUE_FALSE') {
      this.questionForm.options = [
        { text: 'True', correct: true },
        { text: 'False', correct: false }
      ];
    } else if (this.questionForm.options.length < 2) {
      this.questionForm.options = [
        { text: '', correct: true },
        { text: '', correct: false }
      ];
    }
  }

  addOption(): void {
    this.questionForm.options.push({ text: '', correct: false });
  }

  removeOption(index: number): void {
    this.questionForm.options.splice(index, 1);
  }

  markCorrect(index: number): void {
    this.questionForm.options.forEach((option, optionIndex) => {
      option.correct = optionIndex === index;
    });
  }

  saveQuestion(): void {
    if (!this.selectedQuiz) return;
    if (!this.questionForm.text.trim()) return;
    if (this.questionForm.options.some(option => !option.text.trim())) return;
    if (!this.questionForm.options.some(option => option.correct)) return;

    const payload = {
      text: this.questionForm.text.trim(),
      type: this.questionForm.type,
      options: this.questionForm.options
    };

    const request = this.editingQuestionId
      ? this.quizService.updateQuestion(
          this.selectedQuiz.id,
          this.editingQuestionId,
          payload
        )
      : this.quizService.addQuestion(this.selectedQuiz.id, payload);

    request.subscribe({
      next: (quiz) => {
        this.selectedQuiz = quiz;
        this.showQuestionForm = false;
        this.editingQuestionId = null;
        this.loadQuizzes();
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.errorMessage = this.getErrorMessage(
          err,
          'Could not save the question.'
        );
      }
    });
  }

  deleteQuestion(question: QuizQuestion): void {
    if (!this.selectedQuiz || !question.id) return;
    if (!confirm('Delete this question?')) return;

    this.quizService
      .deleteQuestion(this.selectedQuiz.id, question.id)
      .subscribe({
        next: (quiz) => {
          this.selectedQuiz = quiz;
          this.loadQuizzes();
          this.cdr.detectChanges();
        },
        error: (err) => {
          this.errorMessage = this.getErrorMessage(
            err,
            'Could not delete the question.'
          );
        }
      });
  }

  loadResults(): void {
    if (!this.selectedQuiz) return;

    this.quizService.getResults(this.selectedQuiz.id).subscribe({
      next: (res) => {
        this.results = res;
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.errorMessage = this.getErrorMessage(
          err,
          'Could not load quiz results.'
        );
      }
    });
  }

  private getErrorMessage(err: any, fallback: string): string {
    if (err?.status === 401 || err?.status === 403) {
      return "You don't have permission to view this page.";
    }

    return fallback;
  }

  private emptyQuestionForm(): QuestionFormState {
    return {
      text: '',
      type: 'MCQ',
      options: [
        { text: '', correct: true },
        { text: '', correct: false }
      ]
    };
  }
}