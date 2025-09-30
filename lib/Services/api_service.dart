import 'dart:convert';
import 'package:http/http.dart' as http;

enum RouteStepType {
  start,
  goToNextStation,
  changeLine,
  end
}

class StationInfo {
  final Map<String, dynamic> properties;

  StationInfo({required this.properties});

  String get id => properties['Id']?.toString() ?? '';
  String get translationsFa => properties['translations_fa']?.toString() ?? '';
  String get translationsEn => properties['translations_en']?.toString() ?? '';
  double get latitude => (properties['latitude'] as num?)?.toDouble() ?? 0.0;
  double get longitude => (properties['longitude'] as num?)?.toDouble() ?? 0.0;
  List<int> get lines {
    if (properties['lines'] is List) {
      return (properties['lines'] as List).map((e) => (e as num).toInt()).toList();
    }
    return [];
  }

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    return StationInfo(properties: json);
  }
}

class RouteStep {
  final RouteStepType type;
  final StationInfo station;
  final int? lineNumber;
  final int? fromLine;
  final int? toLine;

  RouteStep({
    required this.type,
    required this.station,
    this.lineNumber,
    this.fromLine,
    this.toLine,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    RouteStepType parseType(dynamic typeValue) {
      int typeNum;

      if (typeValue is int) {
        typeNum = typeValue;
      } else if (typeValue is String) {
        typeNum = int.tryParse(typeValue) ?? 1;
      } else {
        typeNum = 1; // default to goToNextStation
      }

      switch (typeNum) {
        case 0:
          return RouteStepType.start;
        case 1:
          return RouteStepType.goToNextStation;
        case 2:
          return RouteStepType.changeLine;
        case 3:
          return RouteStepType.end;
        default:
          return RouteStepType.goToNextStation;
      }
    }

    return RouteStep(
      type: parseType(json['type']),
      station: StationInfo.fromJson(json['station'] ?? {}),
      lineNumber: json['lineNumber'] as int?,
      fromLine: json['fromLine'] as int?,
      toLine: json['toLine'] as int?,
    );
  }
}

class RouteResult {
  final List<List<RouteStep>> routes;
  final String startStation;
  final String endStation;
  final String routeType;
  final List<String> filters;

  RouteResult({
    required this.routes,
    required this.startStation,
    required this.endStation,
    required this.routeType,
    required this.filters,
  });

  // Get the primary route (first route)
  List<RouteStep> get primaryRoute => routes.isNotEmpty ? routes.first : [];

  // Get alternative routes
  List<List<RouteStep>> get alternativeRoutes => routes.length > 1 ? routes.skip(1).toList() : [];

  // Get total stations count for primary route
  int get totalStations => primaryRoute.where((step) =>
  step.type == RouteStepType.start ||
      step.type == RouteStepType.goToNextStation ||
      step.type == RouteStepType.end).length;

  // Get line changes count for primary route
  int get lineChanges => primaryRoute.where((step) => step.type == RouteStepType.changeLine).length;

  // Get unique lines used in primary route
  Set<int> get linesUsed => primaryRoute
      .expand((step) => step.station.lines)
      .where((line) => line > 0)
      .toSet();
}

class ApiService {
  static const String baseUrl = "http://localhost:5248/api/Interface";

  static Future<List<String>> getAvailableStations() async {
    final url = Uri.parse("$baseUrl/GetAvailableStations");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception("Failed to load stations");
    }
  }

  static Future<RouteResult> findRoute({
    required String startStation,
    required String endStation,
    required String routeType,
    List<String> filters = const [],
  }) async {
    String endpoint;

    switch (routeType) {
      case "کمترین ایستگاه":
        endpoint = "FindPathFewestStations";
        break;
      case "کمترین فاصله":
        endpoint = "FindPathLeastDistance";
        break;
      case "کمترین تعویض خط":
        endpoint = "FindPathLeastLineChanges";
        break;
      default:
        endpoint = "FindPathFewestStations";
    }

    final url = Uri.parse("$baseUrl/$endpoint").replace(queryParameters: {
      'startFa': startStation,
      'endFa': endStation,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Parse the nested list structure
      final List<List<RouteStep>> routes = data.map((routeData) {
        if (routeData is List) {
          return routeData.map((stepData) => RouteStep.fromJson(stepData as Map<String, dynamic>)).toList();
        }
        return <RouteStep>[];
      }).toList();

      return RouteResult(
        routes: routes,
        startStation: startStation,
        endStation: endStation,
        routeType: routeType,
        filters: filters,
      );
    } else {
      throw Exception("Failed to find route: ${response.statusCode} - ${response.body}");
    }
  }
}