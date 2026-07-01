import '../../../../core/utils/geo_utils.dart';
import '../../../../shared/enums/route_step_type.dart';
import '../../../../shared/models/route_step.dart';
import '../../../../shared/models/station.dart';
import '../../../../shared/utils/route_time_estimator.dart';

/// A node in the "line-expanded" graph used for the least-line-changes
/// search: every (station, line) combination is a distinct state.
class _LineNode {
  final String stationId;
  final int line;
  const _LineNode(this.stationId, this.line);

  @override
  bool operator ==(Object other) =>
      other is _LineNode && other.stationId == stationId && other.line == line;

  @override
  int get hashCode => Object.hash(stationId, line);

  @override
  String toString() => '$stationId#$line';
}

/// Builds an in-memory graph from the stations + adjacency loaded from
/// `metro.db`, then answers route queries entirely in Dart — no server,
/// no repeated DB round-trips per search.
///
/// All three strategies are now backed by a single, correct generic
/// Dijkstra + Yen's-k-shortest-paths core, so they share the same
/// well-tested search logic instead of three separate hand-rolled
/// (and previously buggy) implementations:
///  • fewest stations     → Dijkstra with unit edge weights
///  • least distance      → Dijkstra on haversine edge weights
///  • least line changes  → Dijkstra over an expanded (station, line)
///                           state graph, where switching lines at a
///                           station costs 1 and riding along a line
///                           costs 0. A shortest path in that graph is,
///                           by construction, a route with the minimum
///                           possible number of line changes.
class PathfindingEngine {
  final Map<String, Station> _stations;
  final Map<String, List<String>> _adjacency;

  PathfindingEngine({
    required List<Station> stations,
    required Map<String, List<String>> adjacency,
  })  : _stations = {for (final s in stations) s.id: s},
        _adjacency = adjacency;

  List<Station> get allStations => _stations.values.toList(growable: false);

  List<Station> _neighbours(Station station) => (_adjacency[station.id] ?? const [])
      .map((id) => _stations[id])
      .whereType<Station>()
      .toList(growable: false);

