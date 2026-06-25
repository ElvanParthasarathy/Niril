import 'package:flutter/material.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../../thiraigal/amaippugal/pattu_mugavari_tharavu.dart';
import 'koorugal/vaangunar_thiruthi_koorugal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SILK / GST MERCHANT EDITOR
// ─────────────────────────────────────────────────────────────────────────────
// 3 sections:
//   ① Business Details   — Bilingual name (required)
//   ② Address            — India: full fields + state dropdown
//                          Other: multiline bilingual address
//   ③ Contact & Tax      — GSTIN (validated), email, phone
// ─────────────────────────────────────────────────────────────────────────────

class SilkMerchantEditor extends ConsumerStatefulWidget {
  const SilkMerchantEditor({super.key, this.vaangunar});

  final VaangunarTharavuru? vaangunar;

  @override
  ConsumerState<SilkMerchantEditor> createState() =>
      _SilkMerchantEditorState();
}

class _SilkMerchantEditorState extends ConsumerState<SilkMerchantEditor> {
  // ── Bilingual fields ──
  Map<String, String> _peyar = {};
  Map<String, String> _mugavari = {};
  Map<String, String> _oor = {};
  Map<String, String> _maavattam = {};
  Map<String, String> _maanilam = {};
  Map<String, String> _naadu = {};
  Map<String, String> _velinaadMugavari = {};

  // ── Single-value fields ──
  final _anjalKuriyeeduController = TextEditingController();
  final _gstinController = TextEditingController();
  final _minnanjalController = TextEditingController();
  final _tholaipaesiController = TextEditingController();

  String? _gstinError;

  bool get _isIndia {
    if (_naadu.isEmpty) return true; // Default: India
    // Check both key systems ('en'/'ta' from picker, 'Tamil'/'English' from DB)
    final enName = (_naadu['en'] ?? _naadu['English'] ?? '').trim().toLowerCase();
    final taName = (_naadu['ta'] ?? _naadu['Tamil'] ?? '').trim();
    return enName == 'india' || taName == K.india.tr(context, ref) || enName.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    if (widget.vaangunar != null) {
      final v = widget.vaangunar!;
      _peyar = Map<String, String>.from(v.peyar);
      _mugavari = Map<String, String>.from(v.mugavari);
      _oor = Map<String, String>.from(v.oor);
      _maavattam = Map<String, String>.from(v.maavattam);
      _maanilam = Map<String, String>.from(v.maanilam);
      _naadu = Map<String, String>.from(v.naadu);
      _velinaadMugavari = Map<String, String>.from(v.velinaadMugavari);
      _anjalKuriyeeduController.text = v.anjalKuriyeedu;
      _gstinController.text = v.gstin;
      _minnanjalController.text = v.minnanjal;
      _tholaipaesiController.text = v.tholaipaesi;
    } else {
      // Default country: India (bilingual)
      _naadu = {'en': 'India', 'ta': K.india.tr(context, ref)};
    }
  }

