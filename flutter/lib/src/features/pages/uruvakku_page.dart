import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import '../niril_silk/presentation/pages/silk_uruvakku_page.dart';
import '../niril_coolie/presentation/pages/coolie_uruvakku_page.dart';

class UruvakkuPage extends ConsumerWidget {
  const UruvakkuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieUruvakkuPage();
    }

    // Default to GST mode
    return const SilkUruvakkuPage();
  }
}
