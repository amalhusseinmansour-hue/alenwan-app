import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_service.dart';
import '../../config.dart';

class EnhancedMovieDetailsPage extends StatefulWidget {
  final int movieId;

  const EnhancedMovieDetailsPage({super.key, required this.movieId});

  @override
  State<EnhancedMovieDetailsPage> createState() => _EnhancedMovieDetailsPageState();
}

class _EnhancedMovieDetailsPageState extends State<EnhancedMovieDetailsPage> {
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await ApiService.getToken();
      final details = await ApiService.getMovieDetails(widget.movieId, token: token);

      if (details != null) {
        setState(() {
          _movieDetails = details;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'فشل في تحميل التفاصيل';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovieDetails,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                          const SizedBox(height: 30),
                          _buildDetailsSection(),
                          const SizedBox(height: 30),
                          _buildRelatedMovies(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppBar() {
    final backdrop = _getImageUrl(_movieDetails?['poster'] ?? _movieDetails?['thumbnail']);

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: backdrop,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.movie, size: 64, color: Colors.white54),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF121212).withValues(alpha: 0.7),
                    const Color(0xFF121212),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final title = _getTitle();
    final rating = _movieDetails?['rating']?.toString() ?? 'N/A';
    final year = _movieDetails?['release_year']?.toString() ?? '';
    final duration = _movieDetails?['duration']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 20),
              if (year.isNotEmpty) ...[
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  year,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
              if (duration.isNotEmpty) ...[
                const SizedBox(width: 20),
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$duration دقيقة',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final commentsCount = _movieDetails?['comments_count'] ?? 0;
    final isFavorited = _movieDetails?['is_favorited'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Play movie
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('تشغيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              // Toggle favorite
            },
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              // Show comments
            },
            icon: Badge(
              label: Text('$commentsCount'),
              child: const Icon(Icons.comment, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final description = _getDescription();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMovies() {
    final relatedMovies = _movieDetails?['related_movies'] as List<dynamic>?;

    if (relatedMovies == null || relatedMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'أفلام مشابهة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: relatedMovies.length,
            itemBuilder: (context, index) {
              final movie = relatedMovies[index];
              return _buildRelatedMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedMovieCard(Map<String, dynamic> movie) {
    final thumbnail = _getImageUrl(movie['thumbnail']);
    final title = _getMovieTitle(movie);

    return GestureDetector(
      onTap: () {
        // Navigate to movie details
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EnhancedMovieDetailsPage(movieId: movie['id']),
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: thumbnail,
                width: 130,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConfig.storageBaseUrl}/$path';
  }

  String _getTitle() {
    final title = _movieDetails?['title'];
    if (title is Map) {
      return title['ar'] ?? title['en'] ?? 'بدون عنوان';
    }
    return title?.toString() ?? 'بدون عنوان';
  }

  String _getMovieTitle(Map<String, dynamic> movie) {
    final title = movie['title'];
    if (title is Map) {
      return title['ar'] ?? title['en'] ?? 'بدون عنوان';
    }
    return title?.toString() ?? 'بدون عنوان';
  }

  String _getDescription() {
    final description = _movieDetails?['description'];
    if (description is Map) {
      return description['ar'] ?? description['en'] ?? 'لا يوجد وصف';
    }
    return description?.toString() ?? 'لا يوجد وصف';
  }
}
