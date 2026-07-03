import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../../amaippugal/tharavu/pattu_niruvana_tharavugal_provider.dart';
import '../thiruthi/pattiyal/niril_pattu_pattiyal_thiruthi.dart';
import '../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../../adippadai/achadippu/achadippu_html_uruvakki.dart';
import '../../vadivangal/pattu_achadippu_html_uruvakki.dart';

Future<void> _handlePrint(dynamic pattiyal, dynamic profile, WidgetRef ref) async {
  bool isWindows = !kIsWeb && Platform.isWindows;
  
  // Fetch full client details from the database if vaangunarId exists
  VaangunarTharavuru? client;
  if (pattiyal.vaangunarId != null) {
    final kalanjiyam = ref.read(vaangunarKalanjiyamProvider);
    client = await kalanjiyam.getVaangunarById(pattiyal.vaangunarId!);
  }

  String html = await PattuAchadippuHtmlUruvakki.generatePattiyalHtml(
    pattiyal: pattiyal,
    profile: profile,
    client: client,
    isWindows: isWindows,
  );

  if (isWindows) {
    // Windows logic (handled via webview_windows, if integrated in this view later)
    // For now, we print a placeholder or trigger a known Windows print channel
    debugPrint('Windows print not fully hooked here yet.');
  } else {
    // Android native Kotlin PrintPreviewActivity
    try {
      const MethodChannel _printChannel = MethodChannel('com.elvan.niril/print');
      await _printChannel.invokeMethod('printHtml', {'html': html});
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke native print: \${e.message}");
    }
  }
}

/// பட்டு பட்டியல் பார்வை — Silk Invoice View Screen
///
/// Shows a PDF preview of the invoice.
/// The preview IS the final PDF — what you see is what gets exported.
class PattuPattiyalPaarvai extends ConsumerWidget {
  const PattuPattiyalPaarvai({
    super.key,
    required this.pattiyal,
  });

  final PattiyalTharavuru pattiyal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get profile data specific to this bill, or fallback to active if missing
    final profile = pattiyal.niruvanamId != null 
        ? ref.watch(pattuNiruvanaTharavugalByIdProvider(pattiyal.niruvanamId))
        : ref.watch(pattuNiruvanaTharavugalProvider);

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
              final profile = pattiyal.niruvanamId != null 
                  ? ref.read(pattuNiruvanaTharavugalByIdProvider(pattiyal.niruvanamId))
                  : ref.read(pattuNiruvanaTharavugalProvider);
              if (profile == null) return;
              // No PDF share implemented yet natively, placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing not implemented natively yet')),
              );
            },
          ),
          // Print / Download
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print',
            onPressed: () {
              if (profile != null) _handlePrint(pattiyal, profile, ref);
            },
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Profile not found'))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'பட்டியல் (Invoice) #${pattiyal.patrucheettuEn}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _handlePrint(pattiyal, profile, ref),
                    icon: const Icon(Icons.print),
                    label: const Text('அச்சு முன்னோட்டம் (Print Preview)'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
