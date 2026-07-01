import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/schedule_repository.dart';
import '../../domain/schedule_group.dart';
import '../../domain/schedule_time_utils.dart';
import '../../domain/schedule_type.dart';

class TrainScheduleState extends Equatable {
  final bool isLoading;
  final String stationNameFa;
  final int lineNumber;
  final List<ScheduleGroup> schedules;

  /// destinationEn -> the ScheduleType the user has picked (null = "today").
  final Map<String, ScheduleType?> selectedScheduleTypes;

  /// destinationEn -> sections for that destination, ready to render.
  final Map<String, List<ScheduleSection>> processedSchedules;

  final double currentTimeAsFraction;
  final ScheduleType? currentDayType;

  const TrainScheduleState({
    this.isLoading = true,
    this.stationNameFa = '',
    this.lineNumber = 0,
    this.schedules = const [],
    this.selectedScheduleTypes = const {},
    this.processedSchedules = const {},
    this.currentTimeAsFraction = 0,
    this.currentDayType,
  });

  TrainScheduleState copyWith({
    bool? isLoading,
    String? stationNameFa,
    int? lineNumber,
    List<ScheduleGroup>? schedules,
    Map<String, ScheduleType?>? selectedScheduleTypes,
    Map<String, List<ScheduleSection>>? processedSchedules,
    double? currentTimeAsFraction,
    ScheduleType? currentDayType,
  }) {
    return TrainScheduleState(
      isLoading: isLoading ?? this.isLoading,
      stationNameFa: stationNameFa ?? this.stationNameFa,
      lineNumber: lineNumber ?? this.lineNumber,
      schedules: schedules ?? this.schedules,
      selectedScheduleTypes: selectedScheduleTypes ?? this.selectedScheduleTypes,
      processedSchedules: processedSchedules ?? this.processedSchedules,
      currentTimeAsFraction: currentTimeAsFraction ?? this.currentTimeAsFraction,
      currentDayType: currentDayType ?? this.currentDayType,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        stationNameFa,
        lineNumber,
        schedules,
        selectedScheduleTypes,
        processedSchedules,
        currentTimeAsFraction,
        currentDayType,
      ];
}

/// Loads the static timetable for a station/line, works out which
/// [ScheduleType] applies "today", and ticks every second so a "next
/// train in mm:ss" countdown stays live.
class TrainScheduleCubit extends Cubit<TrainScheduleState> {
  final TrainScheduleRepository _repository;
  Timer? _ticker;

  TrainScheduleCubit({TrainScheduleRepository? repository})
      : _repository = repository ?? TrainScheduleRepository.instance,
        super(const TrainScheduleState());

  Future<void> load({
    required String stationNameEn,
    required String stationNameFa,
    required int lineNumber,
    bool isBranch = false,
  }) async {
    emit(state.copyWith(isLoading: true, lineNumber: lineNumber, stationNameFa: stationNameFa));

    final schedules = await _repository.getByStation(
      stationNameEn: stationNameEn,
      lineNumber: lineNumber,
      isBranch: isBranch,
    );

    final allTypes = schedules.expand((g) => g.schedules.keys).toList();
    final currentDayType = ScheduleType.forDay(allTypes, DateTime.now().weekday);
    final currentTime = ScheduleTimeUtils.currentTimeAsFraction();

    final selected = <String, ScheduleType?>{};
    final processed = <String, List<ScheduleSection>>{};

    for (final group in schedules) {
      final keys = group.schedules.keys;
      final pick = keys.contains(currentDayType)
          ? currentDayType
          : (keys.contains(ScheduleType.allDay)
              ? ScheduleType.allDay
              : (keys.isNotEmpty ? keys.first : null));
      selected[group.destinationEn] = pick;

      processed[group.destinationEn] = group.schedules.entries
          .map((e) => ScheduleSection(
                type: e.key,
                times: e.value,
                isCurrentDay: e.key == currentDayType || e.key == ScheduleType.allDay,
              ))
          .toList(growable: false);
    }

    emit(state.copyWith(
      isLoading: false,
      schedules: schedules,
      selectedScheduleTypes: selected,
      processedSchedules: processed,
      currentDayType: currentDayType,
      currentTimeAsFraction: currentTime,
    ));

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(currentTimeAsFraction: ScheduleTimeUtils.currentTimeAsFraction()));
    });
  }

  void selectScheduleType(String destinationEn, ScheduleType? type) {
    final group = state.schedules.where((g) => g.destinationEn == destinationEn).firstOrNull;
    if (group == null) return;

    final newSections = group.schedules.entries
        .map((e) => ScheduleSection(
              type: e.key,
              times: e.value,
              isCurrentDay: e.key == state.currentDayType || e.key == ScheduleType.allDay,
            ))
        .toList(growable: false);

    emit(state.copyWith(
      selectedScheduleTypes: {...state.selectedScheduleTypes, destinationEn: type},
      processedSchedules: {...state.processedSchedules, destinationEn: newSections},
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
