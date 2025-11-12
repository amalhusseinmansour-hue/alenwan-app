// lib/widgets/advanced_search_filters.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/theme/app_theme.dart';

class SearchFilters {
  final List<String> categories;
  final List<String> genres;
  final RangeValues yearRange;
  final double minRating;
  final RangeValues durationRange;
  final String? language;
  final String sortBy;

  const SearchFilters({
    this.categories = const [],
    this.genres = const [],
    this.yearRange = const RangeValues(1990, 2024),
    this.minRating = 0.0,
    this.durationRange = const RangeValues(0, 300),
    this.language,
    this.sortBy = 'latest',
  });

  SearchFilters copyWith({
    List<String>? categories,
    List<String>? genres,
    RangeValues? yearRange,
    double? minRating,
    RangeValues? durationRange,
    String? language,
    String? sortBy,
  }) {
    return SearchFilters(
      categories: categories ?? this.categories,
      genres: genres ?? this.genres,
      yearRange: yearRange ?? this.yearRange,
      minRating: minRating ?? this.minRating,
      durationRange: durationRange ?? this.durationRange,
      language: language ?? this.language,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get isEmpty {
    return categories.isEmpty &&
        genres.isEmpty &&
        yearRange.start == 1990 &&
        yearRange.end == 2024 &&
        minRating == 0.0 &&
        durationRange.start == 0 &&
        durationRange.end == 300 &&
        language == null &&
        sortBy == 'latest';
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'genres': genres,
      'year_from': yearRange.start.round(),
      'year_to': yearRange.end.round(),
      'min_rating': minRating,
      'duration_from': durationRange.start.round(),
      'duration_to': durationRange.end.round(),
      'language': language,
      'sort_by': sortBy,
    };
  }
}

class AdvancedSearchFilters extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onFiltersChanged;
  final VoidCallback onClearAll;

  const AdvancedSearchFilters({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    required this.onClearAll,
  });

  @override
  State<AdvancedSearchFilters> createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters>
    with TickerProviderStateMixin {
  late SearchFilters _filters;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _availableCategories = [
    'Movies',
    'Series',
    'Documentaries',
    'Sports',
    'Cartoons',
    'Live Streams',
  ];

  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Fantasy',
    'Crime',
    'Mystery',
    'Animation',
    'Family',
    'War',
    'History',
    'Musical',
    'Biography',
    'Documentary',
    'Sport',
    'News',
  ];

  final List<String> _availableLanguages = [
    'Arabic',
    'English',
    'French',
    'Spanish',
    'Turkish',
    'Korean',
    'Japanese',
    'Hindi',
    'Urdu',
  ];

