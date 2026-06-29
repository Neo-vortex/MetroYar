// lib/Services/local_graph_service.dart
//
// Drop-in replacement for ApiService.
// Reads metro.db from Flutter assets (sqflite + sqflite_common_ffi_web for web)
// and runs all three path-finding algorithms entirely in Dart — no server needed.
//
// ─── pubspec.yaml dependencies to add ────────────────────────────────────────
//   sqflite: ^2.4.1
//   sqflite_common_ffi: ^2.3.4          # for desktop targets (optional)
//   path_provider: ^2.1.4
//   path: ^1.9.0
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

// ══════════════════════════════════════════════════════════════════════════════
// Models  (identical public API to the old ApiService models)
// ══════════════════════════════════════════════════════════════════════════════

enum RouteStepType { start, goToNextStation, changeLine, end }

class StationInfo {
  final String id;
  final String nameEn;
  final String nameFa;
  final double latitude;
  final double longitude;
  final List<int> lines;

  // Amenities
  final bool? disabled;
  final bool? wc;
  final bool? coffeeShop;
  final bool? groceryStore;
  final bool? fastFood;
  final bool? atm;
  final bool? elevator;
  final bool? bicycleParking;
  final bool? waterCooler;
  final bool? cleanFood;
  final bool? blindPath;
  final bool? fireSuppressionSystem;
  final bool? fireExtinguisher;
  final bool? metroPolice;
  final bool? creditTicketSales;
  final bool? waitingChair;
  final bool? camera;
  final bool? trashCan;
  final bool? smoking;
  final bool? petsAllowed;
  final bool? freeWifi;
  final bool? prayerRoom;

  const StationInfo({
    required this.id,
    required this.nameEn,
    required this.nameFa,
    required this.latitude,
    required this.longitude,
    required this.lines,
    this.disabled,
    this.wc,
    this.coffeeShop,
    this.groceryStore,
    this.fastFood,
    this.atm,
    this.elevator,
    this.bicycleParking,
    this.waterCooler,
    this.cleanFood,
    this.blindPath,
    this.fireSuppressionSystem,
    this.fireExtinguisher,
    this.metroPolice,
    this.creditTicketSales,
    this.waitingChair,
    this.camera,
    this.trashCan,
    this.smoking,
    this.petsAllowed,
    this.freeWifi,
    this.prayerRoom,
  });

  // Keep backward-compatible getters used by the existing UI code
  String get translationsFa => nameFa;
  String get translationsEn => nameEn;

  /// Build from a joined DB row.
  /// [row] must include all station columns plus a 'lines' column that is a
  /// comma-separated list of integers (produced by GROUP_CONCAT).
  factory StationInfo.fromRow(Map<String, dynamic> row) {
    bool? _b(String key) {
      final v = row[key];
      if (v == null) return null;
      return v == 1;
    }

    final linesRaw = (row['lines'] as String? ?? '');
    final lines = linesRaw.isEmpty
        ? <int>[]
        : linesRaw.split(',').map((e) => int.tryParse(e) ?? 0).toList();

    return StationInfo(
      id: row['id'] as String,
      nameEn: row['name_en'] as String? ?? '',
      nameFa: row['name_fa'] as String? ?? '',
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
      lines: lines,
      disabled: _b('disabled'),
      wc: _b('wc'),
      coffeeShop: _b('coffee_shop'),
      groceryStore: _b('grocery_store'),
      fastFood: _b('fast_food'),
      atm: _b('atm'),
      elevator: _b('elevator'),
      bicycleParking: _b('bicycle_parking'),
      waterCooler: _b('water_cooler'),
      cleanFood: _b('clean_food'),
      blindPath: _b('blind_path'),
      fireSuppressionSystem: _b('fire_suppression_system'),
      fireExtinguisher: _b('fire_extinguisher'),
      metroPolice: _b('metro_police'),
      creditTicketSales: _b('credit_ticket_sales'),
      waitingChair: _b('waiting_chair'),
      camera: _b('camera'),
      trashCan: _b('trash_can'),
      smoking: _b('smoking'),
      petsAllowed: _b('pets_allowed'),
      freeWifi: _b('free_wifi'),
      prayerRoom: _b('prayer_room'),
    );
  }
}

