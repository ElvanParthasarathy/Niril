import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';

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
import 'koorugal/pattu_urupadi_attai.dart';
import 'koorugal/pattu_mothangal_kooru.dart';
import 'koorugal/pattu_vanigargal_kooru.dart';
import 'koorugal/pattu_pattiyal_tharavugal_kooru.dart';


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
          // ───────────────────────────────────────────────────────────────
          // Section 1: ① Billed To
          // ───────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 1, thalaipu: 'Billed To'),
          PattuVanigargalKooru(
            data: PattuVanigargalData(
              selectedVanigarId: _selectedVanigarId,
              selectedVanigarPeyar: _selectedVanigarPeyar,
              selectedNiruvanamId: _selectedNiruvanamId,
              placeOfSupply: _placeOfSupply,
              placeOfSupplyTa: _placeOfSupplyTa,
            ),
            callbacks: PattuVanigargalCallbacks(
              onCustomerSelected: (entry) {
                setState(() {
                  _selectedVanigarId = entry.id;
                  _selectedVanigarPeyar =
                      entry.peyar['Tamil'] ?? entry.peyar['English'] ?? '';
                  _customerState = (entry.maanilam['English'] ??
                              entry.maanilam['Tamil'] ??
                              '')
                          .trim()
                          .toLowerCase();
                  if (_placeOfSupply.isEmpty) {
                    _placeOfSupply = (entry.maanilam['English'] ??
                                entry.maanilam['Tamil'] ??
                                '')
                            .trim();
                    _placeOfSupplyTa = (entry.maanilam['Tamil'] ?? '').trim();
                  }
                });
                _hasUnsavedChanges = true;
                _recalculate();
              },
              onCustomerCleared: () {
                setState(() {
                  _selectedVanigarId = null;
                  _selectedVanigarPeyar = '';
                  _customerState = '';
                  _placeOfSupply = '';
                  _placeOfSupplyTa = '';
                });
                _hasUnsavedChanges = true;
                _recalculate();
              },
              onRequestAddNewCustomer: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SilkMerchantEditor(),
                  ),
                );
              },
              onProfileChanged: (id, profile) {
                setState(() {
                  _selectedNiruvanamId = id;
                  _selectedProfile = profile;
                });
                _recalculate();
                _computePreviewInvoiceNumber();
              },
              onPlaceOfSupplyChanged: (en, ta) {
                setState(() {
                  _placeOfSupply = en;
                  _placeOfSupplyTa = ta;
                });
                _recalculate();
              },
              onPlaceOfSupplyCleared: () {
                setState(() {
                  _placeOfSupply = '';
                  _placeOfSupplyTa = '';
                });
                _recalculate();
              },
            ),
            selectedVanigar: selectedVanigar,
          ),

          const SizedBox(height: 24),

          // ───────────────────────────────────────────────────────────────
          // Section 2: ② Invoice Details
          // ───────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 2, thalaipu: 'Invoice Details'),
          PattuPattiyalTharavugalKooru(
            isEditing: _isEditing,
            invoiceNumberOverride: _invoiceNumberOverride,
            previewInvoiceNumber: _previewInvoiceNumber,
            isInvNumberEditing: _isInvNumberEditing,
            invNumberController: _invNumberController,
            profilePrefix: _selectedProfile?.kurumPeyar.isNotEmpty == true
                ? _selectedProfile!.kurumPeyar
                : 'INV',
            pattiyalNaal: _pattiyalNaal,
            onToggleEditInvNumber: () {
              setState(() {
                _isInvNumberEditing = !_isInvNumberEditing;
                if (_isInvNumberEditing) {
                  final current = _invoiceNumberOverride.isNotEmpty
                      ? _invoiceNumberOverride
                      : _previewInvoiceNumber;
                  final parts = current.split('-');
                  _invNumberController.text =
                      parts.length > 1 ? parts.sublist(1).join('-') : parts.last;
                } else {
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
            onInvNumberChanged: (_) {},
            onDateChanged: (d) => setState(() {
              _pattiyalNaal = d;
              _hasUnsavedChanges = true;
            }),
            onDirty: () => _hasUnsavedChanges = true,
          ),

          const SizedBox(height: 16),

          // ─── Place of Supply ───
          PattuVilippiIdam(
            placeOfSupply: _placeOfSupply,
            placeOfSupplyTa: _placeOfSupplyTa,
            onSelected: (en, ta) {
              setState(() {
                _placeOfSupply = en;
                _placeOfSupplyTa = ta;
              });
              _recalculate();
            },
            onCleared: () {
              setState(() {
                _placeOfSupply = '';
                _placeOfSupplyTa = '';
              });
              _recalculate();
            },
          ),

          const SizedBox(height: 24),

          // ───────────────────────────────────────────────────────────────
          // Section 3: ③ Line Items (uses PattuUrupadiAttai component)
          // ───────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 3, thalaipu: 'Line Items'),
          ...List.generate(_items.length, (i) => PattuUrupadiAttai(
            item: _items[i],
            index: i,
            itemCount: _items.length,
            seyaliVagai: 'silk',
            onItemUpdated: (updated) {
              setState(() {
                _items = List.from(_items)..[i] = updated;
                _hasUnsavedChanges = true;
              });
              _recalculate();
            },
            onItemDeleted: () {
              setState(() {
                _items = List.from(_items)..removeAt(i);
                _hasUnsavedChanges = true;
              });
              _recalculate();
            },
            onItemCleared: () {
              setState(() {
                _items = List.from(_items)..[i] = const PattuUrupadi();
                _hasUnsavedChanges = true;
              });
              _recalculate();
            },
            onDirty: () => _hasUnsavedChanges = true,
            onRequestAddNewProduct: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SilkItemEditor(),
                ),
              );
            },
          )),
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

          // ───────────────────────────────────────────────────────────────
          // Section 3.5: Global Discount
          // ───────────────────────────────────────────────────────────────
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

          // ───────────────────────────────────────────────────────────────
          // Section 4: ④ Totals (uses PattuMothangalKooru component)
          // ───────────────────────────────────────────────────────────────
          PattuMothangalKooru(totals: _totals),

          const SizedBox(height: 24),

          // ───────────────────────────────────────────────────────────────
          // Section 5: ⑤ Invoice Type
          // ───────────────────────────────────────────────────────────────
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
                _hasUnsavedChanges = true;
                _scheduleDraftSave();
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
