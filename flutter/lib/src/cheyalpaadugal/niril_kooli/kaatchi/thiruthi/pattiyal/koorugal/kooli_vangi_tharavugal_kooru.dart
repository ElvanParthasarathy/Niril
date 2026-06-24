import 'package:flutter/material.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import 'kooli_thiruthi_udhavigal.dart';

/// §4 Bank Details — toggle switch + bank info rows from company profile.
class KooliVangiTharavugalKooru extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ElvanThiruthiAttai(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Show Bank Details'),
            value: showBankDetails,
            onChanged: onToggled,
            contentPadding: EdgeInsets.zero,
          ),
          if (showBankDetails) ...[
            SwitchListTile(
              title: const Text('Show IFSC'),
              value: showIfsc,
              onChanged: onIfscToggled,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const Divider(),
            kooliBankRow(context, 'Bank', profile.vangiPeyar),
            kooliBankRow(context, 'Branch', profile.kilai),
            kooliBankRow(context, 'A/C No', profile.vangiKanakku),
            if (showIfsc) kooliBankRow(context, 'IFSC', profile.ifsc),
            if (profile.upiId.isNotEmpty)
              kooliBankRow(context, 'UPI', profile.upiId),
          ],
        ],
      ),
    );
  }
}
