import 'package:flutter/material.dart';
import '../../models/grammar_example.dart';
import '../../utils/app_colors.dart';

/// Formatlangan misollarni ko'rsatuvchi widget
///
/// Har bir misolni raqamlangan ro'yxat sifatida ko'rsatadi:
/// - Nemischa jumla qalin shriftda
/// - O'zbekcha tarjima kursiv shriftda
/// - Izoh alohida rangda (agar mavjud bo'lsa)
class GrammarExampleWidget extends StatelessWidget {
  /// Formatlangan misollar ro'yxati
  final List<GrammarExample> examples;

  /// Daraja rangi (izoh va raqamlar uchun)
  final Color accentColor;

  /// Qorong'i rejim
  final bool isDark;

  const GrammarExampleWidget({
    super.key,
    required this.examples,
    required this.accentColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sarlavha
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Misollar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        // Misollar ro'yxati
        ...examples.asMap().entries.map((entry) {
          final index = entry.key;
          final example = entry.value;
          return _buildExampleItem(context, index + 1, example);
        }),
      ],
    );
  }

  /// Bitta misol elementini yaratish
  Widget _buildExampleItem(
    BuildContext context,
    int number,
    GrammarExample example,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Raqam
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Misol matni
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nemischa jumla (qalin shrift)
                Text(
                  example.german,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                // O'zbekcha tarjima (kursiv shrift)
                Text(
                  example.uzbek,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                // Izoh (agar mavjud bo'lsa)
                if (example.note != null && example.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            example.note!,
                            style: TextStyle(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
