import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'oru_mozhi.dart';

class KooliAchuMozhiNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(NiruvanaTharavugalProvider);
    return profile?.mudhanMozhi ?? OruMozhi.iyalbuMozhi;
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

final kooliAchuMozhiProvider =
    NotifierProvider<KooliAchuMozhiNotifier, String>(() {
  return KooliAchuMozhiNotifier();
});
