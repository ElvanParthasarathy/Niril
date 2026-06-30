// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../../adippadai/pdf/pdf_ezhuthuru.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

/// SJS PDF Template — Pixel-perfect replica of React SjsTheme.tsx
///
/// Generates a true-vector A4 PDF document using pw.Widget primitives,
/// matching every color, font size, and spacing from the React version.
///
/// Usage:
/// ```dart
/// final pdfBytes = await sjsPdfVadivu(pattiyal, profile);
/// ```
Future<Uint8List> sjsPdfVadivu(
  PattiyalTharavuru pattiyal,
  NiruvanaTharavugal profile,
) async {
  // ── Ensure fonts are loaded ──
  await PdfEzhuthuru.load();

  // ── Parse items ──
  final items = PattiyalUthavigal.pattuListFromJson(pattiyal.tharavugal);

  // ── Derive accent color ──
  final accentHex = profile.thoatraNiram.isNotEmpty
      ? profile.thoatraNiram
      : '#388e3c';
  final accent = _hexColor(accentHex);
  final accentBg10 = _hexColor(accentHex, opacity: 0.10);
  final accentBg08 = _hexColor(accentHex, opacity: 0.08);

  // ── Language settings ──
  final primaryLang = profile.mudhanMozhi.isNotEmpty ? profile.mudhanMozhi : 'Tamil';
  final isBilingual = profile.iruMozhi;
  final isTamilPrimary = primaryLang == 'Tamil';

  // ── Currency formatter ──
  final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // ── Profile data helpers ──
  String mozhiVal(Map<String, dynamic> m, {bool primary = true}) {
    if (primary) {
      return (m[primaryLang]?.toString() ?? '').isNotEmpty
          ? m[primaryLang].toString()
          : (m.values.firstOrNull?.toString() ?? '');
    }
    final secondary = isTamilPrimary ? 'English' : 'Tamil';
    return m[secondary]?.toString() ?? '';
  }

  // ── Invoice details ──
  final billNo = pattiyal.patrucheettuEn;
  final dateStr = DateFormat('dd/MM/yyyy').format(pattiyal.pattiyalNaal);
  final clientName = mozhiVal(pattiyal.vaangunarPeyar);

  // ── Compute totals ──
  double subtotal = 0;
  double totalDiscount = 0;
  double totalTax = 0;
  for (final item in items) {
    final lineAmount = item.adippadaiThogai;
    final disc = item.thallupadiThogai;
    final afterDisc = lineAmount - disc;
    final tax = afterDisc * (item.variVizhukkaadu / 100);
    subtotal += afterDisc;
    totalDiscount += disc;
    totalTax += tax;
  }
  final grandTotal = pattiyal.mothaThogai;

  // ── Font shortcuts ──
  pw.TextStyle ts(double size, {int weight = 400, PdfColor? color, double? spacing}) {
    return pw.TextStyle(
      font: PdfEzhuthuru.fontForWeight(weight),
      fontBold: PdfEzhuthuru.bold,
      fontSize: size,
      color: color ?? PdfColors.black,
      letterSpacing: spacing,
    );
  }

  // ── Build the PDF document ──
  final pdf = pw.Document(
    title: 'Invoice #$billNo',
    author: mozhiVal(profile.niruvanathinPeyar),
  );

  // ── Color constants from React ──
  const slate400 = PdfColor.fromInt(0xFF94a3b8);
  const slate500 = PdfColor.fromInt(0xFF64748b);
  const slate600 = PdfColor.fromInt(0xFF475569);
  const slate700 = PdfColor.fromInt(0xFF334155);
  const slate900 = PdfColor.fromInt(0xFF0f172a);
  const border200 = PdfColor.fromInt(0xFFe2e8f0);

  // ── Render label (bilingual) ──
  String renderLabel(String en, String ta) {
    if (!isBilingual) return isTamilPrimary ? ta : en;
    return isTamilPrimary ? '$ta / $en' : '$en / $ta';
  }

  // ── Page content builder ──
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 20),
      build: (context) => [
        // ════════════════════════════════════════════════════════════════
        // 1. GREETING ROW  —  வாழ்க வையகம் • உ • வாழ்க வளமுடன்
        // ════════════════════════════════════════════════════════════════
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                isTamilPrimary ? 'வாழ்க வையகம்' : 'Vaazhga Vaiyagam',
                style: ts(9.5, weight: 700, color: accent, spacing: 0.5),
              ),
              pw.Text('உ', style: ts(9.5, weight: 700, color: accent, spacing: 0.5)),
              pw.Text(
                isTamilPrimary ? 'வாழ்க வளமுடன்' : 'Vaazhga Valamudan',
                style: ts(9.5, weight: 700, color: accent, spacing: 0.5),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),

        // ════════════════════════════════════════════════════════════════
        // 2. HEADER ROW  —  Company Name (left) + Invoice Type (right)
        // ════════════════════════════════════════════════════════════════
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Container(
            height: 55,
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Company name (skip logo for now)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      mozhiVal(profile.niruvanathinPeyar).isNotEmpty
                          ? mozhiVal(profile.niruvanathinPeyar)
                          : 'Your Business',
                      style: ts(16, weight: 700, color: accent),
                    ),
                    if (isBilingual &&
                        mozhiVal(profile.niruvanathinPeyar, primary: false).isNotEmpty)
                      pw.Text(
                        mozhiVal(profile.niruvanathinPeyar, primary: false),
                        style: ts(12, weight: 500, color: slate600),
                      ),
                  ],
                ),
                // Right: Invoice type title + GSTIN
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      _invoiceTypeTitle(pattiyal.pattiyalVagai, isTamilPrimary),
                      style: ts(12, weight: 700, color: accent),
                    ),
                    if (profile.gstin.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 2),
                        child: pw.Text(
                          'GSTIN: ${profile.gstin}',
                          style: ts(8.5, weight: 400, color: slate600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ════════════════════════════════════════════════════════════════
        // 3. BILL NO / DATE BAR  —  Accent-tinted rounded bar
        // ════════════════════════════════════════════════════════════════
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: accentBg10,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${renderLabel('Bill No', 'பில் எண்')} : ',
                        style: ts(10, weight: 600, color: accent),
                      ),
                      pw.TextSpan(
                        text: billNo,
                        style: ts(10, weight: 700, color: PdfColors.black),
                      ),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${renderLabel('Date', 'நாள்')} : ',
                        style: ts(10, weight: 600, color: accent),
                      ),
                      pw.TextSpan(
                        text: dateStr,
                        style: ts(10, weight: 700, color: PdfColors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ════════════════════════════════════════════════════════════════
        // 4. PARTIES SECTION  —  Bill To (left) + Place of Supply (right)
        // ════════════════════════════════════════════════════════════════
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Bill To
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      renderLabel('Bill To', 'பெறுநர்'),
                      style: ts(7.5, weight: 700, color: slate400),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      clientName.isNotEmpty ? clientName : 'Client Name',
                      style: ts(12, weight: 700, color: slate900),
                    ),
                    if (_clientAddress(pattiyal).isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _clientAddress(pattiyal),
                        style: ts(9, weight: 400, color: slate500),
                      ),
                    ],
                  ],
                ),
              ),
              // Place of Supply placeholder
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    renderLabel('Place of Supply', 'வழங்கும் இடம்'),
                    style: ts(7.5, weight: 700, color: slate400),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    mozhiVal(profile.maanilam).isNotEmpty
                        ? mozhiVal(profile.maanilam)
                        : '-',
                    style: ts(12, weight: 700, color: slate900),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),

        // ════════════════════════════════════════════════════════════════
        // 5. ITEMS TABLE  —  Unified bordered box
        // ════════════════════════════════════════════════════════════════
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: border200, width: 0.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              // Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.symmetric(
                  inside: pw.BorderSide(color: _hexColor('#000000', opacity: 0.08), width: 0.5),
                ),
                headerDecoration: pw.BoxDecoration(color: accentBg10),
                headerStyle: ts(7.5, weight: 700, color: accent),
                headerAlignment: pw.Alignment.centerLeft,
                cellStyle: ts(8.5, weight: 400),
                cellAlignment: pw.Alignment.centerLeft,
                cellHeight: isBilingual ? 22 : 28,
                headerHeight: 24,
                headers: [
                  '#',
                  renderLabel('Product Name', 'பொருள் பெயர்'),
                  renderLabel('Qty', 'எண்'),
                  renderLabel('Rate', 'விலை'),
                  renderLabel('Amount', 'தொகை'),
                ],
                columnWidths: {
                  0: const pw.FixedColumnWidth(24),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FixedColumnWidth(48),
                  3: const pw.FixedColumnWidth(64),
                  4: const pw.FixedColumnWidth(72),
                },
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
                oddRowDecoration: pw.BoxDecoration(color: accentBg08),
                data: List.generate(items.length, (i) {
                  final item = items[i];
                  final name = item.mozhiMap[primaryLang]?.toString().isNotEmpty == true
                      ? item.mozhiMap[primaryLang].toString()
                      : (item.porulPeyar.isNotEmpty ? item.porulPeyar : '-');
                  return [
                    '${i + 1}',
                    name,
                    item.alavu.toStringAsFixed(item.alavu == item.alavu.roundToDouble() ? 0 : 1),
                    fmt.format(item.vilai),
                    fmt.format(item.adippadaiThogai - item.thallupadiThogai),
                  ];
                }),
              ),

              // ── Totals Section (inside the unified box) ──
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: border200, width: 0.5)),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left: Total Items + Amount in Words
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(color: border200, width: 0.5)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Total Items
                            pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  pw.TextSpan(
                                    text: isBilingual
                                        ? (isTamilPrimary
                                            ? 'மொத்த அளவு • Total Items: '
                                            : 'Total Items • மொத்த அளவு: ')
                                        : (isTamilPrimary ? 'மொத்த அளவு: ' : 'Total Items: '),
                                    style: ts(8, weight: 400, color: slate500),
                                  ),
                                  pw.TextSpan(
                                    text: '${items.fold<double>(0, (s, i) => s + i.alavu).toStringAsFixed(0)}',
                                    style: ts(8, weight: 600, color: slate700),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            // Amount in Words
                            pw.Text(
                              _numberToWords(grandTotal),
                              style: ts(8.5, weight: 600, color: slate900),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right: Totals column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Column(
                          children: [
                            _totalRow('Subtotal', 'உபமொத்தம்', fmt.format(subtotal),
                                isTamilPrimary, isBilingual, ts, slate500, slate900),
                            if (totalDiscount > 0)
                              _totalRow('Discount', 'தள்ளுபடி', '- ${fmt.format(totalDiscount)}',
                                  isTamilPrimary, isBilingual, ts, slate500, slate900),
                            if (totalTax > 0) ...[
                              _totalRow('CGST', 'CGST', fmt.format(totalTax / 2),
                                  isTamilPrimary, isBilingual, ts, slate500, slate900),
                              _totalRow('SGST', 'SGST', fmt.format(totalTax / 2),
                                  isTamilPrimary, isBilingual, ts, slate500, slate900),
                            ],
                            if (totalTax == 0 && pattiyal.variThogai > 0)
                              _totalRow('Tax', 'வரி', fmt.format(pattiyal.variThogai),
                                  isTamilPrimary, isBilingual, ts, slate500, slate900),
                            pw.SizedBox(height: 4),
                            // Grand Total
                            pw.Container(
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        isTamilPrimary ? 'மொத்தம்' : 'Grand Total',
                                        style: ts(10, weight: 700, color: accent),
                                      ),
                                      if (isBilingual)
                                        pw.Text(
                                          isTamilPrimary ? 'Grand Total' : 'மொத்தம்',
                                          style: ts(6.5, weight: 500, color: accent),
                                        ),
                                    ],
                                  ),
                                  pw.Text(
                                    fmt.format(grandTotal),
                                    style: ts(12, weight: 700, color: accent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),

        // ════════════════════════════════════════════════════════════════
        // 7. FOOTER  —  Bank Details + Signature + Nandri
        // ════════════════════════════════════════════════════════════════
        _buildFooter(profile, accent, isTamilPrimary, isBilingual, ts, mozhiVal, slate500, slate600, slate700, fmt),

        pw.SizedBox(height: 10),

        // ════════════════════════════════════════════════════════════════
        // 8. CONTACT BLOCK  —  Full-width accent-tinted bar
        // ════════════════════════════════════════════════════════════════
        _buildContactBlock(profile, accent, accentBg08, isTamilPrimary, ts, mozhiVal),
      ],
    ),
  );

  return pdf.save();
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

