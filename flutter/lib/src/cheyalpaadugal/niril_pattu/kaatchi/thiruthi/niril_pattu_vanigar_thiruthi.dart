import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';
import '../thiraigal/amaippugal/pattu_mugavari_tharavu.dart';

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
  const SilkMerchantEditor({super.key, this.vanigar});

  final VanigarEntry? vanigar;

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
    final primaryLang = ref.read(primaryLanguageProvider);
    final country = _naadu[primaryLang]?.trim() ?? '';
    if (country.isEmpty) return true; // Default: India
    // Check both en and ta
    final enName = _naadu['en']?.trim().toLowerCase() ?? '';
    final taName = _naadu['ta']?.trim() ?? '';
    return enName == 'india' || taName == 'இந்தியா' || enName.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    if (widget.vanigar != null) {
      final v = widget.vanigar!;
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
      _naadu = {'en': 'India', 'ta': 'இந்தியா'};
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

  bool get _isEditing => widget.vanigar != null;

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
          content: Text(K.vanigarPeyarThaevai.tr(context, ref)),
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

    final kalanjiyam = ref.read(vanigarKalanjiyamProvider);

    kalanjiyam.saveVanigar(
      id: _isEditing ? widget.vanigar!.id : null,
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

  // ── State Dropdown Helper ─────────────────────────────────────────────

  void _selectState(String primaryKey, String secondaryKey) {
    // Build the list: Indian states + "Custom" at the end
    final states = [
      ...silkIndianStates,
      {primaryKey: K.thanipPayanPtn.tr(context, ref), 'custom': 'true'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => _StatePickerSheet(
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
      builder: (ctx) => _StatePickerSheet(
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
          ? K.pattuVanigarThiruthi.tr(context, ref)
          : K.pudhiyaPattuVanigar.tr(context, ref),
      onSave: _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════════════════════
          // SECTION 1: Business Details
          // ══════════════════════════════════════════════════════════════════
          _SectionTitle(label: K.vanigarTharavugal.tr(context, ref)),
          const SizedBox(height: 16),

          ElvanIrumozhiPulan(
            label: K.vanigarPeyar.tr(context, ref),
            value: _peyar,
            autofocus: !_isEditing,
            onChanged: (map) => setState(() => _peyar = map),
          ),

          const SizedBox(height: 28),

          // ══════════════════════════════════════════════════════════════════
          // SECTION 2: Address
          // ══════════════════════════════════════════════════════════════════
          _SectionTitle(label: K.mugavari.tr(context, ref)),
          const SizedBox(height: 16),

          // Country picker (always shown)
          _DropdownField(
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
            _DropdownField(
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
          _SectionTitle(label: K.thodarpuVari.tr(context, ref)),
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

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Section title with subtle styling
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

/// A tappable dropdown-like field that shows current value + edit icon
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.primaryValue,
    this.secondaryValue,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final String primaryValue;
  final String? secondaryValue;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    primaryValue.isEmpty ? '—' : primaryValue,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryValue.isEmpty
                          ? (isDark ? Colors.white30 : Colors.black26)
                          : null,
                    ),
                  ),
                  if (secondaryValue != null && secondaryValue!.isNotEmpty)
                    Text(
                      secondaryValue!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet picker for states / countries
class _StatePickerSheet extends StatefulWidget {
  const _StatePickerSheet({
    required this.states,
    required this.primaryKey,
    required this.secondaryKey,
    required this.onSelected,
    required this.onCustom,
  });

  final List<Map<String, String>> states;
  final String primaryKey;
  final String secondaryKey;
  final void Function(String primary, String secondary) onSelected;
  final VoidCallback onCustom;

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  String _searchQuery = '';

  List<Map<String, String>> get _filtered {
    if (_searchQuery.isEmpty) return widget.states;
    final q = _searchQuery.toLowerCase();
    return widget.states.where((s) {
      if (s['custom'] == 'true') return true; // Always show custom
      return (s['en']?.toLowerCase().contains(q) ?? false) ||
          (s['ta']?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoSearchTextField(
              onChanged: (q) => setState(() => _searchQuery = q),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          // List
          Flexible(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                final isCustom = item['custom'] == 'true';

                if (isCustom) {
                  return ListTile(
                    leading: const Icon(CupertinoIcons.pencil, size: 18),
                    title: Text(item[widget.primaryKey] ?? ''),
                    onTap: widget.onCustom,
                  );
                }

                return ListTile(
                  title: Text(item[widget.primaryKey] ?? ''),
                  subtitle: widget.primaryKey != widget.secondaryKey
                      ? Text(
                          item[widget.secondaryKey] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        )
                      : null,
                  onTap: () => widget.onSelected(
                    item[widget.primaryKey] ?? '',
                    item[widget.secondaryKey] ?? '',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
