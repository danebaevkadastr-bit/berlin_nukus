import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/auth_navigation.dart';
import '../../core/providers/user_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    final l = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Barcha maydonlarni to\'ldiring', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.duoOrange,
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(email, password);
      
      // Force reload data to guarantee accurate role resolving
      if (userProvider.firebaseUser != null) {
        await userProvider.loadUserDataByUid(userProvider.firebaseUser!.uid);
      }

      if (!mounted) return;

      AuthNavigation.replaceWith(
        context,
        AuthNavigation.homeScreenForRole(userProvider.role),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      
      String errorMsg = l.wrongCredentials;
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMsg = "Ushbu elektron pochta ro'yxatdan o'tmagan.";
        } else if (e.code == 'wrong-password') {
          errorMsg = "Parol noto'g'ri kiritildi.";
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                      color: AppColors.duoBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text('🦉', style: TextStyle(fontSize: 54)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BERLIN-NUKUS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).loginSubtitle,
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
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: AppLocalizations.of(context).email,
                        icon: Icons.email_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: AppLocalizations.of(context).password,
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).forgotPassword,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.duoBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GamifiedCard(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          color: AppColors.duoGreen,
                          shadowColor: AppColors.duoGreenShadow,
                          shadowDepth: 5,
                          onTap: _isLoading ? null : _handleLogin,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : Text(
                                    AppLocalizations.of(context).login.toUpperCase(),
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context).or.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white30 : Colors.black26,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: GamifiedCard(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: isDark ? AppColors.duoCardGray : Colors.white,
                          shadowColor: isDark ? Colors.black45 : AppColors.duoCardGrayShadow,
                          shadowDepth: 3,
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.g_mobiledata, color: AppColors.duoRed, size: 36),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).signInWithGoogle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.duoTextDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context).register,
                          style: const TextStyle(
                            fontSize: 16,
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
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
            child: Icon(icon, size: 20, color: isDark ? Colors.white54 : AppColors.duoTextLight),
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