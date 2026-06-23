import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/nilaimai/app_state.dart';
import '../../../../adippadai/tharavuru/app_mode.dart';
import '../../../niril_pattu/kaatchi/thiraigal/amaippugal/pattu_vangi.dart';
import '../../../niril_kooli/kaatchi/thiraigal/amaippugal/kooli_vangi.dart';

class VangiPage extends ConsumerWidget {
  const VangiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieVangiPage();
    }
    return const SilkVangiPage();
  }
}
