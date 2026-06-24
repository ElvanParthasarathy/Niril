import 'package:flutter/material.dart';

/// பட்டியல் வகை கூறு — Invoice Type dropdown (Tax Invoice / Proforma).
class PattuPattiyalVagaiKooru extends StatelessWidget {
  const PattuPattiyalVagaiKooru({
    super.key,
    required this.pattiyalVagai,
    required this.onChanged,
  });

  /// Current invoice type — `'tax-invoice'` or `'proforma'`.
  final String pattiyalVagai;

  /// Fires when the user picks a different invoice type.
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: DropdownButtonFormField<String>(
        initialValue: pattiyalVagai,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
        ),
        items: const [
          DropdownMenuItem(
              value: 'tax-invoice', child: Text('Tax Invoice')),
          DropdownMenuItem(
              value: 'proforma', child: Text('Proforma')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
