import 'package:flutter/material.dart';

import 'kooli_thiruthi_udhavigal.dart';

/// §3.5 Extra Charges — setharam / ahimsa silk / courier fields in a
/// responsive bento grid layout.
class KooliMelthogaiKooru extends StatelessWidget {
  final TextEditingController setharamCtrl;
  final TextEditingController ahimsaCtrl;
  final TextEditingController thapaalCtrl;
  final ValueChanged<String> onSetharamChanged;
  final ValueChanged<String> onAhimsaChanged;
  final ValueChanged<String> onThapaalChanged;

  const KooliMelthogaiKooru({
    super.key,
    required this.setharamCtrl,
    required this.ahimsaCtrl,
    required this.thapaalCtrl,
    required this.onSetharamChanged,
    required this.onAhimsaChanged,
    required this.onThapaalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 600;
      final gap = 12.0;

      if (isDesktop) {
        final colWidth = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
                width: colWidth,
                child: kooliChargeField(
                    'Setharam (grams)', setharamCtrl, onSetharamChanged)),
            SizedBox(
                width: colWidth,
                child: kooliChargeField(
                    'Ahimsa Silk (₹)', ahimsaCtrl, onAhimsaChanged)),
            SizedBox(
                width: colWidth,
                child: kooliChargeField(
                    'Courier (₹)', thapaalCtrl, onThapaalChanged)),
          ],
        );
      }
      final halfWidth = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          SizedBox(
              width: constraints.maxWidth,
              child: kooliChargeField(
                  'Setharam (grams)', setharamCtrl, onSetharamChanged)),
          SizedBox(
              width: halfWidth,
              child: kooliChargeField(
                  'Ahimsa Silk (₹)', ahimsaCtrl, onAhimsaChanged)),
          SizedBox(
              width: halfWidth,
              child: kooliChargeField(
                  'Courier (₹)', thapaalCtrl, onThapaalChanged)),
        ],
      );
    });
  }
}
