import 'schedule_type.dart';

/// All the departure-time lists towards a single [destinationEn]/[destinationFa]
/// terminus, keyed by which days ([ScheduleType]) they apply to.
///
/// Times are fractions of a day: 0.0 = 00:00:00, 1.0 = 24:00:00.
class ScheduleGroup {
  final String destinationEn;
  final String destinationFa;
  final Map<ScheduleType, List<double>> schedules;

  const ScheduleGroup({
    required this.destinationEn,
    required this.destinationFa,
    required this.schedules,
  });
}

/// One destination's timetable, narrowed down to the [ScheduleType] that
/// applies "today" (or another user-selected day type).
class ScheduleSection {
  final ScheduleType type;
  final List<double> times;
  final bool isCurrentDay;

  const ScheduleSection({
    required this.type,
    required this.times,
    required this.isCurrentDay,
  });
}
