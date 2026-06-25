import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';

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
    final cs = Theme.of(context).colorScheme;

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
                  child: DropdownButtonFormField<int>(
                    value: selectedNiruvanamId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: K.niruvanaththaithThaernhedu.tr(context, ref),
                    ),
                    items: profiles.map((p) {
                      final name = p.niruvanathinPeyar['Tamil']?.isNotEmpty == true
                          ? p.niruvanathinPeyar['Tamil']!
                          : p.niruvanathinPeyar['English'] ?? '';
                      return DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(
                          '$name (${p.kurumPeyar})',
                          style: TextStyle(color: cs.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final p = profiles.firstWhere((profile) => profile.id == val);
                        onChanged(p);
                      } else {
                        onChanged(null);
                      }
                    },
                  ),
                ),
                if (selectedNiruvanamId != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onChanged(null),
                    icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                    tooltip: K.azhikka.tr(context, ref), // Clear
                  ),
                ],
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