  // ══════════════════════════════════════════════════════════════════════
  // Strategy 1 — fewest stations
  // ══════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> findFewestStations(Station start, Station end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    final paths = _kShortestPaths<String>(
      startNodes: [start.id],
      isGoal: (n) => n == end.id,
      neighboursOf: (n) => _neighbours(_stations[n]!).map((s) => s.id),
      weight: (_, __) => 1.0,
      k: 3,
    );

    return paths
        .map((ids) => _buildRouteSteps(ids.map((id) => _stations[id]!).toList()))
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Strategy 2 — least distance
  // ══════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> findLeastDistance(Station start, Station end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    final paths = _kShortestPaths<String>(
      startNodes: [start.id],
      isGoal: (n) => n == end.id,
      neighboursOf: (n) => _neighbours(_stations[n]!).map((s) => s.id),
      weight: (a, b) =>
          GeoUtils.distanceBetweenStations(_stations[a]!, _stations[b]!),
      k: 3,
    );

    return paths
        .map((ids) => _buildRouteSteps(ids.map((id) => _stations[id]!).toList()))
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Strategy 3 — least line changes
  // ══════════════════════════════════════════════════════════════════════

  List<List<RouteStep>> findLeastLineChanges(Station start, Station end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    Iterable<_LineNode> neighboursOf(_LineNode node) sync* {
      final station = _stations[node.stationId]!;

      // Ride to an adjacent station while staying on the same line
      // (cost 0 — handled by the weight function below).
      for (final neighbour in _neighbours(station)) {
        if (neighbour.lines.contains(node.line)) {
          yield _LineNode(neighbour.id, node.line);
        }
      }

      // Switch to another line available at this same station
      // (cost 1 — handled by the weight function below). Crucially,
      // this ONLY changes `line`, never the station, so it can never
      // be used to "teleport" onto an arbitrary line at a neighbour.
      for (final otherLine in station.lines) {
        if (otherLine != node.line) {
          yield _LineNode(node.stationId, otherLine);
        }
      }
    }

    double weight(_LineNode a, _LineNode b) =>
        a.stationId == b.stationId ? 1.0 : 0.0;

    if (start.lines.isEmpty || end.lines.isEmpty) return [];

    final startNodes = [for (final l in start.lines) _LineNode(start.id, l)];

    final paths = _kShortestPaths<_LineNode>(
      startNodes: startNodes,
      isGoal: (n) => n.stationId == end.id,
      neighboursOf: neighboursOf,
      weight: weight,
      k: 3,
    );

    final seen = <String>{};
    final results = <List<RouteStep>>[];
    for (final path in paths) {
      final stationPath = <Station>[];
      for (final node in path) {
        if (stationPath.isEmpty || stationPath.last.id != node.stationId) {
          stationPath.add(_stations[node.stationId]!);
        }
      }
      final key = stationPath.map((s) => s.id).join(',');
      if (seen.add(key)) results.add(_buildRouteSteps(stationPath));
    }
    return results;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Strategy 4 — least time
  // ══════════════════════════════════════════════════════════════════════

  /// Ranks candidate routes by *estimated* travel time rather than hop
  /// count or distance alone: riding between stations costs
  /// distance/averageSpeed + a per-stop dwell time, and switching lines
  /// costs a fixed "average wait for the next train" penalty (see
  /// [RouteTimeEstimator]). We don't have real per-edge scheduled travel
  /// times, so this is the same physical-time model used to show the ETA
  /// on the results screen — it's what makes "least time" different from
  /// "least distance" (it also accounts for the time lost transferring).
  List<List<RouteStep>> findLeastTime(Station start, Station end) {
    if (start.id == end.id) return [_buildRouteSteps([start])];

    Iterable<_LineNode> neighboursOf(_LineNode node) sync* {
      final station = _stations[node.stationId]!;

      for (final neighbour in _neighbours(station)) {
        if (neighbour.lines.contains(node.line)) {
          yield _LineNode(neighbour.id, node.line);
        }
      }

      for (final otherLine in station.lines) {
        if (otherLine != node.line) {
          yield _LineNode(node.stationId, otherLine);
        }
      }
    }

    double weight(_LineNode a, _LineNode b) {
      if (a.stationId == b.stationId) {
        // Line change at the same station.
        return RouteTimeEstimator.transferPenaltySeconds;
      }
      final distance = GeoUtils.distanceBetweenStations(
        _stations[a.stationId]!,
        _stations[b.stationId]!,
      );
      return RouteTimeEstimator.travelSeconds(distance) +
          RouteTimeEstimator.dwellSecondsPerStop;
    }

    if (start.lines.isEmpty || end.lines.isEmpty) return [];

    final startNodes = [for (final l in start.lines) _LineNode(start.id, l)];

    final paths = _kShortestPaths<_LineNode>(
      startNodes: startNodes,
      isGoal: (n) => n.stationId == end.id,
      neighboursOf: neighboursOf,
      weight: weight,
      k: 3,
    );

    final seen = <String>{};
    final results = <List<RouteStep>>[];
    for (final path in paths) {
      final stationPath = <Station>[];
      for (final node in path) {
        if (stationPath.isEmpty || stationPath.last.id != node.stationId) {
          stationPath.add(_stations[node.stationId]!);
        }
      }
      final key = stationPath.map((s) => s.id).join(',');
      if (seen.add(key)) results.add(_buildRouteSteps(stationPath));
    }
    return results;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Shared path → timeline conversion
  // ══════════════════════════════════════════════════════════════════════

  List<RouteStep> _buildRouteSteps(List<Station> stations) {
    final steps = <RouteStep>[];
    if (stations.isEmpty) return steps;

    // Pick the starting line based on what's actually shared with the
    // *next* station, not just the first line in the list — otherwise
    // we can record a spurious line-change on the very first hop.
    int? currentLine;
    if (stations.length > 1) {
      final shared =
      stations[0].lines.toSet().intersection(stations[1].lines.toSet());
      currentLine = shared.isNotEmpty
          ? shared.first
          : (stations[0].lines.isNotEmpty ? stations[0].lines.first : null);
    } else {
      currentLine =
      stations.first.lines.isNotEmpty ? stations.first.lines.first : null;
    }

    for (var i = 0; i < stations.length; i++) {
      final station = stations[i];

      if (i == 0) {
        steps.add(RouteStep(
          type: RouteStepType.start,
          station: station,
          lineNumber: currentLine,
        ));
        continue;
      }

      final previous = stations[i - 1];
      final commonLines =
      previous.lines.toSet().intersection(station.lines.toSet()).toList();

      if (currentLine != null &&
          !commonLines.contains(currentLine) &&
          commonLines.isNotEmpty) {
        final newLine = commonLines.first;
        steps.add(RouteStep(
          type: RouteStepType.changeLine,
          station: previous,
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

    final last = steps.last;
    steps[steps.length - 1] = last.copyWith(type: RouteStepType.end);

    return steps;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Generic Dijkstra (multi-source, with edge/node removal for Yen's) +
  // a generic Yen's-algorithm k-shortest-paths wrapper. Works over any
  // node type T with proper == / hashCode (String, or _LineNode above).
  // ══════════════════════════════════════════════════════════════════════

  List<T>? _shortestPath<T>({
    required List<T> startNodes,
    required bool Function(T) isGoal,
    required Iterable<T> Function(T) neighboursOf,
    required double Function(T a, T b) weight,
    Set<(T, T)> removedEdges = const {},
    Set<T> removedNodes = const {},
  }) {
    final dist = <T, double>{};
    final prev = <T, T?>{};
    final settled = <T>{};
    final frontier = <T>{};

    for (final s in startNodes) {
      if (removedNodes.contains(s)) continue;
      dist[s] = 0;
      prev[s] = null;
      frontier.add(s);
    }

    T? goalNode;
    while (frontier.isNotEmpty) {
      T? current;
      var best = double.infinity;
      for (final n in frontier) {
        final d = dist[n] ?? double.infinity;
        if (d < best) {
          best = d;
          current = n;
        }
      }
      if (current == null) break;
      frontier.remove(current);
      settled.add(current);

      if (isGoal(current)) {
        goalNode = current;
        break;
      }

      for (final next in neighboursOf(current)) {
        if (removedNodes.contains(next) || settled.contains(next)) continue;
        if (removedEdges.contains((current, next))) continue;
        final alt = best + weight(current, next);
        if (alt < (dist[next] ?? double.infinity)) {
          dist[next] = alt;
          prev[next] = current;
          frontier.add(next);
        }
      }
    }

    if (goalNode == null) return null;

    final path = <T>[];
    T? cursor = goalNode;
    while (cursor != null) {
      path.insert(0, cursor);
      cursor = prev[cursor];
    }
    return path;
  }

  List<List<T>> _kShortestPaths<T>({
    required List<T> startNodes,
    required bool Function(T) isGoal,
    required Iterable<T> Function(T) neighboursOf,
    required double Function(T, T) weight,
    required int k,
  }) {
    final result = <List<T>>[];
    final candidates = <List<T>>[];

    final first = _shortestPath<T>(
      startNodes: startNodes,
      isGoal: isGoal,
      neighboursOf: neighboursOf,
      weight: weight,
    );
    if (first == null) return [];
    result.add(first);

    for (var ki = 1; ki < k; ki++) {
      final previousPath = result[ki - 1];

      for (var i = 0; i < previousPath.length - 1; i++) {
        final spurNode = previousPath[i];
        final rootPath = previousPath.sublist(0, i + 1);

        final removedEdges = <(T, T)>{};
        for (final route in result) {
          if (route.length > i && _sameSequence(route.sublist(0, i + 1), rootPath)) {
            removedEdges.add((route[i], route[i + 1]));
          }
        }

        final removedNodes = rootPath.sublist(0, rootPath.length - 1).toSet();

        final spurPath = _shortestPath<T>(
          startNodes: [spurNode],
          isGoal: isGoal,
          neighboursOf: neighboursOf,
          weight: weight,
          removedEdges: removedEdges,
          removedNodes: removedNodes,
        );

        if (spurPath != null) {
          final total = [...rootPath, ...spurPath.sublist(1)];
          final alreadyKnown = candidates.any((c) => _sameSequence(c, total)) ||
              result.any((c) => _sameSequence(c, total));
          if (!alreadyKnown) candidates.add(total);
        }
      }

      if (candidates.isEmpty) break;

      candidates.sort(
              (a, b) => _pathCost(a, weight).compareTo(_pathCost(b, weight)));
      result.add(candidates.removeAt(0));
    }

    return result;
  }

  bool _sameSequence<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  double _pathCost<T>(List<T> path, double Function(T, T) weight) {
    var sum = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      sum += weight(path[i], path[i + 1]);
    }
    return sum;
  }
}
