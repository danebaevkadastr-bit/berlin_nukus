import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GamifiedCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color shadowColor;
  final double borderRadius;
  final double shadowDepth;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GamifiedCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.shadowColor = AppColors.duoCardGrayShadow,
    this.borderRadius = 20.0,
    this.shadowDepth = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(0, shadowDepth),
            blurRadius: 0,
          ),
        ],
        border: Border.all(
          color: shadowColor.withValues(alpha: 0.5),
          width: 2.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
