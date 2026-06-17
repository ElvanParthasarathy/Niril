import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import 'components/vanigar/vanigar_gst.dart';
import 'components/vanigar/vanigar_coolie.dart';

class VanigarPage extends ConsumerWidget {
  const VanigarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const VanigarCoolie();
    }
    
    // Default to GST mode
    return const VanigarGst();
  }
}
