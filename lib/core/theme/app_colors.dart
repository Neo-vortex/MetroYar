import 'package:flutter/material.dart';

/// MetroYar's brand palette. The seed is a metro-line blue; line colors
/// below mirror (and extend) what the original results page used so
/// existing visual associations ("line 1 = red" etc.) stay intact.
abstract final class AppColors {
  static const Color seed = Color(0xFF3D6BFF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3D6BFF);

  /// Tehran metro line colors, 1-indexed to match `station.lines`.
  static const Map<int, Color> metroLines = {
    1: Color(0xFFE3000F),
    2: Color(0xFF2451A4),
    3: Color(0xFFF26522),
    4: Color(0xFFFCD200),
    5: Color(0xFF00A651),
    6: Color(0xFFEC008C),
    7: Color(0xFF652D90),
  };

  static Color lineColor(int line) =>
      metroLines[line] ?? const Color(0xFF6B7280);
}
