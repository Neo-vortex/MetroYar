import '../../../../core/utils/geo_utils.dart';
import '../../../../shared/enums/amenity.dart';
import '../../../../shared/enums/route_search_type.dart';
import '../../../../shared/models/route_result.dart';
import '../../../../shared/models/route_step.dart';
import '../../../../shared/models/station.dart';
import '../../domain/repositories/route_repository.dart';
import '../../domain/services/pathfinding_engine.dart';
import '../datasources/metro_local_data_source.dart';

class RouteRepositoryImpl implements RouteRepository {
  final MetroLocalDataSource _dataSource;

  PathfindingEngine? _engine;
  Future<PathfindingEngine>? _loading;

  RouteRepositoryImpl(this._dataSource);

  Future<PathfindingEngine> _ensureEngine() {
    final cached = _engine;
    if (cached != null) return Future.value(cached);

    return _loading ??= _dataSource.loadGraph().then((graph) {
      final engine = PathfindingEngine(
        stations: graph.stations,
        adjacency: graph.adjacency,
      );
      _engine = engine;
      return engine;
    });
  }

  @override
  Future<List<Station>> getStations() async {
    final engine = await _ensureEngine();
    final stations = engine.allStations.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return stations;
  }

  @override
  Future<RouteResult> findRoute({
    required Station start,
    required Station end,
    required RouteSearchType searchType,
    Set<Amenity> filters = const {},
  }) async {
    final engine = await _ensureEngine();

    final routes = switch (searchType) {
      RouteSearchType.fewestStations => engine.findFewestStations(start, end),
      RouteSearchType.leastDistance => engine.findLeastDistance(start, end),
      RouteSearchType.leastLineChanges =>
        engine.findLeastLineChanges(start, end),
      RouteSearchType.leastTime => engine.findLeastTime(start, end),
    };

    return RouteResult(
      routes: _dedupeRoutes(routes),
      start: start,
      end: end,
      searchType: searchType,
      filters: filters,
    );
  }

  /// Safety net against duplicate alternative routes (same sequence of
  /// stations visited, just possibly reached via a different intermediate
  /// line choice): keeps only the first occurrence.
  List<List<RouteStep>> _dedupeRoutes(List<List<RouteStep>> routes) {
    final seen = <String>{};
    final unique = <List<RouteStep>>[];
    for (final route in routes) {
      final key = route.map((step) => step.station.id).join(',');
      if (seen.add(key)) unique.add(route);
    }
    return unique;
  }

  @override
  Future<Station?> findNearestStation(
    double latitude,
    double longitude,
  ) async {
    final engine = await _ensureEngine();
    return GeoUtils.findNearestStation(
      engine.allStations,
      latitude,
      longitude,
    );
  }
}
