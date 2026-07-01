import 'package:flutter/material.dart';

class RouteTabs extends StatelessWidget {
  final int routeCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const RouteTabs({
    super.key,
    required this.routeCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (routeCount <= 1) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: routeCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = index == 0 ? 'مسیر پیشنهادی' : 'گزینه ${index + 1}';

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onChanged(index),
            selectedColor: colors.primaryContainer,
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
