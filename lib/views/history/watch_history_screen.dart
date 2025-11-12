import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/professional_theme.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ProfessionalTheme.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: ProfessionalTheme.backgroundPrimary,
          elevation: 0,
          title: const Text(
            'سجل المشاهدة',
            style: TextStyle(
              color: ProfessionalTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
              icon: const Icon(Icons.arrow_back,
                  color: ProfessionalTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildEmptyState(),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.premiumGradient,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.history,
              color: ProfessionalTheme.textPrimary,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد سجل مشاهدة',
            style: TextStyle(
              color: ProfessionalTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بمشاهدة المحتوى لرؤية سجل المشاهدة هنا',
            style: TextStyle(
              color: ProfessionalTheme.textTertiary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
