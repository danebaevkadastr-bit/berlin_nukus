import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:core/core/auth_navigation.dart';
import 'package:core/core/providers/user_provider.dart';
import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'auth/login_screen.dart';
import 'student/student_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      AuthNavigation.resolveInitialRole(userProvider),
    ]);

    if (!mounted) return;

    final role = results[1] as String?;
    Widget nextScreen = const LoginScreen();
    if (role == 'student') {
      nextScreen = const StudentHomeScreen();
    } else if (role != null) {
      await userProvider.logout();
    }
    
    AuthNavigation.replaceWith(
      context,
      nextScreen,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.skyBlue,
              AppColors.nukusBlue,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.cloudWhite,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/logo.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance_rounded,
                                size: 80,
                                color: Color(0xFF5C6BC0),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'AwaDe',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cloudWhite,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).loading,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.cloudWhite.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
