import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_mode.dart';
import '../preferences_service.dart';

class AppStateNotifier extends Notifier<AppMode?> {
  static const String _modeKey = 'elvanniril_app_mode';

  @override
  AppMode? build() {
    // Read from SharedPreferences during initialization
    final prefs = ref.read(sharedPreferencesProvider);
    final savedMode = prefs.getString(_modeKey);
    
    if (savedMode == AppMode.gst.id) return AppMode.gst;
    if (savedMode == AppMode.coolie.id) return AppMode.coolie;
    
    return null; // Null means no mode selected yet (show selector)
  }

  Future<void> setMode(AppMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_modeKey, mode.id);
  }
}

final appModeProvider = NotifierProvider<AppStateNotifier, AppMode?>(() {
  return AppStateNotifier();
});

