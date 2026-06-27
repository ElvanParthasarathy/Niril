import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/achu_mozhi_facade.dart';
import '../../../../adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import '../../../../adippadai/iru_mozhi/iru_mozhi_niruvanam_udhavi.dart';
import '../../../../adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
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
    final isBilingual = ref.watch(bilingualProvider);
    final mudhanmaiMozhi = ref.watch(primaryLanguageProvider);
    final irandaamMozhi = ref.watch(secondaryLanguageProvider);

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
                        IruMozhiNiruvanamUdhavi.mudhanmaiPeyar(p, mudhanmaiMozhi, irandaamMozhi): p
                    };
                    final subtitlesMap = {
                      for (final p in profiles)
                        IruMozhiNiruvanamUdhavi.mudhanmaiPeyar(p, mudhanmaiMozhi, irandaamMozhi): IruMozhiNiruvanamUdhavi.thunaiPeyar(p, isBilingual, isSilk, irandaamMozhi)
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
                      label: placeholder, // Properly set the label so it shows in bottom sheet
                      hideLabel: true, // Hide it on the editor form
                      value: currentValue,
                      items: profilesMap.keys.toList(),
                      subtitles: subtitlesMap,
                      onChanged: (String newValue) {
                        onChanged(profilesMap[newValue]);
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
