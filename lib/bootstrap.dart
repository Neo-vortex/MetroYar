import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';

/// Runs every one-time setup step the app needs *before* the first frame:
/// the sqflite desktop backend (Windows/Linux/macOS only — Android/iOS use
/// their native sqflite implementation untouched), dependency injection,
/// and the debug bloc observer. Called from `main.dart`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!_isMobilePlatform) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await setupServiceLocator();

  Bloc.observer = AppBlocObserver();

  runApp(const MetroYarApp());
}

bool get _isMobilePlatform =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
