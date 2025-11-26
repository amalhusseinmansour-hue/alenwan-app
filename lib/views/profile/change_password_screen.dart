import 'dart:async';
import 'dart:ui' as ui;
import 'package:alenwan/core/services/api_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import '../../core/theme/professional_theme.dart';

// لو عندك AuthController فيه التوكن، استخدمه هنا
// import '../../controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  bool _submitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode _currentFocus = FocusNode();
  final FocusNode _newFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  // عدّل العنوان بحسب خادمك
  final filesBase = ApiClient().filesBaseUrl; // https://domain
  Dio get _dio => Dio(
        BaseOptions(
          baseUrl: filesBase,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        ),
      );

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
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // اجلب التوكن من الكونتكست لو متوفر عندك AuthController
    // final auth = context.read<AuthController>();
    // final token = auth.token;
    // إن لم يكن لديك كونترولر، ضع التوكن يدوياً أثناء الاختبار:
    final String? token = null; // <- استبدلها بـ auth.token إن وُجد

    if (token == null || token.isEmpty) {
      _showSnack('يلزم تسجيل الدخول أولاً', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      // لو عندك CORS على الويب، قد تحتاج BrowserHttpClientAdapter
      if (kIsWeb) {
        // ignore: invalid_use_of_internal_member
        // (في معظم الحالات لا تحتاج تخصيص هنا)
      }

      final res = await _dio.post(
        // عدّل المسار حسب لارافيل لديك
        '/change-password',
        data: {
          'current_password': _currentCtrl.text.trim(),
          'password': _newCtrl.text.trim(),
          'password_confirmation': _confirmCtrl.text.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200) {
        _showSnack('تم تغيير كلمة المرور بنجاح');
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnack('فشل تغيير كلمة المرور. (${res.statusCode})', isError: true);
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data is Map && (e.response!.data['message'] is String)
              ? e.response!.data['message'] as String
              : (e.message ?? 'خطأ غير متوقع');
      _showSnack(msg, isError: true);
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            ? ProfessionalTheme.errorColor.withValues(alpha: 0.9)
            : ProfessionalTheme.successColor.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: ProfessionalTheme.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تعديل كلمة السر',
            style: ProfessionalTheme.headlineSmall(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
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
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ProfessionalTheme.space16,
                        vertical: ProfessionalTheme.space24,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.all(ProfessionalTheme.space32),
                        decoration: ProfessionalTheme.glassMorphism,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Icon
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(
                                  bottom: ProfessionalTheme.space20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: ProfessionalTheme.premiumGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: ProfessionalTheme.glowShadow,
                                ),
                                child: const Icon(
                                  Icons.lock_reset,
                                  color: ProfessionalTheme.textPrimary,
                                  size: 28,
                                ),
                              ),

                              // Title
                              Text(
                                'تعديل كلمة السر',
                                textAlign: TextAlign.center,
                                style: ProfessionalTheme.headlineMedium(
                                  color: ProfessionalTheme.textPrimary,
                                  weight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: ProfessionalTheme.space12),

                              // Subtitle
                              Text(
                                'غيّر كلمة السر أو أضف كلمة سر جديدة لاستخدامها عند تسجيل الدخول',
                                textAlign: TextAlign.center,
                                style: ProfessionalTheme.bodyMedium(
                                  color: ProfessionalTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: ProfessionalTheme.space32),

                              _buildPasswordField(
                                label: 'كلمة السر الحالية',
                                controller: _currentCtrl,
                                focusNode: _currentFocus,
                                visible: _showCurrent,
                                onToggle: () =>
                                    setState(() => _showCurrent = !_showCurrent),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'أدخل كلمة السر الحالية';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _newFocus.requestFocus(),
                              ),

                              const SizedBox(height: ProfessionalTheme.space20),

                              _buildPasswordField(
                                label: 'كلمة سر جديدة',
                                controller: _newCtrl,
                                focusNode: _newFocus,
                                visible: _showNew,
                                onToggle: () => setState(() => _showNew = !_showNew),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) return 'أدخل كلمة سر جديدة';
                                  if (t.length < 8) return 'الحد الأدنى 8 أحرف/أرقام';
                                  if (t == _currentCtrl.text.trim()) {
                                    return 'كلمة السر الجديدة يجب أن تختلف عن الحالية';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _confirmFocus.requestFocus(),
                              ),

                              const SizedBox(height: ProfessionalTheme.space20),

                              _buildPasswordField(
                                label: 'تأكيد كلمة السر الجديدة',
                                controller: _confirmCtrl,
                                focusNode: _confirmFocus,
                                visible: _showConfirm,
                                onToggle: () =>
                                    setState(() => _showConfirm = !_showConfirm),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'أدخل تأكيد كلمة السر';
                                  }
                                  if (v.trim() != _newCtrl.text.trim()) {
                                    return 'التأكيد لا يطابق كلمة السر الجديدة';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _submit(),
                              ),

                              const SizedBox(height: ProfessionalTheme.space32),

                              // Save Button
                              _buildProfessionalButton(
                                onPressed: _submitting ? null : _submit,
                                isLoading: _submitting,
                                text: 'حفظ المعلومات',
                              ),

                              const SizedBox(height: ProfessionalTheme.space16),

                              // Back Button
                              TextButton(
                                onPressed: _submitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: ProfessionalTheme.textSecondary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: ProfessionalTheme.space12,
                                  ),
                                ),
                                child: Text(
                                  'الرجوع للخطوة السابقة',
                                  style: ProfessionalTheme.bodyMedium(
                                    color: ProfessionalTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool visible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    Function(String)? onSubmitted,
  }) {
    return AnimatedContainer(
      duration: ProfessionalTheme.durationFast,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {}); // Rebuild to update focus state
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !visible,
          style: ProfessionalTheme.bodyLarge(
            color: ProfessionalTheme.textPrimary,
          ),
          validator: validator,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: ProfessionalTheme.bodyMedium(
              color: focusNode.hasFocus
                  ? ProfessionalTheme.primaryBrand
                  : ProfessionalTheme.textSecondary,
            ),
            filled: true,
            fillColor: focusNode.hasFocus
                ? ProfessionalTheme.surfaceActive.withValues(alpha: 0.8)
                : ProfessionalTheme.surfaceCard.withValues(alpha: 0.6),
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
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              borderSide: const BorderSide(
                color: ProfessionalTheme.primaryBrand,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              borderSide: const BorderSide(
                color: ProfessionalTheme.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
              borderSide: const BorderSide(
                color: ProfessionalTheme.errorColor,
                width: 2,
              ),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: ProfessionalTheme.space12,
              ),
              child: Icon(
                Icons.lock_outline,
                color: focusNode.hasFocus
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textTertiary,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: focusNode.hasFocus
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textTertiary,
                size: 20,
              ),
            ),
            errorStyle: ProfessionalTheme.bodySmall(
              color: ProfessionalTheme.errorColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
        gradient: onPressed != null
            ? ProfessionalTheme.premiumGradient
            : LinearGradient(
                colors: [
                  ProfessionalTheme.primaryBrand.withValues(alpha: 0.5),
                  ProfessionalTheme.accentBrand.withValues(alpha: 0.5),
                ],
              ),
        boxShadow: onPressed != null ? ProfessionalTheme.buttonShadow : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: ProfessionalTheme.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ProfessionalTheme.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ProfessionalTheme.space24,
            vertical: ProfessionalTheme.space16,
          ),
        ),
        child: isLoading
            ? const SizedBox(
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
                text,
                style: ProfessionalTheme.titleMedium(
                  color: ProfessionalTheme.textPrimary,
                  weight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
