import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider that holds the initialized SharedPreferences instance.
// We override this in main() after initialization.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class PreferencesService {
  PreferencesService(this._prefs);
  final SharedPreferences _prefs;

  static const _themeKey = 'app_theme_mode';
  static const _localeKey = 'app_locale';
  static const _isLoggedInKey = 'is_logged_in';

  static const _isSidebarCollapsedKey = 'is_sidebar_collapsed';

  // --- Auth ---
  bool getIsLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setIsLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }

  // --- Sidebar ---
  bool getIsSidebarCollapsed() {
    return _prefs.getBool(_isSidebarCollapsedKey) ?? false;
  }

  Future<void> setIsSidebarCollapsed(bool value) async {
    await _prefs.setBool(_isSidebarCollapsedKey, value);
  }

  // --- Theme ---
  ThemeMode getThemeMode() {
    final themeString = _prefs.getString(_themeKey);
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  // --- Locale ---
  Locale? getLocale() {
    final localeString = _prefs.getString(_localeKey);
    if (localeString == null || localeString.isEmpty) {
      return null;
    }
    return Locale(localeString);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }
}

// Provide the PreferencesService using the sharedPreferencesProvider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(sharedPreferencesProvider));
});