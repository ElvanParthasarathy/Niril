import 'package:flutter/material.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../koorugal/elvan_kooli_irumozhi_pulan.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_paguthi.dart';
import '../../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';

class CoolieMerchantEditor extends ConsumerStatefulWidget {
  const CoolieMerchantEditor({super.key, this.vaangunar});

  /// If provided, we're editing an existing merchant.
  final VaangunarTharavuru? vaangunar;

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
    if (widget.vaangunar != null) {
      _peyar = Map<String, String>.from(widget.vaangunar!.peyar);
      _oor = Map<String, String>.from(widget.vaangunar!.oor);
      _mugavari = Map<String, String>.from(widget.vaangunar!.mugavari);
    }
  }

  bool get _isEditing => widget.vaangunar != null;

  void _handleSave() {
    final primaryLang = ref.read(primaryLanguageProvider);
    final primaryName = _peyar[primaryLang]?.trim() ?? '';

    // Validation: primary name required
    if (primaryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(K.vaangunarPeyarThaevai.tr(context, ref)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final kalanjiyam = ref.read(vaangunarKalanjiyamProvider);

    kalanjiyam.saveVaangunar(VaangunarTharavuru(
      id: _isEditing ? widget.vaangunar!.id : -1,
      peyar: _peyar,
      oor: _oor,
      mugavari: _mugavari,
      maavattam: {},
      maanilam: {},
      naadu: {},
      velinaadMugavari: {},
      anjalKuriyeedu: '',
      gstin: '',
      minnanjal: '',
      tholaipaesi: '',
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).then((_) {
      if (mounted) {
        ref.invalidate(vaangunargalProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(K.vaangunarChaemikkappattadhu.tr(context, ref)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryLang = ref.watch(primaryLanguageProvider);
    final peyarText = _peyar[primaryLang]?.trim().isNotEmpty == true ? _peyar[primaryLang]! : '-';

    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElvanEditorSection(
            index: 0,
            title: K.vaangunarTharavugal.tr(context, ref),
            displayChild: Text(peyarText),
            children: [
              // 1. Bilingual merchant name
              ElvanKooliIrumozhiPulan(
                label: K.vaangunarPeyar.tr(context, ref),
                value: _peyar,
                autofocus: !_isEditing,
                onChanged: (map) => setState(() => _peyar = map),
              ),

              const SizedBox(height: 20),

              // 2. Bilingual city
              ElvanKooliIrumozhiPulan(
                label: K.oor.tr(context, ref),
                value: _oor,
                onChanged: (map) => setState(() => _oor = map),
              ),

              const SizedBox(height: 20),

              // 3. Bilingual address
              ElvanKooliIrumozhiPulan(
                label: K.mugavari.tr(context, ref),
                value: _mugavari,
                onChanged: (map) => setState(() => _mugavari = map),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
