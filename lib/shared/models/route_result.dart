import 'package:equatable/equatable.dart';

import '../enums/amenity.dart';
import '../enums/route_search_type.dart';
import '../enums/route_step_type.dart';
import '../utils/route_time_estimator.dart';
import 'route_step.dart';
import 'station.dart';

/// The outcome of a route search: the primary route plus up to a couple of
/// alternatives, all for the same start/end pair and search strategy.
class RouteResult extends Equatable {
  final List<List<RouteStep>> routes;
  final Station start;
  final Station end;
  final RouteSearchType searchType;

  /// Amenities the user asked to keep an eye out for along the way.
  /// Purely informational — [RouteStepTile] highlights any station that
  /// has one of these, it doesn't change which route is chosen.
  final Set<Amenity> filters;

  const RouteResult({
    required this.routes,
    required this.start,
    required this.end,
    required this.searchType,
    this.filters = const {},
  });

  bool get isEmpty => routes.isEmpty;

  List<RouteStep> get primaryRoute =>
      routes.isNotEmpty ? routes.first : const [];

  List<List<RouteStep>> get alternativeRoutes =>
      routes.length > 1 ? routes.skip(1).toList() : const [];

  int get totalStations => primaryRoute
      .where((s) =>
          s.type == RouteStepType.start ||
          s.type == RouteStepType.goToNextStation ||
          s.type == RouteStepType.end)
      .length;

  int get lineChanges =>
      primaryRoute.where((s) => s.type == RouteStepType.changeLine).length;

  Set<int> get linesUsed =>
      primaryRoute.expand((s) => s.station.lines).where((l) => l > 0).toSet();

  /// Estimated total travel time for the primary route (see
  /// [RouteTimeEstimator] for how this is modelled).
  double get estimatedMinutes =>
      RouteTimeEstimator.estimateMinutes(primaryRoute);

  String get estimatedDurationLabel =>
      RouteTimeEstimator.formatMinutes(estimatedMinutes);

  @override
  List<Object?> get props => [routes, start, end, searchType, filters];
}
