import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/models/app_mode.dart';
import '../../../niril_silk/presentation/pages/settings/silk_vaniga_amaippu.dart';
import '../../../niril_coolie/presentation/pages/settings/coolie_vaniga_amaippu.dart';

class VanigaAmaippugalPage extends ConsumerWidget {
  const VanigaAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieVanigaAmaippuPage();
    }
    return const SilkVanigaAmaippuPage();
  }
}
