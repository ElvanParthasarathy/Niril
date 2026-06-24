import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டியல் தரவுகள் கூறு — Invoice Details Section (Number + Date)
// ─────────────────────────────────────────────────────────────────────────────

/// Section 2: Invoice number (editable) + Date picker, responsive layout.
class PattuPattiyalTharavugalKooru extends ConsumerWidget {
  const PattuPattiyalTharavugalKooru({
    super.key,
    required this.isEditing,
    required this.invoiceNumberOverride,
    required this.previewInvoiceNumber,
    required this.isInvNumberEditing,
    required this.invNumberController,
    required this.profilePrefix,
    required this.pattiyalNaal,
    required this.onToggleEditInvNumber,
    required this.onInvNumberChanged,
    required this.onDateChanged,
    required this.onDirty,
  });

  final bool isEditing;
  final String invoiceNumberOverride;
  final String previewInvoiceNumber;
  final bool isInvNumberEditing;
  final TextEditingController invNumberController;
  final String profilePrefix;
  final DateTime pattiyalNaal;
  final VoidCallback onToggleEditInvNumber;
  final ValueChanged<String> onInvNumberChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onDirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 700;

      final invoiceNumberField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                K.pattiyalEn.tr(context, ref),
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...[
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onToggleEditInvNumber,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isInvNumberEditing ? Icons.check : Icons.edit_outlined,
                      size: 16,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (isInvNumberEditing)
            Row(
              children: [
                // Locked prefix pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$profilePrefix-',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Editable number part
                Expanded(
                  child: TextField(
                    controller: invNumberController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '01',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12)),
                        borderSide: BorderSide(
                          color: cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      onInvNumberChanged(v);
                      onDirty();
                    },
                  ),
                ),
              ],
            )
          else
            ElvanThiruthiAttai(
              child: Text(
                invoiceNumberOverride.isNotEmpty
                    ? invoiceNumberOverride
                    : previewInvoiceNumber.isNotEmpty
                        ? previewInvoiceNumber
                        : K.thaaniyangkiUruvaam.tr(context, ref),
                style: tt.bodyLarge?.copyWith(
                  color: invoiceNumberOverride.isNotEmpty
                      ? cs.onSurface
                      : cs.onSurfaceVariant,
                  fontWeight: invoiceNumberOverride.isNotEmpty
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
        ],
      );

      final dateField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            K.naal.tr(context, ref),
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          PattiyalNaalKooru(
            selectedDate: pattiyalNaal,
            onDateChanged: onDateChanged,
          ),
        ],
      );

      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: invoiceNumberField),
            const SizedBox(width: 24),
            Expanded(child: dateField),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          invoiceNumberField,
          const SizedBox(height: 16),
          dateField,
        ],
      );
    });
  }
}