PdfColor _hexColor(String hex, {double opacity = 1.0}) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final intColor = int.parse(hex, radix: 16);
  final r = ((intColor >> 16) & 0xFF) / 255;
  final g = ((intColor >> 8) & 0xFF) / 255;
  final b = (intColor & 0xFF) / 255;
  return PdfColor(r, g, b, opacity);
}

String _invoiceTypeTitle(String vagai, bool isTamil) {
  switch (vagai) {
    case 'tax-invoice':
      return isTamil ? 'வரிப் பட்டியல்' : 'Tax Invoice';
    case 'proforma':
      return isTamil ? 'மதிப்பீடு' : 'Estimate';
    case 'credit-note':
      return 'Credit Note';
    case 'bill-of-supply':
      return 'Bill of Supply';
    default:
      return isTamil ? 'பட்டியல்' : 'Invoice';
  }
}

String _clientAddress(PattiyalTharavuru p) {
  final parts = <String>[];
  for (final entry in p.vaangunarMunvari.entries) {
    final val = entry.value?.toString() ?? '';
    if (val.isNotEmpty) {
      parts.add(val);
      break;
    }
  }
  return parts.join(', ');
}

pw.Widget _totalRow(
  String enLabel,
  String taLabel,
  String value,
  bool isTamil,
  bool isBilingual,
  pw.TextStyle Function(double, {int weight, PdfColor? color, double? spacing}) ts,
  PdfColor labelColor,
  PdfColor valueColor,
) {
  final label = isBilingual
      ? (isTamil ? taLabel : enLabel)
      : (isTamil ? taLabel : enLabel);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: ts(8.5, weight: 400, color: labelColor)),
        pw.Text(value, style: ts(8.5, weight: 500, color: valueColor)),
      ],
    ),
  );
}

