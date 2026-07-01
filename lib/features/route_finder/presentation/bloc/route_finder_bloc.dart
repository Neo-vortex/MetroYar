import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/location_exceptions.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/enums/amenity.dart';
import '../../domain/repositories/route_repository.dart';
import 'route_finder_event.dart';
import 'route_finder_state.dart';

class RouteFinderBloc extends Bloc<RouteFinderEvent, RouteFinderState> {
  final RouteRepository _repository;
  final LocationService _locationService;

  RouteFinderBloc({
    required RouteRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService,
        super(const RouteFinderState()) {
    on<RouteFinderStationsRequested>(_onStationsRequested);
    on<RouteFinderStartStationChanged>(_onStartStationChanged);
    on<RouteFinderEndStationChanged>(_onEndStationChanged);
    on<RouteFinderStationsSwapped>(_onStationsSwapped);
    on<RouteFinderSearchTypeChanged>(_onSearchTypeChanged);
    on<RouteFinderAmenityFilterToggled>(_onAmenityFilterToggled);
    on<RouteFinderFiltersCleared>(_onFiltersCleared);
    on<RouteFinderCurrentLocationRequested>(_onCurrentLocationRequested);
    on<RouteFinderMapPointPicked>(_onMapPointPicked);
    on<RouteFinderSubmitted>(_onSubmitted);
  }

  Future<void> _onStationsRequested(
    RouteFinderStationsRequested event,
    Emitter<RouteFinderState> emit,
  ) async {
    emit(state.copyWith(
      stationsStatus: StationsLoadStatus.loading,
      stationsError: () => null,
    ));
    try {
      final stations = await _repository.getStations();
      emit(state.copyWith(
        stationsStatus: StationsLoadStatus.loaded,
        stations: stations,
      ));
    } catch (_) {
      emit(state.copyWith(
        stationsStatus: StationsLoadStatus.failed,
        stationsError: () => 'خطا در بارگذاری ایستگاه‌ها. اتصال یا فایل پایگاه‌داده را بررسی کنید.',
      ));
    }
  }

  void _onStartStationChanged(
    RouteFinderStartStationChanged event,
    Emitter<RouteFinderState> emit,
  ) {
    emit(state.copyWith(startStation: () => event.station));
  }

  void _onEndStationChanged(
    RouteFinderEndStationChanged event,
    Emitter<RouteFinderState> emit,
  ) {
    emit(state.copyWith(endStation: () => event.station));
  }

  void _onStationsSwapped(
    RouteFinderStationsSwapped event,
    Emitter<RouteFinderState> emit,
  ) {
    emit(state.copyWith(
      startStation: () => state.endStation,
      endStation: () => state.startStation,
    ));
  }

  void _onSearchTypeChanged(
    RouteFinderSearchTypeChanged event,
    Emitter<RouteFinderState> emit,
  ) {
    emit(state.copyWith(searchType: event.searchType));
  }

  void _onAmenityFilterToggled(
    RouteFinderAmenityFilterToggled event,
    Emitter<RouteFinderState> emit,
  ) {
    final updated = Set<Amenity>.from(state.selectedFilters);
    if (!updated.remove(event.amenity)) {
      updated.add(event.amenity);
    }
    emit(state.copyWith(selectedFilters: updated));
  }

  void _onFiltersCleared(
    RouteFinderFiltersCleared event,
    Emitter<RouteFinderState> emit,
  ) {
    emit(state.copyWith(selectedFilters: const {}));
  }

  Future<void> _onCurrentLocationRequested(
    RouteFinderCurrentLocationRequested event,
    Emitter<RouteFinderState> emit,
  ) async {
    emit(state.copyWith(isLocating: true, locationError: () => null));
    try {
      final position = await _locationService.getCurrentPosition();
      final nearest = await _repository.findNearestStation(
        position.latitude,
        position.longitude,
      );

      if (nearest == null) {
        emit(state.copyWith(
          isLocating: false,
          locationError: () => 'ایستگاهی نزدیک به موقعیت شما یافت نشد.',
        ));
        return;
      }

      emit(state.copyWith(
        isLocating: false,
        startStation: () => nearest,
      ));
    } on LocationServiceDisabledException {
      emit(state.copyWith(
        isLocating: false,
        locationError: () => 'سرویس موقعیت مکانی (GPS) خاموش است.',
      ));
    } on LocationPermissionDeniedException {
      emit(state.copyWith(
        isLocating: false,
        locationError: () => 'اجازهٔ دسترسی به موقعیت مکانی داده نشد.',
      ));
    } on LocationPermissionDeniedForeverException {
      emit(state.copyWith(
        isLocating: false,
        locationError: () =>
            'دسترسی به موقعیت مکانی مسدود شده. آن را از تنظیمات گوشی فعال کنید.',
      ));
    } catch (_) {
      emit(state.copyWith(
        isLocating: false,
        locationError: () => 'خطا در دریافت موقعیت مکانی.',
      ));
    }
  }

  Future<void> _onMapPointPicked(
    RouteFinderMapPointPicked event,
    Emitter<RouteFinderState> emit,
  ) async {
    final nearest = await _repository.findNearestStation(
      event.latitude,
      event.longitude,
    );

    if (nearest == null) {
      emit(state.copyWith(
        locationError: () => 'ایستگاهی نزدیک به نقطهٔ انتخابی یافت نشد.',
      ));
      return;
    }

    if (event.isStart) {
      emit(state.copyWith(startStation: () => nearest));
    } else {
      emit(state.copyWith(endStation: () => nearest));
    }
  }

  Future<void> _onSubmitted(
    RouteFinderSubmitted event,
    Emitter<RouteFinderState> emit,
  ) async {
    final start = state.startStation;
    final end = state.endStation;
    if (start == null || end == null || start == end) return;

    emit(state.copyWith(isSearching: true, searchError: () => null));

    try {
      final result = await _repository.findRoute(
        start: start,
        end: end,
        searchType: state.searchType,
        filters: state.selectedFilters,
      );

      if (result.isEmpty) {
        emit(state.copyWith(
          isSearching: false,
          searchError: () => 'مسیری بین این دو ایستگاه پیدا نشد.',
        ));
        return;
      }

      emit(state.copyWith(
        isSearching: false,
        result: () => result,
        resultRequestId: state.resultRequestId + 1,
      ));
    } catch (_) {
      emit(state.copyWith(
        isSearching: false,
        searchError: () => 'خطا در جستجوی مسیر. دوباره تلاش کنید.',
      ));
    }
  }
}
