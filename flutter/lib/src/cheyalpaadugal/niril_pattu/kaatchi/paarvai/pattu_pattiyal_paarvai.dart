import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../amaippugal/tharavu/pattu_niruvana_tharavugal_provider.dart';
import '../thiruthi/pattiyal/niril_pattu_pattiyal_thiruthi.dart';
import 'sjs_pdf_vadivu.dart';

/// பட்டு பட்டியல் பார்வை — Silk Invoice View Screen
///
/// Shows a pixel-perfect PDF preview of the invoice using the SjsTheme
/// template (rendered via the `printing` package's PdfPreview widget).
/// The preview IS the final PDF — what you see is what gets exported.
class PattuPattiyalPaarvai extends ConsumerWidget {
  const PattuPattiyalPaarvai({
    super.key,
    required this.pattiyal,
  });

  final PattiyalTharavuru pattiyal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get profile data
    final profile = ref.watch(pattuNiruvanaTharavugalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          '${K.pattiyal.tr(context, ref)} #${pattiyal.patrucheettuEn}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: K.maatru.tr(context, ref),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SilkInvoiceEditor(
                    editingEntry: pattiyal,
                  ),
                ),
              );
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () async {
              final profile = ref.read(pattuNiruvanaTharavugalProvider);
              if (profile == null) return;
              final pdfBytes = await sjsPdfVadivu(pattiyal, profile);
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'Invoice_${pattiyal.patrucheettuEn}.pdf',
              );
            },
          ),
          // Print / Download
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print',
            onPressed: () async {
              final profile = ref.read(pattuNiruvanaTharavugalProvider);
              if (profile == null) return;
              final pdfBytes = await sjsPdfVadivu(pattiyal, profile);
              await Printing.layoutPdf(
                onLayout: (_) => pdfBytes,
                name: 'Invoice_${pattiyal.patrucheettuEn}',
              );
            },
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Profile not found'))
          : PdfPreview(
              build: (format) => sjsPdfVadivu(pattiyal, profile),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: 'Invoice_${pattiyal.patrucheettuEn}.pdf',
              actions: const [], // We handle actions in the AppBar
              loadingWidget: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
    );
  }
}
