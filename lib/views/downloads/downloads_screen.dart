import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../controllers/downloads_controller.dart';
import '../common/local_video_player.dart';
import '../../core/theme/professional_theme.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _downloadController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _downloadAnimation;

  // Theme colors
  static const Color primaryColor = Color(0xFFA20136);
  static const Color secondaryColor = Color(0xFF6B0024);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _downloadController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _downloadAnimation = CurvedAnimation(
      parent: _downloadController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
    _scaleController.forward();
    _downloadController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _downloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DownloadsController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Modern header
                  _buildSliverAppBar(context),

                  // Content
                  SliverToBoxAdapter(
                    child: ctrl.isLoading
                        ? _buildLoadingState()
                        : ctrl.downloads.isEmpty
                            ? _buildEmptyState(context)
                            : _buildDownloadsList(context, ctrl),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _downloadController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                surfaceColor.withValues(alpha: 0.3),
                backgroundColor,
                primaryColor.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: DownloadPainter(_downloadAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'التنزيلات',
          style: ProfessionalTheme.getTextStyle(
            context: context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.8),
                secondaryColor.withValues(alpha: 0.6),
                backgroundColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _downloadController,
                builder: (context, child) {
                  return Container(
                    width: 80 + _downloadAnimation.value * 8,
                    height: 80 + _downloadAnimation.value * 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(
                              alpha: _downloadAnimation.value * 0.4),
                          blurRadius: 20,
                          spreadRadius: _downloadAnimation.value * 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => _openDownloadSettings(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'جارٍ التحميل...',
                style: ProfessionalTheme.getTextStyle(
                  context: context,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 500,
      margin: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _downloadController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0,
                            math.sin(_downloadAnimation.value * math.pi * 2) *
                                8),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withValues(alpha: 0.8),
                                secondaryColor.withValues(alpha: 0.6),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.download_for_offline_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'لا توجد تنزيلات بعد',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الأفلام والبرامج التي تقوم بتنزيلها\nستظهر هنا للمشاهدة بدون إنترنت',
                    textAlign: TextAlign.center,
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildGradientButton(
                    onPressed: () => Navigator.pushNamed(context, '/explore'),
                    text: 'تصفح المحتوى',
                    icon: Icons.explore,
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadsList(BuildContext context, DownloadsController ctrl) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'الملفات المحملة',
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ctrl.downloads.length} ملف',
                    style: ProfessionalTheme.getTextStyle(
                      context: context,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Downloads list
          ...ctrl.downloads.asMap().entries.map((entry) {
            final index = entry.key;
            final download = entry.value;
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _scaleController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.elasticOut,
                  ),
                ),
              ),
              child: _buildDownloadCard(context, download, ctrl),
            );
          }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(
    BuildContext context,
    dynamic download,
    DownloadsController ctrl,
  ) {
    final sizeInMB = (download.fileSize / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _playDownload(context, download),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Modern thumbnail
                    Container(
                      width: 120,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.6),
                            secondaryColor.withValues(alpha: 0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: download.thumbnail != null
                                ? CachedNetworkImage(
                                    imageUrl: download.thumbnail,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withValues(alpha: 0.6),
                                            secondaryColor.withValues(
                                                alpha: 0.4),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        _buildThumbnailPlaceholder(),
                                  )
                                : _buildThumbnailPlaceholder(),
                          ),
                          // Play icon overlay with animation
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _downloadController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + _downloadAnimation.value * 0.1,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(
                                                alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            download.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ProfessionalTheme.getTextStyle(
                              context: context,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Info chips
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.folder,
                                text: '$sizeInMB MB',
                                context: context,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.hd,
                                text: download.quality ?? 'HD',
                                context: context,
                              ),
                            ],
                          ),

                          if (download.downloadedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'تم التحميل ${_formatDate(download.downloadedAt)}',
                              style: ProfessionalTheme.getTextStyle(
                                context: context,
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Modern actions menu
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        color: surfaceColor.withValues(alpha: 0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'play':
                              _playDownload(context, download);
                              break;
                            case 'delete':
                              _showDeleteDialog(context, download, ctrl);
                              break;
                            case 'info':
                              _showDownloadInfo(context, download);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'play',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow, color: primaryColor),
                                const SizedBox(width: 12),
                                Text(
                                  'تشغيل',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'info',
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.blue),
                                const SizedBox(width: 12),
                                Text(
                                  'معلومات',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red),
                                const SizedBox(width: 12),
                                Text(
                                  'حذف',
                                  style: ProfessionalTheme.getTextStyle(
                                    context: context,
                                    fontSize: 14,
                                    color: Colors.red,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.6),
            secondaryColor.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: const Icon(
        Icons.movie,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: ProfessionalTheme.getTextStyle(
              context: context,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.8),
            secondaryColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: ProfessionalTheme.getTextStyle(
                    context: context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    }
  }

  void _playDownload(BuildContext context, dynamic download) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocalVideoPlayer(
          filePath: download.path,
          title: download.title,
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    dynamic download,
    DownloadsController ctrl,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Delete Download',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${download.title}"?',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ctrl.deleteDownload(download);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${download.title} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDownloadInfo(BuildContext context, dynamic download) {
    final sizeInMB = (download.fileSize / (1024 * 1024)).toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              download.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('File Size', '$sizeInMB MB'),
            _buildInfoRow('Quality', download.quality ?? 'HD'),
            _buildInfoRow('Duration', download.duration ?? 'Unknown'),
            _buildInfoRow('Path', download.path),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _playDownload(context, download);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _openDownloadSettings(BuildContext context) {
    Navigator.pushNamed(context, '/download-settings');
  }
}

class DownloadPainter extends CustomPainter {
  final double animationValue;

  DownloadPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA20136).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw animated download indicators
    for (int i = 0; i < 12; i++) {
      final x = (size.width * (i * 0.2 + 0.1)) +
          math.sin(animationValue * math.pi * 2 + i * 0.8) * 25;
      final y = (size.height * (i * 0.1 + 0.2)) +
          math.cos(animationValue * math.pi * 2 + i * 0.6) * 20;

      // Main download dot
      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * math.pi * 3 + i) * 1,
        paint,
      );

      // Download arrow effect
      if (i % 4 == 0) {
        final arrowPaint = Paint()
          ..color = const Color(0xFFA20136).withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        final arrowPath = Path();
        final arrowSize = 8 + math.sin(animationValue * math.pi * 2 + i) * 2;

        arrowPath.moveTo(x - arrowSize / 2, y - arrowSize);
        arrowPath.lineTo(x, y);
        arrowPath.lineTo(x + arrowSize / 2, y - arrowSize);

        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Draw progress bars
    final progressPaint = Paint()
      ..color = const Color(0xFFA20136).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int bar = 0; bar < 4; bar++) {
      final barY = size.height * (0.2 + bar * 0.2);
      final progress = (animationValue + bar * 0.25) % 1.0;

      canvas.drawLine(
        Offset(size.width * 0.1, barY),
        Offset(size.width * (0.1 + progress * 0.8), barY),
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
