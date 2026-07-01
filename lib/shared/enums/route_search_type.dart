import 'package:flutter/material.dart';

/// The three route-finding strategies, each backed by a different
/// algorithm in [PathfindingEngine] (BFS, Dijkstra, and a line-change-cost
/// search respectively). Modelling this as an enum — instead of comparing
/// raw Persian strings, like the previous version did — means the compiler
/// catches typos and `switch` statements stay exhaustive.
enum RouteSearchType {
  fewestStations,
  leastDistance,
  leastLineChanges,
  leastTime;

  String get title => switch (this) {
        RouteSearchType.fewestStations => 'کمترین ایستگاه',
        RouteSearchType.leastDistance => 'کمترین فاصله',
        RouteSearchType.leastLineChanges => 'کمترین تعویض خط',
        RouteSearchType.leastTime => 'کمترین زمان',
      };

  String get subtitle => switch (this) {
        RouteSearchType.fewestStations => 'کوتاه‌ترین مسیر از نظر تعداد ایستگاه',
        RouteSearchType.leastDistance => 'کوتاه‌ترین مسافت جغرافیایی',
        RouteSearchType.leastLineChanges => 'کمترین تغییر خط مترو',
        RouteSearchType.leastTime => 'سریع‌ترین مسیر بر اساس برنامهٔ حرکت',
      };

  IconData get icon => switch (this) {
        RouteSearchType.fewestStations => Icons.route_rounded,
        RouteSearchType.leastDistance => Icons.straighten_rounded,
        RouteSearchType.leastLineChanges => Icons.swap_horiz_rounded,
        RouteSearchType.leastTime => Icons.bolt_rounded,
      };
}
