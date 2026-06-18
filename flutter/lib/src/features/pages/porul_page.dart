import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import 'components/porul/porul_gst.dart';
import 'components/porul/porul_coolie.dart';

class PorulPage extends ConsumerWidget {
  const PorulPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const PorulCoolie();
    }
    
    // Default to GST mode
    return const PorulGst();
  }
}