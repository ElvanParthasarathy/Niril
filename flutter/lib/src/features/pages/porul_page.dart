import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import '../niril_silk/presentation/pages/silk_items_page.dart';
import '../niril_coolie/presentation/pages/coolie_items_page.dart';

class PorulPage extends ConsumerWidget {
  const PorulPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const CoolieItemsPage();
    }

    // Default to GST mode
    return const SilkItemsPage();
  }
}
