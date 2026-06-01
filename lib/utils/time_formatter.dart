import '../l10n/app_localizations.dart';

/// Daqiqalarni o'qilishi oson formatga o'girish
/// @param minutes - Daqiqalar soni
/// @param l - AppLocalizations instance
/// @returns Formatlangan string (masalan: "2 soat 30 daqiqa" yoki "45 daqiqa")
String formatMinutes(int minutes, AppLocalizations l) {
  if (minutes < 60) {
    return l.minutesFormat(minutes);
  }
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (remainingMinutes == 0) {
    return l.hoursFormat(hours);
  }
  return l.hoursMinutesFormat(hours, remainingMinutes);
}
