// lib/Services/api_service.dart
//
// *** SERVERLESS VERSION ***
// This file keeps the exact same public API as the original so that
// RouteFindingPage, RouteResultsPage, and any other UI code continues
// to work without a single change.
//
// All logic is now handled by LocalGraphService (local_graph_service.dart).
// The http package is no longer needed for routing — you can remove it
// from pubspec.yaml if nothing else imports it.

export 'local_graph_service.dart'
    show
    RouteStepType,
    StationInfo,
    RouteStep,
    RouteResult;

import 'local_graph_service.dart';

class ApiService {
  static Future<List<String>> getAvailableStations() =>
      LocalGraphService.instance.getAvailableStations();

  static Future<RouteResult> findRoute({
    required String startStation,
    required String endStation,
    required String routeType,
    List<String> filters = const [],
  }) =>
      LocalGraphService.instance.findRoute(
        startStation: startStation,
        endStation: endStation,
        routeType: routeType,
        filters: filters,
      );
}