pw.Widget _buildFooter(
  NiruvanaTharavugal profile,
  PdfColor accent,
  bool isTamil,
  bool isBilingual,
  pw.TextStyle Function(double, {int weight, PdfColor? color, double? spacing}) ts,
  String Function(Map<String, dynamic>, {bool primary}) mozhiVal,
  PdfColor slate500,
  PdfColor slate600,
  PdfColor slate700,
  NumberFormat fmt,
) {
  final bankName = mozhiVal(profile.vangiPeyar);
  final branch = mozhiVal(profile.kilai);
  final acctNo = profile.vangiKanakku;
  final ifsc = profile.ifsc;
  final hasBankDetails = bankName.isNotEmpty;

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Bank details
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (hasBankDetails) ...[
                _bankRow(isTamil ? 'வங்கி விவரம்' : 'Bank Details', '${bankName}${branch.isNotEmpty ? ', $branch' : ''}', accent, ts, slate700),
                _bankRow(isTamil ? 'கணக்கு எண்' : 'Account No', acctNo, accent, ts, slate700),
                if (ifsc.isNotEmpty)
                  _bankRow('IFSC', ifsc, accent, ts, slate700),
                if (profile.upiId.isNotEmpty)
                  _bankRow('UPI', profile.upiId, accent, ts, slate700),
              ],
            ],
          ),
        ),
        // Right: Signature placeholder
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                mozhiVal(profile.niruvanathinPeyar, primary: false).isNotEmpty
                    ? mozhiVal(profile.niruvanathinPeyar, primary: false)
                    : mozhiVal(profile.niruvanathinPeyar),
                style: ts(12, weight: 700, color: accent),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                profile.oppamPeyar.isNotEmpty
                    ? '(${profile.oppamPeyar})'
                    : (isTamil ? '(கையொப்பம்)' : '(Signature)'),
                style: ts(8.5, weight: 600, color: const PdfColor.fromInt(0xFF555555)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _bankRow(
  String label,
  String value,
  PdfColor accent,
  pw.TextStyle Function(double, {int weight, PdfColor? color, double? spacing}) ts,
  PdfColor valueColor,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$label : ', style: ts(9, weight: 700, color: accent)),
        pw.Expanded(
          child: pw.Text(value, style: ts(9, weight: 600, color: valueColor)),
        ),
      ],
    ),
  );
}

