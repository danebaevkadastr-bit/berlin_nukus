import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GamifiedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final double shadowDepth;
  final IconData? icon;

  const GamifiedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.duoGreen,
    this.shadowColor = AppColors.duoGreenShadow,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.shadowDepth = 6.0,
    this.icon,
  });

  @override
  State<GamifiedButton> createState() => _GamifiedButtonState();
}

class _GamifiedButtonState extends State<GamifiedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height + widget.shadowDepth,
        margin: EdgeInsets.only(top: _isPressed ? widget.shadowDepth : 0.0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, widget.shadowDepth),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.textColor, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
