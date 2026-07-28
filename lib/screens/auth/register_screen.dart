import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: { "#": RegExp(r'[0-9]') },
  );

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _handleRegister() async {
    final l = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.fillAllFields, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // Email format validatsiyasi
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.enterValidEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.passwordsDontMatch, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.passwordMin6, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).register(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
        role: 'student',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.registerSuccess, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      String errorMsg = l.genericError;
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMsg = l.emailInUse;
        } else if (e.message != null) {
          errorMsg = e.message!;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+998 ';
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  ),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.duoGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        size: 48,
                        color: AppColors.duoGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  final l = AppLocalizations.of(context);
                  return Column(
                    children: [
                      Text(
                        l.register.toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.duoTextDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),
                Builder(builder: (context) {
                  final l = AppLocalizations.of(context);
                  return GamifiedCard(
                    padding: const EdgeInsets.all(24),
                    color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                    shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: l.fullNameLabel,
                          icon: Icons.person_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _emailController,
                          label: l.email,
                          icon: Icons.email_rounded,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneController,
                          label: l.phone,
                          icon: Icons.phone_iphone_rounded,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneFormatter],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _passwordController,
                          label: l.password,
                          icon: Icons.lock_rounded,
                          isDark: isDark,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: l.confirmPassword,
                          icon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: GamifiedCard(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            color: AppColors.duoGreen,
                            shadowColor: AppColors.duoGreenShadow,
                            shadowDepth: 5,
                            onTap: _isLoading ? null : _handleRegister,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Text(
                                      l.submit.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            l.haveAccountLogin,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : AppColors.duoBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.duoTextDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppColors.duoTextLight,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}