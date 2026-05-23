import 'package:flutter/services.dart';

class HapticService {
  HapticService._internal();

  /// Light impact - for light taps
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium impact - for button presses
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy impact - for important actions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Selection click - for selection changes
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Vibrate - for notifications
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
