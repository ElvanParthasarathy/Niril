import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_ulleedu.dart';
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

  final invoiceNumberField = ElvanThiruthiUlleedu(
    label: customNumberTitle ?? K.pattiyalEn.tr(context, ref),
    controller: isInvNumberEditing ? invNumberController : null,
    initialValue: isInvNumberEditing
        ? null
        : (invoiceNumberOverride.isNotEmpty
            ? invoiceNumberOverride
            : previewInvoiceNumber.isNotEmpty
                ? previewInvoiceNumber
                : K.thaaniyangkiUruvaam.tr(context, ref)),
    readOnly: !isInvNumberEditing,
    keyboardType: TextInputType.number,
    inputFormatters: ElvanVadivamaippigal.enngalMattum,
    prefixText: isInvNumberEditing ? profilePrefix : null,
    hintText: isInvNumberEditing ? '01' : null,
    onChanged: (v) {
      if (isInvNumberEditing) {
        onInvNumberChanged(v);
        onDirty();
      }
    },
    suffixIcon: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onToggleEditInvNumber,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isInvNumberEditing ? Icons.check : Icons.edit_outlined,
          size: 20,
          color: isInvNumberEditing ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
    ),
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
