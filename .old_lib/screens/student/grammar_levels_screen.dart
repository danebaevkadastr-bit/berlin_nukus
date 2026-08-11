import 'package:flutter/material.dart';
import '../../models/grammar_level.dart';
import '../../services/grammar_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import 'grammar_topics_screen.dart';

class GrammarLevelsScreen extends StatelessWidget {
  const GrammarLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final levels = GrammarService().getAllLevels();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Grammatika',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Darajani tanlang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              ...levels.map((level) => _buildLevelCard(context, level, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GrammarLevel level, bool isDark) {
    Color cardColor;
    Color shadowColor;

    switch (level.level) {
      case 'A1':
        cardColor = AppColors.duoGreen;
        shadowColor = AppColors.duoGreenShadow;
        break;
      case 'A2':
        cardColor = AppColors.duoBlue;
        shadowColor = AppColors.duoBlueShadow;
        break;
      case 'B1':
        cardColor = AppColors.duoOrange;
        shadowColor = AppColors.duoOrangeShadow;
        break;
      case 'B2':
        cardColor = AppColors.duoRed;
        shadowColor = AppColors.duoRedShadow;
        break;
      default:
        cardColor = AppColors.duoGreen;
        shadowColor = AppColors.duoGreenShadow;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamifiedCard(
        color: cardColor,
        shadowColor: shadowColor,
        shadowDepth: 6,
        padding: const EdgeInsets.all(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrammarTopicsScreen(level: level),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  level.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${level.level} - ${level.title}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${level.categories.length} kategoriya',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
