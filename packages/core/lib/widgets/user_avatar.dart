import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/app_colors.dart';

/// Profil rasmi yoki fallback emoji.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String fallbackEmoji;
  final Color? backgroundColor;
  final double borderRadius;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.fallbackEmoji = '🧑',
    this.backgroundColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final bg = backgroundColor ?? AppColors.duoBlue.withValues(alpha: 0.15);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: size,
              height: size,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => Center(
        child: Text(fallbackEmoji, style: TextStyle(fontSize: size * 0.48)),
      );
}
