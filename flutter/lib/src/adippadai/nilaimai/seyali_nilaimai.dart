import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tharavuru/seyali_murai.dart';
import '../viruppangal_paniyagam.dart';
import '../tharavuthalam/seyali_tharavuthalam.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal_provider.dart';

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
final profilesStreamProvider =
    StreamProvider<List<NiruvanaTharavugalEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.niruvanaTharavugalTable).watch();
});

// Exposes the loading state of the profiles stream
final profilesLoadingProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(profilesStreamProvider);
  return asyncValue.isLoading && !asyncValue.hasValue;
});

// Derived provider: Which profiles are missing from the DB?
// Returns a list of AppMode strings (e.g. ['silk', 'coolie'], ['coolie'], or [])
final missingProfilesProvider = Provider<List<String>>((ref) {
  final profiles = ref.watch(profilesStreamProvider).value;
  if (profiles == null)
    return ['silk', 'coolie']; // Assume both missing while loading so onboarding fields are visible

  final existingModes = profiles.map((p) => p.seyaliVagai).toList();
  final missing = <String>[];

  if (!existingModes.contains('silk')) missing.add('silk');
  if (!existingModes.contains('coolie')) missing.add('coolie');

  return missing;
});

// Derived provider: Do we have at least one profile setup?
final isSetupCompleteProvider = Provider<bool>((ref) {
  final profiles = ref.watch(profilesStreamProvider).value;
  return profiles != null && profiles.isNotEmpty;
});

// Derived provider: Do we have a profile for the currently selected mode?
final hasProfileForCurrentModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  if (mode == null) return false;

  final profiles = ref.watch(profilesStreamProvider).value;
  if (profiles == null) return true; // Assume true while loading

  final modeKey = mode == AppMode.coolie ? 'coolie' : 'silk';
  return profiles.any((p) => p.seyaliVagai == modeKey);
});

// ── Mode-Filtered Profiles Stream (Firewall) ────────────────────────────────
// Returns ONLY profiles for the current app mode.
// Use this in invoice/receipt/merchant lists to prevent cross-mode leaks.
// The unfiltered `profilesStreamProvider` above is kept for onboarding checks.
final currentModeProfilesStreamProvider =
    StreamProvider<List<NiruvanaTharavugalEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final mode = ref.watch(appModeProvider);

  if (mode == null) {
    return Stream.value(<NiruvanaTharavugalEntry>[]);
  }

  final modeKey = mode == AppMode.coolie ? 'coolie' : 'silk';
  return (db.select(db.niruvanaTharavugalTable)
        ..where((t) => t.seyaliVagai.equals(modeKey)))
      .watch();
});

// Tracks the selected segment inside the Uruvakku tab (0 = Invoices, 1 = Receipts)
// Each mode has its own independent segment state so switching modes doesn't reset the tab.
final _silkUruvakkuSegmentProvider = NotifierProvider<_SegmentNotifier, int>(_SegmentNotifier.new);
final _coolieUruvakkuSegmentProvider = NotifierProvider<_SegmentNotifier, int>(_SegmentNotifier.new);

class _SegmentNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

class UruvakkuSegmentNotifier extends Notifier<int> {
  @override
  int build() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.coolie) {
      return ref.watch(_coolieUruvakkuSegmentProvider);
    } else {
      return ref.watch(_silkUruvakkuSegmentProvider);
    }
  }

  @override
  set state(int value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      ref.read(_coolieUruvakkuSegmentProvider.notifier).set(value);
    } else {
      ref.read(_silkUruvakkuSegmentProvider.notifier).set(value);
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
      final profile = ref.watch(NiruvanaTharavugalProvider);
      return profile?.iruMozhi ?? false;
    }
  }

  set state(bool value) {
    final mode = ref.read(appModeProvider);
    if (mode == AppMode.coolie) {
      // Ignore: Coolie settings are strictly always bilingual for data entry
    } else {
      final profile = ref.read(NiruvanaTharavugalProvider);
      if (profile != null) {
        final newProfile = profile.copyWith(iruMozhi: value);
        ref.read(NiruvanaTharavugalListProvider.notifier).updateProfile(newProfile);
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
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.mudhanMozhi ?? 'Tamil';
  }

  set state(String value) {
    final profile = ref.read(NiruvanaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(mudhanMozhi: value);
      ref.read(NiruvanaTharavugalListProvider.notifier).updateProfile(newProfile);
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
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.thunaiMozhi ?? 'English';
  }

  set state(String value) {
    final profile = ref.read(NiruvanaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(thunaiMozhi: value);
      ref.read(NiruvanaTharavugalListProvider.notifier).updateProfile(newProfile);
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