  @override
  void dispose() {
    _anjalKuriyeeduController.dispose();
    _gstinController.dispose();
    _minnanjalController.dispose();
    _tholaipaesiController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.vaangunar != null;

  // ── GSTIN Validation ──────────────────────────────────────────────────

  bool _validateGstin(String gstin) {
    if (gstin.isEmpty) return true; // Optional field
    // GSTIN format: 2 digits state code + 10 char PAN + 1 entity + 1 'Z' + 1 check
    final regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    return regex.hasMatch(gstin.toUpperCase());
  }

  // ── Save ───────────────────────────────────────────────────────────────

  void _handleSave() {
    final primaryLang = ref.read(primaryLanguageProvider);
    final primaryName = _peyar[primaryLang]?.trim() ?? '';

    if (primaryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(K.vaangunarPeyarThaevai.tr(context, ref)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate GSTIN if provided
    final gstin = _gstinController.text.trim();
    if (gstin.isNotEmpty && !_validateGstin(gstin)) {
      setState(() => _gstinError = K.gstinTavaru.tr(context, ref));
      return;
    }

    final kalanjiyam = ref.read(vaangunarKalanjiyamProvider);

    kalanjiyam.saveVaangunar(
      id: _isEditing ? widget.vaangunar!.id : null,
      seyaliVagai: 'silk',
      peyar: _peyar,
      mugavari: _mugavari,
      oor: _oor,
      maavattam: _maavattam,
      maanilam: _maanilam,
      naadu: _naadu,
      velinaadMugavari: _velinaadMugavari,
      anjalKuriyeedu: _anjalKuriyeeduController.text.trim(),
      gstin: gstin.toUpperCase(),
      minnanjal: _minnanjalController.text.trim(),
      tholaipaesi: _tholaipaesiController.text.trim(),
    ).then((_) {
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

  // ── State Dropdown Helper ─────────────────────────────────────────────

  void _selectState(String primaryKey, String secondaryKey) {
    // Build the list: Indian states + "Custom" at the end
    final states = [
      ...silkIndianStates,
      {primaryKey: K.thanipPayanPtn.tr(context, ref), 'custom': 'true'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => NilaiyamThaeraviPattai(
        states: states,
        primaryKey: primaryKey,
        secondaryKey: secondaryKey,
        onSelected: (primary, secondary) {
          setState(() {
            _maanilam = {
              if (primary.isNotEmpty) primaryKey: primary,
              if (secondary.isNotEmpty) secondaryKey: secondary,
            };
          });
          Navigator.pop(ctx);
        },
        onCustom: () {
          Navigator.pop(ctx);
          // Allow free-form typing
          setState(() {
            _maanilam = {};
          });
        },
      ),
    );
  }

  // ── Country Dropdown Helper ───────────────────────────────────────────

  void _selectCountry(String primaryKey, String secondaryKey) {
    final countries = [
      ...silkCountries,
      {primaryKey: K.thanipPayanPtn.tr(context, ref), 'custom': 'true'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => NilaiyamThaeraviPattai(
        states: countries,
        primaryKey: primaryKey,
        secondaryKey: secondaryKey,
        onSelected: (primary, secondary) {
          setState(() {
            _naadu = {
              if (primary.isNotEmpty) primaryKey: primary,
              if (secondary.isNotEmpty) secondaryKey: secondary,
            };
            // Clear India-specific fields when switching to non-India
            if (!_isIndia) {
              _maanilam = {};
              _maavattam = {};
              _oor = {};
              _mugavari = {};
              _anjalKuriyeeduController.clear();
            }
          });
          Navigator.pop(ctx);
        },
        onCustom: () {
          Navigator.pop(ctx);
          setState(() => _naadu = {});
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();
    final primaryKey = primaryLang == 'aangilam' ? 'en' : 'ta';
    final secondaryKey = secondaryLang == 'aangilam' ? 'en' : 'ta';
    final isBilingual = ref.watch(bilingualProvider);

    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════════════════════
          // SECTION 1: Business Details
          // ══════════════════════════════════════════════════════════════════
          VaangunarThiruthiPaguthiThalaipu(label: K.vaangunarTharavugal.tr(context, ref)),
          const SizedBox(height: 16),

          ElvanIrumozhiPulan(
            label: K.vaangunarPeyar.tr(context, ref),
            value: _peyar,
            autofocus: !_isEditing,
            onChanged: (map) => setState(() => _peyar = map),
          ),

          const SizedBox(height: 28),

          // ══════════════════════════════════════════════════════════════════
          // SECTION 2: Address
          // ══════════════════════════════════════════════════════════════════
          VaangunarThiruthiPaguthiThalaipu(label: K.mugavari.tr(context, ref)),
          const SizedBox(height: 16),

          // Country picker (always shown)
          VaangunarIzhivaruPulan(
            label: K.naadu.tr(context, ref),
            primaryValue: _naadu[primaryKey] ?? '',
            secondaryValue: isBilingual ? (_naadu[secondaryKey] ?? '') : null,
            isDark: isDark,
            onTap: () => _selectCountry(primaryKey, secondaryKey),
          ),
          const SizedBox(height: 16),

          if (_isIndia) ...[
            // ── India address fields ──
            ElvanIrumozhiPulan(
              label: K.mugavari.tr(context, ref),
              value: _mugavari,
              onChanged: (map) => setState(() => _mugavari = map),
            ),
            const SizedBox(height: 16),

            ElvanIrumozhiPulan(
              label: K.oor.tr(context, ref),
              value: _oor,
              onChanged: (map) => setState(() => _oor = map),
            ),
            const SizedBox(height: 16),

            ElvanIrumozhiPulan(
              label: K.maavattam.tr(context, ref),
              value: _maavattam,
              onChanged: (map) => setState(() => _maavattam = map),
            ),
            const SizedBox(height: 16),

            // State dropdown (India only)
            VaangunarIzhivaruPulan(
              label: K.maanilam.tr(context, ref),
              primaryValue: _maanilam[primaryKey] ?? '',
              secondaryValue:
                  isBilingual ? (_maanilam[secondaryKey] ?? '') : null,
              isDark: isDark,
              onTap: () => _selectState(primaryKey, secondaryKey),
            ),

            // If custom was selected (empty map), show text inputs
            if (_maanilam.isEmpty) ...[
              const SizedBox(height: 16),
              ElvanIrumozhiPulan(
                label: K.maanilam.tr(context, ref),
                value: _maanilam,
                onChanged: (map) => setState(() => _maanilam = map),
              ),
            ],

            const SizedBox(height: 16),

            // PIN Code (number)
            _buildTextField(
              context: context,
              isDark: isDark,
              label: K.anjalKuriyeedu.tr(context, ref),
              controller: _anjalKuriyeeduController,
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            // ── Non-India: single multiline bilingual address ──
            ElvanIrumozhiPulan(
              label: K.velinaadMugavari.tr(context, ref),
              value: _velinaadMugavari,
              onChanged: (map) => setState(() => _velinaadMugavari = map),
            ),
          ],

          const SizedBox(height: 28),

          // ══════════════════════════════════════════════════════════════════
          // SECTION 3: Contact & Tax
          // ══════════════════════════════════════════════════════════════════
          VaangunarThiruthiPaguthiThalaipu(label: K.thodarpuVari.tr(context, ref)),
          const SizedBox(height: 16),

          // GSTIN
          _buildTextField(
            context: context,
            isDark: isDark,
            label: 'GSTIN',
            controller: _gstinController,
            textCapitalization: TextCapitalization.characters,
            errorText: _gstinError,
            onChanged: (_) {
              if (_gstinError != null) setState(() => _gstinError = null);
            },
          ),
          const SizedBox(height: 16),

          // Email
          _buildTextField(
            context: context,
            isDark: isDark,
            label: K.minnanjal.tr(context, ref),
            controller: _minnanjalController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildTextField(
            context: context,
            isDark: isDark,
            label: K.tholaipaesi.tr(context, ref),
            controller: _tholaipaesiController,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ── Text Field Builder (matches SilkItemEditor style) ─────────────────

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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
        errorText: errorText,
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
