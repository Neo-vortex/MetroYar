import 'package:flutter/material.dart';

import '../../domain/schedule_time_utils.dart';

/// One scheduled departure. Shows the clock time and, if it's the next
/// upcoming train today, a live "mm:ss remaining" countdown.
class ScheduleTimeTile extends StatelessWidget {
  final double time;
  final double currentTimeAsFraction;
  final bool isCurrentDaySchedule;
  final bool isNextTrain;

  const ScheduleTimeTile({
    super.key,
    required this.time,
    required this.currentTimeAsFraction,
    required this.isCurrentDaySchedule,
    required this.isNextTrain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPast = time <= currentTimeAsFraction;
    final dim = !isCurrentDaySchedule || isPast;

    final showsCountdown = isCurrentDaySchedule && !isPast;
    final remaining =
        showsCountdown ? ScheduleTimeUtils.remainingTime(time) : null;

    return Container(
      decoration: BoxDecoration(
        color: isNextTrain && isCurrentDaySchedule
            ? colors.error.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.train_rounded,
                size: 16,
                color: (isNextTrain && isCurrentDaySchedule
                        ? colors.error
                        : colors.onSurfaceVariant)
                    .withValues(alpha: dim ? 0.5 : 1),
              ),
              const SizedBox(width: 8),
              Text(
                ScheduleTimeUtils.toFarsiNumber(
                  ScheduleTimeUtils.fractionToTime(time),
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isNextTrain ? FontWeight.w800 : FontWeight.w600,
                  color: colors.onSurface.withValues(alpha: dim ? 0.45 : 1),
                ),
              ),
            ],
          ),
          if (remaining != null)
            Text(
              '${ScheduleTimeUtils.toFarsiNumber(remaining)} مانده',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isNextTrain ? FontWeight.w800 : FontWeight.w600,
                color: isNextTrain ? colors.error : colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
