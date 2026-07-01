import 'package:equatable/equatable.dart';

import '../../../../shared/enums/amenity.dart';
import '../../../../shared/enums/route_search_type.dart';
import '../../../../shared/models/station.dart';

sealed class RouteFinderEvent extends Equatable {
  const RouteFinderEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the page first mounts.
final class RouteFinderStationsRequested extends RouteFinderEvent {
  const RouteFinderStationsRequested();
}

final class RouteFinderStartStationChanged extends RouteFinderEvent {
  final Station? station;
  const RouteFinderStartStationChanged(this.station);

  @override
  List<Object?> get props => [station];
}

final class RouteFinderEndStationChanged extends RouteFinderEvent {
  final Station? station;
  const RouteFinderEndStationChanged(this.station);

  @override
  List<Object?> get props => [station];
}

final class RouteFinderStationsSwapped extends RouteFinderEvent {
  const RouteFinderStationsSwapped();
}

final class RouteFinderSearchTypeChanged extends RouteFinderEvent {
  final RouteSearchType searchType;
  const RouteFinderSearchTypeChanged(this.searchType);

  @override
  List<Object?> get props => [searchType];
}

final class RouteFinderAmenityFilterToggled extends RouteFinderEvent {
  final Amenity amenity;
  const RouteFinderAmenityFilterToggled(this.amenity);

  @override
  List<Object?> get props => [amenity];
}

final class RouteFinderFiltersCleared extends RouteFinderEvent {
  const RouteFinderFiltersCleared();
}

/// Triggered by the location button next to the start-station field —
/// fetches the device's GPS position and selects the nearest station.
final class RouteFinderCurrentLocationRequested extends RouteFinderEvent {
  const RouteFinderCurrentLocationRequested();
}

/// Fired after the user picks a point on the map picker for either the
/// start or end field — resolves it to the nearest known station.
final class RouteFinderMapPointPicked extends RouteFinderEvent {
  final bool isStart;
  final double latitude;
  final double longitude;

  const RouteFinderMapPointPicked({
    required this.isStart,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [isStart, latitude, longitude];
}

final class RouteFinderSubmitted extends RouteFinderEvent {
  const RouteFinderSubmitted();
}
