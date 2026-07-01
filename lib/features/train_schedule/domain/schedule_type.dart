/// Which set of days a timetable applies to.
///
/// Mirrors the rival Tehran-metro app's static timetable format: every
/// departure-time list is tagged with one of these, encoded as the last
/// digit of its JSON key (e.g. "Tajrish0" -> [SATURDAY_TO_WEDNESDAY]).
enum ScheduleType {
  saturdayToWednesday(0),
  thursday(1),
  friday(2),
  allDay(3),
  saturdayToThursday(4),
  holidaysAndFriday(5);

  final int id;

  const ScheduleType(this.id);

  static ScheduleType? fromId(int id) {
    for (final type in ScheduleType.values) {
      if (type.id == id) return type;
    }
    return null;
  }

  /// Parses the trailing digit off a raw schedule key, e.g. "Tajrish0" -> 0.
  static ScheduleType? fromScheduleKey(String key) {
    if (key.isEmpty) return null;
    final lastChar = key[key.length - 1];
    final digit = int.tryParse(lastChar);
    if (digit == null) return null;
    return fromId(digit);
  }

  /// Given the current (or supplied) ISO day-of-week (1=Monday..7=Sunday),
  /// picks which [ScheduleType] governs "today" out of the ones available
  /// for a given destination.
  static ScheduleType? forDay(
    List<ScheduleType> available,
    int isoDayOfWeek,
  ) {
    ScheduleType? find(bool Function(ScheduleType) test) {
      for (final t in available) {
        if (test(t)) return t;
      }
      return null;
    }

    switch (isoDayOfWeek) {
      // Saturday(6), Sunday(7), Monday(1), Tuesday(2), Wednesday(3)
      case 6:
      case 7:
      case 1:
      case 2:
      case 3:
        return find((t) =>
            t == ScheduleType.saturdayToWednesday ||
            t == ScheduleType.allDay ||
            t == ScheduleType.saturdayToThursday);
      case 4: // Thursday
        return find((t) =>
            t == ScheduleType.thursday ||
            t == ScheduleType.allDay ||
            t == ScheduleType.saturdayToThursday);
      case 5: // Friday
        return find((t) =>
            t == ScheduleType.friday ||
            t == ScheduleType.allDay ||
            t == ScheduleType.holidaysAndFriday);
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ScheduleType.saturdayToWednesday:
        return 'شنبه تا چهارشنبه';
      case ScheduleType.thursday:
        return 'پنجشنبه';
      case ScheduleType.friday:
        return 'جمعه';
      case ScheduleType.allDay:
        return 'همه روزه';
      case ScheduleType.saturdayToThursday:
        return 'شنبه تا پنجشنبه';
      case ScheduleType.holidaysAndFriday:
        return 'جمعه و تعطیلات';
    }
  }
}
