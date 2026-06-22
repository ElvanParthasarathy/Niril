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
final _profilesStreamProvider =
    StreamProvider<List<VanigaTharavugalEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.vanigaTharavugalTable).watch();
});

// Exposes the loading state of the profiles stream
final profilesLoadingProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(_profilesStreamProvider);
  return asyncValue.isLoading && !asyncValue.hasValue;
});

// Derived provider: Which profiles are missing from the DB?
// Returns a list of AppMode strings (e.g. ['silk', 'coolie'], ['coolie'], or [])
final missingProfilesProvider = Provider<List<String>>((ref) {
  final profiles = ref.watch(_profilesStreamProvider).value;
  if (profiles == null)
    return []; // Assume none missing while loading to prevent flashes

  final existingModes = profiles.map((p) => p.seyaliVagai).toList();
  final missing = <String>[];

  if (!existingModes.contains('silk')) missing.add('silk');
  if (!existingModes.contains('coolie')) missing.add('coolie');

  return missing;
});

// Derived provider: Do we have at least one profile setup?
final isSetupCompleteProvider = Provider<bool>((ref) {
  final profiles = ref.watch(_profilesStreamProvider).value;
  return profiles != null && profiles.isNotEmpty;
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

final uruvakkuSegmentProvider =
    NotifierProvider<UruvakkuSegmentNotifier, int>(() {
  return UruvakkuSegmentNotifier();
});

// Tracks whether bilingual mode is enabled across the app (Firewalled by AppMode)
class BilingualNotifier extends Notifier<bool> {
  @override
  bool build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      // Coolie mode always collects both languages in settings
      return true;
    } else {
      final profile = ref.watch(vanigaTharavugalProvider);
      return profile?.iruMozhi ?? false;
    }
  }

  set state(bool value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      // Ignore: Coolie settings are strictly always bilingual for data entry
    } else {
      final profile = ref.read(vanigaTharavugalProvider);
      if (profile != null) {
        final newProfile = profile.copyWith(iruMozhi: value);
        ref.read(vanigaTharavugalProvider.notifier).updateProfile(newProfile);
      }
    }
  }
}

final bilingualProvider = NotifierProvider<BilingualNotifier, bool>(() {
  return BilingualNotifier();
});

// Tracks primary language for data entry
class PrimaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(vanigaTharavugalProvider);
    return profile?.mudhanMozhi ?? 'Tamil';
  }

  set state(String value) {
    final profile = ref.read(vanigaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(mudhanMozhi: value);
      ref.read(vanigaTharavugalProvider.notifier).updateProfile(newProfile);
    }
  }
}

final primaryLanguageProvider =
    NotifierProvider<PrimaryLanguageNotifier, String>(() {
  return PrimaryLanguageNotifier();
});

// Tracks secondary language for data entry
class SecondaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(vanigaTharavugalProvider);
    return profile?.thunaiMozhi ?? 'English';
  }

  set state(String value) {
    final profile = ref.read(vanigaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(thunaiMozhi: value);
      ref.read(vanigaTharavugalProvider.notifier).updateProfile(newProfile);
    }
  }
}

final secondaryLanguageProvider =
    NotifierProvider<SecondaryLanguageNotifier, String>(() {
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

/// Provider to track if the user clicked "Start Fresh" to skip the restore screen
class SkipRestoreNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setSkip(bool value) => state = value;
}

final skipRestoreProvider = NotifierProvider<SkipRestoreNotifier, bool>(SkipRestoreNotifier.new);
