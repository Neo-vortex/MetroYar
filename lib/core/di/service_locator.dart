import 'package:get_it/get_it.dart';

import '../../features/route_finder/data/datasources/metro_local_data_source.dart';
import '../../features/route_finder/data/repositories/route_repository_impl.dart';
import '../../features/route_finder/domain/repositories/route_repository.dart';
import '../database/app_database.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';

final GetIt sl = GetIt.instance;

/// Registers every singleton/service the app needs. Called once from
/// `bootstrap.dart`, before `runApp`.
Future<void> setupServiceLocator() async {
  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  sl.registerLazySingleton<LocationService>(() => LocationService());

  final preferences = PreferencesService();
  await preferences.init();
  sl.registerLazySingleton<PreferencesService>(() => preferences);

  // ── Route finder feature ────────────────────────────────────────────────
  sl.registerLazySingleton<MetroLocalDataSource>(
    () => MetroLocalDataSource(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(sl<MetroLocalDataSource>()),
  );
}
