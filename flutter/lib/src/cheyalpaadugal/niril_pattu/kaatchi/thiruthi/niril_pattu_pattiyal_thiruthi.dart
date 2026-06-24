import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';
import '../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';
import '../../../amaippugal/tharavu/vaniga_tharavugal_provider.dart';
import '../../../amaippugal/tharavu/vaniga_tharavugal.dart';
import '../thiraigal/amaippugal/pattu_mugavari_tharavu.dart';
import 'niril_pattu_vanigar_thiruthi.dart';
import 'niril_pattu_porul_thiruthi.dart';

/// Indian currency formatter: ₹1,23,456.00
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Silk (GST) Invoice Editor — full form with line items, tax calculation,
/// auto-numbering, and FK-based customer storage.
class SilkInvoiceEditor extends ConsumerStatefulWidget {
  final PatrucheettuEntry? editingEntry;
  final PatrucheettuEntry? duplicateFrom;

  const SilkInvoiceEditor({super.key, this.editingEntry, this.duplicateFrom});

  @override
  ConsumerState<SilkInvoiceEditor> createState() => _SilkInvoiceEditorState();
}

class _SilkInvoiceEditorState extends ConsumerState<SilkInvoiceEditor> {
  // ── Company Profile ──
  int? _selectedNiruvanamId;
  VanigaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVanigarId;
  String _selectedVanigarPeyar = '';
  String _customerState = '';

  // ── Metadata ──
  String _pattiyalVagai = 'tax-invoice';
  DateTime _pattiyalNaal = DateTime.now();
  String _placeOfSupply = '';
  String _placeOfSupplyTa = ''; // Tamil bilingual for Place of Supply
  String _invoiceNumberOverride = ''; // Manual override for inv number
  String _previewInvoiceNumber = ''; // Preview of next auto-generated number
  bool _isInvNumberEditing = false;

  // ── Line Items ──
  List<PattuUrupadi> _items = [const PattuUrupadi()];

  // ── Global Discount ──
  double _globalDiscountValue = 0;
  String _globalDiscountType = 'percentage';

  // ── Notes ──
  String _nibandhanaigal = '';
  String _ullkurippu = '';

  // ── Calculated Totals ──
  PattuMothangal _totals = const PattuMothangal();

  // ── Controllers ──
  final _termsController = TextEditingController();
  final _notesController = TextEditingController();
  final _globalDiscountController = TextEditingController();
  final _invNumberController = TextEditingController();
  bool _saving = false;

