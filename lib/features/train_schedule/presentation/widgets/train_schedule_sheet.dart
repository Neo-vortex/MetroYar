import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/schedule_group.dart';
import '../../domain/schedule_time_utils.dart';
import '../bloc/train_schedule_cubit.dart';
import 'schedule_time_tile.dart';

/// Bottom sheet showing live "next train" countdowns for a station, sourced
/// from the bundled static Tehran-metro timetable (one tab per destination).
class TrainScheduleSheet extends StatelessWidget {
  final String stationNameEn;
  final String stationNameFa;
  final int lineNumber;
  final bool isBranch;

  const TrainScheduleSheet({
    super.key,
    required this.stationNameEn,
    required this.stationNameFa,
    required this.lineNumber,
    this.isBranch = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String stationNameEn,
    required String stationNameFa,
    required int lineNumber,
    bool isBranch = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TrainScheduleSheet(
        stationNameEn: stationNameEn,
        stationNameFa: stationNameFa,
        lineNumber: lineNumber,
        isBranch: isBranch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainScheduleCubit()
        ..load(
          stationNameEn: stationNameEn,
          stationNameFa: stationNameFa,
          lineNumber: lineNumber,
          isBranch: isBranch,
        ),
      child: _TrainScheduleSheetBody(stationNameFa: stationNameFa, lineNumber: lineNumber),
    );
  }
}

class _TrainScheduleSheetBody extends StatelessWidget {
  final String stationNameFa;
  final int lineNumber;

  const _TrainScheduleSheetBody({required this.stationNameFa, required this.lineNumber});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lineColor = AppColors.lineColor(lineNumber);

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<TrainScheduleCubit, TrainScheduleState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.schedules.isEmpty) {
              return _EmptyState(stationNameFa: stationNameFa);
            }

            return DefaultTabController(
              length: state.schedules.length,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lineColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.schedule_rounded, color: lineColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'زمان‌بندی حرکت قطار',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                stationNameFa,
                                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  TabBar(
                    isScrollable: true,
                    labelColor: lineColor,
                    indicatorColor: lineColor,
                    unselectedLabelColor: colors.onSurfaceVariant,
                    tabs: state.schedules
                        .map((g) => Tab(text: 'به سمت ${g.destinationFa}'))
                        .toList(),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: state.schedules
                          .map((g) => _DestinationSchedule(
                                group: g,
                                scrollController: scrollController,
                                lineColor: lineColor,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DestinationSchedule extends StatelessWidget {
  final ScheduleGroup group;
  final ScrollController scrollController;
  final Color lineColor;

  const _DestinationSchedule({
    required this.group,
    required this.scrollController,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainScheduleCubit, TrainScheduleState>(
      buildWhen: (prev, curr) =>
          prev.currentTimeAsFraction != curr.currentTimeAsFraction ||
          prev.selectedScheduleTypes[group.destinationEn] !=
              curr.selectedScheduleTypes[group.destinationEn] ||
          prev.processedSchedules[group.destinationEn] !=
              curr.processedSchedules[group.destinationEn],
      builder: (context, state) {
        final selectedType = state.selectedScheduleTypes[group.destinationEn];
        final sections = state.processedSchedules[group.destinationEn] ?? const [];
        final visible = selectedType == null
            ? sections
            : sections.where((s) => s.type == selectedType).toList();

        // Find the next upcoming time across the visible, current-day sections.
        double? nextTime;
        for (final section in visible) {
          if (!section.isCurrentDay) continue;
          for (final t in section.times) {
            if (t > state.currentTimeAsFraction) {
              nextTime = nextTime == null ? t : (t < nextTime ? t : nextTime);
              break;
            }
          }
        }

        return Column(
          children: [
            // Pinned so the countdown to the next train is always visible
            // at a glance, without scrolling down through the full list.
            if (nextTime != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: _NextTrainBanner(
                  nextTime: nextTime,
                  currentTimeAsFraction: state.currentTimeAsFraction,
                  lineColor: lineColor,
                ),
              ),
            if (group.schedules.keys.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _TypeChip(
                        label: 'امروز',
                        selected: selectedType == null,
                        color: lineColor,
                        onTap: () => context
                            .read<TrainScheduleCubit>()
                            .selectScheduleType(group.destinationEn, null),
                      ),
                      ...group.schedules.keys.map((type) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _TypeChip(
                              label: type.label,
                              selected: selectedType == type,
                              color: lineColor,
                              onTap: () => context
                                  .read<TrainScheduleCubit>()
                                  .selectScheduleType(group.destinationEn, type),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                itemCount: visible.fold<int>(0, (sum, s) => sum + s.times.length + 1),
                itemBuilder: (context, index) {
                  var remaining = index;
                  for (final section in visible) {
                    if (remaining < section.times.length) {
                      final time = section.times[remaining];
                      return ScheduleTimeTile(
                        time: time,
                        currentTimeAsFraction: state.currentTimeAsFraction,
                        isCurrentDaySchedule: section.isCurrentDay,
                        isNextTrain: nextTime != null && time == nextTime,
                      );
                    }
                    remaining -= section.times.length;
                    if (remaining == 0) {
                      return const SizedBox(height: 14);
                    }
                    remaining -= 1;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A compact, always-visible "next train in mm:ss" banner, pinned above
/// the scrollable timetable so the user doesn't have to scroll down and
/// hunt for the next departure among all the listed times.
class _NextTrainBanner extends StatelessWidget {
  final double nextTime;
  final double currentTimeAsFraction;
  final Color lineColor;

  const _NextTrainBanner({
    required this.nextTime,
    required this.currentTimeAsFraction,
    required this.lineColor,
  });

  static String _remainingLabel(double target, double currentFraction) {
    final remainingFraction = target - currentFraction;
    if (remainingFraction <= 0) return '۰۰:۰۰';

    final totalSeconds = (remainingFraction * 86400).floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final label = hours > 0
        ? '$hours:${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';

    return ScheduleTimeUtils.toFarsiNumber(label);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingLabel(nextTime, currentTimeAsFraction);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: lineColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lineColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, size: 20, color: lineColor),
          const SizedBox(width: 10),
          Text(
            'قطار بعدی تا',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: lineColor,
            ),
          ),
          const Spacer(),
          Text(
            remaining,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: lineColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String stationNameFa;

  const _EmptyState({required this.stationNameFa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded,
              size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'زمان‌بندی‌ای برای «$stationNameFa» ثبت نشده است.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
