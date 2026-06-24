import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import 'kooli_thiruthi_udhavigal.dart';

/// §4 Bank Details — toggle switch + bank info rows from company profile.
class KooliVangiTharavugalKooru extends ConsumerWidget {
  final NiruvanaTharavugal profile;
  final bool showBankDetails;
  final ValueChanged<bool> onToggled;
  final bool showIfsc;
  final ValueChanged<bool> onIfscToggled;

  const KooliVangiTharavugalKooru({
    super.key,
    required this.profile,
    required this.showBankDetails,
    required this.onToggled,
    required this.showIfsc,
    required this.onIfscToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElvanThiruthiAttai(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            SwitchListTile(
              title: Text(K.vangiTharavuKaattu.tr(context, ref)),
              value: showBankDetails,
              onChanged: onToggled,
              contentPadding: EdgeInsets.zero,
            ),
            if (showBankDetails) ...[
              SwitchListTile(
                title: Text(K.ifscKaattu.tr(context, ref)),
                value: showIfsc,
                onChanged: onIfscToggled,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const Divider(),
              kooliBankRow(context, K.vangi.tr(context, ref), profile.vangiPeyar),
              kooliBankRow(context, K.kilai.tr(context, ref), profile.kilai),
              kooliBankRow(context, K.kanakkuKuriyeedu.tr(context, ref), profile.vangiKanakku),
              if (showIfsc) kooliBankRow(context, 'IFSC', profile.ifsc),
              if (profile.upiId.isNotEmpty)
                kooliBankRow(context, 'UPI', profile.upiId),
            ],
          ],
        ),
      ),
    );
  }
}
