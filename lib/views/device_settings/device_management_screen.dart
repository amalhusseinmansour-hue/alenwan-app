import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../../core/device_settings/device_manager.dart';
import '../../core/theme/professional_theme.dart';

class DeviceManagementScreen extends StatefulWidget {
  final bool showAsDialog;

  const DeviceManagementScreen({
    super.key,
    this.showAsDialog = false,
  });

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen>
    with TickerProviderStateMixin {
  final DeviceManager _deviceManager = DeviceManager();
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

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

    _loadDevices();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    await _deviceManager.fetchRegisteredDevices();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: ChangeNotifierProvider.value(
        value: _deviceManager,
        child: widget.showAsDialog
            ? _buildDialogContent(context)
            : Scaffold(
                backgroundColor: ProfessionalTheme.backgroundPrimary,
                appBar: _buildAppBar(),
                body: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContent(context),
                ),
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ProfessionalTheme.backgroundPrimary,
      elevation: 0,
      title: Text(
        'device_management'.tr(),
        style: const TextStyle(
          color: ProfessionalTheme.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
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
          icon: const Icon(Icons.arrow_back,
              color: ProfessionalTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ProfessionalTheme.surfaceCard.withValues(alpha: 0.9),
              ProfessionalTheme.surfaceCard.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(context),
                Flexible(
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ProfessionalTheme.premiumGradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ProfessionalTheme.textPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: ProfessionalTheme.textPrimary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.devices_other,
              color: ProfessionalTheme.textPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'device_limit_reached'.tr(),
            style: const TextStyle(
              color: ProfessionalTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'يجب إدارة الأجهزة المسجلة',
            style: TextStyle(
              color: ProfessionalTheme.textPrimary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, deviceManager, child) {
        if (_isLoading) {
          return _buildLoadingState();
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeviceStats(deviceManager),
              const SizedBox(height: 24),
              _buildDevicesList(deviceManager),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ProfessionalTheme.primaryBrand,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل الأجهزة...',
            style: TextStyle(
              color: ProfessionalTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStats(DeviceManager deviceManager) {
    return Container(
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
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأجهزة المسجلة',
                      style: TextStyle(
                        color: ProfessionalTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deviceManager.registeredDevices.length}',
                      style: const TextStyle(
                        color: ProfessionalTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحد الأقصى',
                      style: TextStyle(
                        color: ProfessionalTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3',
                      style: TextStyle(
                        color: ProfessionalTheme.primaryBrand,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevicesList(DeviceManager deviceManager) {
    if (deviceManager.registeredDevices.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'قائمة الأجهزة',
            style: TextStyle(
              color: ProfessionalTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: deviceManager.registeredDevices.length,
              itemBuilder: (context, index) {
                final device = deviceManager.registeredDevices[index];
                // Convert DeviceInfo to Map for compatibility
                final deviceMap = {
                  'id': device.id,
                  'name': device.name,
                  'type': device.platform.toLowerCase(),
                  'lastSeen': device.lastActiveText,
                  'isCurrent': device.isCurrent,
                };
                return _buildDeviceItem(deviceMap, deviceManager);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
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
                    color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.devices_other_outlined,
                color: ProfessionalTheme.textPrimary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد أجهزة مسجلة',
              style: TextStyle(
                color: ProfessionalTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم يتم تسجيل أي أجهزة بعد',
              style: TextStyle(
                color: ProfessionalTheme.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
      Map<String, dynamic> device, DeviceManager deviceManager) {
    final isCurrentDevice = device['isCurrent'] ?? false;
    final deviceName = device['name'] ?? 'Unknown Device';
    final deviceType = device['type'] ?? 'mobile';
    final lastSeen = device['lastSeen'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          color: isCurrentDevice
              ? ProfessionalTheme.primaryBrand.withValues(alpha: 0.5)
              : ProfessionalTheme.primaryBrand.withValues(alpha: 0.2),
          width: isCurrentDevice ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ProfessionalTheme.primaryBrand.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Device icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isCurrentDevice
                        ? ProfessionalTheme.premiumGradient
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ProfessionalTheme.accentBlue.withValues(alpha: 0.3),
                              ProfessionalTheme.accentCyan.withValues(alpha: 0.3),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isCurrentDevice
                          ? ProfessionalTheme.primaryBrand
                          : ProfessionalTheme.accentBlue.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getDeviceIcon(deviceType),
                    color: ProfessionalTheme.textPrimary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Device info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              deviceName,
                              style: const TextStyle(
                                color: ProfessionalTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentDevice)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: ProfessionalTheme.premiumGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'الحالي',
                                style: TextStyle(
                                  color: ProfessionalTheme.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDeviceTypeName(deviceType),
                        style: const TextStyle(
                          color: ProfessionalTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      if (lastSeen.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'آخر نشاط: $lastSeen',
                          style: const TextStyle(
                            color: ProfessionalTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Remove button (if not current device)
                if (!isCurrentDevice)
                  Container(
                    decoration: BoxDecoration(
                      color: ProfessionalTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalTheme.errorColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: ProfessionalTheme.errorColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showRemoveDeviceDialog(device, deviceManager),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'desktop':
        return Icons.computer;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.device_unknown;
    }
  }

  String _getDeviceTypeName(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return 'هاتف ذكي';
      case 'tablet':
        return 'تابلت';
      case 'desktop':
        return 'حاسوب';
      case 'tv':
        return 'تلفاز ذكي';
      default:
        return 'جهاز غير معروف';
    }
  }

  void _showRemoveDeviceDialog(
      Map<String, dynamic> device, DeviceManager deviceManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfessionalTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'إزالة الجهاز',
          style: TextStyle(
            color: ProfessionalTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل تريد إزالة "${device['name']}" من قائمة الأجهزة المسجلة؟',
          style: const TextStyle(
            color: ProfessionalTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  ProfessionalTheme.errorColor,
                  ProfessionalTheme.errorColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await deviceManager.removeDevice(device['id']);
                _showProfessionalSnackBar('تم إزالة الجهاز بنجاح');
              },
              child: const Text(
                'إزالة',
                style: TextStyle(
                  color: ProfessionalTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
