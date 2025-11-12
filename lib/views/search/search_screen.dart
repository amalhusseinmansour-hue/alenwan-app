// lib/views/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/professional_theme.dart';
import '../../routes/app_routes.dart';
import '../../controllers/search_controller.dart';
import '../../models/search_hit.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/advanced_search_filters.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textController;
  SearchFilters _currentFilters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final auth = Provider.of<AuthController>(context, listen: false);

    return ChangeNotifierProvider<AppSearchController>(
      create: (_) => AppSearchController(tokenProvider: () => auth.token),
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: ProfessionalTheme.surfaceColor.withValues(alpha:0.9),
          title: Text('search'.tr()),
          leading: IconButton(
            icon: Icon(isRTL ? Icons.arrow_back : Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFiltersSection(),
            Expanded(
              child: Consumer<AppSearchController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.primaryColor),
                      ),
                    );
                  }

                  // unauthenticated
                  if (controller.error
                          ?.toLowerCase()
                          .contains('unauthenticated') ==
                      true) {
                    return _buildMessage(
                      icon: Icons.lock_outline,
                      message: 'يلزم تسجيل الدخول لإجراء البحث',
                      buttonLabel: 'تسجيل الدخول',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.login),
                    );
                  }

                  // other errors
                  if (controller.error != null) {
                    return _buildMessage(
                      icon: Icons.error_outline,
                      message: 'error_occurred'.tr(),
                      subtitle: controller.error,
                      buttonLabel: 'try_again'.tr(),
                      onPressed: () => controller.search(),
                    );
                  }

                  if (!controller.hasQuery) {
                    return _buildMessage(
                      icon: Icons.search,
                      message: 'search_movies_series'.tr(),
                    );
                  }

                  if (!controller.hasResults) {
                    return _buildMessage(
                      icon: Icons.search_off,
                      message: 'no_results'.tr(),
                      subtitle: 'try_different_keywords'.tr(),
                    );
                  }

                  return _buildSearchResults(controller.results);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<AppSearchController>(
      builder: (context, controller, _) {
        if (_textController.text != controller.query) {
          _textController.text = controller.query;
          _textController.selection =
              TextSelection.collapsed(offset: _textController.text.length);
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _textController,
            onChanged: (value) {
              // Apply filters when searching with debounce
              controller.setQueryWithFilters(value, _currentFilters);
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => controller.searchWithFilters(_currentFilters),
            style: ProfessionalTheme.bodyMedium(),
            decoration: InputDecoration(
              hintText: 'search_movies_series'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                        controller.clearSearch();
                      },
                    )
                  : null,
              filled: true,
              fillColor: ProfessionalTheme.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FiltersBadge(
            filters: _currentFilters,
            onTap: _showAdvancedFilters,
          ),
          const SizedBox(width: 12),
          if (!_currentFilters.isEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._buildActiveFilterChips(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips() {
    final chips = <Widget>[];

    // Add category chips
    for (final category in _currentFilters.categories) {
      chips.add(_buildActiveFilterChip(
        label: category.tr(),
        onRemove: () {
          final newCategories = List<String>.from(_currentFilters.categories);
          newCategories.remove(category);
          _updateFilters(_currentFilters.copyWith(categories: newCategories));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    // Add genre chips
    for (final genre in _currentFilters.genres.take(2)) {
      chips.add(_buildActiveFilterChip(
        label: genre.tr(),
        onRemove: () {
          final newGenres = List<String>.from(_currentFilters.genres);
          newGenres.remove(genre);
          _updateFilters(_currentFilters.copyWith(genres: newGenres));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    // Add more genres indicator
    if (_currentFilters.genres.length > 2) {
      chips.add(_buildActiveFilterChip(
        label: '+${_currentFilters.genres.length - 2} more genres',
        onRemove: () {},
        isReadOnly: true,
      ));
      chips.add(const SizedBox(width: 8));
    }

    // Add year range chip
    if (_currentFilters.yearRange.start != 1990 || _currentFilters.yearRange.end != 2024) {
      chips.add(_buildActiveFilterChip(
        label: '${_currentFilters.yearRange.start.round()}-${_currentFilters.yearRange.end.round()}',
        onRemove: () {
          _updateFilters(_currentFilters.copyWith(yearRange: const RangeValues(1990, 2024)));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    // Add rating chip
    if (_currentFilters.minRating > 0) {
      chips.add(_buildActiveFilterChip(
        label: 'Rating >${_currentFilters.minRating.toStringAsFixed(1)}',
        onRemove: () {
          _updateFilters(_currentFilters.copyWith(minRating: 0.0));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    // Add language chip
    if (_currentFilters.language != null) {
      chips.add(_buildActiveFilterChip(
        label: _currentFilters.language!.tr(),
        onRemove: () {
          _updateFilters(_currentFilters.copyWith(language: null));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    return chips;
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
    bool isReadOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ProfessionalTheme.primaryColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfessionalTheme.primaryColor.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ProfessionalTheme.bodySmall().copyWith(
              color: ProfessionalTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isReadOnly) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: ProfessionalTheme.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedSearchFilters(
        initialFilters: _currentFilters,
        onFiltersChanged: _updateFilters,
        onClearAll: _clearAllFilters,
      ),
    );
  }

  void _updateFilters(SearchFilters newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });

    // Apply filters to search if there's a query
    final controller = Provider.of<AppSearchController>(context, listen: false);
    if (controller.hasQuery) {
      controller.searchWithFilters(newFilters);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = const SearchFilters();
    });

    // Re-search with cleared filters if there's a query
    final controller = Provider.of<AppSearchController>(context, listen: false);
    if (controller.hasQuery) {
      controller.search();
    }
  }

  Widget _buildSearchResults(List<SearchHit> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) => _buildResultCard(results[i]),
    );
  }

  Widget _buildResultCard(SearchHit hit) {
    return GestureDetector(
      onTap: () => _openDetails(hit),
      child: Container(
        decoration: ProfessionalTheme.glassDecoration(
          borderRadius: ProfessionalTheme.mediumRadius,
          boxShadow: ProfessionalTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: hit.image, // ✅ بدل posterUrl
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ProfessionalTheme.primaryColor),
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hit.title,
                    style: ProfessionalTheme.headlineSmall(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hit.year != null)
                    Text(
                      '${hit.year}',
                      style: ProfessionalTheme.bodySmall(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(SearchHit hit) {
    // النوع عندك String، لذلك نقارنه نصّياً
    switch (hit.type.toLowerCase()) {
      case 'movie':
        Navigator.pushNamed(context, AppRoutes.movieDetails, arguments: hit.id);
        break;
      case 'series':
        Navigator.pushNamed(context, AppRoutes.seriesDetails,
            arguments: hit.id);
        break;
      case 'documentary':
        Navigator.pushNamed(context, AppRoutes.documentaryDetails,
            arguments: hit.id);
        break;
      case 'cartoon':
        Navigator.pushNamed(context, AppRoutes.cartoonDetails,
            arguments: hit.id);
        break;
      case 'sport':
        Navigator.pushNamed(context, AppRoutes.sportDetails, arguments: hit.id);
        break;
      case 'livestream':
        Navigator.pushNamed(context, AppRoutes.liveStream, arguments: hit.id);
        break;
      default:
        // fallback
        Navigator.pushNamed(context, AppRoutes.movieDetails, arguments: hit.id);
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    String? subtitle,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: ProfessionalTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ProfessionalTheme.headlineSmall().copyWith(color: ProfessionalTheme.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: ProfessionalTheme.bodySmall(),
              ),
            ],
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
