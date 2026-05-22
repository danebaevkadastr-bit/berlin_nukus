/// Guruh haftalari: boshlanish sanasidan joriy haftaning yakshanbasigacha,
/// keyingi haftalar dushanba–yakshanba.
class CourseWeekRange {
  final DateTime start;
  final DateTime end;
  final int index;

  const CourseWeekRange({
    required this.start,
    required this.end,
    required this.index,
  });
}

class CourseWeekUtils {
  CourseWeekUtils._();

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// [weeksCount] ta hafta: 1-hafta qisman (boshlanish → yakshanba), qolganlari to'liq.
  static List<CourseWeekRange> generateWeeks(DateTime startDate, int weeksCount) {
    if (weeksCount <= 0) return [];

    final anchor = _dateOnly(startDate);
    final weeks = <CourseWeekRange>[];

    var weekStart = anchor;
    var weekEnd = anchor.add(Duration(days: 7 - anchor.weekday));
    weeks.add(CourseWeekRange(start: weekStart, end: weekEnd, index: 0));

    weekStart = weekEnd.add(const Duration(days: 1));
    for (var i = 1; i < weeksCount; i++) {
      weekEnd = weekStart.add(const Duration(days: 6));
      weeks.add(CourseWeekRange(start: weekStart, end: weekEnd, index: i));
      weekStart = weekEnd.add(const Duration(days: 1));
    }

    return weeks;
  }

  /// Hafta oralig'idagi har bir kun (start..end inclusive).
  static Iterable<DateTime> daysInWeek(CourseWeekRange week) sync* {
    var date = _dateOnly(week.start);
    final end = _dateOnly(week.end);
    while (!date.isAfter(end)) {
      yield date;
      date = date.add(const Duration(days: 1));
    }
  }
}
