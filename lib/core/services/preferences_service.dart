import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';

/// Thin, synchronous-after-init wrapper around [SharedPreferences].
///
/// [init] is awaited once in `bootstrap.dart` before `runApp`, so every
/// other read in the app (deciding initial theme, whether to show
/// onboarding, etc.) can happen instantly and synchronously.
class PreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Theme ────────────────────────────────────────────────────────────────

  ThemeMode get themeMode {
    final stored = _prefs.getString(PrefKeys.themeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _prefs.setString(PrefKeys.themeMode, value);
  }

  // ── Onboarding ───────────────────────────────────────────────────────────

  bool get hasCompletedOnboarding =>
      _prefs.getBool(PrefKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(PrefKeys.onboardingComplete, true);
}
