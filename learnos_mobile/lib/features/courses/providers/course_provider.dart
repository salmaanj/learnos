import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../models/course_model.dart';
import '../repositories/course_offline_repository.dart';
import '../services/course_service.dart';

class CourseProvider
    extends ChangeNotifier {
  CourseProvider({
    AppDatabase? database,
  }) : _offlineRepository =
            CourseOfflineRepository(
              database: database,
            );

  final CourseService _service =
      CourseService();

  final CourseOfflineRepository
      _offlineRepository;

  List<CourseModel> _courses = [];
  List<CourseModel> _myCourses = [];
  List<CategoryModel> _categories = [];

  bool _loading = false;
  bool _loadingMyCourses = false;
  bool _loadingMore = false;

  bool _usingOfflineCourses = false;
  bool _usingOfflineMyCourses = false;

  String? _error;
  String? _myCoursesError;
  String? _selectedCategoryId;

  String _searchQuery = '';

  int _page = 0;
  int _totalPages = 1;

  List<CourseModel> get courses =>
      _courses;

  List<CourseModel> get myCourses =>
      _myCourses;

  List<CategoryModel> get categories =>
      _categories;

  bool get loading =>
      _loading;

  bool get loadingMyCourses =>
      _loadingMyCourses;

  bool get loadingMore =>
      _loadingMore;

  bool get usingOfflineCourses =>
      _usingOfflineCourses;

  bool get usingOfflineMyCourses =>
      _usingOfflineMyCourses;

  String? get error =>
      _error;

  String? get myCoursesError =>
      _myCoursesError;

  String? get selectedCategoryId =>
      _selectedCategoryId;

  Future<void> loadInitial() async {
    _loading = true;
    _error = null;
    _usingOfflineCourses = false;
    notifyListeners();

    try {
      _categories =
          await _service.getCategories();

      final result =
          await _service.getCourses(
        page: 0,
        size: 12,
      );

      _courses =
          List<CourseModel>.from(
        result['courses'] ?? [],
      );

      _page = 0;
      _totalPages =
          result['totalPages'] ?? 1;
    } catch (e) {
      _error = e.toString();
      _courses = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMyCourses() async {
    _loadingMyCourses = true;
    _myCoursesError = null;
    _usingOfflineMyCourses = false;
    notifyListeners();

    try {
      final result =
          await _offlineRepository
              .getMyCourses(
        remoteLoader:
            _service.getMyCourses,
      );

      _myCourses =
          result.courses;

      _usingOfflineMyCourses =
          result.fromCache;

      if (
        result.fromCache
        && _myCourses.isEmpty
      ) {
        _myCoursesError =
            'No cached courses are available offline.';
      }
    } catch (e) {
      _myCoursesError = e.toString();
      _myCourses = [];
    }

    _loadingMyCourses = false;
    notifyListeners();
  }

  Future<void> search(
    String query,
  ) async {
    _searchQuery =
        query.trim();

    _selectedCategoryId = null;
    _loading = true;
    _error = null;
    _usingOfflineCourses = false;
    notifyListeners();

    try {
      if (_searchQuery.isEmpty) {
        await loadInitial();
        return;
      }

      _courses =
          await _service.searchCourses(
        _searchQuery,
      );
    } catch (e) {
      _error = e.toString();
      _courses = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> filterByCategory(
    String? categoryId,
  ) async {
    _selectedCategoryId =
        categoryId;

    _searchQuery = '';
    _loading = true;
    _error = null;
    _usingOfflineCourses = false;
    notifyListeners();

    try {
      if (categoryId == null) {
        await loadInitial();
        return;
      }

      _courses =
          await _service
              .getCoursesByCategory(
        categoryId,
      );
    } catch (e) {
      _error = e.toString();
      _courses = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      _searchQuery.isNotEmpty
          ? search(_searchQuery)
          : _selectedCategoryId != null
              ? filterByCategory(
                  _selectedCategoryId,
                )
              : loadInitial(),
      loadMyCourses(),
    ]);
  }

  Future<void> loadMore() async {
    if (
      _loadingMore
      || _page + 1 >= _totalPages
    ) {
      return;
    }

    _loadingMore = true;
    notifyListeners();

    try {
      final next =
          _page + 1;

      final result =
          await _service.getCourses(
        page: next,
        size: 12,
      );

      final more =
          List<CourseModel>.from(
        result['courses'] ?? [],
      );

      _courses = [
        ..._courses,
        ...more,
      ];

      _page = next;

      _totalPages =
          result['totalPages']
          ?? _totalPages;
    } catch (_) {
      // Keep already-loaded courses.
    }

    _loadingMore = false;
    notifyListeners();
  }
}