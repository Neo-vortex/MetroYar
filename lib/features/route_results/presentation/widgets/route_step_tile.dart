import 'package:flutter/material.dart';

import '../../../../shared/enums/amenity.dart';
import '../../../../shared/enums/route_step_type.dart';
import '../../../../shared/models/route_step.dart';
import '../../../../shared/widgets/line_chip.dart';
import '../../../station_details/presentation/widgets/station_details_sheet.dart';

/// One row in the journey timeline: a colored dot/icon, a connecting line
/// to the next stop, the station name, and — if the user picked any
/// amenity filters in the finder — small icons for any that matched.
class RouteStepTile extends StatelessWidget {
  final RouteStep step;
  final bool isLast;
  final Set<Amenity> filters;

  const RouteStepTile({
    super.key,
    required this.step,
    required this.isLast,
    this.filters = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final matchedFilters =
        filters.where((f) => f.isPresentOn(step.station)).toList();

    return InkWell(
      onTap: () => StationDetailsSheet.show(context, step.station),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: step.type.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.type.color.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(step.type.icon, size: 16, color: step.type.color),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: colors.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              step.type.badgeLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (step.type == RouteStepType.changeLine &&
                              step.fromLine != null &&
                              step.toLine != null) ...[
                            LineChip(lineNumber: step.fromLine!, dense: true),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.arrow_back_rounded,
                                  size: 12, color: colors.onSurfaceVariant),
                            ),
                            LineChip(lineNumber: step.toLine!, dense: true),
                          ] else if (step.lineNumber != null)
                            LineChip(lineNumber: step.lineNumber!, dense: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.station.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      if (matchedFilters.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: matchedFilters.map((amenity) {
                            return Chip(
                              avatar: Icon(amenity.icon,
                                  size: 13, color: colors.primary),
                              label: Text(
                                amenity.label,
                                style: const TextStyle(fontSize: 10),
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_left_rounded,
                  size: 18, color: colors.onSurfaceVariant.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
