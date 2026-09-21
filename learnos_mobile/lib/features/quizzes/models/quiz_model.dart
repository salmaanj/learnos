class QuizOptionModel {
  final String id;
  final String text;

  QuizOptionModel({required this.id, required this.text});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'].toString(),
      text: json['text'] ?? '',
    );
  }
}

class QuizQuestionModel {
  final String id;
  final String text;
  final String type; // MCQ | TRUE_FALSE
  final List<QuizOptionModel> options;

  QuizQuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List? ?? [];
    return QuizQuestionModel(
      id: json['id'].toString(),
      text: json['text'] ?? '',
      type: json['type'] ?? 'MCQ',
      options: optionsJson.map((e) => QuizOptionModel.fromJson(e)).toList(),
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final int durationMinutes;
  final int passPercent;
  final int totalQuestions;
  final List<QuizQuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.passPercent,
    required this.totalQuestions,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List? ?? [];
    return QuizModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 30,
      passPercent: json['passPercent'] ?? 60,
      totalQuestions: json['totalQuestions'] ?? questionsJson.length,
      questions: questionsJson.map((e) => QuizQuestionModel.fromJson(e)).toList(),
    );
  }
}

class QuizAttemptResultModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final int totalQuestions;
  final int correctCount;
  final int scorePercent;
  final bool passed;
  final DateTime? submittedAt;

  QuizAttemptResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercent,
    required this.passed,
    this.submittedAt,
  });

  factory QuizAttemptResultModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptResultModel(
      id: json['id'].toString(),
      quizId: json['quizId'].toString(),
      quizTitle: json['quizTitle'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      scorePercent: json['scorePercent'] ?? 0,
      passed: json['passed'] ?? false,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
    );
  }
}