  final List<String> _sortOptions = [
    'latest',
    'rating',
    'popular',
    'alphabetical',
    'oldest',
    'duration_short',
    'duration_long',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateFilters(SearchFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _clearAllFilters() {
    _updateFilters(const SearchFilters());
    widget.onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: AppTheme.glassDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryFilters(),
                    const SizedBox(height: 24),
                    _buildGenreFilters(),
                    const SizedBox(height: 24),
                    _buildYearRangeFilter(),
                    const SizedBox(height: 24),
                    _buildRatingFilter(),
                    const SizedBox(height: 24),
                    _buildDurationFilter(),
                    const SizedBox(height: 24),
                    _buildLanguageFilter(),
                    const SizedBox(height: 24),
                    _buildSortOptions(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'advanced_filters'.tr(),
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (!_filters.isEmpty)
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                  label: Text(
                    'clear_all'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return _buildFilterSection(
      title: 'categories'.tr(),
      icon: Icons.category,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableCategories.map((category) {
          final isSelected = _filters.categories.contains(category);
          return _buildAnimatedFilterChip(
            label: category.tr(),
            isSelected: isSelected,
            onTap: () {
              final newCategories = List<String>.from(_filters.categories);
              if (isSelected) {
                newCategories.remove(category);
              } else {
                newCategories.add(category);
              }
              _updateFilters(_filters.copyWith(categories: newCategories));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGenreFilters() {
    return _buildFilterSection(
      title: 'genres'.tr(),
      icon: Icons.movie_filter,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableGenres.map((genre) {
          final isSelected = _filters.genres.contains(genre);
          return _buildAnimatedFilterChip(
            label: genre.tr(),
            isSelected: isSelected,
            onTap: () {
              final newGenres = List<String>.from(_filters.genres);
              if (isSelected) {
                newGenres.remove(genre);
              } else {
                newGenres.add(genre);
              }
              _updateFilters(_filters.copyWith(genres: newGenres));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildYearRangeFilter() {
    return _buildFilterSection(
      title: 'year_range'.tr(),
      icon: Icons.date_range,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filters.yearRange.start.round()}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_filters.yearRange.end.round()}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: _filters.yearRange,
              min: 1950,
              max: DateTime.now().year.toDouble(),
              divisions: DateTime.now().year - 1950,
              onChanged: (values) {
                _updateFilters(_filters.copyWith(yearRange: values));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return _buildFilterSection(
      title: 'minimum_rating'.tr(),
      icon: Icons.star,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.0',
                style: AppTheme.bodyMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _filters.minRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '10.0',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: _filters.minRating,
              min: 0.0,
              max: 10.0,
              divisions: 100,
              onChanged: (value) {
                _updateFilters(_filters.copyWith(minRating: value));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationFilter() {
    return _buildFilterSection(
      title: 'duration_minutes'.tr(),
      icon: Icons.access_time,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filters.durationRange.start.round()} min',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_filters.durationRange.end.round()} min',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: _filters.durationRange,
              min: 0,
              max: 300,
              divisions: 60,
              onChanged: (values) {
                _updateFilters(_filters.copyWith(durationRange: values));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageFilter() {
    return _buildFilterSection(
      title: 'language'.tr(),
      icon: Icons.language,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableLanguages.map((language) {
          final isSelected = _filters.language == language;
          return _buildAnimatedFilterChip(
            label: language.tr(),
            isSelected: isSelected,
            onTap: () {
              _updateFilters(_filters.copyWith(
                language: isSelected ? null : language,
              ));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortOptions() {
    return _buildFilterSection(
      title: 'sort_by'.tr(),
      icon: Icons.sort,
      child: Column(
        children: _sortOptions.map((option) {
          final isSelected = _filters.sortBy == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                _updateFilters(_filters.copyWith(sortBy: option));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSortIcon(option),
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getSortLabel(option),
                        style: AppTheme.bodyMedium.copyWith(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAnimatedFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.3),
            ),
            boxShadow: isSelected ? AppTheme.primaryShadow : null,
          ),
          child: Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortOption) {
    switch (sortOption) {
      case 'latest':
        return Icons.new_releases;
      case 'rating':
        return Icons.star;
      case 'popular':
        return Icons.trending_up;
      case 'alphabetical':
        return Icons.sort_by_alpha;
      case 'oldest':
        return Icons.history;
      case 'duration_short':
        return Icons.access_time;
      case 'duration_long':
        return Icons.schedule;
      default:
        return Icons.sort;
    }
  }

  String _getSortLabel(String sortOption) {
    switch (sortOption) {
      case 'latest':
        return 'Latest Releases'.tr();
      case 'rating':
        return 'Highest Rated'.tr();
      case 'popular':
        return 'Most Popular'.tr();
      case 'alphabetical':
        return 'A-Z'.tr();
      case 'oldest':
        return 'Oldest First'.tr();
      case 'duration_short':
        return 'Shortest First'.tr();
      case 'duration_long':
        return 'Longest First'.tr();
      default:
        return sortOption.tr();
    }
  }
}

// Helper widget for showing active filters count
class FiltersBadge extends StatelessWidget {
  final SearchFilters filters;
  final VoidCallback onTap;

  const FiltersBadge({
    super.key,
    required this.filters,
    required this.onTap,
  });

  int get _activeFiltersCount {
    int count = 0;
    if (filters.categories.isNotEmpty) count++;
    if (filters.genres.isNotEmpty) count++;
    if (filters.yearRange.start != 1990 || filters.yearRange.end != 2024) count++;
    if (filters.minRating > 0) count++;
    if (filters.durationRange.start != 0 || filters.durationRange.end != 300) count++;
    if (filters.language != null) count++;
    if (filters.sortBy != 'latest') count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _activeFiltersCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: activeCount > 0 ? AppTheme.primaryGradient : null,
          color: activeCount > 0 ? null : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              color: activeCount > 0 ? Colors.white : AppTheme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'filters'.tr(),
              style: AppTheme.bodySmall.copyWith(
                color: activeCount > 0 ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  activeCount.toString(),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}