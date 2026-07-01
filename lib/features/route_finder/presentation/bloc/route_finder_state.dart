import 'package:equatable/equatable.dart';

import '../../../../shared/enums/amenity.dart';
import '../../../../shared/enums/route_search_type.dart';
import '../../../../shared/models/route_result.dart';
import '../../../../shared/models/station.dart';

enum StationsLoadStatus { initial, loading, loaded, failed }

class RouteFinderState extends Equatable {
  final StationsLoadStatus stationsStatus;
  final List<Station> stations;
  final String? stationsError;

  final Station? startStation;
  final Station? endStation;
  final RouteSearchType searchType;
  final Set<Amenity> selectedFilters;

  final bool isLocating;
  final String? locationError;

  final bool isSearching;
  final String? searchError;

  /// The most recent successful search result, paired with a
  /// monotonically increasing id so the UI can detect *a new* result even
  /// if its content happens to equal the previous one.
  final RouteResult? result;
  final int resultRequestId;

  const RouteFinderState({
    this.stationsStatus = StationsLoadStatus.initial,
    this.stations = const [],
    this.stationsError,
    this.startStation,
    this.endStation,
    this.searchType = RouteSearchType.fewestStations,
    this.selectedFilters = const {},
    this.isLocating = false,
    this.locationError,
    this.isSearching = false,
    this.searchError,
    this.result,
    this.resultRequestId = 0,
  });

  bool get canSubmit =>
      startStation != null &&
      endStation != null &&
      startStation != endStation &&
      !isSearching;

  RouteFinderState copyWith({
    StationsLoadStatus? stationsStatus,
    List<Station>? stations,
    String? Function()? stationsError,
    Station? Function()? startStation,
    Station? Function()? endStation,
    RouteSearchType? searchType,
    Set<Amenity>? selectedFilters,
    bool? isLocating,
    String? Function()? locationError,
    bool? isSearching,
    String? Function()? searchError,
    RouteResult? Function()? result,
    int? resultRequestId,
  }) {
    return RouteFinderState(
      stationsStatus: stationsStatus ?? this.stationsStatus,
      stations: stations ?? this.stations,
      stationsError:
          stationsError != null ? stationsError() : this.stationsError,
      startStation:
          startStation != null ? startStation() : this.startStation,
      endStation: endStation != null ? endStation() : this.endStation,
      searchType: searchType ?? this.searchType,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      isLocating: isLocating ?? this.isLocating,
      locationError:
          locationError != null ? locationError() : this.locationError,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError != null ? searchError() : this.searchError,
      result: result != null ? result() : this.result,
      resultRequestId: resultRequestId ?? this.resultRequestId,
    );
  }

  @override
  List<Object?> get props => [
        stationsStatus,
        stations,
        stationsError,
        startStation,
        endStation,
        searchType,
        selectedFilters,
        isLocating,
        locationError,
        isSearching,
        searchError,
        result,
        resultRequestId,
      ];
}
