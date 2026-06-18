import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import '../niril_silk/presentation/pages/silk_merchants_page.dart';
import '../niril_coolie/presentation/pages/coolie_merchants_page.dart';

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