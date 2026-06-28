import 'package:flutter/material.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_marabu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// பட்டியல் வகை கூறு — Invoice Type dropdown (Tax Invoice / Proforma).
class PattuPattiyalVagaiKooru extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: DropdownButtonFormField<String>(
        initialValue: pattiyalVagai,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ElvanThiruthiMarabu.borderRadius),
              borderSide: BorderSide.none),
          contentPadding: ElvanThiruthiMarabu.contentPadding,
          constraints: ElvanThiruthiMarabu.singleLineConstraints,
        ),
        items: [
          DropdownMenuItem(
              value: 'tax-invoice', child: Text(K.varipPattiyal.tr(context, ref))),
          DropdownMenuItem(
              value: 'proforma', child: Text(K.munvaraivu.tr(context, ref))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
