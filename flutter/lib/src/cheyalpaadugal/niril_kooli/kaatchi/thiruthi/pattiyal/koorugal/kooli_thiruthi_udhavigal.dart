import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';

/// Extra-charge field wrapped in an ElvanThiruthiAttai (borderRadius 16).
Widget kooliChargeField(
    String label, TextEditingController ctrl, ValueChanged<String> onChanged) {
  return ElvanThiruthiAttai(
    borderRadius: 16,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: ElvanVadivamaippigal.thasamamEnngal,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
      onChanged: onChanged,
    ),
  );
}

/// Bank detail key-value row.
Widget kooliBankRow(BuildContext context, String label, dynamic value) {
  String text = '';
  if (value is Map) {
    text = (value['Tamil'] ?? value['English'] ?? '').toString();
  } else {
    text = value?.toString() ?? '';
  }
  if (text.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              )),
        ),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
  );
}

/// Pill-shaped text button (borderRadius 24).
Widget kooliPillButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  final cs = Theme.of(context).colorScheme;
  return TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: TextButton.styleFrom(
      backgroundColor: cs.surfaceContainerHighest,
      foregroundColor: cs.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
    ),
  );
}

/// Totals summary row (label | value).
Widget kooliTotalsRow(
  String label,
  String value, {
  FontWeight? labelWeight,
  FontWeight? valueWeight,
  Color? labelColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: labelWeight ?? FontWeight.w500,
              color: labelColor,
            )),
      ),
      const SizedBox(width: 12),
      Text(value,
          style: TextStyle(
            fontWeight: valueWeight ?? FontWeight.w600,
          )),
    ],
  );
}
