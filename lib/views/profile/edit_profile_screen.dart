import 'dart:io' show File;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/professional_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool agreeTerms = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool _saving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // ⬇️ إمّا ملف (موبايل/ديسكتوب) أو bytes (ويب)
  File? _profileImageFile;
  Uint8List? _profileImageBytes;
  String? _profileImageName;

  final _service = ProfileService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    nameController = TextEditingController(text: widget.user?['name'] ?? '');
    emailController = TextEditingController(text: widget.user?['email'] ?? '');
    phoneController = TextEditingController(text: widget.user?['phone'] ?? '');
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _profileImageFile = null;
        _profileImageName = x.name;
      });
    } else {
      setState(() {
        _profileImageFile = File(x.path);
        _profileImageBytes = null;
        _profileImageName = x.name;
      });
    }
  }

  Future<void> _save() async {
    if (!agreeTerms) {
      _showSnack('يرجى الموافقة على الشروط والأحكام', isError: true);
      return;
    }

    setState(() => _saving = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final res = await _service.updateProfile(
      name: name.isEmpty ? null : name,
      email: email.isEmpty ? null : email,
      photoFile: _profileImageFile,
      photoBytes: _profileImageBytes,
      photoFilename: _profileImageName,
    );

    setState(() => _saving = false);
    if (!mounted) return;

    if (res.success) {
      _showSnack('تم حفظ التغييرات بنجاح');
      Navigator.pop(context, true);
    } else {
      _showSnack(res.error ?? 'فشل حفظ التغييرات', isError: true);
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
    ImageProvider? avatarProvider;
    if (_profileImageBytes != null) {
      avatarProvider = MemoryImage(_profileImageBytes!);
    } else if (_profileImageFile != null) {
      avatarProvider = FileImage(_profileImageFile!);
    }

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
            'تعديل الملف الشخصي',
            style: ProfessionalTheme.headlineSmall(
              color: ProfessionalTheme.textPrimary,
              weight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
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
                        padding:
                            const EdgeInsets.all(ProfessionalTheme.space32),
                        decoration: ProfessionalTheme.glassMorphism,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Image Section
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: avatarProvider == null
                                        ? ProfessionalTheme.premiumGradient
                                        : null,
                                    boxShadow: ProfessionalTheme.glowShadow,
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: avatarProvider,
                                    child: avatarProvider == null
                                        ? const Icon(
                                            Icons.camera_alt,
                                            color:
                                                ProfessionalTheme.textPrimary,
                                            size: 40,
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Colors.black.withValues(alpha: 0.3),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color:
                                                  ProfessionalTheme.textPrimary,
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: ProfessionalTheme.space32),

                            // Title
                            Text(
                              'تعديل البيانات الشخصية',
                              textAlign: TextAlign.center,
                              style: ProfessionalTheme.headlineMedium(
                                color: ProfessionalTheme.textPrimary,
                                weight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: ProfessionalTheme.space8),

                            Text(
                              'قم بتحديث بياناتك الشخصية والصورة الشخصية',
                              textAlign: TextAlign.center,
                              style: ProfessionalTheme.bodyMedium(
                                color: ProfessionalTheme.textSecondary,
                              ),
                            ),

                            const SizedBox(height: ProfessionalTheme.space32),

                            // Name Field
                            _buildProfessionalTextField(
                              controller: nameController,
                              focusNode: _nameFocus,
                              label: 'الاسم الكامل',
                              icon: Icons.person,
                              onSubmitted: (_) => _emailFocus.requestFocus(),
                            ),

                            const SizedBox(height: ProfessionalTheme.space20),

                            // Email Field
                            _buildProfessionalTextField(
                              controller: emailController,
                              focusNode: _emailFocus,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              onSubmitted: (_) => _phoneFocus.requestFocus(),
                            ),

                            const SizedBox(height: ProfessionalTheme.space20),

                            // Phone Field with Country Code
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: ProfessionalTheme.space16,
                                    vertical: ProfessionalTheme.space16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ProfessionalTheme.surfaceCard
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(
                                        ProfessionalTheme.radiusM),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '+966',
                                    style: ProfessionalTheme.bodyLarge(
                                      color: ProfessionalTheme.textPrimary,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: ProfessionalTheme.space12),
                                Expanded(
                                  child: _buildProfessionalTextField(
                                    controller: phoneController,
                                    focusNode: _phoneFocus,
                                    label: 'رقم الهاتف (اختياري)',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: ProfessionalTheme.space32),

                            // Terms and Conditions
                            Container(
                              padding: const EdgeInsets.all(
                                  ProfessionalTheme.space16),
                              decoration: BoxDecoration(
                                color: ProfessionalTheme.surfaceCard
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(
                                    ProfessionalTheme.radiusM),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: agreeTerms,
                                      onChanged: (v) => setState(
                                          () => agreeTerms = v ?? false),
                                      activeColor:
                                          ProfessionalTheme.primaryBrand,
                                      checkColor: ProfessionalTheme.textPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: ProfessionalTheme.space12),
                                  Expanded(
                                    child: Text(
                                      'أوافق على الشروط والأحكام وسياسة الخصوصية',
                                      style: ProfessionalTheme.bodyMedium(
                                        color: ProfessionalTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: ProfessionalTheme.space32),

                            // Save Button
                            _buildProfessionalButton(
                              onPressed: _saving ? null : _save,
                              isLoading: _saving,
                              text: 'حفظ التغييرات',
                            ),

                            const SizedBox(height: ProfessionalTheme.space16),

                            // Back Button
                            TextButton(
                              onPressed:
                                  _saving ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    ProfessionalTheme.textSecondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: ProfessionalTheme.space12,
                                ),
                              ),
                              child: Text(
                                'العودة للخلف',
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfessionalTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          style: ProfessionalTheme.bodyLarge(
            color: ProfessionalTheme.textPrimary,
          ),
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
            prefixIcon: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: ProfessionalTheme.space12,
              ),
              child: Icon(
                icon,
                color: focusNode.hasFocus
                    ? ProfessionalTheme.primaryBrand
                    : ProfessionalTheme.textTertiary,
                size: 20,
              ),
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
