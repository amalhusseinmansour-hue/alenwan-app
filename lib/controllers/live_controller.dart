import 'dart:async';
import 'package:alenwan/models/live_stream_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:alenwan/models/comment_live.dart';
import 'package:alenwan/core/services/live_stream_service.dart';

class LiveController extends ChangeNotifier {
  final LiveStreamService _service = LiveStreamService();

  bool _isLoading = false;
  String? _error;
  LiveStreamModel? _currentStream;
  List<LiveStreamModel> _availableStreams = [];
  List<LiveComment> _comments = [];

  Timer? _commentsTimer;
  Timer? _viewersTimer;

  bool get isLoading => _isLoading;
  String? get error => _error;
  LiveStreamModel? get currentStream => _currentStream;
  List<LiveStreamModel> get availableStreams => _availableStreams;
  List<LiveComment> get comments => _comments;

  // تحميل جميع البثوث
  Future<void> loadStreams() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final streams = await _service.fetchLiveStreams();

      _availableStreams = streams;

      if (_availableStreams.isEmpty) {
        _currentStream = null;
        _error = 'no_streams_available'.tr();
      } else {
        // البحث عن أول بث صالح (streamUrl أو videoUrl موجود)
        final firstValidStream = _availableStreams.firstWhere(
          (s) => (s.streamUrl.isNotEmpty || (s.videoUrl?.isNotEmpty ?? false)),
          orElse: () => _availableStreams.first, // اعرض أول عنصر حتى لو فاضي
        );

        // إذا لا يوجد أي بث صالح نعرض خطأ
        if (firstValidStream.streamUrl.isEmpty &&
            (firstValidStream.videoUrl?.isEmpty ?? true)) {
          _currentStream = null;
          _error = 'no_streams_available'.tr();
        } else {
          setCurrentStream(firstValidStream);
          startViewersCounter();
          startCommentsPolling();
        }
      }
    } catch (e) {
      _availableStreams = [];
      _currentStream = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentStream(LiveStreamModel stream) {
    _currentStream = stream;
    notifyListeners();
  }

  // عداد المشاهدين
  void startViewersCounter() {
    _viewersTimer?.cancel();
    _viewersTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_currentStream != null) {
        try {
          final updated = await _service.fetchStreamDetails(_currentStream!.id);
          _currentStream = updated;
          notifyListeners();
        } catch (e) {
          _error = e.toString();
          notifyListeners();
        }
      }
    });
  }

  // تحديث التعليقات بشكل دوري
  void startCommentsPolling() {
    _commentsTimer?.cancel();
    _commentsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchComments();
    });
  }

  Future<void> fetchComments() async {
    if (_currentStream == null) return;
    try {
      final fetched = await _service.fetchComments(_currentStream!.id);
      if (!listEquals(fetched, _comments)) {
        _comments = fetched;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error fetching comments: $e';
      notifyListeners();
    }
  }

  Future<void> postComment(String text) async {
    if (_currentStream == null || text.isEmpty) return;
    try {
      await _service.postComment(_currentStream!.id, text);
      await fetchComments();
    } catch (e) {
      _error = 'Error posting comment: $e';
      notifyListeners();
    }
  }

  Future<void> sendReaction(String type) async {
    if (_currentStream == null) return;
    try {
      await _service.sendReaction(_currentStream!.id, type);
    } catch (e) {
      _error = 'Error sending reaction: $e';
      notifyListeners();
    }
  }

  void clearStreams() {
    _availableStreams = [];
    _currentStream = null;
    _comments = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _commentsTimer?.cancel();
    _viewersTimer?.cancel();
    super.dispose();
  }
}
