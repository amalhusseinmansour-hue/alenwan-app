import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/devices_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/professional_theme.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen>
    with TickerProviderStateMixin {
  final _pairingCtrl = TextEditingController();
  bool _submitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode _pairingFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pairingCtrl.dispose();
    _pairingFocus.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: ProfessionalTheme.bodyMedium(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError
            ? ProfessionalTheme.errorColor.withOpacity(0.9)
            : ProfessionalTheme.successColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _linkDevice(BuildContext context) async {
    final code = _pairingCtrl.text.trim();
    if (code.isEmpty) {
      _showSnack('أدخل رمز الربط أولاً', isError: true);
      return;
    }
    setState(() => _submitting = true);
    final ok = await context.read<DevicesController>().link(code);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      _pairingCtrl.clear();
      _showSnack('تم ربط الجهاز بنجاح');
    } else {
      // ignore: use_build_context_synchronously
      final err = context.read<DevicesController>().error ?? 'فشل ربط الجهاز';
      _showSnack(err, isError: true);
    }
  }

  Future<void> _promptRename(BuildContext context, DeviceItem d) async {
    final ctrl = TextEditingController(text: d.name);

    final newName = await showDialog<String?>(
      context: context,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space24),
            decoration: ProfessionalTheme.glassMorphism,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'إعادة تسمية الجهاز',
                  style: ProfessionalTheme.headlineSmall(
                    color: ProfessionalTheme.textPrimary,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space20),

                // Text Field
                TextFormField(
                  controller: ctrl,
                  style: ProfessionalTheme.bodyLarge(
                    color: ProfessionalTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسم الجهاز',
                    hintStyle: ProfessionalTheme.bodyMedium(
                      color: ProfessionalTheme.textTertiary,
                    ),
                    filled: true,
                    fillColor: ProfessionalTheme.surfaceCard.withOpacity(0.6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ProfessionalTheme.space16,
                      vertical: ProfessionalTheme.space16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                      borderSide: BorderSide(
                        color: ProfessionalTheme.primaryBrand,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        style: TextButton.styleFrom(
                          foregroundColor: ProfessionalTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: ProfessionalTheme.space12,
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: ProfessionalTheme.premiumGradient,
                          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: ProfessionalTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: ProfessionalTheme.space12,
                            ),
                          ),
                          child: Text(
                            'حفظ',
                            style: ProfessionalTheme.titleMedium(
                              color: ProfessionalTheme.textPrimary,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (newName == null || newName.isEmpty) return;

    // ignore: use_build_context_synchronously
    final ok = await context.read<DevicesController>().rename(d.id, newName);
    if (!mounted) return;

    _showSnack(
      ok
          ? 'تم التحديث'
          // ignore: use_build_context_synchronously
          : (context.read<DevicesController>().error ?? 'تعذر التحديث'),
      isError: !ok,
    );
  }

  Future<void> _confirmDelete(BuildContext context, DeviceItem d) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space24),
            decoration: ProfessionalTheme.glassMorphism,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ProfessionalTheme.errorColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: ProfessionalTheme.errorColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space20),

                // Title
                Text(
                  'حذف الجهاز',
                  style: ProfessionalTheme.headlineSmall(
                    color: ProfessionalTheme.textPrimary,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space12),

                // Content
                Text(
                  'هل تريد حذف هذا الجهاز من حسابك؟\nلن تتمكن من التراجع عن هذا الإجراء.',
                  textAlign: TextAlign.center,
                  style: ProfessionalTheme.bodyMedium(
                    color: ProfessionalTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: ProfessionalTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: ProfessionalTheme.space12,
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ProfessionalTheme.space16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalTheme.errorColor,
                              ProfessionalTheme.errorColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: ProfessionalTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: ProfessionalTheme.space12,
                            ),
                          ),
                          child: Text(
                            'حذف',
                            style: ProfessionalTheme.titleMedium(
                              color: ProfessionalTheme.textPrimary,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (yes != true) return;

    // ignore: use_build_context_synchronously
    final ok = await context.read<DevicesController>().unlink(d.id);
    if (!mounted) return;

    _showSnack(
      ok
          ? 'تم الحذف'
          // ignore: use_build_context_synchronously
          : (context.read<DevicesController>().error ?? 'تعذر الحذف'),
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthController?>(context, listen: false);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: ChangeNotifierProvider<DevicesController>(
        create: (_) => DevicesController()..load(),
        child: Scaffold(
          backgroundColor: ProfessionalTheme.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: ProfessionalTheme.backgroundPrimary,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ProfessionalTheme.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'إدارة الأجهزة',
              style: ProfessionalTheme.headlineSmall(
                color: ProfessionalTheme.textPrimary,
                weight: FontWeight.bold,
              ),
            ),
          ),
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ProfessionalTheme.darkGradient,
                    ),
                    child: Consumer<DevicesController>(
                      builder: (context, c, _) {
                        return RefreshIndicator(
                          color: ProfessionalTheme.primaryBrand,
                          backgroundColor: ProfessionalTheme.surfaceCard,
                          onRefresh: () => c.load(),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: ProfessionalTheme.space24,
                                ),
                                children: [
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 820),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: ProfessionalTheme.space16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            _heroHeader(),
                                            const SizedBox(height: ProfessionalTheme.space24),
                                            _topInfoCard(),
                                            const SizedBox(height: ProfessionalTheme.space20),
                                            _pairCard(context, c),
                                            const SizedBox(height: ProfessionalTheme.space32),
                                            _sectionTitle('الأجهزة المرتبطة حالياً بحسابك'),
                                            const SizedBox(height: ProfessionalTheme.space16),
                                            if (c.isLoading)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: ProfessionalTheme.space40,
                                                ),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    color: ProfessionalTheme.primaryBrand,
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                              )
                                            else if (c.error != null)
                                              _errorBox(c.error!, onRetry: c.load)
                                            else if (c.devices.isEmpty)
                                              _emptyBox()
                                            else
                                              ...c.devices.map(_deviceTile),
                                            const SizedBox(height: ProfessionalTheme.space32),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // UI Sections

  Widget _heroHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: ProfessionalTheme.premiumGradient,
            shape: BoxShape.circle,
            boxShadow: ProfessionalTheme.glowShadow,
          ),
          child: Icon(
            Icons.devices,
            color: ProfessionalTheme.textPrimary,
            size: 40,
          ),
        ),
        const SizedBox(height: ProfessionalTheme.space16),
        Text(
          'إدارة الأجهزة المرتبطة',
          style: ProfessionalTheme.headlineMedium(
            color: ProfessionalTheme.textPrimary,
            weight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ProfessionalTheme.space8),
        Text(
          'تحكم بالأجهزة، أعد تسميتها أو احذف ما لا تحتاجه',
          style: ProfessionalTheme.bodyMedium(
            color: ProfessionalTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ProfessionalTheme.primaryBrand.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: ProfessionalTheme.space16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space16,
            vertical: ProfessionalTheme.space8,
          ),
          decoration: BoxDecoration(
            color: ProfessionalTheme.surfaceCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusRound),
            border: Border.all(
              color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: ProfessionalTheme.titleMedium(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: ProfessionalTheme.space16),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfessionalTheme.primaryBrand.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topInfoCard() {
    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space8),
            decoration: BoxDecoration(
              color: ProfessionalTheme.infoColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: ProfessionalTheme.infoColor,
              size: 20,
            ),
          ),
          const SizedBox(width: ProfessionalTheme.space12),
          Expanded(
            child: Text(
              'لقد وصلت إلى الحد الأقصى المسموح به لعدد الأجهزة المرتبطة بحسابك. الرجاء حذف أحد الأجهزة التالية لربط جهاز جديد.',
              style: ProfessionalTheme.bodyMedium(
                color: ProfessionalTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pairCard(BuildContext context, DevicesController c) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'ربط جهاز جديد',
            style: ProfessionalTheme.titleLarge(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'إذا كان لديك رمز خاص لأحد أجهزتك (Pairing Code)، الرجاء إدخاله هنا',
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space20),

          // Input Row
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: ProfessionalTheme.durationFast,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {}); // Rebuild to update focus state
                    },
                    child: TextFormField(
                      controller: _pairingCtrl,
                      focusNode: _pairingFocus,
                      style: ProfessionalTheme.bodyLarge(
                        color: ProfessionalTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'قم بإدخال الرمز هنا',
                        hintStyle: ProfessionalTheme.bodyMedium(
                          color: ProfessionalTheme.textTertiary,
                        ),
                        filled: true,
                        fillColor: _pairingFocus.hasFocus
                            ? ProfessionalTheme.surfaceActive.withOpacity(0.8)
                            : ProfessionalTheme.surfaceCard.withOpacity(0.6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: ProfessionalTheme.space16,
                          vertical: ProfessionalTheme.space16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                          borderSide: BorderSide(
                            color: ProfessionalTheme.primaryBrand,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: ProfessionalTheme.space12,
                          ),
                          child: Icon(
                            Icons.qr_code,
                            color: _pairingFocus.hasFocus
                                ? ProfessionalTheme.primaryBrand
                                : ProfessionalTheme.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),
                      onFieldSubmitted: (_) => _linkDevice(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ProfessionalTheme.space12),

              // Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                  gradient: (_submitting || _pairingCtrl.text.isEmpty)
                      ? LinearGradient(
                          colors: [
                            ProfessionalTheme.primaryBrand.withOpacity(0.5),
                            ProfessionalTheme.accentBrand.withOpacity(0.5),
                          ],
                        )
                      : ProfessionalTheme.premiumGradient,
                  boxShadow: (_submitting || _pairingCtrl.text.isEmpty)
                      ? null
                      : ProfessionalTheme.buttonShadow,
                ),
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _linkDevice(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: ProfessionalTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ProfessionalTheme.space20,
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ProfessionalTheme.textPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'اربط الجهاز',
                          style: ProfessionalTheme.titleMedium(
                            color: ProfessionalTheme.textPrimary,
                            weight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ProfessionalTheme.space16),

          // Info Text
          Container(
            padding: const EdgeInsets.all(ProfessionalTheme.space12),
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Text(
              'يمكنك ربط لغاية 20 جهازاً مع حسابك على التطبيق.',
              style: ProfessionalTheme.bodySmall(
                color: ProfessionalTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceTile(DeviceItem d) {
    String fmtDate(DateTime dt) =>
        '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

    return _SectionCard(
      padding: const EdgeInsets.all(ProfessionalTheme.space16),
      child: Row(
        children: [
          // Device Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: ProfessionalTheme.cardGradient,
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              border: Border.all(
                color: ProfessionalTheme.primaryBrand.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.devices_other,
              color: ProfessionalTheme.primaryBrand,
              size: 24,
            ),
          ),

          const SizedBox(width: ProfessionalTheme.space16),

          // Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: ProfessionalTheme.titleMedium(
                    color: ProfessionalTheme.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: ProfessionalTheme.space4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: ProfessionalTheme.textTertiary,
                    ),
                    const SizedBox(width: ProfessionalTheme.space4),
                    Text(
                      'تاريخ الإضافة ${fmtDate(d.linkedAt)}',
                      style: ProfessionalTheme.bodySmall(
                        color: ProfessionalTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              Container(
                decoration: BoxDecoration(
                  color: ProfessionalTheme.surfaceCard.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                ),
                child: IconButton(
                  tooltip: 'إعادة تسمية',
                  onPressed: () => _promptRename(context, d),
                  icon: Icon(
                    Icons.edit,
                    color: ProfessionalTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: ProfessionalTheme.space8),

              // Delete Button
              Container(
                decoration: BoxDecoration(
                  color: ProfessionalTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ProfessionalTheme.radiusS),
                ),
                child: IconButton(
                  tooltip: 'حذف',
                  onPressed: () => _confirmDelete(context, d),
                  icon: Icon(
                    Icons.delete_outline,
                    color: ProfessionalTheme.errorColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String msg, {required Future<void> Function() onRetry}) {
    return _SectionCard(
      color: ProfessionalTheme.errorColor.withOpacity(0.1),
      borderColor: ProfessionalTheme.errorColor.withOpacity(0.3),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ProfessionalTheme.errorColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: ProfessionalTheme.errorColor,
              size: 30,
            ),
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'حدث خطأ',
            style: ProfessionalTheme.titleMedium(
              color: ProfessionalTheme.errorColor,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            msg,
            style: ProfessionalTheme.bodyMedium(
              color: ProfessionalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfessionalTheme.errorColor,
                  ProfessionalTheme.errorColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
            ),
            child: TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: ProfessionalTheme.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfessionalTheme.space20,
                  vertical: ProfessionalTheme.space12,
                ),
              ),
              child: Text(
                'حاول مرة أخرى',
                style: ProfessionalTheme.titleMedium(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBox() {
    return _SectionCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ProfessionalTheme.surfaceCard.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: ProfessionalTheme.textTertiary.withOpacity(0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Icon(
              Icons.devices_outlined,
              color: ProfessionalTheme.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: ProfessionalTheme.space16),
          Text(
            'لا توجد أجهزة مرتبطة',
            style: ProfessionalTheme.titleMedium(
              color: ProfessionalTheme.textSecondary,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ProfessionalTheme.space8),
          Text(
            'لم يتم ربط أي أجهزة بحسابك حتى الآن.\nاستخدم رمز الربط أعلاه لإضافة جهاز جديد.',
            style: ProfessionalTheme.bodySmall(
              color: ProfessionalTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  const _SectionCard({
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ProfessionalTheme.space16),
      padding: padding ?? const EdgeInsets.all(ProfessionalTheme.space20),
      decoration: BoxDecoration(
        gradient: color != null
            ? null
            : ProfessionalTheme.cardGradient,
        color: color,
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusL),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: ProfessionalTheme.cardShadow,
      ),
      child: child,
    );
  }
}
