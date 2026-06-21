import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_mode.dart';
import '../preferences_service.dart';
import '../database/app_database.dart';
import '../../features/settings/data/vaniga_tharavugal_provider.dart';
class AppStateNotifier extends Notifier<AppMode?> {
  @override
  AppMode? build() {
    // Always return null initially so the Mode Selector is shown on every app launch
    return null;
  }

  void setMode(AppMode? mode) {
    state = mode;
  }
}

final appModeProvider = NotifierProvider<AppStateNotifier, AppMode?>(() {
  return AppStateNotifier();
});


// Stream of all profiles in the database
final _profilesStreamProvider = StreamProvider<List<VanigaTharavugalEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.vanigaTharavugalTable).watch();
});

// Derived provider: Do we have ANY profile at all? (If false, go to Welcome Page)
final hasAnyProfileProvider = Provider<bool>((ref) {
  final profiles = ref.watch(_profilesStreamProvider).valueOrNull;
  // If still loading or null, we assume we might have profiles to avoid flashing Welcome screen
  if (profiles == null) return true;
  return profiles.isNotEmpty;
});

// Derived provider: Do we have a profile for the currently selected mode?
final hasProfileForCurrentModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  if (mode == null) return false;
  
  final profiles = ref.watch(_profilesStreamProvider).valueOrNull;
  if (profiles == null) return true; // Assume true while loading
  
  final modeKey = mode == AppMode.coolie ? 'coolie' : 'silk';
  return profiles.any((p) => p.seyaliVagai == modeKey);
});

// We keep the old onboardedProvider strictly for any legacy references, 
// but we map it to our reactive database check.
final onboardedProvider = Provider<bool>((ref) {
  return ref.watch(hasAnyProfileProvider);
});


// Tracks the selected segment inside the Uruvakku tab (0 = Invoices, 1 = Receipts)
final uruvakkuSegmentProvider = StateProvider<int>((ref) => 0);

// Tracks whether bilingual mode is enabled across the app
final bilingualProvider = StateProvider<bool>((ref) => false);

// Tracks primary and secondary language for data entry
final primaryLanguageProvider = StateProvider<String>((ref) => 'Tamil');
final secondaryLanguageProvider = StateProvider<String>((ref) => 'English');

// Tracks mock authentication state
final isLoggedInProvider = StateProvider<bool>((ref) => false);