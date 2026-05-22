/// Firestore `users` hujjatidan ism, telefon va avatar olish.
class UserProfileUtils {
  static String displayName(
    Map<String, dynamic> data, {
    String fallback = 'Noma\'lum',
  }) {
    final full = (data['fullName'] as String?)?.trim() ?? '';
    if (full.isNotEmpty) return full;

    final first = (data['firstName'] as String?)?.trim() ?? '';
    final last = (data['lastName'] as String?)?.trim() ?? '';
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;

    final name = (data['name'] as String?)?.trim() ?? '';
    if (name.isNotEmpty) return name;

    return fallback;
  }

  static String phone(Map<String, dynamic> data) =>
      (data['phone'] as String?)?.trim() ?? '';

  static String avatarUrl(Map<String, dynamic> data) =>
      (data['avatarUrl'] as String?)?.trim() ?? '';
}
