import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_paguthi.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_keezhvirivu.dart';
import '../../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';


class SilkItemEditor extends ConsumerStatefulWidget {
  const SilkItemEditor({super.key, this.product});

  /// If provided, we're editing an existing product.
  final PorulTharavuru? product;

  @override
  ConsumerState<SilkItemEditor> createState() => _SilkItemEditorState();
}

class _SilkItemEditorState extends ConsumerState<SilkItemEditor> {
  Map<String, String> _porulPeyar = {};
  String _alavuVagai = 'quantity';
  final _hsnController = TextEditingController(text: '50072010');
  final _vilaiController = TextEditingController();
  final _variController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.product != null) {
      final p = widget.product!;
      _porulPeyar = Map<String, String>.from(p.porulPeyar);
      _alavuVagai = p.alavuVagai;
      _hsnController.text = p.hsnCode;
      _vilaiController.text = p.vilai > 0 ? p.vilai.toStringAsFixed(0) : '';
      _variController.text = p.variVeetham.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _hsnController.dispose();
    _vilaiController.dispose();
    _variController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.product != null;

  void _handleSave() {
    final primaryLang = ref.read(primaryLanguageProvider);
    final primaryName = _porulPeyar[primaryLang]?.trim() ?? '';

    // Validation: primary name required
    if (primaryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(K.porulPeyarThaevai.tr(context, ref)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final kalanjiyam = ref.read(porulKalanjiyamProvider);
    final alagu = _alavuVagai == 'weight' ? 'kg' : 'Nos';

    kalanjiyam.savePorul(PorulTharavuru(
      id: _isEditing ? widget.product!.id : -1,
      porulPeyar: _porulPeyar,
      hsnCode: _hsnController.text.trim(),
      vilai: double.tryParse(_vilaiController.text) ?? 0.0,
      variVeetham: double.tryParse(_variController.text) ?? 0.0,
      alavuVagai: _alavuVagai,
      alagu: alagu,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: widget.product?.isDeleted ?? false,
    )).then((_) {
      if (mounted) {
        ref.invalidate(porulgalProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(K.porulChaemikkappattadhu.tr(context, ref)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryLang = ref.watch(primaryLanguageProvider);
    final peyarText = _porulPeyar[primaryLang]?.isNotEmpty == true
        ? _porulPeyar[primaryLang]!
        : '';

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
            title: K.porulTharavugal.tr(context, ref),
            displayChild: Text(peyarText),
            children: [

              // Bilingual product name
              ElvanIrumozhiPulan(
                label: K.porul.tr(context, ref),
                value: _porulPeyar,
                autofocus: !_isEditing,
                onChanged: (map) => setState(() => _porulPeyar = map),
              ),

              // Measurement Method Dropdown
              ElvanThiruthiKeezhvirivu(
                label: K.alaveeduMurai.tr(context, ref),
                value: _alavuVagai == 'weight' ? K.edai : K.alavu,
                items: const [K.alavu, K.edai],
                onChanged: (String newValue) {
                  setState(() {
                    _alavuVagai = newValue == K.edai ? 'weight' : 'quantity';
                  });
                },
              ),
            ],
          ),
          ElvanEditorSection(
            index: 1,
            title: K.vilaiMatrumVari.tr(context, ref),
            displayChild: Text(
              '₹ ${_vilaiController.text.isNotEmpty ? _vilaiController.text : '0'} / ${_variController.text}%',
            ),
            children: [
              // HSN Code
              _buildTextField(
                context: context,
                isDark: isDark,
                label: K.hsnSacKuriyeedu.tr(context, ref),
                controller: _hsnController,
                keyboardType: TextInputType.number,
                inputFormatters: ElvanVadivamaippigal.enngalMattum,
                maxLength: 8,
              ),
              const SizedBox(height: 12),

              // Rate + Tax in a row
              Row(
                children: [
                  // Selling Rate
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      isDark: isDark,
                      label: K.vilai.tr(context, ref),
                      controller: _vilaiController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixText: '₹ ',
                      inputFormatters: ElvanVadivamaippigal.thasamamEnngal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // GST %
                  SizedBox(
                    width: 120,
                    child: _buildTextField(
                      context: context,
                      isDark: isDark,
                      label: K.gstVeedham.tr(context, ref),
                      controller: _variController,
                      keyboardType: TextInputType.number,
                      suffixText: '%',
                      inputFormatters: ElvanVadivamaippigal.thasamamEnngal,
                      maxLength: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required bool isDark,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    String? errorText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            prefixText: prefixText,
            suffixText: suffixText,
            errorText: errorText,
            filled: true,
            fillColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.12);
              }
              return Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08);
            }),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

}

