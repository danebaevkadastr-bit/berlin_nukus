import '../data/grammar_data.dart';
import '../models/grammar_level.dart';

class GrammarService {
  static final GrammarService _instance = GrammarService._internal();
  factory GrammarService() => _instance;
  GrammarService._internal();

  // Barcha darajalarni olish
  List<GrammarLevel> getAllLevels() {
    return GrammarData.allLevels;
  }

  // Ma'lum darajani olish
  GrammarLevel? getLevel(String levelId) {
    try {
      switch (levelId.toLowerCase()) {
        case 'a1':
          return GrammarData.a1Level;
        case 'a2':
          return GrammarData.a2Level;
        case 'b1':
          return GrammarData.b1Level;
        case 'b2':
          return GrammarData.b2Level;
        default:
          return GrammarData.allLevels.firstWhere(
            (level) => level.id == levelId,
            orElse: () => GrammarData.a1Level,
          );
      }
    } catch (e) {
      return null;
    }
  }

  // Ma'lum darajaning kategoriyasini olish
  GrammarCategory? getCategory(String levelId, String categoryId) {
    final level = getLevel(levelId);
    if (level == null) return null;

    try {
      return level.categories.firstWhere(
        (category) => category.id == categoryId,
      );
    } catch (e) {
      return null;
    }
  }

  // Ma'lum mavzuni olish
  GrammarTopic? getTopic(String levelId, String categoryId, String topicId) {
    final category = getCategory(levelId, categoryId);
    if (category == null) return null;

    try {
      return category.topics.firstWhere(
        (topic) => topic.id == topicId,
      );
    } catch (e) {
      return null;
    }
  }

  // Daraja progressini hisoblash (keyin foydalanish uchun)
  double calculateLevelProgress(String levelId, Set<String> completedTopics) {
    final level = getLevel(levelId);
    if (level == null) return 0.0;

    int totalTopics = 0;
    for (final category in level.categories) {
      totalTopics += category.topics.length;
    }

    if (totalTopics == 0) return 0.0;
    return completedTopics.length / totalTopics;
  }

  // Kategoriya progressini hisoblash
  double calculateCategoryProgress(
    String levelId,
    String categoryId,
    Set<String> completedTopics,
  ) {
    final category = getCategory(levelId, categoryId);
    if (category == null) return 0.0;

    int totalTopics = category.topics.length;
    if (totalTopics == 0) return 0.0;

    int completedCount = 0;
    for (final topic in category.topics) {
      if (completedTopics.contains(topic.id)) {
        completedCount++;
      }
    }

    return completedCount / totalTopics;
  }

  // Qidiruv
  List<GrammarRule> searchRules(String query) {
    final List<GrammarRule> results = [];
    final lowerQuery = query.toLowerCase();

    for (final level in GrammarData.allLevels) {
      for (final category in level.categories) {
        for (final topic in category.topics) {
          for (final rule in topic.rules) {
            if (rule.title.toLowerCase().contains(lowerQuery) ||
                rule.explanation.toLowerCase().contains(lowerQuery) ||
                rule.examples.any((example) =>
                    example.toLowerCase().contains(lowerQuery))) {
              results.add(rule);
            }
          }
        }
      }
    }

    return results;
  }
}
