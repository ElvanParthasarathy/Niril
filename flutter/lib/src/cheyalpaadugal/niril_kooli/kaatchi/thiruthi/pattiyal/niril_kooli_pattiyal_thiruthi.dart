import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../../niril_podhu/kalanjiyam/vanigar_nilaimai.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../vanigar/niril_kooli_vanigar_thiruthi.dart';
import '../porul/niril_kooli_porul_thiruthi.dart';
import 'koorugal/koorugal.dart';

/// Coolie Invoice Editor — weight-based billing with setharam, courier,
/// ahimsa, and other charges. Uses floor(kg × rate) truncation.
class CoolieInvoiceEditor extends ConsumerStatefulWidget {
  final PatrucheettuEntry? editingEntry;

  const CoolieInvoiceEditor({super.key, this.editingEntry});

  @override
  ConsumerState<CoolieInvoiceEditor> createState() => _CoolieInvoiceEditorState();
}

class _CoolieInvoiceEditorState extends ConsumerState<CoolieInvoiceEditor> {
  // ── Company Profile ──
  int? _selectedNiruvanamId;
  NiruvanaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVanigarId;
  String _selectedVanigarPeyar = '';

  // ── Metadata ──
  DateTime _pattiyalNaal = DateTime.now();

  // ── Line Items ──
  List<KooliUrupadi> _items = [const KooliUrupadi()];

  // ── Additional Charges ──
  double _setharamGrams = 0;
  double _thapaalThogai = 0;
  double _ahimsaPattuThogai = 0;
  List<PiraVarivu> _piraVarivugal = [];

  // ── Bank Details ──
  bool _showBankDetails = true;
  bool _showIfsc = true;

  // ── Totals ──
  KooliMothangal _totals = const KooliMothangal();

  // ── Controllers ──
  final _setharamCtrl = TextEditingController();
  final _thapaalCtrl = TextEditingController();
  final _ahimsaCtrl = TextEditingController();
  bool _saving = false;

  // ── Unsaved Changes & Draft ──
  bool _hasUnsavedChanges = false;
  Timer? _draftDebounce;

