import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_mode.dart';
import '../preferences_service.dart';

class AppStateNotifier extends Notifier<AppMode?> {
  @override
  AppMode? build() {
    // Always return null initially so the Mode Selector is shown on every app launch
    return null;
  }

  void setMode(AppMode mode) {
    state = mode;
  }
}

final appModeProvider = NotifierProvider<AppStateNotifier, AppMode?>(() {
  return AppStateNotifier();
});