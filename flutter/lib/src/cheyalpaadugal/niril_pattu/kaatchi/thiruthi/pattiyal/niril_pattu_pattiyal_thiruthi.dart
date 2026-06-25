import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_niruvanam_oadu.dart';
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
import '../../../../niril_podhu/kaatchi/koorugal/elvan_pattiyal_tharavugal_kooru.dart';


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



  // ── Calculated Totals ──
  PattuMothangal _totals = const PattuMothangal();

  // ── Controllers ──

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
      if (!_isEditing && _selectedNiruvanamId == null) {
        _computePreviewInvoiceNumber();
      }
      _resolveCustomerState();
      _recalculate();
    });
  }

  /// Applies a loaded snapshot to all state fields + controllers.
  void _applySnapshot(PattuThiruththiNilaimai s) {
    _selectedNiruvanamId = s.selectedNiruvanamId;
    _selectedVanigarId = s.selectedVanigarId;
    _selectedVanigarPeyar = s.selectedVanigarPeyarMap['Tamil'] ?? s.selectedVanigarPeyarMap['English'] ?? '';
    _customerState = s.customerState;
    _pattiyalVagai = s.pattiyalVagai;
    _pattiyalNaal = s.pattiyalNaal;
    _placeOfSupply = s.placeOfSupply;
    _placeOfSupplyTa = s.placeOfSupplyTa;
    _invoiceNumberOverride = s.invoiceNumberOverride;
    _items = s.items.isNotEmpty ? s.items : [const PattuUrupadi()];
    _globalDiscountValue = s.globalDiscountValue;
    _globalDiscountType = s.globalDiscountType;
    _invNumberController.text = _invoiceNumberOverride;
    _globalDiscountController.text =
        _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
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
      final vanigargalData = ref.read(vanigargalProvider);
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
        selectedVanigarPeyarMap: {'Tamil': _selectedVanigarPeyar, 'English': _selectedVanigarPeyar},
        customerState: _customerState,
        pattiyalVagai: _pattiyalVagai,
        pattiyalNaal: _pattiyalNaal,
        placeOfSupply: _placeOfSupply,
        placeOfSupplyTa: _placeOfSupplyTa,
        invoiceNumberOverride: _invoiceNumberOverride,
        items: _items,
        globalDiscountValue: _globalDiscountValue,
        globalDiscountType: _globalDiscountType,

      );

  // ── Save (delegates to helper) ──
  Future<void> _handleSave() async {
    // Unfocus active field → triggers blur commit on ItemFieldWidget
    FocusManager.instance.primaryFocus?.unfocus();
    // Let blur handler run before we read field values
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    if (_selectedVanigarId == null && _selectedVanigarPeyar.isEmpty) {
      ElvanSnackbar.show(context, K.vanigaraiThaerodhu.tr(context, ref));
      return;
    }
    final validItems =
        _items.where((i) => i.alavu > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, K.kuriaindhOruUrupadi.tr(context, ref));
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
        ref.invalidate(pattiyalgalProvider);
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
    final vanigargalAsync = ref.watch(vanigargalProvider);
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
      child: ElvanThiruthiNiruvanamOadu(
        selectedNiruvanamId: _selectedNiruvanamId,
        onChanged: (p) {
          setState(() {
            _selectedNiruvanamId = p?.id;
            _selectedProfile = p;
          });
          _recalculate();
          _computePreviewInvoiceNumber();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // ───────────────────────────────────────────────────────────────
          // Section 1: ① Billed To
          // ───────────────────────────────────────────────────────────────
          ElvanPagudhiThalaipu(en: 1, thalaipu: K.perunar.tr(context, ref)),
          PattuVanigargalKooru(
            data: PattuVanigargalData(
              selectedVanigarId: _selectedVanigarId,
              selectedVanigarPeyarMap: {'Tamil': _selectedVanigarPeyar, 'English': _selectedVanigarPeyar},
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
                setState(() => _hasUnsavedChanges = true);
                _recalculate();
              },
              onRequestAddNewCustomer: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SilkMerchantEditor(),
                  ),
                );
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

          // ── Disabled wrapper when no company selected ──
          Opacity(
            opacity: _selectedNiruvanamId == null ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _selectedNiruvanamId == null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          // ───────────────────────────────────────────────────────────────
          // Section 2: ② Invoice Details
          // ───────────────────────────────────────────────────────────────
          ElvanPagudhiThalaipu(en: 2, thalaipu: K.pattiyalTharavugal.tr(context, ref)),
          ElvanPattiyalTharavugalKooru(
            isEditing: _isEditing,
            invoiceNumberOverride: _invoiceNumberOverride,
            previewInvoiceNumber: _previewInvoiceNumber,
            isInvNumberEditing: _isInvNumberEditing,
            invNumberController: _invNumberController,
            profilePrefix: _selectedProfile?.kurumPeyar.isNotEmpty == true
                ? '${_selectedProfile!.kurumPeyar}-'
                : 'INV-',
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
                        ? '${_selectedProfile!.kurumPeyar}-'
                        : 'INV-';
                    _invoiceNumberOverride = '$prefix$numPart';
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
            onDirty: () => setState(() => _hasUnsavedChanges = true),
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
          ElvanPagudhiThalaipu(en: 3, thalaipu: K.varisaiUrupadigal.tr(context, ref)),
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
            onDirty: () => setState(() => _hasUnsavedChanges = true),
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
              label: Text(K.urupadiChaer.tr(context, ref)),
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
          PattuKazhivuKooru(
            controller: _globalDiscountController,
            discountType: _globalDiscountType,
            onValueChanged: (v) {
              _globalDiscountValue = double.tryParse(v) ?? 0;
              _recalculate();
            },
            onTypeChanged: (type) {
              setState(() => _globalDiscountType = type);
              _recalculate();
            },
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
          ElvanPagudhiThalaipu(en: 5, thalaipu: K.pattiyalVagai.tr(context, ref)),
          PattuPattiyalVagaiKooru(
            pattiyalVagai: _pattiyalVagai,
            onChanged: (v) {
              final newType = v ?? 'tax-invoice';
              setState(() => _pattiyalVagai = newType);
              setState(() => _hasUnsavedChanges = true);
              _scheduleDraftSave();
            },
          ),

          const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
