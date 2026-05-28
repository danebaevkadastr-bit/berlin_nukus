import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Mavzu bo'yicha chat holati va xabarlar (SharedPreferences).
class ChatProgressService {
  static const int maxUserMessagesPerTopic = 25;
  static const int minChatMessageLimit = 10;
  static const int maxChatMessageLimit = 25;
  static const String _messageLimitKey = 'chat_message_limit';

  static Future<int> getChatMessageLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_messageLimitKey) ?? maxChatMessageLimit;
    return v.clamp(minChatMessageLimit, maxChatMessageLimit);
  }

  static Future<void> setChatMessageLimit(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _messageLimitKey,
      count.clamp(minChatMessageLimit, maxChatMessageLimit),
    );
  }

  static int countWords(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  /// AI ga yuboriladigan tarixni xabarlar soni bo'yicha qisqartiradi.
  static List<Map<String, dynamic>> trimHistoryByMessageLimit(
    List<Map<String, dynamic>> history,
    int maxMessages,
  ) {
    if (maxMessages <= 0 || history.isEmpty) return history;
    if (history.length <= maxMessages) return history;
    return history.sublist(history.length - maxMessages);
  }

  static String _slug(String sourceType, String title) {
    final raw = '${sourceType}_${title.trim().toLowerCase()}';
    return raw.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
  }

  static String _completedKey(String sourceType, String title) =>
      'chat_completed_${_slug(sourceType, title)}';

  static String _messagesKey(String sourceType, String title) =>
      'chat_messages_${_slug(sourceType, title)}';

  static Future<bool> isCompleted(String sourceType, String title) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey(sourceType, title)) ?? false;
  }

  static Future<void> markCompleted(String sourceType, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey(sourceType, title), true);
  }

  static Future<void> clearCompleted(String sourceType, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey(sourceType, title));
  }

  static Future<List<Map<String, dynamic>>> loadMessages(
    String sourceType,
    String title,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_messagesKey(sourceType, title));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMessages(
    String sourceType,
    String title,
    List<Map<String, dynamic>> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _messagesKey(sourceType, title),
      jsonEncode(messages),
    );
  }

  static Future<void> clearMessages(String sourceType, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey(sourceType, title));
  }

  /// Suhbatlar ro'yxati uchun tugallangan mavzu sarlavhalari.
  static Future<Set<String>> completedTitlesFor(
    String sourceType,
    Iterable<String> titles,
  ) async {
    final result = <String>{};
    for (final t in titles) {
      if (await isCompleted(sourceType, t)) result.add(t);
    }
    return result;
  }
}