  // ── Unsaved Changes & Draft ──
  bool _hasUnsavedChanges = false;
  Timer? _draftDebounce;
  static const _draftKey = 'niril_draft_silk_invoice';

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEditingData();
    } else if (widget.duplicateFrom != null) {
      _loadDuplicateData();
    } else {
      // Check for saved draft
      _tryRestoreDraft();
    }
    // Auto-select profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing) {
        _autoSelectProfile();
      }
    });
  }

  void _autoSelectProfile() {
    final profiles = ref.read(vanigaTharavugalListProvider);
    if (profiles.isNotEmpty && _selectedNiruvanamId == null) {
      setState(() {
        _selectedProfile = profiles.first;
        _selectedNiruvanamId = profiles.first.id;
      });
    }
    // Compute preview invoice number for new invoices
    if (!_isEditing) {
      _computePreviewInvoiceNumber();
    }
  }

  /// Fetches next vanakkam from DB and formats a preview invoice number.
  Future<void> _computePreviewInvoiceNumber() async {
    if (_isEditing) return;
    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final finYear = PattiyalKalanjiyam.getCurrentFinYear();
      final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'INV';
      final vanakkam = await kalanjiyam.getNextVanakkam(
        'silk', _selectedNiruvanamId, finYear,
      );
      if (mounted) {
        setState(() {
          _previewInvoiceNumber = kalanjiyam.formatPattiyalEn(prefix, vanakkam);
        });
      }
    } catch (_) {}
  }

  void _loadEditingData() {
    final e = widget.editingEntry!;
    _selectedNiruvanamId = e.niruvanamId;
    _selectedVanigarId = e.vanigarId;
    _selectedVanigarPeyar = e.vanigarPeyar;
    _pattiyalVagai = e.pattiyalVagai;
    _pattiyalNaal = e.pattiyalNaal;
    _nibandhanaigal = e.nibandhanaigal;
    _ullkurippu = e.ullkurippu;

    _termsController.text = _nibandhanaigal;
    _notesController.text = _ullkurippu;

    // Load items from JSON
    _items = PattiyalUthavigal.pattuListFromJson(e.tharavugal);
    if (_items.isEmpty) _items = [const PattuUrupadi()];

    // Load settings JSON for global discount + place of supply
    try {
      final settings = jsonDecode(e.sonthaViruppangal) as Map<String, dynamic>;
      _globalDiscountValue = (settings['globalDiscountValue'] as num?)?.toDouble() ?? 0;
      _globalDiscountType = settings['globalDiscountType'] as String? ?? 'percentage';
      _globalDiscountController.text = _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
      _placeOfSupply = settings['placeOfSupply'] as String? ?? '';
      _placeOfSupplyTa = settings['placeOfSupplyTa'] as String? ?? '';
    } catch (_) {}

    // Pre-fill invoice number controller for editing
    _invoiceNumberOverride = e.patrucheettuEn;
    _invNumberController.text = e.patrucheettuEn;

    // Resolve Tamil for Place of Supply if missing
    if (_placeOfSupply.isNotEmpty && _placeOfSupplyTa.isEmpty) {
      final match = silkIndianStates.where(
        (s) => (s['en'] ?? '').toLowerCase() == _placeOfSupply.toLowerCase(),
      ).firstOrNull;
      if (match != null) _placeOfSupplyTa = match['ta'] ?? '';
    }

    // Load profile match and restore customer state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profiles = ref.read(vanigaTharavugalListProvider);
      if (_selectedNiruvanamId != null) {
        final match = profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
        if (match != null) setState(() => _selectedProfile = match);
      }

      // Restore _customerState from saved merchant's maanilam
      if (_selectedVanigarId != null) {
        final vanigargalData = ref.read(vanigargalStreamProvider);
        final vanigargal = vanigargalData.whenOrNull(data: (list) => list) ?? [];
        final vanigar = vanigargal.where((v) => v.id == _selectedVanigarId).firstOrNull;
        if (vanigar != null) {
          _customerState = (vanigar.maanilam['English'] ??
                      vanigar.maanilam['Tamil'] ??
                      '')
                  .trim()
                  .toLowerCase();
        }
      }

      _recalculate();
    });
  }

  /// Load data from a source invoice for duplication.
  /// Same as _loadEditingData but does NOT set editingEntry — creates a new invoice.
  void _loadDuplicateData() {
    final e = widget.duplicateFrom!;
    _selectedNiruvanamId = e.niruvanamId;
    _selectedVanigarId = e.vanigarId;
    _selectedVanigarPeyar = e.vanigarPeyar;
    _pattiyalVagai = e.pattiyalVagai;
    _pattiyalNaal = DateTime.now(); // Fresh date for duplicate
    _nibandhanaigal = e.nibandhanaigal;
    _ullkurippu = e.ullkurippu;

    _termsController.text = _nibandhanaigal;
    _notesController.text = _ullkurippu;

    // Load items from JSON
    _items = PattiyalUthavigal.pattuListFromJson(e.tharavugal);
    if (_items.isEmpty) _items = [const PattuUrupadi()];

    // Load settings JSON
    try {
      final settings = jsonDecode(e.sonthaViruppangal) as Map<String, dynamic>;
      _globalDiscountValue = (settings['globalDiscountValue'] as num?)?.toDouble() ?? 0;
      _globalDiscountType = settings['globalDiscountType'] as String? ?? 'percentage';
      _globalDiscountController.text = _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
      _placeOfSupply = settings['placeOfSupply'] as String? ?? '';
      _placeOfSupplyTa = settings['placeOfSupplyTa'] as String? ?? '';
    } catch (_) {}

    // Invoice number: leave empty for auto-generation (new number)
    _invoiceNumberOverride = '';

    // Load profile match and restore customer state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profiles = ref.read(vanigaTharavugalListProvider);
      if (_selectedNiruvanamId != null) {
        final match = profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
        if (match != null) setState(() => _selectedProfile = match);
      }

      if (_selectedVanigarId != null) {
        final vanigargalData = ref.read(vanigargalStreamProvider);
        final vanigargal = vanigargalData.whenOrNull(data: (list) => list) ?? [];
        final vanigar = vanigargal.where((v) => v.id == _selectedVanigarId).firstOrNull;
        if (vanigar != null) {
          _customerState = (vanigar.maanilam['English'] ??
                      vanigar.maanilam['Tamil'] ??
                      '')
                  .trim()
                  .toLowerCase();
        }
      }

      _recalculate();
    });
  }

  @override
  void dispose() {
    _termsController.dispose();
    _notesController.dispose();
    _globalDiscountController.dispose();
    _invNumberController.dispose();
    _draftDebounce?.cancel();
    super.dispose();
  }

  // ── Recalculate totals using the pure calculation engine ──
  void _recalculate() {
    // Get business state from selected profile
    String businessState = '';
    String country = 'India';
    if (_selectedProfile != null) {
      businessState = (_selectedProfile!.maanilam['English'] ?? _selectedProfile!.maanilam['Tamil'] ?? '').trim().toLowerCase();
    }

    // Place of Supply overrides customer state for GST split
    final effectiveCustomerState =
        _placeOfSupply.isNotEmpty ? _placeOfSupply.toLowerCase() : _customerState;

    setState(() {
      _totals = PattuKanakku.calculate(
        items: _items,
        globalDiscountValue: _globalDiscountValue,
        globalDiscountType: _globalDiscountType,
        businessState: businessState,
        customerState: effectiveCustomerState,
        country: country,
      );
      _hasUnsavedChanges = true;
    });
    _scheduleDraftSave();
  }

  // ── Draft auto-save (debounced 2s) ──
  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (_isEditing) return; // Only for new invoices
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = jsonEncode({
        'vanigarId': _selectedVanigarId,
        'vanigarPeyar': _selectedVanigarPeyar,
        'customerState': _customerState,
        'niruvanamId': _selectedNiruvanamId,
        'pattiyalVagai': _pattiyalVagai,
        'pattiyalNaal': _pattiyalNaal.toIso8601String(),
        'placeOfSupply': _placeOfSupply,
        'placeOfSupplyTa': _placeOfSupplyTa,
        'invoiceNumberOverride': _invoiceNumberOverride,
        'items': PattiyalUthavigal.pattuListToJson(_items),
        'globalDiscountValue': _globalDiscountValue,
        'globalDiscountType': _globalDiscountType,
        'nibandhanaigal': _nibandhanaigal,
        'ullkurippu': _ullkurippu,
      });
      await prefs.setString(_draftKey, draft);
    } catch (_) {}
  }

  Future<void> _tryRestoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);
      if (draftJson == null || draftJson.isEmpty) return;
      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      // Check if draft is blank
      final items = draft['items'] as String? ?? '[]';
      final name = draft['vanigarPeyar'] as String? ?? '';
      if (items == '[]' && name.isEmpty) {
        await prefs.remove(_draftKey);
        return;
      }
      if (!mounted) return;
      // Show restore dialog
      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('வரைவு மீட்கவா?'),
          content: const Text('சேமிக்காத வரைவு உள்ளது. மீட்டமைக்கவா?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('நிராகரி'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('மீட்கவும்'),
            ),
          ],
        ),
      );
      if (restore == true && mounted) {
        setState(() {
          _selectedVanigarId = draft['vanigarId'] as int?;
          _selectedVanigarPeyar = draft['vanigarPeyar'] as String? ?? '';
          _customerState = draft['customerState'] as String? ?? '';
          _selectedNiruvanamId = draft['niruvanamId'] as int?;
          _pattiyalVagai = draft['pattiyalVagai'] as String? ?? 'tax-invoice';
          _pattiyalNaal = DateTime.tryParse(draft['pattiyalNaal'] as String? ?? '') ?? DateTime.now();
          _placeOfSupply = draft['placeOfSupply'] as String? ?? '';
          _placeOfSupplyTa = draft['placeOfSupplyTa'] as String? ?? '';
          _invoiceNumberOverride = draft['invoiceNumberOverride'] as String? ?? '';
          _invNumberController.text = _invoiceNumberOverride;
          _items = PattiyalUthavigal.pattuListFromJson(items);
          if (_items.isEmpty) _items = [const PattuUrupadi()];
          _globalDiscountValue = (draft['globalDiscountValue'] as num?)?.toDouble() ?? 0;
          _globalDiscountType = draft['globalDiscountType'] as String? ?? 'percentage';
          _globalDiscountController.text = _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
          _nibandhanaigal = draft['nibandhanaigal'] as String? ?? '';
          _ullkurippu = draft['ullkurippu'] as String? ?? '';
          _termsController.text = _nibandhanaigal;
          _notesController.text = _ullkurippu;
        });
        // Restore profile match
        final profiles = ref.read(vanigaTharavugalListProvider);
        if (_selectedNiruvanamId != null) {
          final match = profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
          if (match != null) setState(() => _selectedProfile = match);
        }
        _recalculate();
      } else {
        await prefs.remove(_draftKey);
      }
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  // ── Save ──
  Future<void> _handleSave() async {
    // Validate
    if (_selectedVanigarId == null && _selectedVanigarPeyar.isEmpty) {
      ElvanSnackbar.show(context, 'Select a customer');
      return;
    }
    final validItems = _items.where((i) => i.alavu > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, 'Add at least one item');
      return;
    }

    setState(() => _saving = true);

    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final finYear = PattiyalKalanjiyam.getCurrentFinYear();

      // Get business prefix from selected profile
      final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'INV';

      // Settings JSON (includes place of supply)
      final settingsJson = jsonEncode({
        'globalDiscountValue': _globalDiscountValue,
        'globalDiscountType': _globalDiscountType,
        'placeOfSupply': _placeOfSupply,
        'placeOfSupplyTa': _placeOfSupplyTa,
      });

      if (_isEditing) {
        // Update existing — include invoice number if user changed it
        final invNumChanged = _invoiceNumberOverride != widget.editingEntry!.patrucheettuEn;
        await kalanjiyam.updatePattiyal(
          widget.editingEntry!.id,
          PatrucheettuTableCompanion(
            patrucheettuEn: invNumChanged ? Value(_invoiceNumberOverride) : const Value.absent(),
            niruvanamId: Value(_selectedNiruvanamId),
            vanigarId: Value(_selectedVanigarId),
            vanigarPeyar: Value(_selectedVanigarPeyar),
            pattiyalVagai: Value(_pattiyalVagai),
            pattiyalNaal: Value(_pattiyalNaal),
            tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
            mothaThogai: Value(_totals.mothaMothangal),
            thallupadi: Value(_totals.thallupadiMothangal),
            variThogai: Value(_totals.variMothangal),
            variTharavugal: Value(jsonEncode(_totals.variToJson())),
            sonthaViruppangal: Value(settingsJson),
            nibandhanaigal: Value(_nibandhanaigal),
            ullkurippu: Value(_ullkurippu),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        // Create new — use manual override or auto-generate
        String invoiceNumber;
        int vanakkam;
        if (_invoiceNumberOverride.isNotEmpty) {
          invoiceNumber = _invoiceNumberOverride;
          vanakkam = await kalanjiyam.getNextVanakkam('silk', _selectedNiruvanamId, finYear);
        } else {
          vanakkam = await kalanjiyam.getNextVanakkam('silk', _selectedNiruvanamId, finYear);
          invoiceNumber = kalanjiyam.formatPattiyalEn(prefix, vanakkam);
        }

        await kalanjiyam.createPattiyal(
          PatrucheettuTableCompanion.insert(
            seyaliVagai: 'silk',
            patrucheettuEn: invoiceNumber,
            finYear: finYear,
            vanakkam: Value(vanakkam),
            niruvanamId: Value(_selectedNiruvanamId),
            vanigarPeyar: _selectedVanigarPeyar,
            vanigarId: Value(_selectedVanigarId),
            pattiyalVagai: Value(_pattiyalVagai),
            pattiyalNaal: Value(_pattiyalNaal),
            tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
            mothaThogai: Value(_totals.mothaMothangal),
            thallupadi: Value(_totals.thallupadiMothangal),
            variThogai: Value(_totals.variMothangal),
            variTharavugal: Value(jsonEncode(_totals.variToJson())),
            sonthaViruppangal: Value(settingsJson),
            nibandhanaigal: Value(_nibandhanaigal),
            ullkurippu: Value(_ullkurippu),
          ),
        );
      }

      await _clearDraft();
      _hasUnsavedChanges = false;
      if (mounted) {
        ElvanSnackbar.show(context, K.porulChaemikkappattadhu.tr(context, ref));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ElvanSnackbar.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── UI ── (Rewritten to match React InvoiceEditorV2)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Resolve selected customer from stream for "Saved Details" card
    final vanigargalAsync = ref.watch(vanigargalStreamProvider);
    final VanigarEntry? selectedVanigar = vanigargalAsync.whenOrNull(
      data: (list) => _selectedVanigarId != null
          ? list.cast<VanigarEntry?>().firstWhere(
                (v) => v!.id == _selectedVanigarId,
                orElse: () => null,
              )
          : null,
    );

    return ElvanEditorShell(
      title: _isEditing
          ? K.pattupattiyalthiruthi.tr(context, ref)
          : K.pudhiyaPattupPattiyal.tr(context, ref),
      onSave: _saving ? null : _handleSave,
      hasUnsavedChanges: _hasUnsavedChanges,
      onDiscard: () async {
        await _clearDraft();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─────────────────────────────────────────────────────────────────
          // Section 1: ① Billed To
          // ─────────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 1, thalaipu: 'Billed To'),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final customerSearch = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption
                Text(
                  'Client Name',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Customer autocomplete
                VanigarThaeduKooru(
                  seyaliVagai: 'silk',
                  selectedId: _selectedVanigarId,
                  onSelected: (entry) {
                    setState(() {
                      _selectedVanigarId = entry.id;
                      _selectedVanigarPeyar =
                          entry.peyar['Tamil'] ?? entry.peyar['English'] ?? '';
                      _customerState = (entry.maanilam['English'] ??
                                  entry.maanilam['Tamil'] ??
                                  '')
                              .trim()
                              .toLowerCase();
                      // Auto-set Place of Supply from customer
                      if (_placeOfSupply.isEmpty) {
                        _placeOfSupply = (entry.maanilam['English'] ??
                                    entry.maanilam['Tamil'] ??
                                    '')
                                .trim();
                        _placeOfSupplyTa = (entry.maanilam['Tamil'] ?? '').trim();
                      }
                    });
                    _recalculate();
                  },
                  onCleared: () {
                    setState(() {
                      _selectedVanigarId = null;
                      _selectedVanigarPeyar = '';
                      _customerState = '';
                      _placeOfSupply = '';
                      _placeOfSupplyTa = '';
                    });
                    _recalculate();
                  },
                  onRequestAddNew: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SilkMerchantEditor(),
                      ),
                    );
                    // Stream auto-refreshes; user can search for newly created customer
                  },
                ),
              ],
            );

            final savedDetailsCard = selectedVanigar != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElvanThiruthiAttai(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Details',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Primary name (Tamil)
                          Text(
                            selectedVanigar.peyar['Tamil'] ?? _selectedVanigarPeyar,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Full bilingual address block (Tamil + English + GSTIN)
                          _buildAddressBlock(selectedVanigar, cs, tt),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink();

            final profileDropdown = _buildProfileDropdown();

            final leftColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customerSearch,
                savedDetailsCard,
                profileDropdown,
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: leftColumn),
                  const SizedBox(width: 24),
                  const Expanded(flex: 7, child: SizedBox.shrink()),
                ],
              );
            }
            return leftColumn;
          }),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Section 2: ② Invoice Details
          // ─────────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 2, thalaipu: 'Invoice Details'),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;

            final invoiceNumberField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Invoice Number',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ...[
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _isInvNumberEditing = !_isInvNumberEditing;
                            if (_isInvNumberEditing) {
                              // Extract just the number part for editing
                              final current = _invoiceNumberOverride.isNotEmpty
                                  ? _invoiceNumberOverride
                                  : _previewInvoiceNumber;
                              final parts = current.split('-');
                              _invNumberController.text =
                                  parts.length > 1 ? parts.sublist(1).join('-') : parts.last;
                            } else {
                              // Reconstruct full invoice number
                              final numPart = _invNumberController.text.trim();
                              if (numPart.isNotEmpty) {
                                final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
                                    ? _selectedProfile!.kurumPeyar
                                    : 'INV';
                                _invoiceNumberOverride = '$prefix-$numPart';
                              }
                              _hasUnsavedChanges = true;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            _isInvNumberEditing ? Icons.check : Icons.edit_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (_isInvNumberEditing)
                  Row(
                    children: [
                      // Locked prefix pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${_selectedProfile?.kurumPeyar.isNotEmpty == true ? _selectedProfile!.kurumPeyar : "INV"}-',
                          style: tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Editable number part
                      Expanded(
                        child: TextField(
                          controller: _invNumberController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: '01',
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12)),
                              borderSide: BorderSide(
                                color: cs.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            isDense: true,
                          ),
                          onChanged: (v) {
                            _hasUnsavedChanges = true;
                          },
                        ),
                      ),
                    ],
                  )
                else
                  ElvanThiruthiAttai(
                    child: Text(
                      _invoiceNumberOverride.isNotEmpty
                          ? _invoiceNumberOverride
                          : _previewInvoiceNumber.isNotEmpty
                              ? _previewInvoiceNumber
                              : 'Auto-generated on save',
                      style: tt.bodyLarge?.copyWith(
                        color: _invoiceNumberOverride.isNotEmpty
                            ? cs.onSurface
                            : cs.onSurfaceVariant,
                        fontWeight: _invoiceNumberOverride.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );

            final dateField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                PattiyalNaalKooru(
                  selectedDate: _pattiyalNaal,
                  onDateChanged: (d) => setState(() => _pattiyalNaal = d),
                ),
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: invoiceNumberField),
                  const SizedBox(width: 24),
                  Expanded(child: dateField),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                invoiceNumberField,
                const SizedBox(height: 16),
                dateField,
              ],
            );
          }),

          const SizedBox(height: 16),

          // ─── Place of Supply ───
          _buildPlaceOfSupply(cs, tt),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Section 3: ③ Line Items
          // ─────────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 3, thalaipu: 'Line Items'),
          ...List.generate(_items.length, (i) => _buildItemRow(i)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() => _items = [..._items, const PattuUrupadi()]);
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Add Item'),
              style: TextButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                foregroundColor: cs.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Section 3.5: Global Discount (inside items area)
          // ─────────────────────────────────────────────────────────────────
          ElvanThiruthiAttai(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _globalDiscountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Global Discount',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onChanged: (v) {
                      _globalDiscountValue = double.tryParse(v) ?? 0;
                      _recalculate();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'percentage', label: Text('%')),
                    ButtonSegment(value: 'amount', label: Text('₹')),
                  ],
                  selected: {_globalDiscountType},
                  onSelectionChanged: (s) {
                    setState(() => _globalDiscountType = s.first);
                    _recalculate();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Section 4: ④ Totals (inverted badge)
          // ─────────────────────────────────────────────────────────────────
          _buildTotalsSection(cs, tt),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Section 5: ⑤ Invoice Type
          // ─────────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 5, thalaipu: 'Invoice Type'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: DropdownButtonFormField<String>(
              initialValue: _pattiyalVagai,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'tax-invoice', child: Text('Tax Invoice')),
                DropdownMenuItem(
                    value: 'proforma', child: Text('Proforma')),
              ],
              onChanged: (v) async {
                final newType = v ?? 'tax-invoice';
                setState(() => _pattiyalVagai = newType);
                // Auto-generate new invoice number with new prefix
                if (!_isEditing && _invoiceNumberOverride.isEmpty) {
                  // The prefix changes based on type, so reset override
                  // The actual number is generated at save time
                }
                _hasUnsavedChanges = true;
                _scheduleDraftSave();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Terms & Notes removed per user request (not used in production)
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Helper Widgets ──
  // ═══════════════════════════════════════════════════════════════════════════

  /// Totals section with inverted badge colors.
  Widget _buildTotalsSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inverted badge: onSurface bg, surface text
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 24),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '4',
                  style: TextStyle(
                    color: cs.surface,
                    fontSize: 12.8,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Totals',
                style: TextStyle(
                  fontSize: 17.6,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Constrained totals card
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ElvanThiruthiAttai(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _totalsRow('Subtotal', _totals.adippadaiMothangal, cs, tt),
                if (_totals.thallupadiMothangal > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('Discount', -_totals.thallupadiMothangal, cs, tt,
                      color: Colors.red),
                ],
                if (_totals.cgst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('CGST', _totals.cgst, cs, tt),
                ],
                if (_totals.sgst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('SGST', _totals.sgst, cs, tt),
                ],
                if (_totals.igst > 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('IGST', _totals.igst, cs, tt),
                ],
                if (_totals.suttruOff != 0) ...[
                  const SizedBox(height: 6),
                  _totalsRow('Round Off', _totals.suttruOff, cs, tt),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: cs.outlineVariant),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _inrFormat.format(_totals.mothaMothangal),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Single row in the totals card.
  Widget _totalsRow(
    String label,
    double amount,
    ColorScheme cs,
    TextTheme tt, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          _inrFormat.format(amount),
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color ?? cs.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Single Line Item Row ──
  Widget _buildItemRow(int index) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final item = _items[index];
    final taxableAmount = item.adippadaiThogai - item.thallupadiThogai;
    final rowTax = taxableAmount * (item.variVizhukkaadu / 100);
    final rowTotal = taxableAmount + rowTax;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: "பொருள் #N" + trash icon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  '${K.porul.tr(context, ref)} #${index + 1}',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: cs.error),
                  onPressed: () {
                    setState(
                        () => _items = List.from(_items)..removeAt(index));
                    _recalculate();
                  },
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          // ── Item card ──
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final gap = const SizedBox(width: 12);
              final vGap = const SizedBox(height: 12);

              // Product search row (always full width)
              final productSearch = PorulThaeduKooru(
                seyaliVagai: 'silk',
                initialText: item.porulPeyar,
                onSelected: (p) {
                  final updated = item.copyWith(
                    porulId: p.id.toString(),
                    porulPeyar:
                        p.porulPeyar['Tamil'] ?? p.porulPeyar['English'] ?? '',
                    porulPeyarEn: p.porulPeyar['English'] ?? '',
                    hsnKuriyeedu: p.hsnCode,
                    vilai: p.vilai,
                    variVizhukkaadu: p.variVeetham,
                    alagu: p.alagu,
                  );
                  setState(() {
                    _items = List.from(_items)..[index] = updated;
                  });
                  _recalculate();
                },
                onRequestAddNew: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SilkItemEditor(),
                    ),
                  );
                },
                onCleared: () {
                  setState(() {
                    _items = List.from(_items)..[index] = const PattuUrupadi();
                  });
                  _recalculate();
                },
              );

              // Build field widgets
              final isWeightItem = item.alagu == 'Kg';
              final qtyField = _itemField(
                isWeightItem ? 'Weight (kg)' : 'Qty',
                item.alavu,
                (v) {
                  _updateItem(
                      index, item.copyWith(alavu: double.tryParse(v) ?? 0));
                },
                isWeight: isWeightItem,
              );

              final rateField = _itemField('Rate', item.vilai, (v) {
                _updateItem(
                    index, item.copyWith(vilai: double.tryParse(v) ?? 0));
              });

              final discField = Row(
                children: [
                  Expanded(
                    child: _itemField('Disc', item.thallupadi, (v) {
                      _updateItem(index,
                          item.copyWith(thallupadi: double.tryParse(v) ?? 0));
                    }),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      final newType = item.thallupadiVagai == 'percentage'
                          ? 'amount'
                          : 'percentage';
                      _updateItem(
                          index, item.copyWith(thallupadiVagai: newType));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.thallupadiVagai == 'percentage' ? '%' : '₹',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );

              final totalDisplay = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _inrFormat.format(rowTotal),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              );

              // Bilingual info line (English name · GST%)
              final infoLine = (item.porulPeyarEn.isNotEmpty ||
                      item.variVizhukkaadu > 0)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        [
                          if (item.porulPeyarEn.isNotEmpty) item.porulPeyarEn,
                          if (item.variVizhukkaadu > 0)
                            'GST ${item.variVizhukkaadu.toStringAsFixed(item.variVizhukkaadu.truncateToDouble() == item.variVizhukkaadu ? 0 : 1)}%',
                        ].join(' · '),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();

              if (isWide) {
                // Desktop: 3-column top row, 2-column bottom row
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    productSearch,
                    infoLine,
                    vGap,
                    Row(
                      children: [
                        Expanded(child: qtyField),
                        gap,
                        Expanded(child: rateField),
                      ],
                    ),
                    vGap,
                    Row(
                      children: [
                        Expanded(child: discField),
                        gap,
                        Expanded(child: totalDisplay),
                      ],
                    ),
                  ],
                );
              }

              // Mobile: matches React layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productSearch,
                  infoLine,
                  vGap,
                  Row(children: [
                    Expanded(child: qtyField),
                    gap,
                    Expanded(child: rateField),
                  ]),
                  vGap,
                  Row(children: [
                    Expanded(child: discField),
                    gap,
                    Expanded(child: totalDisplay),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Borderless numeric field used inside item cards.
  /// When [isWeight] is true, formats to 3 decimals on blur (grams precision).
  Widget _itemField(
      String label, double value, ValueChanged<String> onChanged,
      {bool isWeight = false}) {
    // Show clean number: 6 not 6.0, but keep 6.5 as-is
    String displayText = '';
    if (value != 0) {
      displayText = value == value.truncateToDouble()
          ? value.toInt().toString()
          : value.toString();
    }
    final controller = TextEditingController(text: displayText);
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: isWeight ? 'kg' : null,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        isDense: true,
      ),
      onChanged: onChanged,
      onEditingComplete: isWeight
          ? () {
              final v = double.tryParse(controller.text) ?? 0;
              controller.text = v > 0 ? v.toStringAsFixed(3) : '';
            }
          : null,
    );
  }

  void _updateItem(int index, PattuUrupadi updated) {
    setState(() {
      _items = List.from(_items)..[index] = updated;
    });
    _recalculate();
  }

  /// Business profile dropdown — mode-independent.
  /// Hidden when only 1 profile exists (auto-selected).
  /// Returns as pill-shaped dropdown when 2+ profiles exist.
  Widget _buildProfileDropdown() {
    final profiles = ref.watch(vanigaTharavugalListProvider);
    // Auto-select if only one and nothing selected
    if (profiles.length == 1 && _selectedNiruvanamId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedProfile = profiles.first;
            _selectedNiruvanamId = profiles.first.id;
          });
        }
      });
    }
    // Hide dropdown when only 1 profile
    if (profiles.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedNiruvanamId,
        decoration: InputDecoration(
          labelText: 'Company Profile',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        items: profiles.map((p) {
          final name = p.niruvanathinPeyar['Tamil'] ??
              p.niruvanathinPeyar['English'] ??
              'Company';
          return DropdownMenuItem(value: p.id, child: Text(name));
        }).toList(),
        onChanged: (v) {
          final match = profiles.where((p) => p.id == v).firstOrNull;
          setState(() {
            _selectedNiruvanamId = v;
            _selectedProfile = match;
          });
          _recalculate();
          _computePreviewInvoiceNumber();
        },
      ),
    );
  }

  // ── Full Address Block in Saved Details Card ──
  // Shows bilingual multi-line address: Tamil block, English block, then GSTIN
  Widget _buildAddressBlock(VanigarEntry v, ColorScheme cs, TextTheme tt) {
    // Build address lines for a given language key
    List<String> buildLines(String key) {
      final lines = <String>[];

      // Street address
      final mugavari = (v.mugavari[key] ?? '').trim();
      if (mugavari.isNotEmpty) lines.add(mugavari);

      // City - District - PIN
      final oor = (v.oor[key] ?? '').trim();
      final maavattam = (v.maavattam[key] ?? '').trim();
      final pin = v.anjalKuriyeedu.trim();
      final cityLine = [
        if (oor.isNotEmpty) oor,
        if (maavattam.isNotEmpty) maavattam,
        if (pin.isNotEmpty) pin,
      ].join(' - ');
      if (cityLine.isNotEmpty) lines.add(cityLine);

      // State
      final maanilam = (v.maanilam[key] ?? '').trim();
      if (maanilam.isNotEmpty) lines.add(maanilam);

      // Country
      final naadu = (v.naadu[key] ?? '').trim();
      if (naadu.isNotEmpty) lines.add(naadu);

      return lines;
    }

    final taLines = buildLines('Tamil');
    final enLines = buildLines('English');

    if (taLines.isEmpty && enLines.isEmpty && v.gstin.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tamil address block
          if (taLines.isNotEmpty) ...[
            ...taLines.map((line) => Text(
              line,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface,
                height: 1.6,
              ),
            )),
          ],
          // Spacer between language blocks
          if (taLines.isNotEmpty && enLines.isNotEmpty)
            const SizedBox(height: 8),
          // English address block (italic, dimmer)
          if (enLines.isNotEmpty) ...[
            ...enLines.map((line) => Text(
              line,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            )),
          ],
          // GSTIN
          if (v.gstin.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'GSTIN: ${v.gstin}',
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Place of Supply: Two Pills (Editable + Bilingual Locked) ──
  Widget _buildPlaceOfSupply(ColorScheme cs, TextTheme tt) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 500;

      final editablePill = GestureDetector(
        onTap: () => _showStatePickerSheet(cs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  _placeOfSupply.isEmpty
                      ? 'Select State'
                      : _placeOfSupply,
                  style: tt.bodyMedium?.copyWith(
                    color: _placeOfSupply.isEmpty
                        ? cs.onSurfaceVariant
                        : cs.onSurface,
                    fontWeight: _placeOfSupply.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (_placeOfSupply.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _placeOfSupply = '';
                      _placeOfSupplyTa = '';
                    });
                    _recalculate();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
                  ),
                )
              else
                Icon(Icons.arrow_drop_down, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      );

      final tamilPill = _placeOfSupplyTa.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _placeOfSupplyTa,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place of Supply',
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (isNarrow)
            // Mobile: stacked vertically
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                editablePill,
                if (_placeOfSupplyTa.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  tamilPill,
                ],
              ],
            )
          else
            // Desktop: side by side
            Row(
              children: [
                Expanded(child: editablePill),
                if (_placeOfSupplyTa.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(child: tamilPill),
                ],
              ],
            ),
        ],
      );
    });
  }

  void _showStatePickerSheet(ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => _InvoiceStatePickerSheet(
        isDark: isDark,
        onSelected: (en, ta) {
          setState(() {
            _placeOfSupply = en;
            _placeOfSupplyTa = ta;
          });
          _recalculate();
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// Bottom sheet state picker for Place of Supply — reuses silkIndianStates data.
class _InvoiceStatePickerSheet extends StatefulWidget {
  const _InvoiceStatePickerSheet({
    required this.isDark,
    required this.onSelected,
  });

  final bool isDark;
  final void Function(String en, String ta) onSelected;

  @override
  State<_InvoiceStatePickerSheet> createState() =>
      _InvoiceStatePickerSheetState();
}

class _InvoiceStatePickerSheetState extends State<_InvoiceStatePickerSheet> {
  String _searchQuery = '';

  List<Map<String, String>> get _filtered {
    if (_searchQuery.isEmpty) return silkIndianStates;
    final q = _searchQuery.toLowerCase();
    return silkIndianStates.where((s) =>
        (s['en']?.toLowerCase().contains(q) ?? false) ||
        (s['ta']?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search state...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          // List
          Flexible(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                return ListTile(
                  title: Text(item['en'] ?? ''),
                  subtitle: Text(
                    item['ta'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  onTap: () => widget.onSelected(
                    item['en'] ?? '',
                    item['ta'] ?? '',
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
