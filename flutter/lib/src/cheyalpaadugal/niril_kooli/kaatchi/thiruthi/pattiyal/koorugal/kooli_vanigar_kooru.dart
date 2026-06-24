import 'package:flutter/material.dart';

import '../../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';

/// §1 Customer — client search + company dropdown + saved-details card.
class KooliVanigarKooru extends StatelessWidget {
  final int? selectedVanigarId;
  final String selectedVanigarPeyar;
  final int? selectedNiruvanamId;
  final List<NiruvanaTharavugal> profiles;
  final ValueChanged<VanigarEntry> onVanigarSelected;
  final ValueChanged<int?> onNiruvanamChanged;
  final VoidCallback? onRequestAddNewVanigar;
  final VanigarEntry? selectedVanigar;

  const KooliVanigarKooru({
    super.key,
    required this.selectedVanigarId,
    required this.selectedVanigarPeyar,
    required this.selectedNiruvanamId,
    required this.profiles,
    required this.onVanigarSelected,
    required this.onNiruvanamChanged,
    this.onRequestAddNewVanigar,
    this.selectedVanigar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 600;
      final customerColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Text('Client Name',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                )),
          ),
          VanigarThaeduKooru(
            seyaliVagai: 'coolie',
            selectedId: selectedVanigarId,
            onSelected: onVanigarSelected,
            onRequestAddNew: onRequestAddNewVanigar,
          ),
          if (selectedVanigarPeyar.isNotEmpty) ...[
            const SizedBox(height: 12),
            ElvanThiruthiAttai(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAVED DETAILS',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      )),
                  const SizedBox(height: 8),
                  Text(selectedVanigarPeyar,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  if (selectedVanigar != null) ...[
                    if ((selectedVanigar!.mugavari['Tamil'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(selectedVanigar!.mugavari['Tamil']!,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                    if ((selectedVanigar!.oor['Tamil'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(selectedVanigar!.oor['Tamil']!,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                    if ((selectedVanigar!.maavattam['Tamil'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(selectedVanigar!.maavattam['Tamil']!,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                    if (selectedVanigar!.anjalKuriyeedu.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(selectedVanigar!.anjalKuriyeedu,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                    if ((selectedVanigar!.maanilam['Tamil'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(selectedVanigar!.maanilam['Tamil']!,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      );

      final companyColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Text('Company',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                )),
          ),
          DropdownButtonFormField<int>(
            initialValue: selectedNiruvanamId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50)),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
            ),
            items: profiles.map((p) {
              final name = p.niruvanathinPeyar['Tamil'] ??
                  p.niruvanathinPeyar['English'] ??
                  'Company';
              return DropdownMenuItem(value: p.id, child: Text(name));
            }).toList(),
            onChanged: onNiruvanamChanged,
          ),
        ],
      );

      if (isDesktop) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: customerColumn),
            const SizedBox(width: 24),
            Expanded(flex: 7, child: companyColumn),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [customerColumn, companyColumn],
      );
    });
  }
}
