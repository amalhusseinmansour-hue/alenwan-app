import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import 'dart:ui';

import '../../core/theme/professional_theme.dart';
import '../../controllers/detail_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../models/media_item.dart';
import '../common/subscription_required_widget.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const DetailScreen({
    super.key,
    required this.mediaItem,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late DetailController _detailController;
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // تأخير قصير لتأثير الانتقال
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تهيئة المتحكم
    _detailController = DetailController(mediaItem: widget.mediaItem);

    // التحقق من الاشتراك قبل تحميل التفاصيل
    final subscriptionController =
        Provider.of<SubscriptionController>(context, listen: false);
    _detailController
        .checkSubscriptionAccess(subscriptionController)
        .then((hasAccess) {
      if (hasAccess) {
        _detailController.loadDetails();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: ChangeNotifierProvider.value(
        value: _detailController,
        child: Consumer<DetailController>(
          builder: (context, controller, child) {
            final mediaItem = controller.mediaItem;

            return Scaffold(
              backgroundColor: ProfessionalTheme.backgroundPrimary,
              extendBodyBehindAppBar: true,
              appBar: _buildAppBar(),
              body: AnimatedOpacity(
                opacity: _isLoading ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: _buildContent(context, controller, mediaItem),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ProfessionalTheme.surfaceCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProfessionalTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: ProfessionalTheme.textPrimary),
            onPressed: () {
              _showProfessionalSnackBar('تم نسخ الرابط للحافظة');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, DetailController controller, MediaItem mediaItem) {
    // إذا كان جاري التحقق من الاشتراك
    if (controller.isCheckingSubscription) {
      return _buildLoadingState();
    }

    // إذا لم يكن لدى المستخدم اشتراك نشط
    if (!controller.hasSubscriptionAccess) {
      return SubscriptionRequiredWidget(
        message: 'premium_content_subscription_required'.tr(),
      );
    }

    // إذا كان هناك خطأ
    if (controller.error != null) {
      return _buildErrorState(controller);
    }

    // عرض المحتوى للمستخدمين المشتركين
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الغلاف الكبيرة
              _buildBackdropImage(mediaItem),

              // معلومات الفيلم/المسلسل
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    _buildTitle(mediaItem),

                    const SizedBox(height: 12),

                    // معلومات إضافية (التقييم، السنة، إلخ)
                    _buildInfoRow(mediaItem),

                    const SizedBox(height: 20),

                    // الوصف
                    if (mediaItem.description != null)
                      _buildDescription(mediaItem),

                    const SizedBox(height: 24),

                    // أزرار الإجراءات
                    _buildActionButtons(),

                    const SizedBox(height: 24),

                    // قسم الحلقات (للمسلسلات فقط)
                    if (mediaItem.type == MediaType.series)
                      _buildEpisodesSection(context, controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ProfessionalTheme.surfaceCard.withOpacity(0.8),
              ProfessionalTheme.surfaceCard.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: ProfessionalTheme.primaryBrand,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    color: ProfessionalTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(DetailController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ProfessionalTheme.surfaceCard.withOpacity(0.8),
              ProfessionalTheme.surfaceCard.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfessionalTheme.errorColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.errorColor,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalTheme.errorColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    color: ProfessionalTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.error!,
                  style: TextStyle(
                    color: ProfessionalTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: ProfessionalTheme.premiumGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => controller.loadDetails(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'try_again'.tr(),
                      style: const TextStyle(
                        color: ProfessionalTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء صورة الغلاف الكبيرة
  Widget _buildBackdropImage(MediaItem mediaItem) {
    final String backdropUrl =
        mediaItem.backdropUrl ?? mediaItem.posterUrl ?? '';

    return Stack(
      children: [
        // صورة الغلاف
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(300),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: ProfessionalTheme.darkGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: ProfessionalTheme.textPrimary,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
        ),

        // تدرج لتحسين قراءة النص
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                ProfessionalTheme.backgroundPrimary.withOpacity(0.9),
              ],
              stops: const [0.3, 1.0],
            ),
          ),
        ),

        // شارة التقييم
        if (mediaItem.rating != null)
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfessionalTheme.surfaceCard.withOpacity(0.9),
                    ProfessionalTheme.surfaceCard.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ProfessionalTheme.accentGold.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ProfessionalTheme.accentGold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: ProfessionalTheme.accentGold,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mediaItem.rating!.toString(),
                        style: const TextStyle(
                          color: ProfessionalTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(MediaItem mediaItem) {
    return Text(
      mediaItem.title,
      style: const TextStyle(
        color: ProfessionalTheme.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }

  // بناء صف المعلومات (السنة، التصنيف، إلخ)
  Widget _buildInfoRow(MediaItem mediaItem) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // السنة
        if (mediaItem.year != null)
          _buildInfoChip(Icons.calendar_today, mediaItem.year.toString(), ProfessionalTheme.accentBlue),

        // التصنيف
        if (mediaItem.type == MediaType.movie)
          _buildInfoChip(Icons.movie, 'movies'.tr(), ProfessionalTheme.accentCyan),
        if (mediaItem.type == MediaType.series)
          _buildInfoChip(Icons.tv, 'series'.tr(), ProfessionalTheme.accentPink),

        // التصنيفات
        if (mediaItem.genres != null && mediaItem.genres!.isNotEmpty)
          _buildInfoChip(Icons.category, mediaItem.genres!.first, ProfessionalTheme.primaryBrand),
      ],
    );
  }

  // بناء رقاقة معلومات
  Widget _buildInfoChip(IconData icon, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: ProfessionalTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(MediaItem mediaItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalTheme.surfaceCard.withOpacity(0.6),
            ProfessionalTheme.surfaceCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Text(
            mediaItem.description!,
            style: TextStyle(
              color: ProfessionalTheme.textPrimary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  // بناء أزرار الإجراءات
  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر المشاهدة
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                _showProfessionalSnackBar('جاري تشغيل المحتوى...');
              },
              icon: const Icon(Icons.play_arrow, color: ProfessionalTheme.textPrimary),
              label: Text(
                'play'.tr(),
                style: const TextStyle(
                  color: ProfessionalTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // زر التنزيل
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfessionalTheme.surfaceCard.withOpacity(0.8),
                  ProfessionalTheme.surfaceCard.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showProfessionalSnackBar('جاري تحضير التنزيل...');
                  },
                  icon: Icon(
                    Icons.download,
                    color: ProfessionalTheme.primaryBrand,
                  ),
                  label: Text(
                    'download'.tr(),
                    style: TextStyle(
                      color: ProfessionalTheme.primaryBrand,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // بناء قسم الحلقات (للمسلسلات فقط)
  Widget _buildEpisodesSection(
      BuildContext context, DetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          'episodes'.tr(),
          style: const TextStyle(
            color: ProfessionalTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // قائمة الحلقات
        if (controller.isLoadingEpisodes)
          _buildLoadingEpisodes()
        else if (controller.episodes.isEmpty)
          _buildEmptyEpisodes()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.episodes.length,
            itemBuilder: (context, index) {
              final episode = controller.episodes[index];
              return _buildEpisodeItem(context, episode, index);
            },
          ),
      ],
    );
  }

  Widget _buildLoadingEpisodes() {
    return Column(
      children: List.generate(3, (index) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildShimmerLoader(double.infinity, 120),
        ),
      ),
    );
  }

  Widget _buildEmptyEpisodes() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ProfessionalTheme.surfaceCard.withOpacity(0.6),
              ProfessionalTheme.surfaceCard.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.tv_off,
              color: ProfessionalTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'no_episodes'.tr(),
              style: TextStyle(
                color: ProfessionalTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر الحلقة
  Widget _buildEpisodeItem(
      BuildContext context, Map<String, dynamic> episode, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalTheme.surfaceCard.withOpacity(0.8),
            ProfessionalTheme.surfaceCard.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showProfessionalSnackBar('جاري تشغيل الحلقة ${index + 1}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // صورة الحلقة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 120,
                        height: 80,
                        child: episode['thumbnailUrl'] != null
                            ? CachedNetworkImage(
                                imageUrl: episode['thumbnailUrl'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _buildShimmerLoader(120, 80),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    gradient: ProfessionalTheme.premiumGradient,
                                  ),
                                  child: const Icon(
                                    Icons.tv,
                                    color: ProfessionalTheme.textPrimary,
                                    size: 32,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: ProfessionalTheme.premiumGradient,
                                ),
                                child: const Icon(
                                  Icons.tv,
                                  color: ProfessionalTheme.textPrimary,
                                  size: 32,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // معلومات الحلقة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode['title'] ?? '${'episode'.tr()} ${index + 1}',
                            style: const TextStyle(
                              color: ProfessionalTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (episode['description'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              episode['description'],
                              style: TextStyle(
                                color: ProfessionalTheme.textSecondary,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // زر التشغيل
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: ProfessionalTheme.premiumGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: ProfessionalTheme.textPrimary,
                        ),
                        onPressed: () {
                          _showProfessionalSnackBar('جاري تشغيل الحلقة ${index + 1}');
                        },
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

  Widget _buildImagePlaceholder(double height) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                ProfessionalTheme.surfaceCard,
                ProfessionalTheme.surfaceHover,
                ProfessionalTheme.surfaceCard,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoader(double width, double height) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                ProfessionalTheme.surfaceCard,
                ProfessionalTheme.surfaceHover,
                ProfessionalTheme.surfaceCard,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  void _showProfessionalSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: ProfessionalTheme.textPrimary),
        ),
        backgroundColor: ProfessionalTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}