import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/schedule_group.dart';
import '../domain/schedule_type.dart';
import 'line_endpoints.dart';

/// Raw shape decoded straight from `assets/schedules/train_schedule_N.json`:
/// { "1" | "2" (path) : { stationNameEn : { "<dest><typeId>" : [times] } } }
typedef _RawScheduleData = Map<String, Map<String, Map<String, List<double>>>>;

/// Loads and caches the static Tehran-metro timetables (one JSON file per
/// line, bundled as assets) and looks up the departure-time lists for a
/// given station, exactly like the rival app's `ScheduleRepositoryImpl`.
///
/// These are *fixed, scheduled* departure times — there is no live GPS
/// tracking of trains — but combined with a ticking clock they give a
/// "next train in mm:ss" experience.
class TrainScheduleRepository {
  TrainScheduleRepository._();

  static final TrainScheduleRepository instance = TrainScheduleRepository._();

  static const Map<int, String> _assetPaths = {
    1: 'assets/schedules/train_schedule_1.json',
    2: 'assets/schedules/train_schedule_2.json',
    3: 'assets/schedules/train_schedule_3.json',
    4: 'assets/schedules/train_schedule_4.json',
    5: 'assets/schedules/train_schedule_5.json',
    6: 'assets/schedules/train_schedule_6.json',
    7: 'assets/schedules/train_schedule_7.json',
  };

  final Map<int, _RawScheduleData> _cache = {};

  /// Returns every destination's timetable for [stationNameEn] on line
  /// [lineNumber]. If [isBranch] is true and the line has a branch, the
  /// branch path is preferred (falling back to the main path if the
  /// station isn't on the branch).
  Future<List<ScheduleGroup>> getByStation({
    required String stationNameEn,
    required int lineNumber,
    bool isBranch = false,
  }) async {
    final schedule = await _getLineSchedule(lineNumber);
    if (schedule.isEmpty) return const [];

    final mainPath = schedule['1']?[stationNameEn];
    final branchPath = schedule['2']?[stationNameEn];

    Map<String, List<double>>? scheduleData;
    bool useBranchEndpoints;
    if (isBranch && branchPath != null) {
      scheduleData = branchPath;
      useBranchEndpoints = true;
    } else if (isBranch && mainPath != null) {
      scheduleData = mainPath;
      useBranchEndpoints = false;
    } else if (!isBranch && mainPath != null) {
      scheduleData = mainPath;
      useBranchEndpoints = false;
    } else if (!isBranch && branchPath != null) {
      scheduleData = branchPath;
      useBranchEndpoints = true;
    } else {
      return const [];
    }

    final endpointsEn =
        LineEndpoints.getEn(lineNumber, useBranch: useBranchEndpoints);
    final endpointsFa =
        LineEndpoints.getFa(lineNumber, useBranch: useBranchEndpoints);
    if (endpointsEn == null || endpointsFa == null) return const [];

    // destination(en,fa) -> ScheduleType -> times
    final grouped = <String, Map<String, dynamic>>{};

    scheduleData.forEach((scheduleKey, times) {
      final scheduleType = ScheduleType.fromScheduleKey(scheduleKey);
      if (scheduleType == null) return;

      final towardsStation =
          scheduleKey.substring(0, scheduleKey.length - 1);

      String validEn;
      String validFa;
      if (towardsStation == endpointsEn.$1) {
        validEn = endpointsEn.$1;
        validFa = endpointsFa.$1;
      } else if (towardsStation == endpointsEn.$2) {
        validEn = endpointsEn.$2;
        validFa = endpointsFa.$2;
      } else {
        // Fall back to the first terminus, matching the rival app's
        // behaviour for keys it doesn't recognize.
        validEn = endpointsEn.$1;
        validFa = endpointsFa.$1;
      }

      final bucket = grouped.putIfAbsent(
        validEn,
        () => {'fa': validFa, 'schedules': <ScheduleType, List<double>>{}},
      );
      (bucket['schedules'] as Map<ScheduleType, List<double>>)[scheduleType] =
          times;
    });

    return grouped.entries
        .map((e) => ScheduleGroup(
              destinationEn: e.key,
              destinationFa: e.value['fa'] as String,
              schedules:
                  e.value['schedules'] as Map<ScheduleType, List<double>>,
            ))
        .toList(growable: false);
  }

  Future<_RawScheduleData> _getLineSchedule(int lineNumber) async {
    final cached = _cache[lineNumber];
    if (cached != null) return cached;

    final path = _assetPaths[lineNumber];
    if (path == null) return {};

    final text = await rootBundle.loadString(path);
    final decoded = json.decode(text) as Map<String, dynamic>;

    final data = decoded.map<String, Map<String, Map<String, List<double>>>>(
      (pathKey, stations) => MapEntry(
        pathKey,
        (stations as Map<String, dynamic>).map<String, Map<String, List<double>>>(
          (stationName, keys) => MapEntry(
            stationName,
            (keys as Map<String, dynamic>).map<String, List<double>>(
              (scheduleKey, times) => MapEntry(
                scheduleKey,
                (times as List<dynamic>)
                    .map((t) => (t as num).toDouble())
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );

    _cache[lineNumber] = data;
    return data;
  }
}
