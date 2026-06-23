import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../adippadai/tharavuru/app_mode.dart';
import '../../adippadai/nilaimai/app_state.dart';
import '../niril_pattu/kaatchi/thiraigal/pattu_vanigargal_thirai.dart';
import '../niril_kooli/kaatchi/thiraigal/kooli_vanigargal_thirai.dart';

class VanigarPage extends ConsumerWidget {
  const VanigarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieMerchantsPage();
    }

    // Default to GST mode
    return const SilkMerchantsPage();
  }
}
