import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';

import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../vanigar/niril_pattu_vanigar_thiruthi.dart';
import '../porul/niril_pattu_porul_thiruthi.dart';
import 'koorugal/koorugal.dart';


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
  NiruvanaTharavugal? _selectedProfile;

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

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _applySnapshot(
        PattuPattiyalUthavi.loadFromEntry(widget.editingEntry!),
      );
    } else if (widget.duplicateFrom != null) {
      _applySnapshot(
        PattuPattiyalUthavi.loadFromEntry(widget.duplicateFrom!,
            isDuplicate: true),
      );
    } else {
      _tryRestoreDraft();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing) _autoSelectProfile();
      _resolveCustomerState();
      _recalculate();
    });
  }

  /// Applies a loaded snapshot to all state fields + controllers.
  void _applySnapshot(PattuThiruththiNilaimai s) {
    _selectedNiruvanamId = s.selectedNiruvanamId;
    _selectedVanigarId = s.selectedVanigarId;
    _selectedVanigarPeyar = s.selectedVanigarPeyar;
    _customerState = s.customerState;
    _pattiyalVagai = s.pattiyalVagai;
    _pattiyalNaal = s.pattiyalNaal;
    _placeOfSupply = s.placeOfSupply;
    _placeOfSupplyTa = s.placeOfSupplyTa;
    _invoiceNumberOverride = s.invoiceNumberOverride;
    _items = s.items.isNotEmpty ? s.items : [const PattuUrupadi()];
    _globalDiscountValue = s.globalDiscountValue;
    _globalDiscountType = s.globalDiscountType;
    _nibandhanaigal = s.nibandhanaigal;
    _ullkurippu = s.ullkurippu;

    _termsController.text = _nibandhanaigal;
    _notesController.text = _ullkurippu;
    _invNumberController.text = _invoiceNumberOverride;
    _globalDiscountController.text =
        _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
  }

  void _autoSelectProfile() {
    final profiles = ref.read(NiruvanaTharavugalListProvider);
    if (profiles.isNotEmpty && _selectedNiruvanamId == null) {
      setState(() {
        _selectedProfile = profiles.first;
        _selectedNiruvanamId = profiles.first.id;
      });
    }
    if (!_isEditing) _computePreviewInvoiceNumber();
  }

  /// Resolves _selectedProfile and _customerState from provider data.
  void _resolveCustomerState() {
    final profiles = ref.read(NiruvanaTharavugalListProvider);
    if (_selectedNiruvanamId != null) {
      final match =
          profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
      if (match != null) setState(() => _selectedProfile = match);
    }
    if (_selectedVanigarId != null) {
      final vanigargalData = ref.read(vanigargalStreamProvider);
      final vanigargal =
          vanigargalData.whenOrNull(data: (list) => list) ?? [];
      final vanigar =
          vanigargal.where((v) => v.id == _selectedVanigarId).firstOrNull;
      if (vanigar != null) {
        _customerState = (vanigar.maanilam['English'] ??
                    vanigar.maanilam['Tamil'] ??
                    '')
                .trim()
                .toLowerCase();
      }
    }
  }

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
          _previewInvoiceNumber =
              kalanjiyam.formatPattiyalEn(prefix, vanakkam);
        });
      }
    } catch (_) {}
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

  // ── Recalculate totals ──
  void _recalculate() {
    String businessState = '';
    if (_selectedProfile != null) {
      businessState = (_selectedProfile!.maanilam['English'] ??
              _selectedProfile!.maanilam['Tamil'] ??
              '')
          .trim()
          .toLowerCase();
    }
    final effectiveCustomerState = _placeOfSupply.isNotEmpty
        ? _placeOfSupply.toLowerCase()
        : _customerState;

    setState(() {
      _totals = PattuKanakku.calculate(
        items: _items,
        globalDiscountValue: _globalDiscountValue,
        globalDiscountType: _globalDiscountType,
        businessState: businessState,
        customerState: effectiveCustomerState,
        country: 'India',
      );
    });
    _scheduleDraftSave();
  }

  // ── Draft (delegates to helper) ──
  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(seconds: 2), () {
      if (_isEditing) return;
      PattuPattiyalUthavi.saveDraft(_currentSnapshot());
    });
  }

  Future<void> _tryRestoreDraft() async {
    final snapshot = await PattuPattiyalUthavi.tryRestoreDraft(context);
    if (snapshot != null && mounted) {
      setState(() => _applySnapshot(snapshot));
      _resolveCustomerState();
      _recalculate();
    }
  }

  /// Builds a snapshot from current state (for draft / save).
  PattuThiruththiNilaimai _currentSnapshot() => PattuThiruththiNilaimai(
        selectedNiruvanamId: _selectedNiruvanamId,
        selectedVanigarId: _selectedVanigarId,
        selectedVanigarPeyar: _selectedVanigarPeyar,
        customerState: _customerState,
        pattiyalVagai: _pattiyalVagai,
        pattiyalNaal: _pattiyalNaal,
        placeOfSupply: _placeOfSupply,
        placeOfSupplyTa: _placeOfSupplyTa,
        invoiceNumberOverride: _invoiceNumberOverride,
        items: _items,
        globalDiscountValue: _globalDiscountValue,
        globalDiscountType: _globalDiscountType,
        nibandhanaigal: _nibandhanaigal,
        ullkurippu: _ullkurippu,
      );

  // ── Save (delegates to helper) ──
  Future<void> _handleSave() async {
    if (_selectedVanigarId == null && _selectedVanigarPeyar.isEmpty) {
      ElvanSnackbar.show(context, 'Select a customer');
      return;
    }
    final validItems =
        _items.where((i) => i.alavu > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, 'Add at least one item');
      return;
    }

    setState(() => _saving = true);
    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'INV';

      await PattuPattiyalUthavi.save(
        kalanjiyam: kalanjiyam,
        state: _currentSnapshot(),
        totals: _totals,
        profilePrefix: prefix,
        editingEntry: widget.editingEntry,
      );

      await PattuPattiyalUthavi.clearDraft();
      _hasUnsavedChanges = false;
      if (mounted) {
        ElvanSnackbar.show(context, K.porulChaemikkappattadhu.tr(context, ref));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ElvanSnackbar.show(context, 'Error: $e');
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
        await PattuPattiyalUthavi.clearDraft();
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
