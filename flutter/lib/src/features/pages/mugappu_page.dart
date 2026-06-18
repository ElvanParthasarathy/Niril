import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_mode.dart';
import '../../core/state/app_state.dart';
import 'components/mugappu/mugappu_gst.dart';
import 'components/mugappu/mugappu_coolie.dart';

class MugappuPage extends ConsumerWidget {
  const MugappuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.coolie) {
      return const MugappuCoolie();
    }
    
    // Default to GST mode
    return const MugappuGst();
  }
}