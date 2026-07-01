import 'package:flutter/material.dart';

import '../../../../shared/enums/amenity.dart';

/// A collapsible "what should stations along the way have?" picker, backed
/// directly by the [Amenity] enum — i.e. it can only ever offer amenities
/// that genuinely exist in `metro.db`.
class AmenityFilterSelector extends StatefulWidget {
  final Set<Amenity> selected;
  final ValueChanged<Amenity> onToggle;
  final VoidCallback onClear;

  const AmenityFilterSelector({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  @override
  State<AmenityFilterSelector> createState() => _AmenityFilterSelectorState();
}

class _AmenityFilterSelectorState extends State<AmenityFilterSelector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 19, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'امکانات ایستگاه‌های مسیر',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  if (widget.selected.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${widget.selected.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: Amenity.values.map((amenity) {
                            final isSelected = widget.selected.contains(amenity);
                            return FilterChip(
                              avatar: Icon(
                                amenity.icon,
                                size: 16,
                                color: isSelected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                              label: Text(amenity.label),
                              selected: isSelected,
                              onSelected: (_) => widget.onToggle(amenity),
                            );
                          }).toList(),
                        ),
                        if (widget.selected.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: widget.onClear,
                              child: const Text('پاک کردن فیلترها'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
