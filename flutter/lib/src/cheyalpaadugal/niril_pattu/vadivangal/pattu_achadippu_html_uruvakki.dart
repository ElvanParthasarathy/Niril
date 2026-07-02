import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../adippadai/achadippu/achadippu_html_uruvakki.dart';
import '../../../adippadai/tharavuru/uruvugal.dart';

import '../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../adippadai/oru_mozhi/oru_mozhi_vaangunar_udhavi.dart';

class PattuAchadippuHtmlUruvakki {
  static Future<String> generatePattiyalHtml({
    required PattiyalTharavuru pattiyal,
    required dynamic profile,
    VaangunarTharavuru? client,
    required bool isWindows,
  }) async {
    // 1. Read templates from assets/templates/silk folder
    final templateHtml = await rootBundle.loadString('assets/templates/silk/invoice.html');
    final invoiceCss = await rootBundle.loadString('assets/templates/silk/invoice.css');
    final printCss = await rootBundle.loadString('assets/templates/silk/print.css');

    // Make sure basic fonts from universal generator are ready if Windows
    if (isWindows) {
      await AchadippuHtmlUruvakki.initFonts();
    }

    String html = templateHtml;

    // Inject CSS inline to avoid asset path resolution in WebView
    html = html.replaceFirst('<link rel="stylesheet" href="invoice.css">', '<style>\n$invoiceCss\n</style>');
    html = html.replaceFirst('<link rel="stylesheet" href="print.css">', '<style>\n$printCss\n</style>');

    // Format Date
    final df = DateFormat('dd/MM/yyyy');
    final dateStr = df.format(pattiyal.pattiyalNaal);

    // Profile Details
    final companyName = profile.niruvanathinPeyar != null 
        ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(profile.niruvanathinPeyar.cast<String, dynamic>(), 'ta')
        : 'Elvan Niril';
    final companyNameSec = profile.niruvanathinPeyar != null 
        ? (profile.niruvanathinPeyar['en'] ?? '')
        : '';
    final address1 = profile.mugavari != null 
        ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(profile.mugavari.cast<String, dynamic>(), 'ta')
        : '';
    final address2 = profile.oor != null 
        ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(profile.oor.cast<String, dynamic>(), 'ta')
        : '';
    final phone = profile.tholaipaesi1 ?? '';
    final email = profile.minnanjal ?? '';
    final gstin = profile.gstin ?? '';

    // Customer Details
    final clientName = OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(
      pattiyal.vaangunarPeyar.cast<String, dynamic>(), 'ta',
    );
    final clientAddress = OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(
      pattiyal.vaangunarMunvari.cast<String, dynamic>(), 'ta',
    );

    // Build Items HTML
    String itemRows = '';
    int index = 1;
    double subTotal = 0;
    double totalCgst = 0;
    double totalSgst = 0;
    int totalQty = 0;
    String commonHSN = '';

    final items = PattiyalUthavigal.pattuListFromJson(pattiyal.tharavugal);
    for (final item in items) {
      final amount = item.alavu * item.vilai;
      
      final cgstRate = item.variVizhukkaadu / 2;
      final sgstRate = item.variVizhukkaadu / 2;
      final cgstAmt = amount * (cgstRate / 100);
      final sgstAmt = amount * (sgstRate / 100);
      final rowTotal = amount + cgstAmt + sgstAmt;

      subTotal += amount;
      totalCgst += cgstAmt;
      totalSgst += sgstAmt;
      totalQty += item.alavu.toInt();

      if (commonHSN.isEmpty && item.hsnKuriyeedu.isNotEmpty) {
        commonHSN = item.hsnKuriyeedu;
      }
      
      itemRows += '''
          <tr>
            <td class="inv-td inv-td-muted">\$index</td>
            <td class="inv-td">
              <div class="item-name">\${item.porulPeyar}</div>
              \${item.porulPeyarEn.isNotEmpty ? '<div class="item-name-sec">\${item.porulPeyarEn}</div>' : ''}
            </td>
            <td class="inv-td inv-td-center inv-td-muted">\${item.hsnKuriyeedu}</td>
            <td class="inv-td inv-td-center">\${item.alavu.toInt()}</td>
            <td class="inv-td inv-td-right">₹ \${item.vilai.toStringAsFixed(2)}</td>
            <td class="inv-td inv-td-center">\${cgstRate.toStringAsFixed(1)}%</td>
            <td class="inv-td inv-td-right">₹ \${cgstAmt.toStringAsFixed(2)}</td>
            <td class="inv-td inv-td-center">\${sgstRate.toStringAsFixed(1)}%</td>
            <td class="inv-td inv-td-right">₹ \${sgstAmt.toStringAsFixed(2)}</td>
            <td class="inv-td inv-td-right">₹ \${rowTotal.toStringAsFixed(2)}</td>
          </tr>
      ''';
      index++;
    }

    final grandTotal = subTotal + totalCgst + totalSgst - pattiyal.thallupadi;
    
    // Convert to words (Assuming AchadippuHtmlUruvakki has a words function, if not leave blank or implement later)
    final wordsEn = '₹ \${grandTotal.toStringAsFixed(2)} Only'; 
    final wordsTa = '';

    // String Replacements
    final Map<String, String> data = {
      'businessNamePrimary': companyName,
      'businessNameSecondary': companyNameSec,
      'businessNameForSignature': companyName,
      'businessGstin': gstin,
      'invoiceNumber': pattiyal.patrucheettuEn,
      'invoiceDate': dateStr,
      
      'clientName': client != null 
          ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.peyar.cast<String, dynamic>(), 'ta')
          : clientName,
      'clientAddress1': client != null
          ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.mugavari.cast<String, dynamic>(), 'ta')
          : clientAddress,
      'clientAddress2': client != null
          ? [
              OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.oor.cast<String, dynamic>(), 'ta'),
              OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.maavattam.cast<String, dynamic>(), 'ta'),
              OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.maanilam.cast<String, dynamic>(), 'ta'),
              client.anjalKuriyeedu
            ].where((e) => e.isNotEmpty).join(', ')
          : '',
      'clientGstin': client?.gstin ?? '', 
      'clientPhone': client?.tholaipaesi ?? '',
      
      'posPrimary': client != null 
          ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(client.maanilam.cast<String, dynamic>(), 'ta')
          : 'தமிழ்நாடு',
      'posSecondary': 'Tamil Nadu',
      
      'itemRows': itemRows,
      'totalItemsQty': totalQty.toString(),
      'commonHSN': commonHSN,
      
      'amountInWordsPrimary': wordsTa,
      'amountInWordsSecondary': wordsEn,
      
      'subTotal': '₹ \${subTotal.toStringAsFixed(2)}',
      'totalCgst': '₹ \${totalCgst.toStringAsFixed(2)}',
      'totalSgst': '₹ \${totalSgst.toStringAsFixed(2)}',
      'grandTotal': '₹ \${grandTotal.toStringAsFixed(2)}',
      
      'bankName': profile.vangiPeyar != null ? OruMozhiVaangunarUdhavi.mudhanmaiPeyarFromMap(profile.vangiPeyar.cast<String, dynamic>(), 'ta') : '',
      'accountNumber': profile.vangiKanakku ?? '',
      'ifscCode': profile.ifsc ?? '',
      
      'businessAddress1': address1,
      'businessAddress2': address2,
      'businessPhone': phone,
      'businessEmail': email,
    };

    data.forEach((key, value) {
      html = html.replaceAll('{{\$key}}', value);
    });

    // Remove any remaining unused placeholders
    html = html.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');

    return html;
  }
}
