import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/course_service.dart';

class CourseLearnScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String? selectedLessonId;

  const CourseLearnScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.selectedLessonId,
  });

  @override
  State<CourseLearnScreen> createState() =>
      _CourseLearnScreenState();
}

class _CourseLearnScreenState
    extends State<CourseLearnScreen> {
  final _service = CourseService();
  final _dio = Dio();

  List<LessonModel> _lessons = [];

  bool _loading = true;
  bool _progressLoading = false;
  bool _savingProgress = false;
  bool _markingComplete = false;
  bool _ratingLoading = false;
  bool _ratingSaving = false;
  bool _downloadingLesson = false;

  String? _courseLoadError;
  String? _mediaError;

  int _selectedIndex = 0;
  int _courseProgressPercent = 0;
  int _completedLessons = 0;
  bool _contentCompleted = false;
  int _lastSavedPositionSeconds = 0;

  double _averageRating = 0.0;
  int _ratingCount = 0;
  int? _myRating;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _ytController;

  PDFViewController? _pdfController;
  String? _pdfLessonId;
  String? _pdfFilePath;
  bool _pdfLoading = false;
  String? _pdfError;

  static const int _progressSaveIntervalSeconds = 15;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _loadCourseRating();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _loading = true;
      _courseLoadError = null;
      _mediaError = null;
      _pdfError = null;
    });

    try {
      final lessons = await _service.getLessons(widget.courseId);
      if (!mounted) return;

      lessons.sort(
        (left, right) => left.order.compareTo(right.order),
      );

      if (lessons.isEmpty) {
        setState(() {
          _lessons = [];
          _loading = false;
        });
        return;
      }

      final selectedIndex = _findSelectedLessonIndex(
        lessons,
        widget.selectedLessonId,
      );

      setState(() {
        _lessons = lessons;
        _selectedIndex = selectedIndex;
        _loading = false;
      });

      _playLesson(selectedIndex, disposeCurrent: false);

      if (widget.selectedLessonId == null ||
          widget.selectedLessonId!.isEmpty) {
        await _loadProgressAndResume();
      } else {
        _loadProgressOnly();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _courseLoadError = _friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _loadCourseRating() async {
    if (mounted) setState(() => _ratingLoading = true);

    try {
      final rating = await _service.getCourseRating(widget.courseId);
      if (!mounted) return;

      setState(() {
        _averageRating = rating.averageRating;
        _ratingCount = rating.ratingCount;
        _myRating = rating.myRating;
        _ratingLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _ratingLoading = false);
    }
  }

  Future<void> _submitCourseRating(int stars) async {
    if (stars < 1 || stars > 5 || _ratingSaving) return;

    setState(() => _ratingSaving = true);

    try {
      final rating = await _service.saveCourseRating(
        courseId: widget.courseId,
        stars: stars,
      );
      if (!mounted) return;

      setState(() {
        _averageRating = rating.averageRating;
        _ratingCount = rating.ratingCount;
        _myRating = rating.myRating;
        _ratingSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course rating saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _ratingSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  int _findSelectedLessonIndex(
    List<LessonModel> lessons,
    String? selectedLessonId,
  ) {
    if (selectedLessonId == null || selectedLessonId.isEmpty) return 0;
    final index = lessons.indexWhere(
      (lesson) => lesson.id == selectedLessonId,
    );
    return index >= 0 ? index : 0;
  }

  Future<void> _loadProgressAndResume() async {
    await _loadProgress(applyResumeLesson: true);
  }

  Future<void> _loadProgressOnly() async {
    await _loadProgress(applyResumeLesson: false);
  }

  Future<void> _loadProgress({
    required bool applyResumeLesson,
  }) async {
    if (_lessons.isEmpty) return;
    setState(() => _progressLoading = true);

    try {
      final progress = await _service.getCourseProgress(widget.courseId);
      if (!mounted) return;

      final hydratedLessons = _applyProgress(
        _lessons,
        progress.lessons,
      );
      final resumeIndex = applyResumeLesson
          ? _findResumeIndex(
              hydratedLessons,
              progress.resumeLessonId,
            )
          : _selectedIndex;
      final shouldChangeLesson = resumeIndex != _selectedIndex;

      setState(() {
        _lessons = hydratedLessons;
        _selectedIndex = resumeIndex;
        _courseProgressPercent = progress.progressPercent;
        _completedLessons = progress.completedLessons;
        _contentCompleted = progress.contentCompleted;
        _progressLoading = false;
      });

      if (shouldChangeLesson) _playLesson(resumeIndex);
    } catch (_) {
      if (mounted) setState(() => _progressLoading = false);
    }
  }

  List<LessonModel> _applyProgress(
    List<LessonModel> lessons,
    List<LessonProgressModel> progressItems,
  ) {
    final progressByLessonId = {
      for (final item in progressItems) item.lessonId: item,
    };

    return lessons.map((lesson) {
      final progress = progressByLessonId[lesson.id];
      if (progress == null) return lesson;

      return lesson.copyWith(
        isCompleted: progress.completed,
        watchedSeconds: progress.watchedSeconds,
        progressPercent: progress.progressPercent,
        durationSeconds: progress.durationSeconds,
      );
    }).toList();
  }

  int _findResumeIndex(
    List<LessonModel> lessons,
    String? resumeLessonId,
  ) {
    if (resumeLessonId == null || resumeLessonId.isEmpty) return 0;
    final index = lessons.indexWhere(
      (lesson) => lesson.id == resumeLessonId,
    );
    return index >= 0 ? index : 0;
  }

  String _friendlyError(Object error) {
    final message = error
        .toString()
        .replaceAll('Exception: ', '')
        .trim();
    return message.isEmpty ? 'Could not load this course.' : message;
  }

  Future<void> _refreshCourseProgress() async {
    await _loadProgressOnly();
  }

  void _playLesson(
    int index, {
    bool disposeCurrent = true,
  }) {
    if (index < 0 || index >= _lessons.length) return;

    if (disposeCurrent) {
      _saveCurrentMediaProgress();
      _disposeMediaControllers();
      _clearPdfViewer();
    }

    setState(() {
      _selectedIndex = index;
      _lastSavedPositionSeconds = _lessons[index].watchedSeconds;
      _mediaError = null;
      _pdfError = null;
    });

    final lesson = _lessons[index];

    if (lesson.type == 'PDF' ||
        lesson.type == 'SLIDES' ||
        lesson.type == 'DOCUMENT') {
      _loadPdfDocument(lesson);
    } else if (lesson.type == 'VIDEO' || lesson.type == 'AUDIO') {
      _loadMediaLesson(lesson, index);
    }
  }

  void _loadMediaLesson(LessonModel lesson, int index) {
    final url = lesson.videoUrl;

    if (url == null || url.isEmpty) {
      setState(() => _mediaError =
          'No media file has been uploaded for this lesson yet.');
      return;
    }

    if (lesson.isYoutube && lesson.youtubeId != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: lesson.youtubeId!,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
      return;
    }

    final mediaUrl = Uri.tryParse(url);
    if (mediaUrl == null) {
      setState(() => _mediaError = 'This lesson has an invalid media URL.');
      return;
    }

    _videoController = VideoPlayerController.networkUrl(mediaUrl);

    _videoController!.initialize().then((_) async {
      if (!mounted || _videoController == null) return;

      final resumePosition = Duration(seconds: lesson.watchedSeconds);
      if (lesson.watchedSeconds > 0 &&
          _videoController!.value.duration > resumePosition) {
        await _videoController!.seekTo(resumePosition);
      }

      _videoController!.addListener(_onVideoPositionChanged);

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: lesson.type == 'AUDIO'
            ? 16 / 5
            : (_videoController!.value.aspectRatio == 0
                ? 16 / 9
                : _videoController!.value.aspectRatio),
        allowFullScreen: lesson.type == 'VIDEO',
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        placeholder: Container(color: Colors.black),
        errorBuilder: (_, message) => _MediaErrorView(
          message: 'Unable to play this lesson.\n$message',
          onRetry: () => _playLesson(index),
        ),
      );

      if (mounted) setState(() {});
    }).catchError((_) {
      if (!mounted) return;
      _disposeMediaControllers();
      setState(() => _mediaError =
          'Unable to load this lesson media. Please try another lesson.');
    });
  }

  Future<void> _loadPdfDocument(LessonModel lesson) async {
    final documentUrl = lesson.documentUrl;

    if (documentUrl == null || documentUrl.isEmpty) {
      setState(() => _pdfError =
          'No document has been uploaded for this lesson yet.');
      return;
    }

    final uri = Uri.tryParse(documentUrl);
    if (uri == null) {
      setState(() => _pdfError = 'This document has an invalid URL.');
      return;
    }

    setState(() {
      _pdfLoading = true;
      _pdfError = null;
      _pdfLessonId = lesson.id;
      _pdfFilePath = null;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/lesson_${lesson.id}.pdf';
      await _dio.download(uri.toString(), filePath);
      if (!mounted) return;

      setState(() {
        _pdfFilePath = filePath;
        _pdfLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pdfLoading = false;
        _pdfError = 'Unable to load this document.';
      });
    }
  }

  void _clearPdfViewer() {
    _pdfController = null;
    _pdfLessonId = null;
    _pdfFilePath = null;
    _pdfLoading = false;
    _pdfError = null;
  }

  Future<void> _downloadCurrentLesson() async {
    if (_lessons.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _lessons.length) {
      return;
    }

    final lesson = _lessons[_selectedIndex];
    if (!lesson.downloadable || _downloadingLesson) return;

    setState(() => _downloadingLesson = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final safeTitle = lesson.title
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      final fileName = '${safeTitle.isEmpty ? 'lesson' : safeTitle}'
          '${_downloadExtension(lesson)}';
      final filePath = path.join(directory.path, fileName);

      await _service.downloadLessonFile(
        lessonId: lesson.id,
        filePath: filePath,
      );

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: lesson.title,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingLesson = false);
    }
  }

  String _downloadExtension(LessonModel lesson) {
    switch (lesson.type.toUpperCase()) {
      case 'PDF':
      case 'SLIDES':
        return '.pdf';
      case 'AUDIO':
        return '.mp3';
      case 'VIDEO':
        return '.mp4';
      default:
        return '.bin';
    }
  }

  void _onVideoPositionChanged() {
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _lessons.isEmpty) {
      return;
    }

    final positionSeconds = controller.value.position.inSeconds;
    final durationSeconds = controller.value.duration.inSeconds;

    if (positionSeconds - _lastSavedPositionSeconds >=
        _progressSaveIntervalSeconds) {
      _saveProgress(positionSeconds, completed: false);
    }

    if (durationSeconds > 0 &&
        positionSeconds >= durationSeconds &&
        !controller.value.isPlaying) {
      _saveProgress(durationSeconds, completed: true);
    }
  }

  Future<void> _saveCurrentMediaProgress() async {
    final controller = _videoController;
    if (controller == null ||
        _lessons.isEmpty ||
        !controller.value.isInitialized) {
      return;
    }

    await _saveProgress(
      controller.value.position.inSeconds,
      completed: controller.value.duration.inSeconds > 0 &&
          controller.value.position.inSeconds >=
              controller.value.duration.inSeconds,
    );
  }

  Future<void> _saveProgress(
    int watchedSeconds, {
    required bool completed,
  }) async {
    if (_savingProgress ||
        _lessons.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _lessons.length) {
      return;
    }

    final lesson = _lessons[_selectedIndex];
    if (lesson.type != 'VIDEO' && lesson.type != 'AUDIO') return;

    _savingProgress = true;
    try {
      final progress = await _service.saveLessonProgress(
        lessonId: lesson.id,
        watchedSeconds: watchedSeconds < 0 ? 0 : watchedSeconds,
        completed: completed,
      );
      if (!mounted) return;

      _replaceLessonProgress(
        lesson.id,
        completed: progress.completed,
        watchedSeconds: progress.watchedSeconds,
        progressPercent: progress.progressPercent,
        durationSeconds: progress.durationSeconds,
      );
      _lastSavedPositionSeconds = progress.watchedSeconds;

      if (progress.completed || completed) {
        await _refreshCourseProgress();
      }
    } catch (_) {
      // Keep playback uninterrupted if saving progress fails.
    } finally {
      _savingProgress = false;
    }
  }

  Future<void> _markCurrentLessonCompleted() async {
    if (_markingComplete ||
        _lessons.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _lessons.length) {
      return;
    }

    final lesson = _lessons[_selectedIndex];
    if (lesson.isCompleted) return;

    setState(() => _markingComplete = true);
    try {
      final progress = await _service.markLessonCompleted(lesson.id);
      if (!mounted) return;

      _replaceLessonProgress(
        lesson.id,
        completed: progress.completed,
        watchedSeconds: progress.watchedSeconds,
        progressPercent: progress.progressPercent,
        durationSeconds: progress.durationSeconds,
      );
      await _refreshCourseProgress();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson marked as complete'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _markingComplete = false);
    }
  }

  void _replaceLessonProgress(
    String lessonId, {
    required bool completed,
    required int watchedSeconds,
    required int progressPercent,
    int? durationSeconds,
  }) {
    final index = _lessons.indexWhere(
      (lesson) => lesson.id == lessonId,
    );
    if (index < 0) return;

    setState(() {
      _lessons[index] = _lessons[index].copyWith(
        isCompleted: completed,
        watchedSeconds: watchedSeconds,
        progressPercent: progressPercent,
        durationSeconds: durationSeconds,
      );
    });
  }

  void _disposeMediaControllers() {
    _videoController?.removeListener(_onVideoPositionChanged);
    _ytController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    _ytController = null;
    _chewieController = null;
    _videoController = null;
  }

  @override
  void dispose() {
    _saveCurrentMediaProgress();
    _disposeMediaControllers();
    _clearPdfViewer();
    super.dispose();
  }

  // The download arrow is shown only when the admin ticked "downloadable"
  // and the lesson actually has a file (video, audio, PDF or slides).
  bool _canDownload(LessonModel lesson) =>
      lesson.downloadable && lesson.type != 'TEXT' && !lesson.isYoutube;

  bool _isPdfLessonSelected() {
    if (_selectedIndex < 0 || _selectedIndex >= _lessons.length) return false;
    final type = _lessons[_selectedIndex].type;
    return type == 'PDF' || type == 'SLIDES' || type == 'DOCUMENT';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _loading ||
              _courseLoadError != null ||
              _lessons.isEmpty
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.courseTitle,
                style: AppTextStyles.h4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
      body: SafeArea(
        child: _loading
            ? const AppLoader()
            : _courseLoadError != null
                ? _CourseLoadErrorView(
                    error: _courseLoadError!,
                    onRetry: _loadLessons,
                  )
                : _lessons.isEmpty
                    ? _EmptyView(
                        onBack: () => Navigator.pop(context),
                      )
                    : Column(
                        children: [
                          _buildTopBar(),
                          _buildCourseProgress(),
                          _buildRatingPanel(),
                          Expanded(child: _buildLessonContent()),
                          _buildNavigation(),
                        ],
                      ),
      ),
    );
  }

  Widget _buildLessonContent() {
    if (_isPdfLessonSelected()) {
      return Column(
        children: [
          Expanded(flex: 3, child: _buildPlayer()),
          if (_canDownload(_lessons[_selectedIndex])) _buildNowPlaying(),
          Expanded(flex: 2, child: _buildLessonList()),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlayer(),
                _buildNowPlaying(),
                Divider(color: AppColors.divider, height: 1),
              ],
            ),
          ),
        ),
        Expanded(child: _buildLessonList()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.courseTitle,
              style: AppTextStyles.h4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_selectedIndex + 1}/${_lessons.length}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgress() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$_completedLessons of ${_lessons.length} lessons completed',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$_courseProgressPercent%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _courseProgressPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              color: AppColors.success,
            ),
          ),
          if (_progressLoading) ...[
            const SizedBox(height: 4),
            Text(
              'Syncing progress…',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_contentCompleted) ...[
            const SizedBox(height: 6),
            Text(
              '✓ Course content completed. Assessment unlocked.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingPanel() {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: _ratingLoading
                  ? Text(
                      'Loading ratings…',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ratingCount == 0
                              ? 'No ratings yet'
                              : '${_averageRating.toStringAsFixed(1)} (${_ratingCount == 1 ? '1 rating' : '$_ratingCount ratings'})',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final isSelected = star <= (_myRating ?? 0);
                            return InkWell(
                              onTap: _ratingSaving
                                  ? null
                                  : () => _submitCourseRating(star),
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.amber.shade600,
                                  size: 25,
                                ),
                              ),
                            );
                          }),
                        ),
                        Text(
                          _ratingSaving
                              ? 'Saving your rating…'
                              : _myRating == null
                                  ? 'Tap a star to rate this course'
                                  : 'Your rating: $_myRating out of 5',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final lesson = _lessons[_selectedIndex];
    if (_mediaError != null) {
      return _MediaErrorView(
        message: _mediaError!,
        onRetry: () => _playLesson(_selectedIndex),
      );
    }
    if (lesson.type == 'VIDEO' || lesson.type == 'AUDIO') {
      return _buildMediaPlayer(lesson);
    }
    if (lesson.type == 'TEXT' ||
        lesson.textContent?.trim().isNotEmpty == true) {
      return _TextLessonView(
        lesson: lesson,
        onMarkComplete: _markCurrentLessonCompleted,
        markingComplete: _markingComplete,
      );
    }
    if (lesson.type == 'PDF' ||
        lesson.type == 'SLIDES' ||
        lesson.type == 'DOCUMENT') {
      return _PdfLessonView(
        lesson: lesson,
        filePath: _pdfLessonId == lesson.id ? _pdfFilePath : null,
        loading: _pdfLessonId == lesson.id && _pdfLoading,
        error: _pdfLessonId == lesson.id ? _pdfError : null,
        onRetry: () => _loadPdfDocument(lesson),
        onMarkComplete: _markCurrentLessonCompleted,
        markingComplete: _markingComplete,
        onControllerReady: (controller) => _pdfController = controller,
      );
    }
    return _UnsupportedLessonView(
      lesson: lesson,
      onMarkComplete: _markCurrentLessonCompleted,
      markingComplete: _markingComplete,
    );
  }

  Widget _buildMediaPlayer(LessonModel lesson) {
    if (lesson.videoUrl == null || lesson.videoUrl!.isEmpty) {
      return _MediaErrorView(
        message: 'No media file has been uploaded for this lesson yet.',
        onRetry: () => _playLesson(_selectedIndex),
      );
    }
    if (lesson.isYoutube && _ytController != null) {
      return YoutubePlayer(
        controller: _ytController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
      );
    }
    if (_chewieController != null &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: lesson.type == 'AUDIO'
            ? 16 / 5
            : (_videoController!.value.aspectRatio == 0
                ? 16 / 9
                : _videoController!.value.aspectRatio),
        child: Chewie(controller: _chewieController!),
      );
    }
    return AspectRatio(
      aspectRatio: lesson.type == 'AUDIO' ? 16 / 5 : 16 / 9,
      child: Container(
        color: Colors.black,
        child: const Center(child: AppLoader()),
      ),
    );
  }

  Widget _buildNowPlaying() {
    final lesson = _lessons[_selectedIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Icon(
            lesson.isCompleted
                ? Icons.check_circle_rounded
                : _lessonTypeIcon(lesson.type),
            color: lesson.isCompleted
                ? AppColors.success
                : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              lesson.title,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lesson.progressPercent > 0 && !lesson.isCompleted)
            Text(
              '${lesson.progressPercent}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (_canDownload(lesson)) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Download lesson',
              onPressed: _downloadingLesson
                  ? null
                  : _downloadCurrentLesson,
              icon: _downloadingLesson
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  IconData _lessonTypeIcon(String type) {
    switch (type) {
      case 'VIDEO': return Icons.play_circle_rounded;
      case 'AUDIO': return Icons.audiotrack_rounded;
      case 'PDF': return Icons.picture_as_pdf_rounded;
      case 'SLIDES': return Icons.slideshow_rounded;
      case 'TEXT': return Icons.subject_rounded;
      default: return Icons.description_outlined;
    }
  }

  Widget _buildLessonList() {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        final isSelected = index == _selectedIndex;
        return ListTile(
          onTap: () => _playLesson(index),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : lesson.isCompleted
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isSelected
                  ? const Icon(Icons.play_arrow_rounded,
                      color: AppColors.white, size: 18)
                  : lesson.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 18)
                      : Icon(_lessonTypeIcon(lesson.type),
                          color: AppColors.textSecondary, size: 18),
            ),
          ),
          title: Text(
            lesson.title,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? AppColors.primary : AppColors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              lesson.type,
              if (lesson.durationText.isNotEmpty) lesson.durationText,
              if (lesson.progressPercent > 0 && !lesson.isCompleted)
                '${lesson.progressPercent}% complete',
              if (lesson.isCompleted) 'Completed',
            ].join(' · '),
            style: AppTextStyles.caption.copyWith(
              color: lesson.isCompleted
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
          trailing: lesson.isCompleted
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18)
              : null,
        );
      },
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectedIndex > 0
                  ? () => _playLesson(_selectedIndex - 1)
                  : null,
              icon: const Icon(Icons.skip_previous_rounded),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: BorderSide(color: AppColors.divider),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectedIndex < _lessons.length - 1
                  ? () => _playLesson(_selectedIndex + 1)
                  : null,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MediaErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.warning, size: 48),
          const SizedBox(height: 12),
          Text('Unable to play this lesson',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _TextLessonView extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onMarkComplete;
  final bool markingComplete;

  const _TextLessonView({
    required this.lesson,
    required this.onMarkComplete,
    required this.markingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final text = lesson.textContent?.trim().isNotEmpty == true
        ? lesson.textContent!.trim()
        : 'No text content has been added for this lesson yet.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lesson.description != null &&
              lesson.description!.trim().isNotEmpty)
            Text(lesson.description!,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 18),
          SelectableText(text,
              style: AppTextStyles.body.copyWith(height: 1.7)),
          const SizedBox(height: 20),
          _CompletionButton(
            completed: lesson.isCompleted,
            loading: markingComplete,
            onPressed: onMarkComplete,
          ),
        ],
      ),
    );
  }
}

