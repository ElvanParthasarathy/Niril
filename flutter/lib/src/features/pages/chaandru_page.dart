import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import 'components/chaandru/chaandru_gst.dart';
import 'components/chaandru/chaandru_coolie.dart';

class ChaandruPage extends ConsumerWidget {
  const ChaandruPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const ChaandruCoolie();
    }
    
    // Default to GST mode
    return const ChaandruGst();
  }
}