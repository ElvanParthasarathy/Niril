import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_thalaippu.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../koorugal/elvan_niruvanam_keezhvirivu_kooru.dart';

/// A shared wrapper that enforces Business Profile selection before 
/// allowing interaction with the editor form.
class ElvanThiruthiNiruvanamOadu extends ConsumerWidget {
  /// The currently selected business profile ID.
  final int? selectedNiruvanamId;

  /// Callback when a profile is selected or auto-selected.
  final ValueChanged<NiruvanaTharavugal?> onChanged;

  /// The inner form/editor.
  final Widget child;

  const ElvanThiruthiNiruvanamOadu({
    super.key,
    required this.selectedNiruvanamId,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(NiruvanaTharavugalListProvider);

    // Auto-select if only one profile exists
    if (profiles.length == 1 && selectedNiruvanamId == null) {
      Future.microtask(() {
        onChanged(profiles.first);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profiles.length > 1) ...[
          ElvanPagudhiThalaipu(en: 1, thalaipu: K.niruvanam.tr(context, ref)),
          ElvanThiruthiThalaippu(label: K.niruvanam.tr(context, ref)),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = MediaQuery.sizeOf(context).width >= 800;
              final width = isDesktop ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
              return Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                child: SizedBox(
                  width: width,
                  child: ElvanNiruvanamKeezhvirivuKooru(
                    selectedNiruvanamId: selectedNiruvanamId,
                    hideLabel: true,
                    showClearButton: true,
                    onChanged: (p) => onChanged(p),
                  ),
                ),
              );
            }
          ),
        ],

        // Form Lock (Opacity + IgnorePointer)
        Opacity(
          opacity: selectedNiruvanamId == null ? 0.4 : 1.0,
          child: IgnorePointer(
            ignoring: selectedNiruvanamId == null,
            child: child,
          ),
        ),
      ],
    );
  }
}
