import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool enabled;
  final double scaleDown;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.enabled = true,
    this.scaleDown = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enabled && widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? _handleTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.enabled
                ? widget.backgroundColor ?? Colors.blue
                : (widget.backgroundColor ?? Colors.blue).withValues(alpha: 0.5),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? Colors.white,
                fontWeight: FontWeight.w700,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final bool enabled;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 24,
    this.enabled = true,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enabled && widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? _handleTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size! * 2,
          height: widget.size! * 2,
          decoration: BoxDecoration(
            color: widget.enabled
                ? widget.backgroundColor ?? Colors.transparent
                : (widget.backgroundColor ?? Colors.transparent).withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.enabled
                ? widget.iconColor ?? Colors.white
                : (widget.iconColor ?? Colors.white).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
