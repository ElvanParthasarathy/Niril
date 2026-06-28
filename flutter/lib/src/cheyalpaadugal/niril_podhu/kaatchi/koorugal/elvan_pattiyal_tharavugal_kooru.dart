import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';
import 'pattiyal_naal_kooru.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டியல் தரவுகள் கூறு — Invoice Details Section (Number + Date)
// ─────────────────────────────────────────────────────────────────────────────

/// Section 2/3: Invoice number (editable) + Date picker, responsive layout.
/// Used commonly across Silk and Coolie editors.
List<Widget> buildElvanPattiyalTharavugalKooru({
  required BuildContext context,
  required WidgetRef ref,
  required bool isEditing,
  required String invoiceNumberOverride,
  required String previewInvoiceNumber,
  required bool isInvNumberEditing,
  required TextEditingController invNumberController,
  required String profilePrefix,
  required DateTime pattiyalNaal,
  required VoidCallback onToggleEditInvNumber,
  required ValueChanged<String> onInvNumberChanged,
  required ValueChanged<DateTime> onDateChanged,
  required VoidCallback onDirty,
  String? customNumberTitle,
  String? customDateTitle,
}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;

  final invoiceNumberField = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            customNumberTitle ?? K.pattiyalEn.tr(context, ref),
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
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                profilePrefix,
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
                inputFormatters: ElvanVadivamaippigal.enngalMattum,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '01',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        customDateTitle ?? K.naal.tr(context, ref),
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

  return [
    invoiceNumberField,
    dateField,
  ];
}
