import '../../../../shared/enums/amenity.dart';
import '../../../../shared/enums/route_search_type.dart';
import '../../../../shared/models/route_result.dart';
import '../../../../shared/models/station.dart';

/// The route-finder feature's single point of contact with metro data.
/// The bloc depends on this abstraction, never on sqflite or the engine
/// directly — that's what makes swapping the data source (a future API,
/// a different DB) a one-class change.
abstract class RouteRepository {
  Future<List<Station>> getStations();

  Future<RouteResult> findRoute({
    required Station start,
    required Station end,
    required RouteSearchType searchType,
    Set<Amenity> filters = const {},
  });

  /// Returns the closest station to ([latitude], [longitude]), loading the
  /// graph first if it hasn't been loaded yet.
  Future<Station?> findNearestStation(double latitude, double longitude);
}
