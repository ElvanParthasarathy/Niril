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

// Tracks the selected segment inside the Uruvakku tab (0 = Invoices, 1 = Receipts)
final uruvakkuSegmentProvider = StateProvider<int>((ref) => 0);

// Tracks whether bilingual mode is enabled across the app
final bilingualProvider = StateProvider<bool>((ref) => false);

// Tracks primary and secondary language for data entry
final primaryLanguageProvider = StateProvider<String>((ref) => 'Tamil');
final secondaryLanguageProvider = StateProvider<String>((ref) => 'English');