import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/preferences_service.dart';

/// Holds the app's current [ThemeMode] and persists every change via
/// [PreferencesService], so the choice survives app restarts.
class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(_preferencesService.themeMode);

  void setThemeMode(ThemeMode mode) {
    if (mode == state) return;
    emit(mode);
    _preferencesService.setThemeMode(mode);
  }
}
