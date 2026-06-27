import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'koorugal/elvan_thiruthi_keezhvirivu.dart';

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
    final isSilk = ref.watch(appModeProvider) != AppMode.coolie;
    final mudhanmaiMozhi = isSilk ? ref.watch(silkMudhanmaiMozhiProvider) : ref.watch(kooliAchuMozhiProvider);
    final irandaamMozhi = isSilk ? ref.watch(silkIrandaamMozhiProvider) : 'English';

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
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Builder(builder: (context) {
                    final profilesMap = {
                      for (final p in profiles)
                        '${(p.niruvanathinPeyar[mudhanmaiMozhi]?.isNotEmpty == true ? p.niruvanathinPeyar[mudhanmaiMozhi] : p.niruvanathinPeyar[irandaamMozhi]) ?? p.niruvanathinPeyar['Tamil'] ?? p.niruvanathinPeyar.values.firstOrNull ?? ''} (${p.kurumPeyar})': p
                    };
                    final subtitlesMap = {
                      for (final p in profiles)
                        '${(p.niruvanathinPeyar[mudhanmaiMozhi]?.isNotEmpty == true ? p.niruvanathinPeyar[mudhanmaiMozhi] : p.niruvanathinPeyar[irandaamMozhi]) ?? p.niruvanathinPeyar['Tamil'] ?? p.niruvanathinPeyar.values.firstOrNull ?? ''} (${p.kurumPeyar})': p.niruvanathinPeyar[irandaamMozhi] ?? p.niruvanathinPeyar['English'] ?? ''
                    };

                    final placeholder =
                        K.niruvanaththaithThaernhedu.tr(context, ref);
                    final currentValue = selectedNiruvanamId == null
                        ? placeholder
                        : profilesMap.entries
                            .firstWhere(
                              (e) => e.value.id == selectedNiruvanamId,
                              orElse: () => profilesMap.entries.first,
                            )
                            .key;

                    return ElvanThiruthiKeezhvirivu(
                      label: '', // Empty label since PagudhiThalaipu handles it
                      value: currentValue,
                      items: [placeholder, ...profilesMap.keys],
                      subtitles: subtitlesMap,
                      onChanged: (String newValue) {
                        if (newValue == placeholder) {
                          onChanged(null);
                        } else {
                          onChanged(profilesMap[newValue]);
                        }
                      },
                      onClear: selectedNiruvanamId != null
                          ? () => onChanged(null)
                          : null,
                    );
                  }),
                ),
              ],
            ),
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
