import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A small colored pill showing a metro line number, e.g. "خط ۱" tinted
/// in that line's brand color. Reused on the results timeline, the
/// station-details sheet and the route-finder summary.
class LineChip extends StatelessWidget {
  final int lineNumber;
  final bool dense;

  const LineChip({super.key, required this.lineNumber, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.lineColor(lineNumber);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'خط $lineNumber',
            style: TextStyle(
              fontSize: dense ? 10.5 : 11.5,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
