import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../niril_podhu/tharavuru/seluthi_vagai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RECEIPT EDITOR — EXTRACTED SECTION BUILDERS
// ─────────────────────────────────────────────────────────────────────────────


/// Invoice picker button + selected invoice chips.
class PatruPattiyalTheervuPagudhi extends ConsumerWidget {
  const PatruPattiyalTheervuPagudhi({
    super.key,
    required this.selectedInvoices,
    required this.isDark,
    required this.onPickInvoices,
    required this.onRemoveInvoice,
  });

  final List<PattiyalTharavuru> selectedInvoices;
  final bool isDark;
  final VoidCallback onPickInvoices;
  final void Function(PattiyalTharavuru invoice) onRemoveInvoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Select Invoices" button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPickInvoices,
            icon: const Icon(CupertinoIcons.doc_text, size: 18),
            label: Text(
              selectedInvoices.isEmpty
                  ? K.pattiyalgalaiThaernhedu.tr(context, ref)
                  : '${selectedInvoices.length} ${K.pattiyalgal.tr(context, ref)}',
            ),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              foregroundColor: isDark ? Colors.white : Colors.black87,
              elevation: 0,
            ),
          ),
        ),

        // Selected invoice chips
        if (selectedInvoices.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedInvoices.map((inv) {
              return Chip(
                label: Text(inv.patrucheettuEn,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                deleteIcon:
                    const Icon(CupertinoIcons.xmark, size: 14),
                onDeleted: () => onRemoveInvoice(inv),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Payment section: amount, payment mode, reference, note.
class PatruSeluthiPagudhi extends ConsumerWidget {
  const PatruSeluthiPagudhi({
    super.key,
    required this.thogaiCtrl,
    required this.suttruEnCtrl,
    required this.ullkurippuCtrl,
    required this.seluthiVagai,
    required this.isDark,
    required this.onThogaiChanged,
    required this.onSeluthiVagaiChanged,
    required this.onSuttruEnChanged,
    required this.onUllkurippuChanged,
  });

  final TextEditingController thogaiCtrl;
  final TextEditingController suttruEnCtrl;
  final TextEditingController ullkurippuCtrl;
  final SeluthiVagai? seluthiVagai;
  final bool isDark;
  final ValueChanged<String> onThogaiChanged;
  final ValueChanged<SeluthiVagai?> onSeluthiVagaiChanged;
  final ValueChanged<String> onSuttruEnChanged;
  final ValueChanged<String> onUllkurippuChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Amount field
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: TextField(
                controller: thogaiCtrl,
                decoration: InputDecoration(
                  labelText: K.thogaiVinmeen.tr(context, ref),
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: onThogaiChanged,
              ),
            ),
            // Payment mode dropdown
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: DropdownButtonFormField<SeluthiVagai>(
                initialValue: seluthiVagai,
                decoration: InputDecoration(
                  labelText: K.cheluthumMuraiVinmeen.tr(context, ref),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: SeluthiVagai.values.map((mode) {
                  final isUpi = mode == SeluthiVagai.upi;
                  return DropdownMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(mode.icon, size: 18, color: mode.badgeColor(isDark)),
                        const SizedBox(width: 10),
                        Text(mode.label(context, ref), style: const TextStyle(height: 1.2)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onSeluthiVagaiChanged,
              ),
            ),
          ],
        ),

        // Reference number (shown only when not Cash)
        if (seluthiVagai != null && seluthiVagai!.needsReference) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: isDesktop ? 380 : double.infinity,
            child: TextField(
              controller: suttruEnCtrl,
              decoration: InputDecoration(
                labelText: K.kurippuEnParimaatraEn.tr(context, ref),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSuttruEnChanged,
            ),
          ),
        ],

        // Note
        const SizedBox(height: 16),
        TextField(
          controller: ullkurippuCtrl,
          decoration: InputDecoration(
            labelText: K.kurippu.tr(context, ref),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          onChanged: onUllkurippuChanged,
        ),
      ],
    );
  }
}
