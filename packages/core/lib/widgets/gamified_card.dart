import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/haptic_service.dart';

class GamifiedCard extends StatefulWidget {
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
  State<GamifiedCard> createState() => _GamifiedCardState();
}

class _GamifiedCardState extends State<GamifiedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      HapticService.lightImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            offset: Offset(0, widget.shadowDepth),
            blurRadius: 0,
          ),
        ],
        border: Border.all(
          color: widget.shadowColor.withValues(alpha: 0.5),
          width: 2.0,
        ),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
