import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tharavuthalam/seyali_tharavuthalam.dart';
import '../tharavuthalam/pattu_tharavuthalam.dart';
import '../tharavuthalam/kooli_tharavuthalam.dart';

import '../tharavuru/seyali_murai.dart';
import '../viruppangal_paniyagam.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/pattu_niruvana_tharavugal_provider.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/kooli_niruvana_tharavugal_provider.dart';

class AppStateNotifier extends Notifier<AppMode?> {
  @override
  AppMode? build() {
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
    StreamProvider<List<NiruvanaTharavugal>>((ref) {
  final pattuDb = ref.watch(pattuDatabaseProvider);
  final kooliDb = ref.watch(kooliDatabaseProvider);
  
  final controller = StreamController<List<NiruvanaTharavugal>>();
  List<NiruvanaTharavugal>? pattuProfiles;
  List<NiruvanaTharavugal>? kooliProfiles;

  void update() {
    if (pattuProfiles != null && kooliProfiles != null) {
      controller.add([...pattuProfiles!, ...kooliProfiles!]);
    }
  }

  // We use the notifiers' methods or just watch the stream from DB
  final sub1 = pattuDb.select(pattuDb.pattuNiruvanaTharavugalTable).watch().listen((data) {
    pattuProfiles = data.map((e) => NiruvanaTharavugal(
      id: e.id,
      mudhanMozhi: e.mudhanMozhi,
      thunaiMozhi: e.thunaiMozhi,
      iruMozhi: e.iruMozhi,
      niruvanathinPeyar: e.niruvanathinPeyar,
      kurumPeyar: e.kurumPeyar,
      // mapping others as empty string to save space here, since this stream is just for mode checking
      // but let's map seyaliVagai for hasProfileForCurrentModeProvider. 
      // Wait, NiruvanaTharavugal domain model doesn't have seyaliVagai!
      // We can use an adaimozhi trick or just map it properly.
    )).toList();
    // Because domain model doesn't have seyaliVagai, we just inject it into adaimozhi for the stream check
    for(var p in pattuProfiles!) {
      p.adaimozhi = {'mode': 'silk'};
    }
    update();
  });

  final sub2 = kooliDb.select(kooliDb.kooliNiruvanaTharavugalTable).watch().listen((data) {
    kooliProfiles = data.map((e) => NiruvanaTharavugal(
      id: e.id,
      kurumPeyar: e.kurumPeyar,
    )).toList();
    for(var p in kooliProfiles!) {
      p.adaimozhi = {'mode': 'coolie'};
    }
    update();
  });

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    controller.close();
  });

  return controller.stream;
});

final profilesLoadingProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(profilesStreamProvider);
  return asyncValue.isLoading && !asyncValue.hasValue;
});

final missingProfilesProvider = Provider<List<String>>((ref) {
  final profiles = ref.watch(profilesStreamProvider).value;
  if (profiles == null) {
    return ['silk', 'coolie']; 
  }

  final existingModes = profiles.map((p) => p.adaimozhi['mode'] ?? '').toList();
  final missing = <String>[];

  if (!existingModes.contains('silk')) missing.add('silk');
  if (!existingModes.contains('coolie')) missing.add('coolie');

  return missing;
});

final isSetupCompleteProvider = Provider<bool>((ref) {
  final profiles = ref.watch(profilesStreamProvider).value;
  return profiles != null && profiles.isNotEmpty;
});

final hasProfileForCurrentModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(appModeProvider);
  if (mode == null) return false;

  final profiles = ref.watch(profilesStreamProvider).value;
  if (profiles == null) return true; 

  final modeKey = mode == AppMode.coolie ? 'coolie' : 'silk';
  return profiles.any((p) => p.adaimozhi['mode'] == modeKey);
});

// Segment state inside Uruvakku tab
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

class BilingualNotifier extends Notifier<bool> {
  @override
  bool build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.iruMozhi ?? false;
  }

  @override
  set state(bool value) {
    final profile = ref.read(NiruvanaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(iruMozhi: value);
      ref.read(niruvanaTharavugalNotifierProvider).updateProfile(newProfile);
    }
  }
}

final bilingualProvider = NotifierProvider<BilingualNotifier, bool>(() {
  return BilingualNotifier();
});

class PrimaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.mudhanMozhi ?? 'Tamil';
  }

  @override
  set state(String value) {
    final profile = ref.read(NiruvanaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(mudhanMozhi: value);
      ref.read(niruvanaTharavugalNotifierProvider).updateProfile(newProfile);
    }
  }
}

final primaryLanguageProvider =
    NotifierProvider<PrimaryLanguageNotifier, String>(() {
  return PrimaryLanguageNotifier();
});

class SecondaryLanguageNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.thunaiMozhi ?? 'English';
  }

  @override
  set state(String value) {
    final profile = ref.read(NiruvanaTharavugalProvider);
    if (profile != null) {
      final newProfile = profile.copyWith(thunaiMozhi: value);
      ref.read(niruvanaTharavugalNotifierProvider).updateProfile(newProfile);
    }
  }
}

final secondaryLanguageProvider =
    NotifierProvider<SecondaryLanguageNotifier, String>(() {
  return SecondaryLanguageNotifier();
});

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

class SkipRestoreNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setSkip(bool value) => state = value;
}

final skipRestoreProvider = NotifierProvider<SkipRestoreNotifier, bool>(SkipRestoreNotifier.new);







