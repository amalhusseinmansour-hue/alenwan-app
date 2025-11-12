import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import '../../controllers/live_controller.dart';
import '../../models/live_stream_model.dart';
import 'live_stream_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'رياضة',
    'أخبار',
    'ترفيه',
    'أطفال',
    'وثائقي',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    // تحميل البث المباشر من API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveController>().loadStreams();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<LiveController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA20136),
                  ),
                );
              }

              if (controller.error != null) {
                return _buildErrorView(controller.error!);
              }

              final streams = _getFilteredStreams(controller.availableStreams);

              if (streams.isEmpty) {
                return _buildEmptyView();
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.black,
                      title: const Text(
                        'البث المباشر',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      centerTitle: true,
                    ),

                    // Categories
                    SliverToBoxAdapter(
                      child: _buildCategories(),
                    ),

                    // Live Streams Grid
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildStreamCard(streams[index]),
                          childCount: streams.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<LiveStreamModel> _getFilteredStreams(List<LiveStreamModel> allStreams) {
    if (_selectedCategory == 'الكل') {
      return allStreams;
    }

    return allStreams.where((stream) {
      final category = stream.category?.toLowerCase() ?? '';
      final selectedLower = _selectedCategory.toLowerCase();

      return category.contains(selectedLower) ||
          category.contains(_getCategoryEnglish(_selectedCategory));
    }).toList();
  }

  String _getCategoryEnglish(String arabicCategory) {
    final map = {
      'رياضة': 'sport',
      'أخبار': 'news',
      'ترفيه': 'entertainment',
      'أطفال': 'kids',
      'وثائقي': 'documentary',
    };
    return map[arabicCategory] ?? arabicCategory;
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFA20136), Color(0xFF6B0024)],
                      )
                    : null,
                color: isSelected ? null : Colors.grey[900],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreamCard(LiveStreamModel stream) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveStreamScreen(stream: stream),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with LIVE badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: stream.thumbnail ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFA20136),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.live_tv, color: Colors.white54),
                      ),
                    ),
                  ),
                  // LIVE Badge
                  if (stream.isLiveNow ?? false)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'مباشر',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Viewers count
                  if (stream.concurrentViewers != null &&
                      stream.concurrentViewers! > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              _formatViewers(stream.concurrentViewers!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Stream info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (stream.category != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      stream.category!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViewers(int viewers) {
    if (viewers >= 1000000) {
      return '${(viewers / 1000000).toStringAsFixed(1)}M';
    } else if (viewers >= 1000) {
      return '${(viewers / 1000).toStringAsFixed(1)}K';
    }
    return viewers.toString();
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<LiveController>().loadStreams();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA20136),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv, color: Colors.grey[600], size: 80),
          const SizedBox(height: 16),
          Text(
            'لا توجد بثوث مباشرة حالياً',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<LiveController>().loadStreams();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA20136),
            ),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}
