/// Helpers for working with the schedule JSON's "fraction of day" time
/// format (0.0 = 00:00:00 .. 1.0 = 24:00:00), ported from the rival app's
/// `TimeUtils`.
class ScheduleTimeUtils {
  ScheduleTimeUtils._();

  static double currentTimeAsFraction([DateTime? now]) {
    final n = now ?? DateTime.now();
    final secondsOfDay = n.hour * 3600 + n.minute * 60 + n.second;
    return secondsOfDay / 86400.0;
  }

  /// "HH:mm" for a fraction-of-day value.
  static String fractionToTime(double fraction) {
    final totalSeconds = (fraction * 86400).floor();
    final hours = (totalSeconds ~/ 3600) % 24;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// "HH:mm:ss" countdown from now until [target] (fraction of day).
  /// Returns "00:00:00" once [target] has passed.
  static String remainingTime(double target, [DateTime? now]) {
    final currentFraction = currentTimeAsFraction(now);
    final remainingFraction = target - currentFraction;
    if (remainingFraction <= 0) return '00:00:00';

    final totalSeconds = (remainingFraction * 86400).floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Short "mm:ss" or "H:mm:ss" countdown, friendlier for a compact chip.
  static String remainingTimeShort(double target, [DateTime? now]) {
    final currentFraction = currentTimeAsFraction(now);
    final remainingFraction = target - currentFraction;
    if (remainingFraction <= 0) return '۰۰:۰۰';

    final totalSeconds = (remainingFraction * 86400).floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  static String toFarsiNumber(String input) {
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      final digit = int.tryParse(ch);
      buffer.write(digit == null ? ch : _persianDigits[digit]);
    }
    return buffer.toString();
  }
}
