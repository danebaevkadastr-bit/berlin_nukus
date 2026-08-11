import 'grammar_explanation.dart';

class GrammarLevel {
  final String id;
  final String level; // A1, A2, B1, B2
  final String title;
  final String description;
  final String emoji;
  final List<GrammarCategory> categories;

  GrammarLevel({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.emoji,
    required this.categories,
  });

  factory GrammarLevel.fromJson(Map<String, dynamic> json) {
    return GrammarLevel(
      id: json['id'] as String,
      level: json['level'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => GrammarCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'title': title,
      'description': description,
      'emoji': emoji,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}

class GrammarCategory {
  final String id;
  final String name;
  final String icon;
  final List<GrammarTopic> topics;

  GrammarCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.topics,
  });

  factory GrammarCategory.fromJson(Map<String, dynamic> json) {
    return GrammarCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => GrammarTopic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'topics': topics.map((e) => e.toJson()).toList(),
    };
  }
}

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final List<GrammarRule> rules;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.rules,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rules: (json['rules'] as List<dynamic>)
          .map((e) => GrammarRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rules': rules.map((e) => e.toJson()).toList(),
    };
  }
}

class GrammarRule {
  final String id;
  final String title;
  final String explanation;
  final List<String> examples;
  final List<String>? exceptions;

  /// Batafsil tushuntirish (ixtiyoriy, orqaga muvofiqlik uchun)
  final GrammarExplanation? detailedExplanation;

  GrammarRule({
    required this.id,
    required this.title,
    required this.explanation,
    required this.examples,
    this.exceptions,
    this.detailedExplanation,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String,
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      examples: (json['examples'] as List<dynamic>).map((e) => e as String).toList(),
      exceptions: json['exceptions'] != null
          ? (json['exceptions'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      detailedExplanation: json['detailedExplanation'] != null
          ? GrammarExplanation.fromJson(json['detailedExplanation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'explanation': explanation,
      'examples': examples,
      if (exceptions != null) 'exceptions': exceptions,
      if (detailedExplanation != null) 'detailedExplanation': detailedExplanation!.toJson(),
    };
  }
}