pw.Widget _buildContactBlock(
  NiruvanaTharavugal profile,
  PdfColor accent,
  PdfColor accentBg,
  bool isTamil,
  pw.TextStyle Function(double, {int weight, PdfColor? color, double? spacing}) ts,
  String Function(Map<String, dynamic>, {bool primary}) mozhiVal,
) {
  final addr = mozhiVal(profile.mugavari);
  final oor = mozhiVal(profile.oor);
  final addrLine = [addr, oor].where((s) => s.isNotEmpty).join(', ');
  final pin = profile.anjalKuriyeedu;
  final fullAddr = pin.isNotEmpty ? '$addrLine - $pin' : addrLine;

  final district = mozhiVal(profile.maavattam);
  final state = mozhiVal(profile.maanilam);
  final addr2 = [district, state].where((s) => s.isNotEmpty).join(', ');

  const textColor = PdfColor.fromInt(0xFF333333);

  return pw.Container(
    decoration: pw.BoxDecoration(
      color: accentBg,
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Address
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              isTamil ? 'தொடர்பு கொள்ள' : 'Contact Us',
              style: ts(10, weight: 700, color: accent),
            ),
            pw.SizedBox(height: 4),
            if (fullAddr.isNotEmpty)
              pw.Text(fullAddr, style: ts(9, weight: 500, color: textColor)),
            if (addr2.isNotEmpty)
              pw.Text(addr2, style: ts(9, weight: 500, color: textColor)),
          ],
        ),
        // Right: Phone + Email
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (profile.tholaipaesi1.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  profile.tholaipaesi1,
                  style: ts(9, weight: 600, color: const PdfColor.fromInt(0xFF444444)),
                ),
              ),
            if (profile.tholaipaesi2.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(
                  profile.tholaipaesi2,
                  style: ts(9, weight: 600, color: const PdfColor.fromInt(0xFF444444)),
                ),
              ),
            if (profile.minnanjal.isNotEmpty)
              pw.Text(
                profile.minnanjal,
                style: ts(9, weight: 400, color: const PdfColor.fromInt(0xFF444444)),
              ),
          ],
        ),
      ],
    ),
  );
}

/// Basic Indian number-to-words (for now, English only).
String _numberToWords(double amount) {
  final rounded = amount.round();
  if (rounded == 0) return 'Zero Rupees Only';

  final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
  final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

  String convert(int n) {
    if (n == 0) return '';
    if (n < 20) return '${ones[n]} ';
    if (n < 100) return '${tens[n ~/ 10]} ${n % 10 > 0 ? ones[n % 10] : ''} ';
    if (n < 1000) return '${ones[n ~/ 100]} Hundred ${convert(n % 100)}';
    if (n < 100000) return '${convert(n ~/ 1000)}Thousand ${convert(n % 1000)}';
    if (n < 10000000) return '${convert(n ~/ 100000)}Lakh ${convert(n % 100000)}';
    return '${convert(n ~/ 10000000)}Crore ${convert(n % 10000000)}';
  }

  final whole = rounded;
  final paise = ((amount - whole) * 100).round();
  String result = '${convert(whole).trim()} Rupees';
  if (paise > 0) result += ' and ${convert(paise).trim()} Paise';
  return '$result Only';
}
