import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import 'kooli_thiruthi_udhavigal.dart';

/// §3.5 Extra Charges — setharam / ahimsa silk / courier fields in a
/// responsive bento grid layout.
class KooliMelthogaiKooru extends ConsumerWidget {
  final TextEditingController setharamCtrl;
  final TextEditingController ahimsaCtrl;
  final TextEditingController thabaalCtrl;
  final ValueChanged<String> onSetharamChanged;
  final ValueChanged<String> onAhimsaChanged;
  final ValueChanged<String> onThabaalChanged;

  const KooliMelthogaiKooru({
    super.key,
    required this.setharamCtrl,
    required this.ahimsaCtrl,
    required this.thabaalCtrl,
    required this.onSetharamChanged,
    required this.onAhimsaChanged,
    required this.onThabaalChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    K.chaedhaaramGiraam.tr(context, ref), setharamCtrl, onSetharamChanged)),
            SizedBox(
                width: colWidth,
                child: kooliChargeField(
                    K.ahimsaiPattuThogai.tr(context, ref), ahimsaCtrl, onAhimsaChanged)),
            SizedBox(
                width: colWidth,
                child: kooliChargeField(
                    K.thabaalThogai.tr(context, ref), thabaalCtrl, onThabaalChanged)),
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
                  K.chaedhaaramGiraam.tr(context, ref), setharamCtrl, onSetharamChanged)),
          SizedBox(
              width: halfWidth,
              child: kooliChargeField(
                  K.ahimsaiPattuThogai.tr(context, ref), ahimsaCtrl, onAhimsaChanged)),
          SizedBox(
              width: halfWidth,
              child: kooliChargeField(
                  K.thabaalThogai.tr(context, ref), thabaalCtrl, onThabaalChanged)),
        ],
      );
    });
  }
}
