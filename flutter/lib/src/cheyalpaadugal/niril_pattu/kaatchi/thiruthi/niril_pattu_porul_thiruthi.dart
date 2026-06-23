import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';

class SilkItemEditor extends ConsumerStatefulWidget {
  const SilkItemEditor({super.key, this.product});

  /// If provided, we're editing an existing product.
  final PorulEntry? product;

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

    kalanjiyam.savePorul(
      id: _isEditing ? widget.product!.id : null,
      seyaliVagai: 'gst',
      porulPeyar: _porulPeyar,
      hsnCode: _hsnController.text.trim(),
      vilai: double.tryParse(_vilaiController.text) ?? 0.0,
      variVeetham: double.tryParse(_variController.text) ?? 0.0,
      alavuVagai: _alavuVagai,
      alagu: alagu,
    ).then((_) {
      if (mounted) {
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

    return ElvanEditorShell(
      title: _isEditing
          ? K.pattupPorulThiruthi.tr(context, ref)
          : K.pudhiyaPattupPorul.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Product Details ──
          Text(
            K.porulTharavugal.tr(context, ref),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // Bilingual product name
          ElvanIrumozhiPulan(
            label: K.porul.tr(context, ref),
            value: _porulPeyar,
            autofocus: !_isEditing,
            onChanged: (map) => setState(() => _porulPeyar = map),
          ),
          const SizedBox(height: 16),

          // Measure type toggle
          Text(
            K.alavuVagai.tr(context, ref),
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MeasureToggle(
                label: K.alavu.tr(context, ref),
                isSelected: _alavuVagai == 'quantity',
                onTap: () => setState(() => _alavuVagai = 'quantity'),
              ),
              const SizedBox(width: 8),
              _MeasureToggle(
                label: K.edai.tr(context, ref),
                isSelected: _alavuVagai == 'weight',
                onTap: () => setState(() => _alavuVagai = 'weight'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Section 2: Pricing & Tax ──
          Text(
            K.vilaiMatrumVari.tr(context, ref),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // HSN Code
          _buildTextField(
            context: context,
            isDark: isDark,
            label: K.hsnSacKuriyeedu.tr(context, ref),
            controller: _hsnController,
            keyboardType: TextInputType.number,
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
                ),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

/// A pill-shaped toggle button for measure type selection.
class _MeasureToggle extends StatelessWidget {
  const _MeasureToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? primary
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
