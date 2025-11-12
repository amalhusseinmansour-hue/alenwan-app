// lib/views/live/live_stream_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:alenwan/models/live_stream_model.dart';
import 'package:alenwan/models/comment_live.dart';
import 'package:alenwan/core/theme/professional_theme.dart';
import 'package:alenwan/core/services/comment_service.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class LiveStreamScreen extends StatefulWidget {
  final LiveStreamModel stream;

  const LiveStreamScreen({super.key, required this.stream});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLive = false;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<LiveComment> comments = [];
  bool _isLoadingComments = false;
  bool _isPostingComment = false;
  CommentService? _commentService;

  String? extractYoutubeId(String url) {
    try {
      final cleanUrl = url.split('?').first.trim();

      final id = YoutubePlayerController.convertUrlToId(cleanUrl);
      if (id != null && id.length == 11) {
        return id;
      }

      final uri = Uri.parse(cleanUrl);

      if ((uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) &&
          uri.pathSegments.isNotEmpty) {
        final idx = uri.pathSegments.indexOf('live');
        if (idx >= 0 && idx < uri.pathSegments.length - 1) {
          final candidate = uri.pathSegments[idx + 1];
          if (RegExp(r'^[_\-a-zA-Z0-9]{11}$').hasMatch(candidate)) {
            return candidate;
          }
        }

        if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
          final candidate = uri.pathSegments.last;
          if (RegExp(r'^[_\-a-zA-Z0-9]{11}$').hasMatch(candidate)) {
            return candidate;
          }
        }
      }

      final parts = cleanUrl.split('v=');
      if (parts.length > 1) {
        final afterV = parts[1];
        final candidate = afterV.split(RegExp(r'[^0-9A-Za-z_\-]')).first;
        if (RegExp(r'^[_\-a-zA-Z0-9]{11}$').hasMatch(candidate)) {
          return candidate;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Check if stream is live based on startsAt
    final now = DateTime.now();
    if (widget.stream.startsAt.isEmpty) {
      _isLive = true;
    } else {
      final startsAt = DateTime.tryParse(widget.stream.startsAt);
      _isLive = startsAt == null || !startsAt.isAfter(now);
    }
    _initializePlayer();

    // Initialize comment service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        _commentService = CommentService(apiClient.dio);
        _loadComments();
      }
    });
  }

  void _initializePlayer() {
    final url = widget.stream.videoUrl ?? widget.stream.streamUrl ?? '';

    print('🎥 Initializing player for URL: $url');
    print('🎥 Stream type: ${widget.stream.sourceType}');
    print('🎥 Platform: ${widget.stream.sourceType}');

    // Check if URL is empty
    if (url.isEmpty) {
      print('❌ No video URL provided for livestream');
      return;
    }

    // 🔧 تحسين: التعامل مع YouTube و Vimeo
    if (url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        widget.stream.sourceType.toLowerCase() == 'youtube') {
      final videoId = extractYoutubeId(url);
      print('🔍 Extracted YouTube ID: $videoId');

      if (videoId != null) {
        _ytController = YoutubePlayerController(
          params: YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
            enableCaption: true,
            enableJavaScript: true,
            playsInline: false,
            loop: false,
            strictRelatedVideos: true,
          ),
        );
        _ytController!.loadVideoById(videoId: videoId);
        print('✅ YouTube player initialized with ID: $videoId');
      } else {
        print('❌ Failed to extract YouTube ID from URL: $url');
      }
    }
    // 🔧 دعم Vimeo
    else if (url.contains('vimeo.com') ||
             widget.stream.sourceType.toLowerCase() == 'vimeo') {
      print('🎬 Vimeo stream detected, using web view or direct URL');
      // For Vimeo, we might need to use WebView or extract the direct stream URL
      // For now, try to use as direct stream
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            aspectRatio: 16 / 9,
            allowFullScreen: true,
            allowMuting: true,
            showControls: true,
            placeholder: Container(color: ProfessionalTheme.backgroundColor),
            materialProgressColors: ChewieProgressColors(
              playedColor: ProfessionalTheme.primaryBrand,
              handleColor: ProfessionalTheme.primaryBrand,
              backgroundColor: Colors.grey,
              bufferedColor: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            ),
          );
        }).catchError((error) {
          print('❌ Error initializing Vimeo player: $error');
        });
    }
    // 🔧 البثوث المباشرة بصيغ أخرى
    else if (url.endsWith('.m3u8') || url.endsWith('.mp4') || url.startsWith('rtmp://')) {
      print('🎬 Initializing video player for direct stream');

      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            aspectRatio: 16 / 9,
            allowFullScreen: true,
            allowMuting: true,
            showControls: true,
            placeholder: Container(color: ProfessionalTheme.backgroundColor),
            materialProgressColors: ChewieProgressColors(
              playedColor: ProfessionalTheme.primaryBrand,
              handleColor: ProfessionalTheme.primaryBrand,
              backgroundColor: Colors.grey,
              bufferedColor: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            ),
          );
        }).catchError((error) {
          print('❌ Error initializing video player: $error');
        });
    } else {
      print('⚠️ Unknown stream format, attempting as direct URL');
      // Try as direct URL anyway
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            aspectRatio: 16 / 9,
            allowFullScreen: true,
            allowMuting: true,
            showControls: true,
            placeholder: Container(color: ProfessionalTheme.backgroundColor),
            materialProgressColors: ChewieProgressColors(
              playedColor: ProfessionalTheme.primaryBrand,
              handleColor: ProfessionalTheme.primaryBrand,
              backgroundColor: Colors.grey,
              bufferedColor: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            ),
          );
        }).catchError((error) {
          print('❌ Error initializing player: $error');
        });
    }
  }

  void _loadComments() async {
    if (_commentService == null) return;

    setState(() => _isLoadingComments = true);

    try {
      // Load comments for this livestream
      final loadedComments = await _commentService!.fetchComments(
        commentableType: 'App\\Models\\LiveStream',
        commentableId: widget.stream.id,
        perPage: 50,
      );

      if (mounted) {
        setState(() {
          comments = loadedComments;
          _isLoadingComments = false;
        });
      }

      print('✅ Loaded ${comments.length} comments for livestream #${widget.stream.id}');
    } catch (e) {
      print('❌ Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoadingComments = false);

        // Show sample comments as fallback
        setState(() {
          comments = [
            LiveComment(
              id: 1,
              userName: 'مستخدم تجريبي',
              text: 'مرحباً بالجميع! 👋',
              createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ];
        });
      }
    }
  }

  void _sendComment() async {
    if (_commentService == null) return;

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يجب تسجيل الدخول أولاً للتعليق'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'تسجيل الدخول',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
            ),
          ),
        );
      }
      return;
    }

    if (_commentController.text.trim().isEmpty) return;
    if (_isPostingComment) return; // Prevent double posting

    final commentText = _commentController.text.trim();
    _commentController.clear();

    setState(() => _isPostingComment = true);

    try {
      // Post comment to API
      final newComment = await _commentService!.postComment(
        commentableType: 'App\\Models\\LiveStream',
        commentableId: widget.stream.id,
        content: commentText,
      );

      if (mounted) {
        setState(() {
          comments.add(newComment);
          _isPostingComment = false;
        });

        print('✅ Comment posted successfully');

        // Scroll to bottom to show new comment
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error posting comment: $e');
      if (mounted) {
        setState(() => _isPostingComment = false);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال التعليق. يرجى المحاولة مرة أخرى.'),
            backgroundColor: Colors.red,
          ),
        );

        // Restore the comment text
        _commentController.text = commentText;
      }
    }
  }

  Widget _buildPlayer() {
    if (_ytController != null) {
      return YoutubePlayer(controller: _ytController!);
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    // Check if URL is empty or invalid
    final url = widget.stream.videoUrl ?? widget.stream.streamUrl ?? '';
    if (url.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'لا يوجد رابط فيديو',
                style: ProfessionalTheme.bodyLarge(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إضافة رابط الفيديو من لوحة التحكم',
                style: ProfessionalTheme.bodySmall(
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Loading state
    return Center(
      child: CircularProgressIndicator(
        color: ProfessionalTheme.primaryBrand,
      ),
    );
  }

  @override
  void dispose() {
    _ytController?.close();
    _videoController?.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: ProfessionalTheme.surfaceCard,
        elevation: 2,
        shadowColor: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ProfessionalTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            if (_isLive) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade600,
                      Colors.red.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مباشر',
                      style: ProfessionalTheme.labelMedium(
                        color: Colors.white,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.stream.getTitle(context.locale.languageCode),
                style: ProfessionalTheme.titleLarge(
                  color: ProfessionalTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: ProfessionalTheme.textPrimary,
            ),
            onPressed: () {
              // Share functionality
            },
          ),
          IconButton(
            icon: Icon(
              Icons.fullscreen,
              color: ProfessionalTheme.textPrimary,
            ),
            onPressed: () {
              // Fullscreen functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Video Player Section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPlayer(),
              ),
            ),
          ),

          // Stream Info with enhanced design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ProfessionalTheme.surfaceCard,
                  ProfessionalTheme.surfaceCard.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stream.getTitle(context.locale.languageCode),
                            style: ProfessionalTheme.headlineSmall(
                              color: ProfessionalTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.stream.getDescription(context.locale.languageCode),
                            style: ProfessionalTheme.bodySmall(
                              color: ProfessionalTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.stream.viewersCount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalTheme.primaryBrand.withValues(alpha: 0.15),
                              ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 14,
                                color: ProfessionalTheme.primaryBrand,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.stream.viewersCount}',
                              style: ProfessionalTheme.labelMedium(
                                color: ProfessionalTheme.primaryBrand,
                                weight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'مشاهد',
                              style: ProfessionalTheme.labelSmall(
                                color: ProfessionalTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Comments Section with enhanced design
          Container(
            height: 400, // Fixed height to replace Expanded
            margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalTheme.surfaceCard,
                          ProfessionalTheme.surfaceCard.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: ProfessionalTheme.primaryBrand,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'التعليقات المباشرة',
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${comments.length}',
                            style: ProfessionalTheme.labelMedium(
                              color: ProfessionalTheme.primaryBrand,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: comments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: ProfessionalTheme.textTertiary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'كن أول من يعلق',
                                style: ProfessionalTheme.bodyLarge(
                                  color: ProfessionalTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ProfessionalTheme.backgroundColor,
                                    ProfessionalTheme.backgroundColor.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: ProfessionalTheme.premiumGradient,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            comment.userName[0].toUpperCase(),
                                            style: ProfessionalTheme.labelMedium(
                                              color: Colors.white,
                                              weight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      comment.userName,
                                      style: ProfessionalTheme.titleSmall(
                                        color: ProfessionalTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(comment.createdAt),
                                    style: ProfessionalTheme.labelSmall(
                                      color: ProfessionalTheme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment.text,
                                style: ProfessionalTheme.bodyMedium(
                                  color: ProfessionalTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalTheme.surfaceCard,
                          ProfessionalTheme.surfaceCard.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: ProfessionalTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _commentController,
                              style: ProfessionalTheme.bodyMedium(
                                color: ProfessionalTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'اكتب تعليقاً...',
                                hintStyle: ProfessionalTheme.bodyMedium(
                                  color: ProfessionalTheme.textTertiary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: ProfessionalTheme.textTertiary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: ProfessionalTheme.premiumGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _sendComment,
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}