import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// What kind of "hop" a single [RouteStep] represents in the journey
/// timeline.
enum RouteStepType {
  start,
  goToNextStation,
  changeLine,
  end;

  String get badgeLabel => switch (this) {
        RouteStepType.start => 'شروع',
        RouteStepType.goToNextStation => 'ایستگاه',
        RouteStepType.changeLine => 'تعویض خط',
        RouteStepType.end => 'پایان',
      };

  IconData get icon => switch (this) {
        RouteStepType.start => Icons.trip_origin_rounded,
        RouteStepType.goToNextStation => Icons.train_rounded,
        RouteStepType.changeLine => Icons.swap_horiz_rounded,
        RouteStepType.end => Icons.location_on_rounded,
      };

  Color get color => switch (this) {
        RouteStepType.start => AppColors.success,
        RouteStepType.goToNextStation => AppColors.info,
        RouteStepType.changeLine => AppColors.warning,
        RouteStepType.end => AppColors.danger,
      };
}
