import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Shows a floating snack bar with an optional leading icon, using the
  /// app's snack bar theme. Centralised so every "خطا/موفقیت" toast looks
  /// the same.
  void showSnack(String message, {IconData? icon, Color? color}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: colors.onInverseSurface, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
