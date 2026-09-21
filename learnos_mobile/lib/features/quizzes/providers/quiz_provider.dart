import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _service = QuizService();

  QuizModel? _quiz;
  int _currentIndex = 0;
  final Map<String, String> _answers = {}; // questionId -> optionId

  bool _loading = false;
  bool _submitting = false;
  String? _error;

  QuizAttemptResultModel? _result;

  QuizModel? get quiz => _quiz;
  int get currentIndex => _currentIndex;
  Map<String, String> get answers => _answers;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;
  QuizAttemptResultModel? get result => _result;

  QuizQuestionModel? get currentQuestion =>
      _quiz != null && _quiz!.questions.isNotEmpty
          ? _quiz!.questions[_currentIndex]
          : null;

  bool get isLastQuestion =>
      _quiz != null && _currentIndex == _quiz!.questions.length - 1;

  int get answeredCount => _answers.length;

  Future<void> loadQuiz(String quizId) async {
    _loading = true;
    _error = null;
    _quiz = null;
    _result = null;
    _currentIndex = 0;
    _answers.clear();
    notifyListeners();
    try {
      _quiz = await _service.getQuizToTake(quizId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void selectAnswer(String questionId, String optionId) {
    _answers[questionId] = optionId;
    notifyListeners();
  }

  void nextQuestion() {
    if (_quiz == null) return;
    if (_currentIndex < _quiz!.questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (_quiz == null) return false;
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      _result = await _service.submitAttempt(
        quizId: _quiz!.id,
        answers: _answers,
      );
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }
}
