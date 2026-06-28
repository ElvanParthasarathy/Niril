import 'package:elvan_niril/src/adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import '../../../../niril_podhu/kalanjiyam/pattu_pattiyal_kalanjiyam.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_paguthi.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_niruvanam_oadu.dart';
import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../vaangunar/niril_pattu_vaangunar_thiruthi.dart';
import '../porul/niril_pattu_porul_thiruthi.dart';
import 'koorugal/koorugal.dart';
import '../../../../niril_podhu/kaatchi/koorugal/elvan_pattiyal_tharavugal_kooru.dart';


/// Silk (GST) Invoice Editor — full form with line items, tax calculation,
/// auto-numbering, and FK-based customer storage.
class SilkInvoiceEditor extends ConsumerStatefulWidget {
  final PattiyalTharavuru? editingEntry;
  final PattiyalTharavuru? duplicateFrom;

  const SilkInvoiceEditor({super.key, this.editingEntry, this.duplicateFrom});

  @override
  ConsumerState<SilkInvoiceEditor> createState() => _SilkInvoiceEditorState();
}

class _SilkInvoiceEditorState extends ConsumerState<SilkInvoiceEditor> {
  // ── Company Profile ──
  int? _selectedNiruvanamId;
  NiruvanaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVaangunarId;
  String _selectedVaangunarPeyar = '';
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
    _selectedVaangunarId = s.selectedVaangunarId;
    _selectedVaangunarPeyar = s.selectedVaangunarPeyarMap[ref.read(silkMudhanmaiMozhiProvider)] ?? s.selectedVaangunarPeyarMap[ref.read(silkIrandaamMozhiProvider)] ?? s.selectedVaangunarPeyarMap.values.firstOrNull ?? '';
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
    if (_selectedVaangunarId != null) {
      final vaangunargalData = ref.read(vaangunargalProvider);
      final vaangunargal =
          vaangunargalData.whenOrNull(data: (list) => list) ?? [];
      final vaangunar =
          vaangunargal.where((v) => v.id == _selectedVaangunarId).firstOrNull;
      if (vaangunar != null) {
        _customerState = (vaangunar.maanilam['English'] ??
                    vaangunar.maanilam[ref.read(silkMudhanmaiMozhiProvider)] ??
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
      final finYear = PattuPattiyalKalanjiyam.getCurrentFinYear();
      final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'INV';
      final vanakkam = await kalanjiyam.getNextVanakkam(_selectedNiruvanamId, finYear);
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
              _selectedProfile!.maanilam[ref.read(silkMudhanmaiMozhiProvider)] ??
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
    final snapshot = await PattuPattiyalUthavi.tryRestoreDraft(context, ref);
    if (snapshot != null && mounted) {
      setState(() => _applySnapshot(snapshot));
      _resolveCustomerState();
      _recalculate();
    }
  }

  /// Builds a snapshot from current state (for draft / save).
  PattuThiruththiNilaimai _currentSnapshot() => PattuThiruththiNilaimai(
        selectedNiruvanamId: _selectedNiruvanamId,
        selectedVaangunarId: _selectedVaangunarId,
        selectedVaangunarPeyarMap: {ref.read(silkMudhanmaiMozhiProvider): _selectedVaangunarPeyar, ref.read(silkIrandaamMozhiProvider): _selectedVaangunarPeyar},
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

    if (_selectedVaangunarId == null && _selectedVaangunarPeyar.isEmpty) {
      ElvanSnackbar.show(context, K.vaangunaraiThaerodhu.tr(context, ref));
      return;
    }
    final validItems =
        _items.where((i) => i.alavu > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, K.kuriaindhOruPorul.tr(context, ref));
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
        ElvanSnackbar.show(
          context,
          K.porulChaemikkappattadhu.tr(context, ref),
          showAboveNavbar: true,
        );
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
    final vaangunargalAsync = ref.watch(vaangunargalProvider);
    final VaangunarTharavuru? selectedVaangunar = vaangunargalAsync.whenOrNull(
      data: (list) => _selectedVaangunarId != null
          ? list.cast<VaangunarTharavuru?>().firstWhere(
                (v) => v!.id == _selectedVaangunarId,
                orElse: () => null,
              )
          : null,
    );

    final profiles = ref.watch(NiruvanaTharavugalListProvider);
    final baseIndex = profiles.length > 1 ? 1 : 0;

    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
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
          ElvanEditorSection(
            index: baseIndex,
            title: K.perunar.tr(context, ref),
            displayChild: const SizedBox(),
            initiallyExpanded: true,
            children: [
              PattuVaangunargalKooru(
                data: PattuVaangunargalData(
                  selectedVaangunarId: _selectedVaangunarId,
                  selectedVaangunarPeyarMap: {ref.watch(silkMudhanmaiMozhiProvider): _selectedVaangunarPeyar, ref.watch(silkIrandaamMozhiProvider): _selectedVaangunarPeyar},
                  placeOfSupply: _placeOfSupply,
                  placeOfSupplyTa: _placeOfSupplyTa,
                ),
                callbacks: PattuVaangunargalCallbacks(
                  onCustomerSelected: (entry) {
                    setState(() {
                      _selectedVaangunarId = entry.id;
                      _selectedVaangunarPeyar =
                          entry.peyar[ref.read(silkMudhanmaiMozhiProvider)] ?? entry.peyar[ref.read(silkIrandaamMozhiProvider)] ?? entry.peyar.values.firstOrNull ?? '';
                      _customerState = (entry.maanilam['English'] ??
                                  entry.maanilam[ref.read(silkMudhanmaiMozhiProvider)] ??
                                  '')
                              .trim()
                              .toLowerCase();
                      if (_placeOfSupply.isEmpty) {
                        _placeOfSupply = (entry.maanilam['English'] ??
                                    entry.maanilam[ref.read(silkMudhanmaiMozhiProvider)] ??
                                    '')
                                .trim();
                        _placeOfSupplyTa = (entry.maanilam[ref.read(silkMudhanmaiMozhiProvider)] ?? '').trim();
                      }
                    });
                    _hasUnsavedChanges = true;
                    _recalculate();
                  },
                  onCustomerCleared: () {
                    setState(() {
                      _selectedVaangunarId = null;
                      _selectedVaangunarPeyar = '';
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
                selectedVaangunar: selectedVaangunar,
              ),
            ],
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
          ElvanEditorSection(
            index: baseIndex + 1,
            title: K.pattiyalTharavugal.tr(context, ref),
            displayChild: const SizedBox(),
            initiallyExpanded: true,
            children: [
              ...buildElvanPattiyalTharavugalKooru(
                context: context,
                ref: ref,
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
            ],
          ),

          const SizedBox(height: 24),

          // ───────────────────────────────────────────────────────────────
          // Section 3: ③ Line Items (uses PattuUrupadiAttai component)
          // ───────────────────────────────────────────────────────────────
          ElvanEditorSection(
            index: baseIndex + 2,
            title: K.porutkal.tr(context, ref),
            displayChild: const SizedBox(),
            initiallyExpanded: true,
            children: [
              ElvanFullWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        label: Text(K.porulaichChaerPtn.tr(context, ref)),
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
                  ],
                ),
              ),
            ],
          ),

          // ───────────────────────────────────────────────────────────────
          // Section 4: ④ Totals (uses PattuMothangalKooru component)
          // ───────────────────────────────────────────────────────────────
          ElvanEditorSection(
            index: baseIndex + 3,
            title: K.mothangal.tr(context, ref),
            displayChild: const SizedBox(),
            initiallyExpanded: true,
            children: [
              ElvanFullWidth(
                child: PattuMothangalKooru(totals: _totals),
              ),
            ],
          ),

          // ───────────────────────────────────────────────────────────────
          // Section 5: ⑤ Invoice Type
          // ───────────────────────────────────────────────────────────────
          ElvanEditorSection(
            index: baseIndex + 4,
            title: K.pattiyalVagai.tr(context, ref),
            displayChild: const SizedBox(),
            initiallyExpanded: true,
            children: [
              ElvanFullWidth(
                child: PattuPattiyalVagaiKooru(
                  pattiyalVagai: _pattiyalVagai,
                  onChanged: (v) {
                    final newType = v ?? 'tax-invoice';
                    setState(() => _pattiyalVagai = newType);
                    setState(() => _hasUnsavedChanges = true);
                    _scheduleDraftSave();
                  },
                ),
              ),
            ],
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
