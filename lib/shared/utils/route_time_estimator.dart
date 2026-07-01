import '../../core/utils/geo_utils.dart';
import '../enums/route_step_type.dart';
import '../models/route_step.dart';

/// Estimates how long a route takes, in the absence of a full,
/// per-edge scheduled-travel-time dataset.
///
/// We don't have real inter-station travel times or per-line headways in
/// the bundled data — only, per station, the list of clock times each
/// destination's trains depart (see `TrainScheduleRepository`). So instead
/// of pretending to do full timetable-based routing, this uses a simple,
/// transparent physical model:
///   • riding between two adjacent stations takes distance / averageSpeed
///   • every intermediate stop adds a fixed dwell time
///   • every line change adds a fixed "average wait for the next train"
///     penalty
///
/// This is enough to meaningfully rank "fewest stations" vs "least
/// distance" vs "least line changes" candidates by *time* and to show a
/// friendly ETA — it is an estimate, not a live prediction.
abstract final class RouteTimeEstimator {
  /// Average scheduled speed of a metro train, including acceleration/
  /// deceleration between closely-spaced stations (~35 km/h).
  static const double averageSpeedMetersPerSecond = 35 * 1000 / 3600;

  /// Time spent stopped at each intermediate station.
  static const double dwellSecondsPerStop = 25;

  /// Average wait for a train on the new line after a transfer.
  static const double transferPenaltySeconds = 4 * 60;

  static double travelSeconds(double distanceMeters) =>
      distanceMeters / averageSpeedMetersPerSecond;

  /// Total estimated seconds for an already-built [RouteStep] timeline.
  static double estimateSeconds(List<RouteStep> steps) {
    if (steps.length < 2) return 0;

    var total = 0.0;
    for (var i = 1; i < steps.length; i++) {
      final step = steps[i];
      final previous = steps[i - 1];

      if (step.type == RouteStepType.changeLine) {
        total += transferPenaltySeconds;
        continue;
      }

      total += travelSeconds(
        GeoUtils.distanceBetweenStations(previous.station, step.station),
      );
      total += dwellSecondsPerStop;
    }
    return total;
  }

  static double estimateMinutes(List<RouteStep> steps) =>
      estimateSeconds(steps) / 60;

  /// "N دقیقه" / "H:MM" friendly label for a minutes value.
  static String formatMinutes(double minutes) {
    final rounded = minutes.round();
    if (rounded < 60) return '$rounded دقیقه';
    final hours = rounded ~/ 60;
    final mins = rounded % 60;
    return '$hours ساعت و $mins دقیقه';
  }
}