class RouteStep {
  final RouteStepType type;
  final StationInfo station;
  final int? lineNumber;
  final int? fromLine;
  final int? toLine;

  const RouteStep({
    required this.type,
    required this.station,
    this.lineNumber,
    this.fromLine,
    this.toLine,
  });
}

class RouteResult {
  final List<List<RouteStep>> routes;
  final String startStation;
  final String endStation;
  final String routeType;
  final List<String> filters;

  const RouteResult({
    required this.routes,
    required this.startStation,
    required this.endStation,
    required this.routeType,
    required this.filters,
  });

  List<RouteStep> get primaryRoute => routes.isNotEmpty ? routes.first : [];
  List<List<RouteStep>> get alternativeRoutes =>
      routes.length > 1 ? routes.skip(1).toList() : [];

  int get totalStations => primaryRoute
      .where((s) =>
  s.type == RouteStepType.start ||
      s.type == RouteStepType.goToNextStation ||
      s.type == RouteStepType.end)
      .length;

  int get lineChanges =>
      primaryRoute.where((s) => s.type == RouteStepType.changeLine).length;

  Set<int> get linesUsed => primaryRoute
      .expand((s) => s.station.lines)
      .where((l) => l > 0)
      .toSet();
}

// ══════════════════════════════════════════════════════════════════════════════
// LocalGraphService — loads DB once, answers queries in-memory
// ══════════════════════════════════════════════════════════════════════════════

class LocalGraphService {
  // Singleton
  LocalGraphService._();
  static final LocalGraphService instance = LocalGraphService._();

