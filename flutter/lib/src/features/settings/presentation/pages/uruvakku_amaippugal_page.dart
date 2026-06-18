import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/models/app_mode.dart';
import '../../../niril_silk/presentation/pages/settings/silk_uruvakku_amaippu.dart';
import '../../../niril_coolie/presentation/pages/settings/coolie_uruvakku_amaippu.dart';

class UruvakkuAmaippugalPage extends ConsumerWidget {
  const UruvakkuAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieUruvakkuAmaippuPage();
    }
    return const SilkUruvakkuAmaippuPage();
  }
}
