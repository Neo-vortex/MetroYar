import 'package:flutter/material.dart';

import '../../../../shared/enums/amenity.dart';
import '../../../../shared/models/route_step.dart';
import 'route_step_tile.dart';

class RouteStepsTimeline extends StatelessWidget {
  final List<RouteStep> steps;
  final Set<Amenity> filters;

  const RouteStepsTimeline({
    super.key,
    required this.steps,
    this.filters = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        return RouteStepTile(
          step: steps[index],
          isLast: index == steps.length - 1,
          filters: filters,
        );
      }),
    );
  }
}