  // ── Bill Number Preview ──
  String _previewBillNumber = '';

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEditingData();
    } else {
      _tryRestoreDraft();
    }
    // Auto-select first profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing) {
        final profiles = ref.read(NiruvanaTharavugalListProvider);
        if (profiles.isNotEmpty) {
          setState(() {
            _selectedProfile = profiles.first;
            _selectedNiruvanamId = profiles.first.id;
          });
          _computePreviewBillNumber();
        }
      }
    });
  }

  void _loadEditingData() {
    final snapshot = KooliPattiyalUthavi.loadFromEntry(widget.editingEntry!);
    _selectedVanigarId = snapshot.selectedVanigarId;
    _selectedVanigarPeyar = snapshot.selectedVanigarPeyar;
    _selectedNiruvanamId = snapshot.selectedNiruvanamId;
    _pattiyalNaal = snapshot.pattiyalNaal;
    _items = snapshot.items.isNotEmpty ? snapshot.items : [const KooliUrupadi()];
    _setharamGrams = snapshot.setharamGrams;
    _thapaalThogai = snapshot.thapaalThogai;
    _ahimsaPattuThogai = snapshot.ahimsaPattuThogai;
    _piraVarivugal = snapshot.piraVarivugal;

    _setharamCtrl.text = _setharamGrams > 0 ? _setharamGrams.toString() : '';
    _thapaalCtrl.text = _thapaalThogai > 0 ? _thapaalThogai.toString() : '';
    _ahimsaCtrl.text = _ahimsaPattuThogai > 0 ? _ahimsaPattuThogai.toString() : '';

    // Load profile match
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profiles = ref.read(NiruvanaTharavugalListProvider);
      if (_selectedNiruvanamId != null) {
        final match = profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
        if (match != null) setState(() => _selectedProfile = match);
      }
    });

    _recalculate();
  }

  @override
  void dispose() {
    _setharamCtrl.dispose();
    _thapaalCtrl.dispose();
    _ahimsaCtrl.dispose();
    _draftDebounce?.cancel();
    super.dispose();
  }

  void _recalculate() {
    setState(() {
      _totals = KooliKanakku.calculate(
        items: _items,
        setharamGrams: _setharamGrams,
        thapaalThogai: _thapaalThogai,
        ahimsaPattuThogai: _ahimsaPattuThogai,
        piraVarivugal: _piraVarivugal,
      );
    });
    _scheduleDraftSave();
  }

  // ── Draft (delegates to helper) ──
  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(seconds: 2), () {
      if (_isEditing) return;
      KooliPattiyalUthavi.saveDraft(_currentSnapshot());
    });
  }

  Future<void> _tryRestoreDraft() async {
    final snapshot = await KooliPattiyalUthavi.tryRestoreDraft(context);
    if (snapshot != null && mounted) {
      setState(() {
        _selectedVanigarId = snapshot.selectedVanigarId;
        _selectedVanigarPeyar = snapshot.selectedVanigarPeyar;
        _selectedNiruvanamId = snapshot.selectedNiruvanamId;
        _pattiyalNaal = snapshot.pattiyalNaal;
        _items = snapshot.items.isNotEmpty
            ? snapshot.items
            : [const KooliUrupadi()];
        _setharamGrams = snapshot.setharamGrams;
        _thapaalThogai = snapshot.thapaalThogai;
        _ahimsaPattuThogai = snapshot.ahimsaPattuThogai;
        _piraVarivugal = snapshot.piraVarivugal;
        _showBankDetails = snapshot.showBankDetails;

        _setharamCtrl.text =
            _setharamGrams > 0 ? _setharamGrams.toString() : '';
        _thapaalCtrl.text =
            _thapaalThogai > 0 ? _thapaalThogai.toString() : '';
        _ahimsaCtrl.text =
            _ahimsaPattuThogai > 0 ? _ahimsaPattuThogai.toString() : '';
      });
      _recalculate();
    }
  }

  /// Builds a snapshot from current state (for draft / save).
  KooliThiruththiNilaimai _currentSnapshot() => KooliThiruththiNilaimai(
        selectedNiruvanamId: _selectedNiruvanamId,
        selectedProfile: _selectedProfile,
        selectedVanigarId: _selectedVanigarId,
        selectedVanigarPeyar: _selectedVanigarPeyar,
        pattiyalNaal: _pattiyalNaal,
        items: _items,
        setharamGrams: _setharamGrams,
        thapaalThogai: _thapaalThogai,
        ahimsaPattuThogai: _ahimsaPattuThogai,
        piraVarivugal: _piraVarivugal,
        showBankDetails: _showBankDetails,
      );

  // ── Bill Number Preview ──
  Future<void> _computePreviewBillNumber() async {
    if (_isEditing) return;
    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final finYear = PattiyalKalanjiyam.getCurrentFinYear();
      final prefix = _selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'CB';
      final vanakkam = await kalanjiyam.getNextVanakkam(
        'coolie', _selectedNiruvanamId, finYear,
      );
      if (mounted) {
        setState(() {
          _previewBillNumber =
              kalanjiyam.formatPattiyalEn(prefix, vanakkam);
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    if (_selectedProfile == null) {
      ElvanSnackbar.show(context, K.niruvanamThaerodhu.tr(context, ref));
      return;
    }
    if (_selectedVanigarId == null && _selectedVanigarPeyar.isEmpty) {
      ElvanSnackbar.show(context, K.vanigaraiThaerodhu.tr(context, ref));
      return;
    }
    final validItems = _items.where((i) => i.edai > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, K.kuriaindhOruUrupadi.tr(context, ref));
      return;
    }

    setState(() => _saving = true);

    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final prefix = _selectedProfile!.kurumPeyar.isNotEmpty
          ? _selectedProfile!.kurumPeyar
          : 'CB';

      await KooliPattiyalUthavi.save(
        kalanjiyam: kalanjiyam,
        state: KooliThiruththiNilaimai(
          selectedNiruvanamId: _selectedNiruvanamId,
          selectedProfile: _selectedProfile,
          selectedVanigarId: _selectedVanigarId,
          selectedVanigarPeyar: _selectedVanigarPeyar,
          pattiyalNaal: _pattiyalNaal,
          items: validItems,
          setharamGrams: _setharamGrams,
          thapaalThogai: _thapaalThogai,
          ahimsaPattuThogai: _ahimsaPattuThogai,
          piraVarivugal: _piraVarivugal,
          showBankDetails: _showBankDetails,
        ),
        totals: _totals,
        profilePrefix: prefix,
        profile: _selectedProfile!,
        editingEntry: widget.editingEntry,
      );

      await KooliPattiyalUthavi.clearDraft();
      _hasUnsavedChanges = false;
      if (mounted) {
        ref.invalidate(pattiyalgalProvider);
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
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(NiruvanaTharavugalListProvider);
    final formatter = NumberFormat('#,##0', 'en_IN');
    final vanigargalAsync = ref.watch(vanigargalProvider);
    final VanigarEntry? selectedVanigar = vanigargalAsync.whenOrNull(
      data: (list) => _selectedVanigarId != null
          ? list.cast<VanigarEntry?>().firstWhere(
                (v) => v!.id == _selectedVanigarId, orElse: () => null)
          : null,
    );

    return ElvanEditorShell(
      title: _isEditing
          ? K.koolipattiyalthiruthi.tr(context, ref)
          : K.pudhiyaKoolipPattiyal.tr(context, ref),
      onSave: _saving ? null : _handleSave,
      hasUnsavedChanges: _hasUnsavedChanges,
      onDiscard: () async {
        await KooliPattiyalUthavi.clearDraft();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: ① Customer ──
          ElvanPagudhiThalaipu(en: 1, thalaipu: K.vanigar.tr(context, ref)),
          KooliVanigarKooru(
            selectedVanigarId: _selectedVanigarId,
            selectedVanigarPeyar: _selectedVanigarPeyar,
            selectedNiruvanamId: _selectedNiruvanamId,
            profiles: profiles,
            selectedVanigar: selectedVanigar,
            onVanigarSelected: (entry) {
              setState(() {
                _selectedVanigarId = entry.id;
                _selectedVanigarPeyar =
                    entry.peyar['Tamil'] ?? entry.peyar['English'] ?? '';
                _hasUnsavedChanges = true;
              });
            },
            onNiruvanamChanged: (v) {
              final match = profiles.where((p) => p.id == v).firstOrNull;
              setState(() {
                _selectedNiruvanamId = v;
                _selectedProfile = match;
                _hasUnsavedChanges = true;
              });
              _computePreviewBillNumber();
            },
            onRequestAddNewVanigar: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CoolieMerchantEditor()),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Disabled wrapper when no company selected ──
          Opacity(
            opacity: _selectedNiruvanamId == null ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _selectedNiruvanamId == null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 2: ② Invoice Details ──
                  ElvanPagudhiThalaipu(en: 2, thalaipu: K.pattiyalTharavugal.tr(context, ref)),
                  KooliPattiyalTharavugalKooru(
                    pattiyalNaal: _pattiyalNaal,
                    previewBillNumber: _previewBillNumber,
                    onDateChanged: (d) => setState(() {
                      _pattiyalNaal = d;
                      _hasUnsavedChanges = true;
                    }),
                  ),

                  const SizedBox(height: 24),

                  // ── Section 3: ③ Items ──
                  ElvanPagudhiThalaipu(en: 3, thalaipu: K.urupadigal.tr(context, ref)),
                  ...List.generate(_items.length, (i) => KooliUrupadiKooru(
                    index: i,
                    item: _items[i],
                    itemCount: _items.length,
                    formatter: formatter,
                    onUpdated: (updated) {
                      setState(() {
                        _items = List.from(_items)..[i] = updated;
                        _hasUnsavedChanges = true;
                      });
                      _recalculate();
                    },
                    onDeleted: () {
                      setState(() {
                        _items = List.from(_items)..removeAt(i);
                        _hasUnsavedChanges = true;
                      });
                      _recalculate();
                    },
                    onRequestAddNewProduct: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CoolieItemEditor()),
                      );
                    },
                  )),

                  // Other charges item cards
                  ...List.generate(_piraVarivugal.length, (i) => KooliPiraVarivuKooru(
                    index: i,
                    charge: _piraVarivugal[i],
                    onUpdated: (updated) {
                      setState(() {
                        _piraVarivugal = List.from(_piraVarivugal)..[i] = updated;
                        _hasUnsavedChanges = true;
                      });
                    },
                    onDeleted: () {
                      setState(() {
                        _piraVarivugal = List.from(_piraVarivugal)..removeAt(i);
                        _hasUnsavedChanges = true;
                      });
                      _recalculate();
                    },
                    onRecalculate: _recalculate,
                  )),

                  const SizedBox(height: 12),

                  // Pill buttons row
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      kooliPillButton(context,
                        icon: Icons.add_rounded,
                        label: K.urupadiChaer.tr(context, ref),
                        onPressed: () => setState(() {
                          _items = [..._items, const KooliUrupadi()];
                          _hasUnsavedChanges = true;
                        }),
                      ),
                      // Always show the Add Other Charges button (not just when empty)
                      kooliPillButton(context,
                          icon: Icons.add_rounded,
                          label: K.piraVarivuChaer.tr(context, ref),
                          onPressed: () => setState(() {
                            _piraVarivugal = [
                              ..._piraVarivugal,
                              const PiraVarivu(),
                            ];
                            _hasUnsavedChanges = true;
                          }),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Extra Charges Bento Grid ──
                  KooliMelthogaiKooru(
                    setharamCtrl: _setharamCtrl,
                    ahimsaCtrl: _ahimsaCtrl,
                    thapaalCtrl: _thapaalCtrl,
                    onSetharamChanged: (v) {
                      _setharamGrams = double.tryParse(v) ?? 0;
                      _hasUnsavedChanges = true;
                      _recalculate();
                    },
                    onAhimsaChanged: (v) {
                      _ahimsaPattuThogai = double.tryParse(v) ?? 0;
                      _hasUnsavedChanges = true;
                      _recalculate();
                    },
                    onThapaalChanged: (v) {
                      _thapaalThogai = double.tryParse(v) ?? 0;
                      _hasUnsavedChanges = true;
                      _recalculate();
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Bank Details ──
                  if (_selectedProfile != null)
                    KooliVangiTharavugalKooru(
                      profile: _selectedProfile!,
                      showBankDetails: _showBankDetails,
                      onToggled: (v) => setState(() {
                        _showBankDetails = v;
                        _hasUnsavedChanges = true;
                      }),
                      showIfsc: _showIfsc,
                      onIfscToggled: (v) => setState(() => _showIfsc = v),
                    ),

                  const SizedBox(height: 24),

                  // ── Totals Card ──
                  KooliMothangalKooru(
                    totals: _totals,
                    setharamGrams: _setharamGrams,
                    ahimsaPattuThogai: _ahimsaPattuThogai,
                    thapaalThogai: _thapaalThogai,
                    piraVarivugal: _piraVarivugal,
                    formatter: formatter,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
