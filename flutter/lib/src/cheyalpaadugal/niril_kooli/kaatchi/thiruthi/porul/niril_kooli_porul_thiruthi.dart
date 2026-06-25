import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';

class CoolieItemEditor extends ConsumerStatefulWidget {
  const CoolieItemEditor({super.key, this.product});

  /// If provided, we're editing an existing product.
  final PorulEntry? product;

  @override
  ConsumerState<CoolieItemEditor> createState() => _CoolieItemEditorState();
}

class _CoolieItemEditorState extends ConsumerState<CoolieItemEditor> {
  Map<String, String> _porulPeyar = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.product != null) {
      _porulPeyar = Map<String, String>.from(widget.product!.porulPeyar);
    }
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

    kalanjiyam.savePorul(
      id: _isEditing ? widget.product!.id : null,
      seyaliVagai: 'coolie',
      porulPeyar: _porulPeyar,
    ).then((_) {
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
    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section: Product Details ──
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
        ],
      ),
    );
  }
}
