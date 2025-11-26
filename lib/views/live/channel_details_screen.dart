import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:alenwan/models/channel_model.dart';
import 'package:alenwan/models/live_stream_model.dart';
import 'package:alenwan/controllers/live_controller.dart';
import 'package:alenwan/core/services/api_client.dart';
import 'package:alenwan/routes/app_routes.dart';
import 'package:alenwan/core/theme/professional_theme.dart';

class ChannelDetailsScreen extends StatefulWidget {
  final ChannelModel channel;
  const ChannelDetailsScreen({super.key, required this.channel});

  @override
  State<ChannelDetailsScreen> createState() => _ChannelDetailsScreenState();
}

class _ChannelDetailsScreenState extends State<ChannelDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  DateTime? _safeParse(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String s) {
    final dt = _safeParse(s);
    if (dt == null) return '';
    return DateFormat('dd/MM • HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final liveC = context.watch<LiveController>();
    final streams = liveC.availableStreams
        .where((s) => s.channelId == widget.channel.id)
        .toList();

    final now = DateTime.now();
    final liveNow = streams.where((s) {
      final start = _safeParse(s.startsAt);
      if (start == null) return true;
      return !start.isAfter(now);
    }).toList();

    final comingSoon = streams.where((s) {
      final start = _safeParse(s.startsAt);
      if (start == null) return false;
      return start.isAfter(now);
    }).toList();

    final ended = streams.where((s) {
      final start = _safeParse(s.startsAt);
      if (start == null) return false;
      return start.isBefore(now.subtract(const Duration(hours: 1)));
    }).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
            _buildTabBar(),
          ],
          body: TabBarView(
            children: [
              _buildStreamList(context, liveNow),
              _buildStreamList(context, comingSoon, showDate: true),
              _buildStreamList(context, ended, showDate: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: ProfessionalTheme.backgroundPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.channel.name,
          style: const TextStyle(
            color: ProfessionalTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Channel background
            Container(
              decoration: BoxDecoration(
                gradient: ProfessionalTheme.darkGradient,
              ),
            ),

            // Glass morphism overlay
            Container(
              decoration: ProfessionalTheme.glassMorphism,
            ),

            // Channel info overlay
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
                      ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: ProfessionalTheme.primaryBrand,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.live_tv,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.channel.name,
                                    style: const TextStyle(
                                      color: ProfessionalTheme.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'قناة مباشرة',
                                    style: TextStyle(
                                      color: ProfessionalTheme.textSecondary,
                                      fontSize: 14,
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
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProfessionalTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: ProfessionalTheme.backgroundSecondary,
          border: Border(
            bottom: BorderSide(
              color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: const TabBar(
          indicatorColor: ProfessionalTheme.primaryBrand,
          indicatorWeight: 3,
          labelColor: ProfessionalTheme.primaryBrand,
          unselectedLabelColor: ProfessionalTheme.textSecondary,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'مباشر'),
            Tab(text: 'يعرض قريباً'),
            Tab(text: 'المنتهية'),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamList(
    BuildContext context,
    List<LiveStreamModel> streams, {
    bool showDate = false,
  }) {
    if (streams.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: streams.length,
      itemBuilder: (context, i) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = i * 0.1;
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(delay, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: _buildStreamCard(streams[i], showDate),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreamCard(LiveStreamModel stream, bool showDate) {
    final img = stream.thumbnail.startsWith('http')
        ? stream.thumbnail
        : '${ApiClient().filesBaseUrl}/${stream.thumbnail}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
            ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                Navigator.pushNamed(
                  context,
                  AppRoutes.liveStreamDetails,
                  arguments: stream,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 120,
                        height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildShimmerLoader(120, 80),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: ProfessionalTheme.premiumGradient,
                                ),
                                child: const Icon(
                                  Icons.live_tv,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            // Play overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stream.getTitle(context.locale.languageCode),
                            style: const TextStyle(
                              color: ProfessionalTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          if (showDate) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDate(stream.startsAt),
                                style: const TextStyle(
                                  color: ProfessionalTheme.primaryBrand,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: ProfessionalTheme.accentRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'مباشر الآن',
                                  style: TextStyle(
                                    color: ProfessionalTheme.accentRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 8),

                          const Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: ProfessionalTheme.textSecondary,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'مشاهدة',
                                style: TextStyle(
                                  color: ProfessionalTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: ProfessionalTheme.primaryBrand,
                        size: 16,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.tv_off,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا يوجد محتوى',
            style: TextStyle(
              color: ProfessionalTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لا توجد بث مباشر متاح حالياً',
            style: TextStyle(
              color: ProfessionalTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
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
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: const [
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
}