import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../controllers/video_translation_controller.dart';
import '../services/audio_translation_service.dart';
import '../core/theme/professional_theme.dart';

class VideoTranslationOverlay extends StatefulWidget {
  final Widget child;
  final bool showControls;

  const VideoTranslationOverlay({
    super.key,
    required this.child,
    this.showControls = true,
  });

  @override
  State<VideoTranslationOverlay> createState() =>
      _VideoTranslationOverlayState();
}

class _VideoTranslationOverlayState extends State<VideoTranslationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late AnimationController _subtitleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _subtitleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _subtitleAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _controlsAnimationController.forward();
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _subtitleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoTranslationController(),
      child: Consumer<VideoTranslationController>(
        builder: (context, controller, _) {
          return Stack(
            children: [
              // Video player widget
              widget.child,

              // Translation controls
              if (widget.showControls) _buildTranslationControls(controller),

              // Subtitle overlay
              if (controller.showSubtitles && controller.isTranslationEnabled)
                _buildSubtitleOverlay(controller),

              // Translation panel
              if (controller.showTranslationPanel)
                _buildTranslationPanel(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTranslationControls(VideoTranslationController controller) {
    return Positioned(
      top: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: controller.isTranslationEnabled
                  ? ProfessionalTheme.primaryBrand
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: controller.isTranslationEnabled
                    ? ProfessionalTheme.primaryBrand.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleTranslation(),
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        controller.isTranslationEnabled
                            ? Icons.translate
                            : Icons.translate_outlined,
                        color: controller.isTranslationEnabled
                            ? ProfessionalTheme.primaryBrand
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                    if (controller.isTranslationEnabled) ...[
                      const SizedBox(width: 8),
                      _buildStatusIndicator(controller.status),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(TranslationStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case TranslationStatus.listening:
        color = Colors.green;
        icon = Icons.mic;
        break;
      case TranslationStatus.translating:
        color = Colors.blue;
        icon = Icons.sync;
        break;
      case TranslationStatus.speaking:
        color = Colors.orange;
        icon = Icons.volume_up;
        break;
      case TranslationStatus.error:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      child: Icon(icon, color: color, size: 12),
    );
  }

  Widget _buildSubtitleOverlay(VideoTranslationController controller) {
    if (controller.currentTranslation.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                controller.currentTranslation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranslationPanel(VideoTranslationController controller) {
    return Positioned(
      top: 60,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 320,
        height: 400,
        decoration: BoxDecoration(
          color: ProfessionalTheme.surfaceCard.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
              children: [
                _buildPanelHeader(controller),
                _buildLanguageSelector(controller),
                Expanded(child: _buildTranslationHistory(controller)),
                _buildPanelControls(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeader(VideoTranslationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfessionalTheme.primaryBrand.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.translate,
            color: ProfessionalTheme.primaryBrand,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Live Translation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => controller.toggleTranslationPanel(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(VideoTranslationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageDropdown(
              label: 'From',
              value: controller.sourceLanguage,
              onChanged: (value) => controller.setSourceLanguage(value!),
              languages: controller.availableLanguages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              color: ProfessionalTheme.primaryBrand,
              size: 20,
            ),
          ),
          Expanded(
            child: _buildLanguageDropdown(
              label: 'To',
              value: controller.targetLanguage,
              onChanged: (value) => controller.setTargetLanguage(value!),
              languages: controller.availableLanguages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required String value,
    required Function(String?) onChanged,
    required Map<String, String> languages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: ProfessionalTheme.surfaceCard,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          isDense: true,
          items: languages.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTranslationHistory(VideoTranslationController controller) {
    if (controller.translationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Translation history will appear here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.translationHistory.length,
      itemBuilder: (context, index) {
        final segment = controller.translationHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segment.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(segment.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelControls(VideoTranslationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.subtitles,
            label: 'Subtitles',
            isActive: controller.showSubtitles,
            onTap: () => controller.toggleSubtitles(),
          ),
          _buildControlButton(
            icon: Icons.delete_outline,
            label: 'Clear',
            isActive: false,
            onTap: () => controller.clearHistory(),
          ),
          _buildControlButton(
            icon: Icons.download,
            label: 'Export',
            isActive: false,
            onTap: () => _exportTranslations(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? ProfessionalTheme.primaryBrand.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? ProfessionalTheme.primaryBrand.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color:
                    isActive ? ProfessionalTheme.primaryBrand : Colors.white70,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? ProfessionalTheme.primaryBrand
                      : Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  void _exportTranslations(VideoTranslationController controller) {
    final text = controller.exportTranslationHistory();
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Translation history exported'),
        backgroundColor: ProfessionalTheme.primaryBrand,
      ),
    );
  }
}
