import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainer.withValues(alpha: 0.95),
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(icon: Icons.add_rounded, onTap: onZoomIn, label: 'بزرگ‌نمایی'),
          Divider(height: 1, color: colors.outlineVariant),
          _ControlButton(icon: Icons.remove_rounded, onTap: onZoomOut, label: 'کوچک‌نمایی'),
          Divider(height: 1, color: colors.outlineVariant),
          _ControlButton(
            icon: Icons.center_focus_strong_rounded,
            onTap: onReset,
            label: 'بازنشانی نما',
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