  // In-memory graph built on first call to _ensureLoaded()
  final Map<String, StationInfo> _stations = {};         // id → StationInfo
  final Map<String, List<String>> _adj = {};             // id → neighbour ids
  bool _loaded = false;

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    // Copy the bundled asset DB to a writable location (required by sqflite)
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'metro.db');

    // Always overwrite on first install; version-gate in production if desired
    if (!File(dbPath).existsSync()) {
      final bytes = await rootBundle.load('assets/metro.db');
      await File(dbPath)
          .writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }

    final db = await openDatabase(dbPath, readOnly: true);

    // Load all stations with their lines (GROUP_CONCAT aggregates per station)
    final stationRows = await db.rawQuery('''
      SELECT s.*,
             GROUP_CONCAT(sl.line) AS lines
      FROM   stations s
      LEFT   JOIN station_lines sl ON sl.station_id = s.id
      GROUP  BY s.id
    ''');

    for (final row in stationRows) {
      final info = StationInfo.fromRow(row);
      _stations[info.id] = info;
      _adj[info.id] = [];
    }

    // Load adjacency
    final connRows = await db.rawQuery('SELECT from_id, to_id FROM connections');
    for (final row in connRows) {
      final a = row['from_id'] as String;
      final b = row['to_id'] as String;
      _adj[a]?.add(b);
      _adj[b]?.add(a);
    }

    await db.close();
    _loaded = true;
  }

  // ── Public API (mirrors the old ApiService) ─────────────────────────────────

  /// Returns all station Persian names, sorted.
  Future<List<String>> getAvailableStations() async {
    await _ensureLoaded();
    return _stations.values
        .map((s) => s.nameFa)
        .where((n) => n.isNotEmpty)
        .toList()
      ..sort();
  }

  Future<RouteResult> findRoute({
    required String startStation,   // Persian name (translations_fa)
    required String endStation,
    required String routeType,
    List<String> filters = const [],
  }) async {
    await _ensureLoaded();

    final startInfo = _stationByFa(startStation);
    final endInfo   = _stationByFa(endStation);

    if (startInfo == null || endInfo == null) {
      throw Exception('Station not found: $startStation → $endStation');
    }

    List<List<RouteStep>> routes;

    switch (routeType) {
      case 'کمترین ایستگاه':
        routes = _findFewestStations(startInfo, endInfo);
        break;
      case 'کمترین فاصله':
        routes = _findLeastDistance(startInfo, endInfo);
        break;
      case 'کمترین تعویض خط':
        routes = _findLeastLineChanges(startInfo, endInfo);
        break;
      default:
        routes = _findFewestStations(startInfo, endInfo);
    }

    return RouteResult(
      routes: routes,
      startStation: startStation,
      endStation: endStation,
      routeType: routeType,
      filters: filters,
    );
  }

  // ── Lookup helpers ───────────────────────────────────────────────────────────

  StationInfo? _stationByFa(String nameFa) {
    try {
      return _stations.values.firstWhere((s) => s.nameFa == nameFa);
    } catch (_) {
      return null;
    }
  }

  List<StationInfo> _neighbours(StationInfo s) =>
      (_adj[s.id] ?? []).map((id) => _stations[id]).whereType<StationInfo>().toList();

  // ══════════════════════════════════════════════════════════════════════════
  // Algorithm 1 — Fewest stations  (BFS, equivalent to Neo4j shortestPath)
  // ══════════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> _findFewestStations(StationInfo start, StationInfo end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    // BFS — collect up to 3 shortest paths (same length allowed)
    final results = <List<StationInfo>>[];
    int? targetLen;

    // prev maps each node to the set of nodes that can precede it on a shortest path
    // We use a level-by-level BFS and stop after the level that first reaches [end]
    final queue = <List<StationInfo>>[[start]];
    final visited = <String>{start.id};

    while (queue.isNotEmpty && results.length < 3) {
      final path = queue.removeAt(0);
      final current = path.last;

      if (targetLen != null && path.length > targetLen) break;

      for (final nb in _neighbours(current)) {
        if (visited.contains(nb.id) && nb.id != end.id) continue;
        final newPath = [...path, nb];

        if (nb.id == end.id) {
          targetLen = newPath.length;
          results.add(newPath);
          if (results.length >= 3) break;
        } else if (targetLen == null) {
          visited.add(nb.id);
          queue.add(newPath);
        }
      }
    }

    if (results.isEmpty) return [];
    return results.map(_buildRouteSteps).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Algorithm 2 — Least distance  (Dijkstra on haversine edge weights)
  // ══════════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> _findLeastDistance(StationInfo start, StationInfo end) {
    // Dijkstra — single shortest, then try k-shortest with Yen's first 3
    final best = _dijkstra(start, end, (a, b) => _haversine(a, b));
    if (best == null) return [];

    // For "up to 3 alternatives" we do a simple 3-path Yen's variant
    return _kShortest(start, end, 3, (a, b) => _haversine(a, b));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Algorithm 3 — Least line changes  (BFS on (station, currentLine) state)
  // ══════════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> _findLeastLineChanges(StationInfo start, StationInfo end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    // State: (stationId, currentLine)  — penalise entering a node on a new line
    // Cost: number of line changes
    // We use BFS over change-cost levels (0 changes first, then 1, etc.)

    // (stationId, line) → best cost
    final costMap = <String, int>{};
    // (stationId, line) → previous (stationId, line) for path reconstruction
    final prev = <String, String?>{};
    // (stationId, line) → List<StationInfo> path so far (to reconstruct)
    final pathMap = <String, List<StationInfo>>{};

    final results = <List<StationInfo>>[];

    // Priority queue via simple list + sort (network is small)
    // Entry: [cost, stationId, currentLine]
    final pq = <_State>[];

    for (final line in start.lines) {
      final key = '${start.id}:$line';
      pq.add(_State(0, start.id, line));
      costMap[key] = 0;
      pathMap[key] = [start];
    }

    final seenEnd = <String>{};

    while (pq.isNotEmpty && results.length < 3) {
      pq.sort((a, b) => a.cost.compareTo(b.cost));
      final cur = pq.removeAt(0);
      final curKey = '${cur.stationId}:${cur.line}';
      final curPath = pathMap[curKey]!;
      final curStation = _stations[cur.stationId]!;

      if (cur.stationId == end.id) {
        results.add(curPath);
        continue;
      }

      for (final nb in _neighbours(curStation)) {
        final commonLines =
        curStation.lines.toSet().intersection(nb.lines.toSet());
        if (commonLines.isEmpty) continue;

        for (final nbLine in nb.lines) {
          final isChange = !commonLines.contains(cur.line) ? 1 : 0;
          // only allow valid transitions: either stay on same line or change at interchange
          if (isChange == 1 && !commonLines.contains(nbLine)) continue;

          final newCost = cur.cost + (nb.lines.contains(cur.line) ? 0 : 1);
          final nbKey = '${nb.id}:$nbLine';

          if (!costMap.containsKey(nbKey) || newCost < costMap[nbKey]!) {
            costMap[nbKey] = newCost;
            pathMap[nbKey] = [...curPath, nb];
            pq.add(_State(newCost, nb.id, nbLine));
          }
        }
      }
    }

    // de-duplicate paths by station sequence
    final seen = <String>{};
    final unique = <List<StationInfo>>[];
    for (final r in results) {
      final key = r.map((s) => s.id).join(',');
      if (seen.add(key)) unique.add(r);
    }

    if (unique.isEmpty) return [];
    return unique.map(_buildRouteSteps).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared path-building  (mirrors C# BuildRouteSteps exactly)
  // ══════════════════════════════════════════════════════════════════════════

  List<RouteStep> _buildRouteSteps(List<StationInfo> stations) {
    final steps = <RouteStep>[];
    if (stations.isEmpty) return steps;

    int? currentLine = stations.first.lines.isNotEmpty ? stations.first.lines.first : null;

    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];

      if (i == 0) {
        steps.add(RouteStep(
          type: RouteStepType.start,
          station: station,
          lineNumber: currentLine,
        ));
        continue;
      }

      final prev = stations[i - 1];
      final commonLines = prev.lines.toSet().intersection(station.lines.toSet()).toList();

      if (currentLine != null && !commonLines.contains(currentLine) && commonLines.isNotEmpty) {
        final newLine = commonLines.first;
        steps.add(RouteStep(
          type: RouteStepType.changeLine,
          station: prev,
          fromLine: currentLine,
          toLine: newLine,
        ));
        currentLine = newLine;
      }

      steps.add(RouteStep(
        type: RouteStepType.goToNextStation,
        station: station,
        lineNumber: currentLine,
      ));
    }

    if (steps.isNotEmpty) {
      final last = steps.last;
      steps[steps.length - 1] = RouteStep(
        type: RouteStepType.end,
        station: last.station,
        lineNumber: last.lineNumber,
        fromLine: last.fromLine,
        toLine: last.toLine,
      );
    }

    return steps;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════════════════════

  /// Haversine distance in metres between two stations.
  double _haversine(StationInfo a, StationInfo b) {
    const r = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }

  List<StationInfo>? _dijkstra(
      StationInfo start,
      StationInfo end,
      double Function(StationInfo, StationInfo) weight,
      ) {
    final dist = <String, double>{start.id: 0};
    final prevMap = <String, String?>{start.id: null};
    final unvisited = <String>{..._stations.keys};

    while (unvisited.isNotEmpty) {
      // pick minimum-dist unvisited
      String? u;
      double minD = double.infinity;
      for (final id in unvisited) {
        final d = dist[id] ?? double.infinity;
        if (d < minD) { minD = d; u = id; }
      }
      if (u == null || u == end.id) break;
      unvisited.remove(u);

      for (final nb in _neighbours(_stations[u]!)) {
        if (!unvisited.contains(nb.id)) continue;
        final alt = minD + weight(_stations[u]!, nb);
        if (alt < (dist[nb.id] ?? double.infinity)) {
          dist[nb.id] = alt;
          prevMap[nb.id] = u;
        }
      }
    }

    if (!prevMap.containsKey(end.id)) return null;

    final path = <StationInfo>[];
    String? cur = end.id;
    while (cur != null) {
      path.insert(0, _stations[cur]!);
      cur = prevMap[cur];
    }
    return path;
  }

  /// Simple Yen's k-shortest paths using [weight].
  List<List<RouteStep>> _kShortest(
      StationInfo start,
      StationInfo end,
      int k,
      double Function(StationInfo, StationInfo) weight,
      ) {
    final result = <List<StationInfo>>[];
    final candidates = <List<StationInfo>>[];

    final first = _dijkstra(start, end, weight);
    if (first == null) return [];
    result.add(first);

    for (int ki = 1; ki < k; ki++) {
      final prevPath = result[ki - 1];

      for (int i = 0; i < prevPath.length - 1; i++) {
        final spurNode = prevPath[i];
        final rootPath = prevPath.sublist(0, i + 1);

        // Temporarily remove edges used by result paths that share rootPath
        final removedEdges = <(String, String)>{};
        for (final rp in result) {
          if (rp.length > i &&
              rp.sublist(0, i + 1).map((s) => s.id).join() ==
                  rootPath.map((s) => s.id).join()) {
            removedEdges.add((rp[i].id, rp[i + 1].id));
          }
        }

        // Temporarily remove root path nodes from graph (except spur)
        final removedNodes = rootPath.sublist(0, rootPath.length - 1).map((s) => s.id).toSet();

        final spurPath = _dijkstraFiltered(spurNode, end, weight, removedEdges, removedNodes);
        if (spurPath != null) {
          final total = [...rootPath, ...spurPath.sublist(1)];
          final key = total.map((s) => s.id).join(',');
          if (!candidates.any((c) => c.map((s) => s.id).join(',') == key) &&
              !result.any((c) => c.map((s) => s.id).join(',') == key)) {
            candidates.add(total);
          }
        }
      }

      if (candidates.isEmpty) break;
      candidates.sort((a, b) {
        double da = 0, db = 0;
        for (int i = 0; i < a.length - 1; i++) da += weight(a[i], a[i + 1]);
        for (int i = 0; i < b.length - 1; i++) db += weight(b[i], b[i + 1]);
        return da.compareTo(db);
      });
      result.add(candidates.removeAt(0));
    }

    return result.map(_buildRouteSteps).toList();
  }

  List<StationInfo>? _dijkstraFiltered(
      StationInfo start,
      StationInfo end,
      double Function(StationInfo, StationInfo) weight,
      Set<(String, String)> removedEdges,
      Set<String> removedNodes,
      ) {
    final dist = <String, double>{start.id: 0};
    final prevMap = <String, String?>{start.id: null};
    final unvisited = <String>{
      ..._stations.keys.where((id) => !removedNodes.contains(id)),
      start.id,
    };

    while (unvisited.isNotEmpty) {
      String? u;
      double minD = double.infinity;
      for (final id in unvisited) {
        final d = dist[id] ?? double.infinity;
        if (d < minD) { minD = d; u = id; }
      }
      if (u == null || u == end.id) break;
      unvisited.remove(u);

      for (final nb in _neighbours(_stations[u]!)) {
        if (!unvisited.contains(nb.id)) continue;
        if (removedEdges.contains((u, nb.id)) || removedEdges.contains((nb.id, u))) continue;
        final alt = minD + weight(_stations[u]!, nb);
        if (alt < (dist[nb.id] ?? double.infinity)) {
          dist[nb.id] = alt;
          prevMap[nb.id] = u;
        }
      }
    }

    if (!prevMap.containsKey(end.id)) return null;
    final path = <StationInfo>[];
    String? cur = end.id;
    while (cur != null) {
      path.insert(0, _stations[cur]!);
      cur = prevMap[cur];
    }
    return path;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Internal priority-queue state for line-change algorithm
// ══════════════════════════════════════════════════════════════════════════════
class _State {
  final int cost;
  final String stationId;
  final int line;
  const _State(this.cost, this.stationId, this.line);
}
