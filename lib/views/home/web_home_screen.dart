import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/movie_controller.dart';
import '../../controllers/series_controller.dart';
import '../../controllers/sport_controller.dart';
import '../../controllers/cartoon_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/movie_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_app_bar.dart';
import 'app_drawer.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  int _currentHeroIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      context.read<MovieController>().loadMovies(reset: true);
      context.read<SeriesController>().loadSeries();
      context.read<SportController>().loadSports();
      context.read<CartoonController>().loadCartoons();
      context.read<HomeController>().loadData(isGuest: auth.isGuestMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer: const AppDrawer(),
      appBar: const CommonAppBar(
        title: 'ALENWAN PLAY PLUS',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section (like Shahid)
            _buildHeroSection(isDesktop, isTablet),

            const SizedBox(height: 60),

            // Trending Movies
            _buildSection(
              'الأفلام الأكثر مشاهدة',
              'اكتشف ما يشاهده الجميع',
              _buildMoviesRow(isDesktop, isTablet),
            ),

            const SizedBox(height: 60),

            // Series Section
            _buildSection(
              'مسلسلات مميزة',
              'أحدث المسلسلات والبرامج',
              _buildSeriesRow(isDesktop, isTablet),
            ),

            const SizedBox(height: 60),

            // Sports Section
            _buildSection(
              'رياضة',
              'مباريات ولقاءات حصرية',
              _buildSportsRow(isDesktop, isTablet),
            ),

            const SizedBox(height: 60),

            // Kids Section
            _buildSection(
              'عالم الأطفال',
              'محتوى آمن ومسلي للأطفال',
              _buildCartoonsRow(isDesktop, isTablet),
            ),

            const SizedBox(height: 80),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return Consumer<MovieController>(
      builder: (context, movieController, child) {
        final movies = movieController.movies;

        if (movies.isEmpty) {
          return Container(
            height: isDesktop ? 700 : (isTablet ? 500 : 400),
            color: AppColors.backgroundDark,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // Take first 3 movies for hero
        final heroMovies = movies.take(3).toList();

        return SizedBox(
          height: isDesktop ? 700 : (isTablet ? 500 : 400),
          child: Stack(
            children: [
              // Hero Carousel
              CarouselSlider.builder(
                itemCount: heroMovies.length,
                options: CarouselOptions(
                  height: isDesktop ? 700 : (isTablet ? 500 : 400),
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentHeroIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final movie = heroMovies[index];
                  return _buildHeroItem(movie, isDesktop, isTablet);
                },
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.backgroundDark.withValues(alpha: 0.7),
                        AppColors.backgroundDark,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Indicators
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: heroMovies.asMap().entries.map((entry) {
                    return Container(
                      width: _currentHeroIndex == entry.key ? 40 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentHeroIndex == entry.key
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroItem(MovieModel movie, bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(movie.bannerPath ??
              movie.posterPath ??
              'https://via.placeholder.com/1920x1080'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 60 : 20),
          vertical: isDesktop ? 100 : 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Rating Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movie.rating?.toString() ?? '0.0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              movie.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 56 : (isTablet ? 42 : 32),
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // Year and Category
            Text(
              '${movie.releaseYear ?? 'N/A'} • ${movie.categoryName ?? 'عام'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : (isTablet ? 500 : 300),
              ),
              child: Text(
                movie.description ?? 'لا يوجد وصف',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isDesktop ? 18 : 16,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                // Play Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.movieDetails,
                      arguments: movie,
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'شاهد الآن',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 30,
                      vertical: isDesktop ? 20 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.movieDetails,
                      arguments: movie,
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 24),
                  label: const Text(
                    'المزيد',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 30,
                      vertical: isDesktop ? 20 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildMoviesRow(bool isDesktop, bool isTablet) {
    return Consumer<MovieController>(
      builder: (context, movieController, child) {
        final movies = movieController.movies;

        if (movieController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (movies.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد أفلام متاحة',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SizedBox(
          height: isDesktop ? 350 : (isTablet ? 300 : 250),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return _buildContentCard(
                movies[index],
                isDesktop,
                isTablet,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.movieDetails,
                  arguments: movies[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSeriesRow(bool isDesktop, bool isTablet) {
    return Consumer<SeriesController>(
      builder: (context, seriesController, child) {
        final series = seriesController.series;

        if (seriesController.isLoadingList) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (series.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد مسلسلات متاحة',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SizedBox(
          height: isDesktop ? 350 : (isTablet ? 300 : 250),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: series.length,
            itemBuilder: (context, index) {
              final item = series[index];
              return _buildSeriesCard(
                item.thumbnail ?? 'https://via.placeholder.com/300x450',
                item.titleEn,
                '9.0',
                isDesktop,
                isTablet,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.seriesDetails,
                  arguments: item.id,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSportsRow(bool isDesktop, bool isTablet) {
    return Consumer<SportController>(
      builder: (context, sportController, child) {
        final sports = sportController.sports;

        if (sportController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (sports.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد رياضات متاحة',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SizedBox(
          height: isDesktop ? 350 : (isTablet ? 300 : 250),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            itemBuilder: (context, index) {
              final sport = sports[index];
              return _buildSeriesCard(
                sport.posterUrl ??
                    sport.bannerUrl ??
                    'https://via.placeholder.com/300x450',
                sport.title,
                '${sport.rating ?? 10.0}',
                isDesktop,
                isTablet,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.sportDetails,
                  arguments: sport.id,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCartoonsRow(bool isDesktop, bool isTablet) {
    return Consumer<CartoonController>(
      builder: (context, cartoonController, child) {
        final cartoons = cartoonController.cartoons;

        if (cartoonController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (cartoons.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد رسوم متحركة متاحة',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SizedBox(
          height: isDesktop ? 350 : (isTablet ? 300 : 250),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cartoons.length,
            itemBuilder: (context, index) {
              final cartoon = cartoons[index];
              return _buildSeriesCard(
                cartoon.posterPath ??
                    cartoon.bannerPath ??
                    'https://via.placeholder.com/300x450',
                cartoon.title,
                '${cartoon.rating ?? 0.0}',
                isDesktop,
                isTablet,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.cartoonDetails,
                  arguments: cartoon.id,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContentCard(
    MovieModel movie,
    bool isDesktop,
    bool isTablet,
    VoidCallback onTap,
  ) {
    final cardWidth = isDesktop ? 280.0 : (isTablet ? 220.0 : 180.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: isDesktop ? 280 : (isTablet ? 240 : 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    movie.posterPath ?? 'https://via.placeholder.com/300x450',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Quality Badge (using subscription tier)
                  if (movie.subscriptionTier != 'free')
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          movie.subscriptionTier.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Play Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Year and Rating
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${movie.rating ?? 0.0}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${movie.releaseYear ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesCard(
    String image,
    String title,
    String rating,
    bool isDesktop,
    bool isTablet,
    VoidCallback onTap,
  ) {
    final cardWidth = isDesktop ? 280.0 : (isTablet ? 220.0 : 180.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: isDesktop ? 280 : (isTablet ? 240 : 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Play Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(60),
      color: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          // Logo and Description
          const Text(
            'ALENWAN PLAY PLUS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'منصة البث المباشر الأولى لأفضل الأفلام والمسلسلات',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 40),

          // Links
          Wrap(
            spacing: 40,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('الرئيسية', () {}),
              _buildFooterLink('الأفلام', () {
                Navigator.pushNamed(context, AppRoutes.allMovies);
              }),
              _buildFooterLink('المسلسلات', () {
                Navigator.pushNamed(context, AppRoutes.allSeries);
              }),
              _buildFooterLink('الرياضة', () {
                Navigator.pushNamed(context, AppRoutes.allSports);
              }),
              _buildFooterLink('الأطفال', () {
                Navigator.pushNamed(context, AppRoutes.allCartoons);
              }),
              _buildFooterLink('الاشتراكات', () {
                Navigator.pushNamed(context, AppRoutes.subscriptionPlans);
              }),
            ],
          ),

          const SizedBox(height: 40),

          // Copyright
          Text(
            '© 2025 Alenwan Play Plus. جميع الحقوق محفوظة.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 16,
        ),
      ),
    );
  }
}
