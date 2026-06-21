import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

// Derived provider: Which profiles are missing from the DB?
// Returns a list of AppMode strings (e.g. ['silk', 'coolie'], ['coolie'], or [])
final missingProfilesProvider = Provider<List<String>>((ref) {
  final profiles = ref.watch(_profilesStreamProvider).value;
  if (profiles == null) return []; // Assume none missing while loading to prevent flashes
  
  final existingModes = profiles.map((p) => p.seyaliVagai).toList();
  final missing = <String>[];
  
  if (!existingModes.contains('silk')) missing.add('silk');
  if (!existingModes.contains('coolie')) missing.add('coolie');
  
  return missing;
});

// Derived provider: Do we have BOTH profiles setup?
final hasBothProfilesProvider = Provider<bool>((ref) {
  final missing = ref.watch(missingProfilesProvider);
  return missing.isEmpty;
});

// Derived provider: Do we have a profile for the currently selected mode?
final hasProfileForCurrentModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  if (mode == null) return false;
  
  final profiles = ref.watch(_profilesStreamProvider).value;
  if (profiles == null) return true; // Assume true while loading
  
  final modeKey = mode == AppMode.coolie ? 'coolie' : 'silk';
  return profiles.any((p) => p.seyaliVagai == modeKey);
});


// Tracks the selected segment inside the Uruvakku tab (0 = Invoices, 1 = Receipts)
final silkUruvakkuSegmentProvider = StateProvider<int>((ref) => 0);
final coolieUruvakkuSegmentProvider = StateProvider<int>((ref) => 0);

class UruvakkuSegmentNotifier extends Notifier<int> {
  @override
  int build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      return ref.watch(coolieUruvakkuSegmentProvider);
    } else {
      return ref.watch(silkUruvakkuSegmentProvider);
    }
  }
  set state(int value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      ref.read(coolieUruvakkuSegmentProvider.notifier).state = value;
    } else {
      ref.read(silkUruvakkuSegmentProvider.notifier).state = value;
    }
  }
}

final uruvakkuSegmentProvider = NotifierProvider<UruvakkuSegmentNotifier, int>(() {
  return UruvakkuSegmentNotifier();
});

// Tracks whether bilingual mode is enabled across the app (Firewalled by AppMode)
final silkBilingualProvider = StateProvider<bool>((ref) => false);

class BilingualNotifier extends Notifier<bool> {
  @override
  bool build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      // Coolie mode always collects both languages in settings
      return true;
    } else {
      return ref.watch(silkBilingualProvider);
    }
  }

  set state(bool value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      // Ignore: Coolie settings are strictly always bilingual for data entry
    } else {
      ref.read(silkBilingualProvider.notifier).state = value;
    }
  }
}

final bilingualProvider = NotifierProvider<BilingualNotifier, bool>(() {
  return BilingualNotifier();
});

// Tracks primary and secondary language for data entry
final silkPrimaryLanguageProvider = StateProvider<String>((ref) => 'Tamil');
final cooliePrimaryLanguageProvider = StateProvider<String>((ref) => 'Tamil');

class PrimaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      return ref.watch(cooliePrimaryLanguageProvider);
    } else {
      return ref.watch(silkPrimaryLanguageProvider);
    }
  }
  set state(String value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      ref.read(cooliePrimaryLanguageProvider.notifier).state = value;
    } else {
      ref.read(silkPrimaryLanguageProvider.notifier).state = value;
    }
  }
}

final primaryLanguageProvider = NotifierProvider<PrimaryLanguageNotifier, String>(() {
  return PrimaryLanguageNotifier();
});

final silkSecondaryLanguageProvider = StateProvider<String>((ref) => 'English');
final coolieSecondaryLanguageProvider = StateProvider<String>((ref) => 'English');

class SecondaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      return ref.watch(coolieSecondaryLanguageProvider);
    } else {
      return ref.watch(silkSecondaryLanguageProvider);
    }
  }
  set state(String value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      ref.read(coolieSecondaryLanguageProvider.notifier).state = value;
    } else {
      ref.read(silkSecondaryLanguageProvider.notifier).state = value;
    }
  }
}

final secondaryLanguageProvider = NotifierProvider<SecondaryLanguageNotifier, String>(() {
  return SecondaryLanguageNotifier();
});

// Tracks authentication state via SharedPreferences
class IsLoggedInNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(preferencesServiceProvider).getIsLoggedIn();
  }

  void setLoggedIn(bool value) {
    state = value;
    ref.read(preferencesServiceProvider).setIsLoggedIn(value);
  }
}

final isLoggedInProvider = NotifierProvider<IsLoggedInNotifier, bool>(() {
  return IsLoggedInNotifier();
});