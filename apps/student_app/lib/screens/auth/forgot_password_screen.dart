import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final l = AppLocalizations.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
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

    // Basic email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<UserProvider>(context, listen: false).resetPassword(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.resetLinkSent, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMsg = l.tryAgainLater;
      if (e is FirebaseAuthException && e.message != null) {
        errorMsg = e.message!;
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
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: (_isSuccess ? AppColors.duoGreen : AppColors.duoOrange).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        _isSuccess ? '✉️' : '🤔',
                        style: const TextStyle(fontSize: 54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.forgotPassword.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSuccess 
                      ? l.resetLinkSent
                      : l.forgotPasswordSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight,
                  ),
                ),
                const SizedBox(height: 32),
                GamifiedCard(
                  padding: const EdgeInsets.all(24),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  child: _isSuccess 
                      ? Column(
                          children: [
                            const Text(
                              '📬',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _emailController.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.duoBlue : AppColors.duoTextDark,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: GamifiedCard(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                color: AppColors.duoBlue,
                                shadowColor: AppColors.duoBlueShadow,
                                shadowDepth: 5,
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    l.back.toUpperCase(),
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
                          ],
                        )
                      : Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              label: l.email,
                              icon: '📧',
                              isDark: isDark,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: GamifiedCard(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                color: AppColors.duoOrange,
                                shadowColor: AppColors.duoOrangeShadow,
                                shadowDepth: 5,
                                onTap: _isLoading ? null : _handleResetPassword,
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                        )
                                      : Text(
                                          l.sendResetLink.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
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
                                l.back.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.duoBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
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
    required String icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