class _PdfLessonView extends StatelessWidget {
  final LessonModel lesson;
  final String? filePath;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onMarkComplete;
  final bool markingComplete;
  final ValueChanged<PDFViewController> onControllerReady;

  const _PdfLessonView({
    required this.lesson,
    required this.filePath,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onMarkComplete,
    required this.markingComplete,
    required this.onControllerReady,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _DocumentError(
        lesson: lesson,
        error: error!,
        onRetry: onRetry,
        onMarkComplete: onMarkComplete,
        markingComplete: markingComplete,
      );
    }
    if (filePath == null) {
      return Container(
        color: AppColors.surface,
        child: const Center(child: AppLoader()),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ClipRect(
            child: PDFView(
              filePath: filePath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              fitPolicy: FitPolicy.BOTH,
              onViewCreated: onControllerReady,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: _CompletionButton(
                  completed: lesson.isCompleted,
                  loading: markingComplete,
                  onPressed: onMarkComplete,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'View full screen',
                icon: const Icon(Icons.fullscreen_rounded),
                color: AppColors.primary,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _PdfFullScreenPage(
                      title: lesson.title,
                      filePath: filePath!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PdfFullScreenPage extends StatelessWidget {
  final String title;
  final String filePath;

  const _PdfFullScreenPage({
    required this.title,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Exit full screen',
          icon: const Icon(
            Icons.fullscreen_exit_rounded,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTextStyles.h4,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: PDFView(
          filePath: filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          fitPolicy: FitPolicy.BOTH,
        ),
      ),
    );
  }
}

class _DocumentError extends StatelessWidget {
  final LessonModel lesson;
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onMarkComplete;
  final bool markingComplete;

  const _DocumentError({
    required this.lesson,
    required this.error,
    required this.onRetry,
    required this.onMarkComplete,
    required this.markingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.warning, size: 48),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary)),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            _CompletionButton(
              completed: lesson.isCompleted,
              loading: markingComplete,
              onPressed: onMarkComplete,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedLessonView extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onMarkComplete;
  final bool markingComplete;

  const _UnsupportedLessonView({
    required this.lesson,
    required this.onMarkComplete,
    required this.markingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            Text('This lesson uses content type: ${lesson.type}',
                textAlign: TextAlign.center,
                style: AppTextStyles.body),
            const SizedBox(height: 16),
            _CompletionButton(
              completed: lesson.isCompleted,
              loading: markingComplete,
              onPressed: onMarkComplete,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final bool completed;
  final bool loading;
  final VoidCallback onPressed;

  const _CompletionButton({
    required this.completed,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: completed || loading ? null : onPressed,
        icon: Icon(completed
            ? Icons.check_circle_rounded
            : Icons.check_rounded),
        label: Text(completed
            ? 'Lesson completed'
            : loading
                ? 'Saving…'
                : 'Mark lesson as complete'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              completed ? AppColors.success : AppColors.primary,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }
}

class _CourseLoadErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _CourseLoadErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text('Failed to load lessons', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.video_library_outlined,
              color: AppColors.textSecondary, size: 64),
          const SizedBox(height: 16),
          Text('No lessons yet', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Lessons will appear here once added.',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}