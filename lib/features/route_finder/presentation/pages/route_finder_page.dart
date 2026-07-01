import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/extensions/build_context_extensions.dart';
import '../../../../shared/models/station.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/repositories/route_repository.dart';
import '../bloc/route_finder_bloc.dart';
import '../bloc/route_finder_event.dart';
import '../bloc/route_finder_state.dart';
import '../widgets/amenity_filter_selector.dart';
import '../widgets/route_search_type_selector.dart';
import '../widgets/station_field.dart';
import '../widgets/swap_stations_button.dart';
import 'map_location_picker_page.dart';

class RouteFinderPage extends StatelessWidget {
  const RouteFinderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteFinderBloc(
        repository: sl<RouteRepository>(),
        locationService: sl<LocationService>(),
      )..add(const RouteFinderStationsRequested()),
      child: const _RouteFinderView(),
    );
  }
}

class _RouteFinderView extends StatelessWidget {
  const _RouteFinderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسیریاب مترو')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RouteFinderBloc, RouteFinderState>(
            listenWhen: (prev, curr) =>
                curr.result != null &&
                curr.resultRequestId != prev.resultRequestId,
            listener: (context, state) {
              Navigator.of(context).pushNamed(
                AppRoutes.routeResults,
                arguments: state.result,
              );
            },
          ),
          BlocListener<RouteFinderBloc, RouteFinderState>(
            listenWhen: (prev, curr) =>
                curr.searchError != null && curr.searchError != prev.searchError,
            listener: (context, state) {
              context.showSnack(state.searchError!, icon: Icons.error_outline);
            },
          ),
          BlocListener<RouteFinderBloc, RouteFinderState>(
            listenWhen: (prev, curr) =>
                curr.locationError != null &&
                curr.locationError != prev.locationError,
            listener: (context, state) {
              context.showSnack(
                state.locationError!,
                icon: Icons.location_off_rounded,
              );
            },
          ),
        ],
        child: BlocBuilder<RouteFinderBloc, RouteFinderState>(
          builder: (context, state) {
            if (state.stationsStatus == StationsLoadStatus.loading ||
                state.stationsStatus == StationsLoadStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.stationsStatus == StationsLoadStatus.failed) {
              return EmptyStateView(
                icon: Icons.cloud_off_rounded,
                title: 'بارگذاری ایستگاه‌ها ناموفق بود',
                message: state.stationsError,
                actionLabel: 'تلاش دوباره',
                onAction: () => context
                    .read<RouteFinderBloc>()
                    .add(const RouteFinderStationsRequested()),
              );
            }

            final bloc = context.read<RouteFinderBloc>();

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                Column(
                  children: [
                    StationField(
                      label: 'ایستگاه مبدا',
                      icon: Icons.trip_origin_rounded,
                      iconColor: context.colors.primary,
                      stations: state.stations,
                      value: state.startStation,
                      showLocationButton: true,
                      isLocating: state.isLocating,
                      onLocationPressed: () => bloc.add(
                        const RouteFinderCurrentLocationRequested(),
                      ),
                      onChanged: (station) => bloc.add(
                        RouteFinderStartStationChanged(station),
                      ),
                      onPickFromMapPressed: () => _pickFromMap(
                        context,
                        bloc: bloc,
                        stations: state.stations,
                        isStart: true,
                      ),
                    ),
                    SwapStationsButton(
                      onPressed: () =>
                          bloc.add(const RouteFinderStationsSwapped()),
                    ),
                    StationField(
                      label: 'ایستگاه مقصد',
                      icon: Icons.location_on_rounded,
                      iconColor: context.colors.error,
                      stations: state.stations,
                      value: state.endStation,
                      onChanged: (station) => bloc.add(
                        RouteFinderEndStationChanged(station),
                      ),
                      onPickFromMapPressed: () => _pickFromMap(
                        context,
                        bloc: bloc,
                        stations: state.stations,
                        isStart: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'نحوهٔ جستجو',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),
                RouteSearchTypeSelector(
                  selected: state.searchType,
                  onChanged: (type) =>
                      bloc.add(RouteFinderSearchTypeChanged(type)),
                ),
                const SizedBox(height: AppSpacing.md),
                AmenityFilterSelector(
                  selected: state.selectedFilters,
                  onToggle: (amenity) =>
                      bloc.add(RouteFinderAmenityFilterToggled(amenity)),
                  onClear: () => bloc.add(const RouteFinderFiltersCleared()),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'یافتن مسیر',
                  loadingLabel: 'در حال جستجو…',
                  icon: Icons.search_rounded,
                  isLoading: state.isSearching,
                  onPressed: state.canSubmit
                      ? () => bloc.add(const RouteFinderSubmitted())
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickFromMap(
    BuildContext context, {
    required RouteFinderBloc bloc,
    required List<Station> stations,
    required bool isStart,
  }) async {
    // Center on the average position of all known stations (falls back to
    // Tehran if the list is somehow empty).
    final center = _centerFor(stations);

    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerPage(
          stations: stations,
          initialCenter: center,
          title: isStart ? 'انتخاب مبدا از نقشه' : 'انتخاب مقصد از نقشه',
        ),
      ),
    );

    if (picked == null || !context.mounted) return;

    bloc.add(RouteFinderMapPointPicked(
      isStart: isStart,
      latitude: picked.latitude,
      longitude: picked.longitude,
    ));
  }

  LatLng _centerFor(List<Station> stations) {
    if (stations.isEmpty) return const LatLng(35.6892, 51.3890); // Tehran
    final avgLat =
        stations.map((s) => s.latitude).reduce((a, b) => a + b) /
            stations.length;
    final avgLng =
        stations.map((s) => s.longitude).reduce((a, b) => a + b) /
            stations.length;
    return LatLng(avgLat, avgLng);
  }
}
