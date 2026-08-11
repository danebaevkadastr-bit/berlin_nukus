import 'package:flutter/material.dart';

class SlideTransitionPage extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;

  SlideTransitionPage({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.rightToLeft:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.leftToRight:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.topToBottom:
                begin = const Offset(0.0, -1.0);
                break;
              case SlideDirection.bottomToTop:
                begin = const Offset(0.0, 1.0);
                break;
            }
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

enum SlideDirection {
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
}

class FadeTransitionPage extends PageRouteBuilder {
  final Widget child;

  FadeTransitionPage({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class ScaleTransitionPage extends PageRouteBuilder {
  final Widget child;

  ScaleTransitionPage({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            );
          },
        );
}

class FadeScaleTransitionPage extends PageRouteBuilder {
  final Widget child;

  FadeScaleTransitionPage({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

class SlideFadeTransitionPage extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;

  SlideFadeTransitionPage({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.rightToLeft:
                begin = const Offset(0.3, 0.0);
                break;
              case SlideDirection.leftToRight:
                begin = const Offset(-0.3, 0.0);
                break;
              case SlideDirection.topToBottom:
                begin = const Offset(0.0, -0.3);
                break;
              case SlideDirection.bottomToTop:
                begin = const Offset(0.0, 0.3);
                break;
            }
            const end = Offset.zero;

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
