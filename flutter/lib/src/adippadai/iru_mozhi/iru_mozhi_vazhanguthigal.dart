import 'package:elvan_niril/src/adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'iru_mozhi.dart';

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

class SilkMudhanmaiMozhiNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.mudhanMozhi ?? IruMozhi.iyalbuMudhanmaiMozhi;
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

final silkMudhanmaiMozhiProvider =
    NotifierProvider<SilkMudhanmaiMozhiNotifier, String>(() {
  return SilkMudhanmaiMozhiNotifier();
});

class SilkIrandaamMozhiNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.thunaiMozhi ?? IruMozhi.iyalbuIrandaamMozhi;
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

final silkIrandaamMozhiProvider =
    NotifierProvider<SilkIrandaamMozhiNotifier, String>(() {
  return SilkIrandaamMozhiNotifier();
});
