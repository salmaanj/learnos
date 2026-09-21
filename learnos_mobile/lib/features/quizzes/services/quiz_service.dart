import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/quiz_model.dart';

class QuizService {
  final _dio = ApiClient().dio;

  /// Published quizzes available for a given course (metadata only).
  Future<List<QuizModel>> getQuizzesForCourse(String courseId) async {
    final response = await _dio.get(
      '${ApiConstants.quizAttempts}/course/$courseId',
    );
    final List data = response.data;
    return data.map((e) => QuizModel.fromJson({
          ...Map<String, dynamic>.from(e),
          'questions': [], // summary endpoint doesn't include questions
        })).toList();
  }

  /// Fetches a published quiz in its "safe to show a learner" form -
  /// correct answers are never sent to the client until after submission.
  Future<QuizModel> getQuizToTake(String quizId) async {
    final response = await _dio.get(
      '${ApiConstants.quizAttempts}/quiz/$quizId/take',
    );
    return QuizModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  /// Submits the learner's answers (questionId -> selected optionId) and
  /// returns the graded result immediately.
  Future<QuizAttemptResultModel> submitAttempt({
    required String quizId,
    required Map<String, String> answers,
  }) async {
    final response = await _dio.post(
      ApiConstants.quizAttempts,
      data: {
        'quizId': quizId,
        'answers': answers,
      },
    );
    return QuizAttemptResultModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  /// The learner's own quiz attempt history, across all quizzes.
  Future<List<QuizAttemptResultModel>> getMyAttempts() async {
    final response = await _dio.get(ApiConstants.myQuizAttempts);
    final List data = response.data;
    return data
        .map((e) => QuizAttemptResultModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
