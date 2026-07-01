import 'package:flutter/material.dart';

import '../../../../shared/models/route_result.dart';
import '../../../../shared/widgets/line_chip.dart';

/// The card at the top of the results page summarising the chosen route:
/// search strategy, stop count, line-change count and the lines involved.
class RouteSummaryCard extends StatelessWidget {
  final RouteResult result;

  const RouteSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(result.searchType.icon, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  result.searchType.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatChip(
                  icon: Icons.train_rounded,
                  label: 'ایستگاه',
                  value: '${result.totalStations}',
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.swap_horiz_rounded,
                  label: 'تعویض خط',
                  value: '${result.lineChanges}',
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.access_time_rounded,
                  label: 'زمان',
                  value: result.estimatedDurationLabel,
                ),
              ],
            ),
            if (result.linesUsed.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.linesUsed
                    .toList()
                    .map((line) => LineChip(lineNumber: line, dense: true))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
