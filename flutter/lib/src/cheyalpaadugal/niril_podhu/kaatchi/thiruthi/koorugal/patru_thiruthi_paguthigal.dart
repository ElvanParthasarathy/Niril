import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';
import '../../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RECEIPT EDITOR — EXTRACTED SECTION BUILDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Profile switcher chips for multi-profile companies.
class PatruThannuruMaatrigan extends StatelessWidget {
  const PatruThannuruMaatrigan({
    super.key,
    required this.profiles,
    required this.selectedNiruvanamId,
    required this.isDark,
    required this.onSelected,
  });

  final List<NiruvanaTharavugalEntry> profiles;
  final int? selectedNiruvanamId;
  final bool isDark;
  final void Function(NiruvanaTharavugalEntry profile) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: profiles.map((p) {
            final isActive = p.id == selectedNiruvanamId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.kurumPeyar.isNotEmpty
                    ? p.kurumPeyar
                    : (p.niruvanathinPeyar.values.firstOrNull ?? '')),
                selected: isActive,
                onSelected: (_) => onSelected(p),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Invoice picker button + selected invoice chips.
class PatruPattiyalTheervuPagudhi extends StatelessWidget {
  const PatruPattiyalTheervuPagudhi({
    super.key,
    required this.selectedInvoices,
    required this.isDark,
    required this.onPickInvoices,
    required this.onRemoveInvoice,
  });

  final List<PatrucheettuEntry> selectedInvoices;
  final bool isDark;
  final VoidCallback onPickInvoices;
  final void Function(PatrucheettuEntry invoice) onRemoveInvoice;

  @override
  Widget build(BuildContext context) {
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
                  ? 'பட்டியலைத் தேர்ந்தெடு'
                  : '${selectedInvoices.length} பட்டியல்கள்',
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

/// Receipt data section: date, customer, receipt number.
class PatruTharavuPagudhi extends StatelessWidget {
  const PatruTharavuPagudhi({
    super.key,
    required this.patruNaal,
    required this.seyaliVagai,
    required this.selectedVanigarId,
    required this.patruEn,
    required this.isDark,
    required this.onDateChanged,
    required this.onVanigarSelected,
  });

  final DateTime patruNaal;
  final String seyaliVagai;
  final int? selectedVanigarId;
  final String patruEn;
  final bool isDark;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(VanigarEntry vanigar) onVanigarSelected;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Date picker
        SizedBox(
          width: isDesktop ? 280 : double.infinity,
          child: PattiyalNaalKooru(
            selectedDate: patruNaal,
            onDateChanged: onDateChanged,
          ),
        ),
        // Customer picker
        SizedBox(
          width: isDesktop ? 380 : double.infinity,
          child: VanigarThaeduKooru(
            seyaliVagai: seyaliVagai,
            selectedId: selectedVanigarId,
            onSelected: onVanigarSelected,
          ),
        ),
        // Receipt number (read-only display)
        if (patruEn.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.number,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black38),
                const SizedBox(width: 8),
                Text(
                  patruEn,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Payment section: amount, payment mode, reference, note.
class PatruSeluthiPagudhi extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  labelText: 'தொகை *',
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
                  labelText: 'செலுத்தி வகை *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: SeluthiVagai.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(mode.icon, size: 18,
                            color: mode.badgeColor(isDark)),
                        const SizedBox(width: 10),
                        Text(mode.tamilLabel),
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
                labelText: 'குறிப்பு எண் / Transaction ID',
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
            labelText: 'குறிப்பு',
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
