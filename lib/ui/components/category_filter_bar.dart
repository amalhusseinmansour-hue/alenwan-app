import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import '../../core/theme/professional_theme.dart';

class CategoryFilterBar extends StatefulWidget {
  final List<CategoryFilter> categories;
  final Function(CategoryFilter)? onCategorySelected;
  final List<SortOption>? sortOptions;
  final Function(SortOption)? onSortChanged;
  final VoidCallback? onFilterTap;
  final bool showSortAndFilter;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.sortOptions,
    this.onSortChanged,
    this.onFilterTap,
    this.showSortAndFilter = true,
  });

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  CategoryFilter? _selectedCategory;
  SortOption? _selectedSort;
  bool _showSortDropdown = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scrollController = ScrollController();
    _animationController.forward();

    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
    if (widget.sortOptions != null && widget.sortOptions!.isNotEmpty) {
      _selectedSort = widget.sortOptions!.first;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? ProfessionalTheme.space64 : ProfessionalTheme.space24,
        ),
        child: Row(
          children: [
            // Categories
            Expanded(
              child: _buildCategoriesScroll(),
            ),

            // Sort and Filter
            if (widget.showSortAndFilter) ...[
              const SizedBox(width: ProfessionalTheme.space16),
              _buildSortButton(),
              const SizedBox(width: ProfessionalTheme.space12),
              _buildFilterButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesScroll() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < widget.categories.length; i++)
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (i * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: ProfessionalTheme.space8),
                      child: _CategoryChip(
                        category: widget.categories[i],
                        isSelected: _selectedCategory == widget.categories[i],
                        onTap: () {
                          setState(() => _selectedCategory = widget.categories[i]);
                          widget.onCategorySelected?.call(widget.categories[i]);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _showSortDropdown = true),
      onExit: (_) => setState(() => _showSortDropdown = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _ActionButton(
            icon: Icons.sort_rounded,
            label: _selectedSort?.label ?? 'ترتيب',
            onTap: () => setState(() => _showSortDropdown = !_showSortDropdown),
          ),
          if (_showSortDropdown && widget.sortOptions != null)
            Positioned(
              top: 48,
              right: 0,
              child: _SortDropdown(
                options: widget.sortOptions!,
                selectedOption: _selectedSort,
                onOptionSelected: (option) {
                  setState(() {
                    _selectedSort = option;
                    _showSortDropdown = false;
                  });
                  widget.onSortChanged?.call(option);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return _ActionButton(
      icon: Icons.tune_rounded,
      label: 'فلترة',
      onTap: widget.onFilterTap,
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final CategoryFilter category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ProfessionalTheme.durationFast,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: ProfessionalTheme.durationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space20,
            vertical: ProfessionalTheme.space10,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? ProfessionalTheme.premiumGradient
                : null,
            color: widget.isSelected
                ? null
                : (_isHovering
                    ? ProfessionalTheme.surfaceCard
                    : ProfessionalTheme.surfaceCard.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusRound),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : ProfessionalTheme.textTertiary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.category.icon != null) ...[
                Icon(
                  widget.category.icon,
                  size: 18,
                  color: widget.isSelected
                      ? ProfessionalTheme.textPrimary
                      : (_isHovering
                          ? ProfessionalTheme.textPrimary
                          : ProfessionalTheme.textSecondary),
                ),
                const SizedBox(width: ProfessionalTheme.space8),
              ],
              Text(
                widget.category.label,
                style: ProfessionalTheme.labelLarge(
                  color: widget.isSelected
                      ? ProfessionalTheme.textPrimary
                      : (_isHovering
                          ? ProfessionalTheme.textPrimary
                          : ProfessionalTheme.textSecondary),
                  weight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (widget.category.count != null) ...[
                const SizedBox(width: ProfessionalTheme.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ProfessionalTheme.space8,
                    vertical: ProfessionalTheme.space2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? ProfessionalTheme.textPrimary.withValues(alpha: 0.2)
                        : ProfessionalTheme.textTertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                  ),
                  child: Text(
                    widget.category.count.toString(),
                    style: ProfessionalTheme.labelSmall(
                      color: widget.isSelected
                          ? ProfessionalTheme.textPrimary
                          : ProfessionalTheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space16,
            vertical: ProfessionalTheme.space10,
          ),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
            border: Border.all(
              color: ProfessionalTheme.textTertiary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: ProfessionalTheme.textSecondary,
              ),
              const SizedBox(width: ProfessionalTheme.space8),
              Text(
                label,
                style: ProfessionalTheme.labelLarge(
                  color: ProfessionalTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final List<SortOption> options;
  final SortOption? selectedOption;
  final Function(SortOption) onOptionSelected;

  const _SortDropdown({
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: ProfessionalTheme.surfaceCard,
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == selectedOption;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onOptionSelected(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ProfessionalTheme.space16,
                      vertical: ProfessionalTheme.space12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          size: 18,
                          color: isSelected
                              ? ProfessionalTheme.primaryBrand
                              : ProfessionalTheme.textSecondary,
                        ),
                        const SizedBox(width: ProfessionalTheme.space12),
                        Expanded(
                          child: Text(
                            option.label,
                            style: ProfessionalTheme.bodyMedium(
                              color: isSelected
                                  ? ProfessionalTheme.primaryBrand
                                  : ProfessionalTheme.textPrimary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: ProfessionalTheme.primaryBrand,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class CategoryFilter {
  final String id;
  final String label;
  final IconData? icon;
  final int? count;
  final Color? color;

  CategoryFilter({
    required this.id,
    required this.label,
    this.icon,
    this.count,
    this.color,
  });
}

class SortOption {
  final String id;
  final String label;
  final IconData icon;

  SortOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}