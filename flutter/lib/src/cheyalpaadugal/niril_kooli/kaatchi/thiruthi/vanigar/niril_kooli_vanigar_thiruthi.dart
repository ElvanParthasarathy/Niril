import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';

class CoolieMerchantEditor extends ConsumerStatefulWidget {
  const CoolieMerchantEditor({super.key, this.vanigar});

  /// If provided, we're editing an existing merchant.
  final VanigarEntry? vanigar;

  @override
  ConsumerState<CoolieMerchantEditor> createState() =>
      _CoolieMerchantEditorState();
}

class _CoolieMerchantEditorState extends ConsumerState<CoolieMerchantEditor> {
  Map<String, String> _peyar = {};
  Map<String, String> _oor = {};
  Map<String, String> _mugavari = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.vanigar != null) {
      _peyar = Map<String, String>.from(widget.vanigar!.peyar);
      _oor = Map<String, String>.from(widget.vanigar!.oor);
      _mugavari = Map<String, String>.from(widget.vanigar!.mugavari);
    }
  }

  bool get _isEditing => widget.vanigar != null;

  void _handleSave() {
    final primaryLang = ref.read(primaryLanguageProvider);
    final primaryName = _peyar[primaryLang]?.trim() ?? '';

    // Validation: primary name required
    if (primaryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(K.vanigarPeyarThaevai.tr(context, ref)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final kalanjiyam = ref.read(vanigarKalanjiyamProvider);

    kalanjiyam.saveVanigar(
      id: _isEditing ? widget.vanigar!.id : null,
      seyaliVagai: 'coolie',
      peyar: _peyar,
      oor: _oor,
      mugavari: _mugavari,
    ).then((_) {
      if (mounted) {
        ref.invalidate(vanigargalProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(K.vanigarChaemikkappattadhu.tr(context, ref)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section: Merchant Details ──
          Text(
            K.vanigarTharavugal.tr(context, ref),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // 1. Bilingual merchant name
          ElvanIrumozhiPulan(
            label: K.vanigarPeyar.tr(context, ref),
            value: _peyar,
            autofocus: !_isEditing,
            onChanged: (map) => setState(() => _peyar = map),
          ),

          const SizedBox(height: 20),

          // 2. Bilingual city
          ElvanIrumozhiPulan(
            label: K.oor.tr(context, ref),
            value: _oor,
            onChanged: (map) => setState(() => _oor = map),
          ),

          const SizedBox(height: 20),

          // 3. Bilingual address
          ElvanIrumozhiPulan(
            label: K.mugavari.tr(context, ref),
            value: _mugavari,
            onChanged: (map) => setState(() => _mugavari = map),
          ),
        ],
      ),
    );
  }
}
