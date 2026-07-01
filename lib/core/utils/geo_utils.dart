import 'dart:math';

import '../../shared/models/station.dart';

/// Geographic helpers shared by the route-finder's "least distance" search
/// and the "use my location" nearest-station feature.
abstract final class GeoUtils {
  static const double _earthRadiusMeters = 6371000;

  /// Great-circle distance between two coordinates, in meters.
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lon2 - lon1) * pi / 180;

    final h = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);

    return 2 * _earthRadiusMeters * asin(sqrt(h));
  }

  static double distanceBetweenStations(Station a, Station b) =>
      haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude);

  /// Returns the station in [stations] closest to ([latitude], [longitude]),
  /// or null if [stations] is empty.
  static Station? findNearestStation(
    List<Station> stations,
    double latitude,
    double longitude,
  ) {
    if (stations.isEmpty) return null;

    Station? nearest;
    double bestDistance = double.infinity;

    for (final station in stations) {
      final distance = haversineMeters(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        nearest = station;
      }
    }

    return nearest;
  }
}
