import 'package:elvan_niril/src/cheyalpaadugal/niril_podhu/kalanjiyam/kooli_pattiyal_kalanjiyam.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_paguthi.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_niruvanam_oadu.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../../niril_podhu/kalanjiyam/vaangunar_nilaimai.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../porul/niril_kooli_porul_thiruthi.dart';
import 'koorugal/koorugal.dart';
import '../../../../niril_podhu/kalanjiyam/porul_nilaimai.dart';
import '../../../../niril_podhu/kaatchi/koorugal/elvan_pattiyal_tharavugal_kooru.dart';

/// Coolie Invoice Editor — weight-based billing with setharam, courier,
/// ahimsa, and other charges. Uses floor(kg × rate) truncation.
class CoolieInvoiceEditor extends ConsumerStatefulWidget {
  final PattiyalTharavuru? editingEntry;

  const CoolieInvoiceEditor({super.key, this.editingEntry});

  @override
  ConsumerState<CoolieInvoiceEditor> createState() => _CoolieInvoiceEditorState();
}

class _CoolieInvoiceEditorState extends ConsumerState<CoolieInvoiceEditor> {
  // ── Company Profile ──
  int? _selectedNiruvanamId;
  NiruvanaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVaangunarId;
  Map<String, String> _selectedVaangunarPeyarMap = const {};
  Map<String, String> _selectedVaangunarMunvariMap = const {};

  // ── Metadata ──
  DateTime _pattiyalNaal = DateTime.now();

  // ── Line Items ──
  List<KooliUrupadi> _items = [const KooliUrupadi()];

  // ── Additional Charges ──
  double _setharamGrams = 0;
  double _thabaalThogai = 0;
  double _ahimsaPattuThogai = 0;
  List<PiraVarivu> _piraVarivugal = [];

  // ── Totals ──
  KooliMothangal _totals = const KooliMothangal();

  // ── Controllers ──
  final _setharamCtrl = TextEditingController();
  final _thabaalCtrl = TextEditingController();
  final _ahimsaCtrl = TextEditingController();
  final _globalDiscountController = TextEditingController();
  final _kurippuCtrl = TextEditingController();
  bool _saving = false;

  // ── Unsaved Changes & Draft ──
  bool _hasUnsavedChanges = false;
  Timer? _draftDebounce;

  final GlobalKey<AnimatedListState> _itemsListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _piraVarivugalListKey = GlobalKey<AnimatedListState>();

  // ── Bill Number ──
  String _previewBillNumber = '';
  String _invoiceNumberOverride = '';
  String _profilePrefix = 'CB';

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEditingData();
    } else {
      _tryRestoreDraft();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing && _selectedNiruvanamId == null) {
        _computePreviewBillNumber();
      }
    });
  }

  void _loadEditingData() {
    final snapshot = KooliPattiyalUthavi.loadFromEntry(widget.editingEntry!);
    _selectedVaangunarId = snapshot.selectedVaangunarId;
    _selectedVaangunarPeyarMap = snapshot.selectedVaangunarPeyarMap;
    _selectedVaangunarMunvariMap = snapshot.selectedVaangunarMunvariMap;
    _selectedNiruvanamId = snapshot.selectedNiruvanamId;
    _pattiyalNaal = snapshot.pattiyalNaal;
    _items = snapshot.items.isNotEmpty ? snapshot.items : [const KooliUrupadi()];
    _setharamGrams = snapshot.setharamGrams;
    _thabaalThogai = snapshot.thabaalThogai;
    _ahimsaPattuThogai = snapshot.ahimsaPattuThogai;
    _piraVarivugal = snapshot.piraVarivugal;

    // Load existing bill number for display + override
    _previewBillNumber = widget.editingEntry!.patrucheettuEn;
    _invoiceNumberOverride = widget.editingEntry!.patrucheettuEn;

    _setharamCtrl.text = _setharamGrams > 0 ? _cleanNum(_setharamGrams) : '';
    _thabaalCtrl.text = _thabaalThogai > 0 ? _cleanNum(_thabaalThogai) : '';
    _ahimsaCtrl.text = _ahimsaPattuThogai > 0 ? _cleanNum(_ahimsaPattuThogai) : '';

    // Load profile match + derive prefix
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profiles = ref.read(NiruvanaTharavugalListProvider);
      if (_selectedNiruvanamId != null) {
        final match = profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
        if (match != null) {
          setState(() {
            _selectedProfile = match;
            final shortName = match.kurumPeyar.isNotEmpty ? match.kurumPeyar : 'CB';
            _profilePrefix = '$shortName-';
          });
        }
      }
    });

    _backfillItems();
    _recalculate();
  }

  Future<void> _backfillItems() async {
    final products = await ref.read(porulgalProvider.future);
    bool changed = false;
    final newItems = _items.map((item) {
      if (item.porulPeyarEn.isEmpty && (item.porulId?.isNotEmpty == true)) {
        final product = products.where((p) => p.id.toString() == item.porulId).firstOrNull;
        if (product != null) {
          final enName = product.porulPeyar['en'] ?? ''; // or use a provider if available, but en works
          if (enName.isNotEmpty) {
            changed = true;
            return item.copyWith(porulPeyarEn: enName);
          }
        }
      }
      return item;
    }).toList();
    if (changed && mounted) {
      setState(() => _items = newItems);
    }
  }

  @override
  void dispose() {
    _setharamCtrl.dispose();
    _thabaalCtrl.dispose();
    _ahimsaCtrl.dispose();
    _draftDebounce?.cancel();
    super.dispose();
  }

  /// Clean number display: 100 → '100', 100.5 → '100.5' (no trailing .0)
  static String _cleanNum(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  void _recalculate() {
    setState(() {
      _totals = KooliKanakku.calculate(
        items: _items,
        setharamGrams: _setharamGrams,
        thabaalThogai: _thabaalThogai,
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
    final snapshot = await KooliPattiyalUthavi.tryRestoreDraft(context, ref);
    if (snapshot != null && mounted) {
      setState(() {
        _selectedVaangunarId = snapshot.selectedVaangunarId;
        _selectedVaangunarPeyarMap = snapshot.selectedVaangunarPeyarMap;
        _selectedVaangunarMunvariMap = snapshot.selectedVaangunarMunvariMap;
        _selectedNiruvanamId = snapshot.selectedNiruvanamId;
        _pattiyalNaal = snapshot.pattiyalNaal;
        _items = snapshot.items.isNotEmpty
            ? snapshot.items
            : [const KooliUrupadi()];
        _setharamGrams = snapshot.setharamGrams;
        _thabaalThogai = snapshot.thabaalThogai;
        _ahimsaPattuThogai = snapshot.ahimsaPattuThogai;
        _piraVarivugal = snapshot.piraVarivugal;
        _invoiceNumberOverride = snapshot.invoiceNumberOverride;

        _setharamCtrl.text =
            _setharamGrams > 0 ? _cleanNum(_setharamGrams) : '';
        _thabaalCtrl.text =
            _thabaalThogai > 0 ? _cleanNum(_thabaalThogai) : '';
        _ahimsaCtrl.text =
            _ahimsaPattuThogai > 0 ? _cleanNum(_ahimsaPattuThogai) : '';
      });
      _backfillItems();
      _recalculate();
    }
  }

  /// Builds a snapshot from current state (for draft / save).
  KooliThiruththiNilaimai _currentSnapshot() => KooliThiruththiNilaimai(
        selectedNiruvanamId: _selectedNiruvanamId,
        selectedProfile: _selectedProfile,
        selectedVaangunarId: _selectedVaangunarId,
        selectedVaangunarPeyarMap: _selectedVaangunarPeyarMap,
        selectedVaangunarMunvariMap: _selectedVaangunarMunvariMap,
        pattiyalNaal: _pattiyalNaal,
        items: _items,
        setharamGrams: _setharamGrams,
        thabaalThogai: _thabaalThogai,
        ahimsaPattuThogai: _ahimsaPattuThogai,
        piraVarivugal: _piraVarivugal,
        invoiceNumberOverride: _invoiceNumberOverride,
      );

  // ── Bill Number Preview ──
  Future<void> _computePreviewBillNumber() async {
    if (_isEditing) return;
    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final finYear = KooliPattiyalKalanjiyam.getCurrentFinYear();
      final shortName = (_selectedProfile?.kurumPeyar.isNotEmpty == true
          ? _selectedProfile!.kurumPeyar
          : 'CB');
      _profilePrefix = '$shortName-';
      final vanakkam = await kalanjiyam.getNextVanakkam(_selectedNiruvanamId, finYear,
      );
      if (mounted) {
        setState(() {
          _previewBillNumber =
              kalanjiyam.formatPattiyalEn(shortName, vanakkam);
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    // Unfocus active field → triggers blur commit on ItemFieldWidget
    FocusManager.instance.primaryFocus?.unfocus();
    // Let blur handler run before we read field values
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    if (_selectedProfile == null) {
      ElvanSnackbar.show(context, K.niruvanamThaerodhu.tr(context, ref));
      return;
    }
    if (_selectedVaangunarId == null && _selectedVaangunarPeyarMap.isEmpty) {
      ElvanSnackbar.show(context, K.vaangunaraiThaerodhu.tr(context, ref));
      return;
    }
    final validItems = _items.where((i) => i.edai > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, K.kuriaindhOruPorul.tr(context, ref));
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
          selectedVaangunarId: _selectedVaangunarId,
          selectedVaangunarPeyarMap: _selectedVaangunarPeyarMap,
          selectedVaangunarMunvariMap: _selectedVaangunarMunvariMap,
          pattiyalNaal: _pattiyalNaal,
          items: validItems,
          setharamGrams: _setharamGrams,
          thabaalThogai: _thabaalThogai,
          ahimsaPattuThogai: _ahimsaPattuThogai,
          piraVarivugal: _piraVarivugal,
          invoiceNumberOverride: _invoiceNumberOverride,
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
        ElvanSnackbar.show(
          context,
          K.porulChaemikkappattadhu.tr(context, ref),
          showAboveNavbar: true,
        );
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
    final vaangunargalAsync = ref.watch(vaangunargalProvider);
    final VaangunarTharavuru? selectedVaangunar = vaangunargalAsync.whenOrNull(
      data: (list) => _selectedVaangunarId != null
          ? list.cast<VaangunarTharavuru?>().firstWhere(
                (v) => v!.id == _selectedVaangunarId, orElse: () => null)
          : null,
    );

    return ElvanEditorShell(
      title: _isEditing
          ? K.maatriyamai.tr(context, ref)
          : K.pudhiyaAakkam.tr(context, ref),
      onSave: _saving ? null : _handleSave,
      hasUnsavedChanges: _hasUnsavedChanges,
      onDiscard: () async {
        await KooliPattiyalUthavi.clearDraft();
      },
      child: ElvanThiruthiNiruvanamOadu(
        selectedNiruvanamId: _selectedNiruvanamId,
        onChanged: (p) {
          setState(() {
            _selectedNiruvanamId = p?.id;
            _selectedProfile = p;
            _profilePrefix = p?.kurumPeyar.isNotEmpty == true ? p!.kurumPeyar : 'CB';
            _invoiceNumberOverride = '';
            _hasUnsavedChanges = true;
          });
          _computePreviewBillNumber();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: ① Customer ──
            ElvanEditorSection(
              index: 0,
              title: K.vaangunar.tr(context, ref),
              displayChild: const SizedBox(),
              initiallyExpanded: true,
              children: [
                KooliVaangunarKooru(
                    selectedVaangunarId: _selectedVaangunarId,
                    selectedVaangunarPeyarMap: _selectedVaangunarPeyarMap,
                    selectedVaangunar: selectedVaangunar,
                    onVaangunarSelected: (entry) {
                      setState(() {
                        _selectedVaangunarId = entry.id;
                        _selectedVaangunarPeyarMap = entry.peyar.cast<String, String>();
                        _selectedVaangunarMunvariMap = entry.mugavari.cast<String, String>();
                        _hasUnsavedChanges = true;
                      });
                    },
                    onVaangunarCleared: () {
                      setState(() {
                        _selectedVaangunarId = null;
                        _selectedVaangunarPeyarMap = const {};
                        _selectedVaangunarMunvariMap = const {};
                        _hasUnsavedChanges = true;
                      });
                    },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section 2: ② Invoice Details ──
                    ElvanEditorSection(
                      index: 1,
                      title: K.pattiyalTharavugal.tr(context, ref),
                      displayChild: const SizedBox(),
                      initiallyExpanded: true,
                      children: [
                        ...buildElvanPattiyalTharavugalKooru(
                          context: context,
                          ref: ref,
                          isEditing: _isEditing,
                          invoiceNumberOverride: _invoiceNumberOverride,
                          previewInvoiceNumber: _previewBillNumber,
                          profilePrefix: _profilePrefix,
                          pattiyalNaal: _pattiyalNaal,
                          onInvNumberChanged: (v) {
                            setState(() {
                              _invoiceNumberOverride = v;
                              _hasUnsavedChanges = true;
                            });
                          },
                          onDateChanged: (d) => setState(() {
                            _pattiyalNaal = d;
                            _hasUnsavedChanges = true;
                          }),
                          onDirty: () => setState(() => _hasUnsavedChanges = true),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Section 3: ③ Items ──
                    ElvanEditorSection(
                      index: 2,
                      title: K.porutkal.tr(context, ref),
                      displayChild: const SizedBox(),
                      initiallyExpanded: true,
                      children: [
                        ElvanFullWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedList(
                                key: _itemsListKey,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                initialItemCount: _items.length,
                                itemBuilder: (context, i, animation) {
                                  final curvedAnimation = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutQuart,
                                    reverseCurve: Curves.easeInQuart,
                                  );
                                  return ClipRect(
                                    child: SizeTransition(
                                      sizeFactor: curvedAnimation,
                                      axisAlignment: -1.0,
                                      child: FadeTransition(
                                        opacity: curvedAnimation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, -0.1),
                                            end: Offset.zero,
                                          ).animate(curvedAnimation),
                                          child: KooliUrupadiKooru(
                                            index: i,
                                            item: _items[i],
                                            itemCount: _items.length,
                                            formatter: formatter,
                                            onUpdated: (updated) {
                                              setState(() {
                                                _items = List.from(_items).. [i] = updated;
                                                _hasUnsavedChanges = true;
                                              });
                                              _recalculate();
                                            },
                                            onDeleted: () {
                                              final removedItem = _items[i];
                                              setState(() {
                                                _items = List.from(_items)..removeAt(i);
                                                _hasUnsavedChanges = true;
                                              });
                                              _itemsListKey.currentState?.removeItem(
                                                i,
                                                (context, anim) {
                                                  final curvedAnimation = CurvedAnimation(
                                                    parent: anim,
                                                    curve: Curves.easeOutQuart,
                                                    reverseCurve: Curves.easeInQuart,
                                                  );
                                                  return ClipRect(
                                                    child: SizeTransition(
                                                      sizeFactor: curvedAnimation,
                                                      axisAlignment: -1.0,
                                                      child: FadeTransition(
                                                        opacity: curvedAnimation,
                                                        child: SlideTransition(
                                                          position: Tween<Offset>(
                                                            begin: const Offset(0.0, -0.1),
                                                            end: Offset.zero,
                                                          ).animate(curvedAnimation),
                                                          child: KooliUrupadiKooru(
                                                            index: i,
                                                            item: removedItem,
                                                            itemCount: _items.length + 1,
                                                            formatter: formatter,
                                                            onUpdated: (_) {},
                                                            onDeleted: () {},
                                                            onRequestAddNewProduct: () async {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                duration: const Duration(milliseconds: 250),
                                              );
                                              _recalculate();
                                            },
                                            onRequestAddNewProduct: () async {
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => const CoolieItemEditor()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                              },
                              ),

                              // Other charges item cards
                              if (_piraVarivugal.isNotEmpty)
                              AnimatedList(
                                key: _piraVarivugalListKey,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                initialItemCount: _piraVarivugal.length,
                                itemBuilder: (context, i, animation) {
                                  final curvedAnimation = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutQuart,
                                    reverseCurve: Curves.easeInQuart,
                                  );
                                  return ClipRect(
                                    child: SizeTransition(
                                      sizeFactor: curvedAnimation,
                                      axisAlignment: -1.0,
                                      child: FadeTransition(
                                        opacity: curvedAnimation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, -0.1),
                                            end: Offset.zero,
                                          ).animate(curvedAnimation),
                                          child: KooliPiraVarivuKooru(
                                            index: i,
                                            charge: _piraVarivugal[i],
                                            onUpdated: (updated) {
                                              setState(() {
                                                _piraVarivugal = List.from(_piraVarivugal).. [i] = updated;
                                                _hasUnsavedChanges = true;
                                              });
                                            },
                                            onDeleted: () {
                                              final removedItem = _piraVarivugal[i];
                                              setState(() {
                                                _piraVarivugal = List.from(_piraVarivugal)..removeAt(i);
                                                _hasUnsavedChanges = true;
                                              });
                                              _piraVarivugalListKey.currentState?.removeItem(
                                                i,
                                                (context, anim) {
                                                  final curvedAnimation = CurvedAnimation(
                                                    parent: anim,
                                                    curve: Curves.easeOutQuart,
                                                    reverseCurve: Curves.easeInQuart,
                                                  );
                                                  return ClipRect(
                                                    child: SizeTransition(
                                                      sizeFactor: curvedAnimation,
                                                      axisAlignment: -1.0,
                                                      child: FadeTransition(
                                                        opacity: curvedAnimation,
                                                        child: SlideTransition(
                                                          position: Tween<Offset>(
                                                            begin: const Offset(0.0, -0.1),
                                                            end: Offset.zero,
                                                          ).animate(curvedAnimation),
                                                          child: KooliPiraVarivuKooru(
                                                            index: i,
                                                            charge: removedItem,
                                                            onUpdated: (_) {},
                                                            onDeleted: () {},
                                                            onRecalculate: () {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                duration: const Duration(milliseconds: 250),
                                              );
                                              _recalculate();
                                            },
                                            onRecalculate: _recalculate,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                              },
                              ),

                              const SizedBox(height: 8),

                              // Pill buttons row
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  kooliPillButton(context,
                                    icon: Icons.add,
                                    label: K.chaerPtn.tr(context, ref),
                                    onPressed: () => setState(() {
                                      _items = [..._items, const KooliUrupadi()];
                                      _itemsListKey.currentState?.insertItem(
                                        _items.length - 1,
                                        duration: const Duration(milliseconds: 250),
                                      );
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
                                        _piraVarivugalListKey.currentState?.insertItem(
                                          _piraVarivugal.length - 1,
                                          duration: const Duration(milliseconds: 250),
                                        );
                                        _hasUnsavedChanges = true;
                                      }),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Section 4: ④ Totals ──
                    ElvanEditorSection(
                      index: 3,
                      title: K.mothangal.tr(context, ref),
                      displayChild: const SizedBox(),
                      initiallyExpanded: true,
                      children: [
                        ElvanFullWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Extra Charges Bento Grid ──
                              KooliMelthogaiKooru(
                                setharamCtrl: _setharamCtrl,
                                ahimsaCtrl: _ahimsaCtrl,
                                thabaalCtrl: _thabaalCtrl,
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
                                onThabaalChanged: (v) {
                                  _thabaalThogai = double.tryParse(v) ?? 0;
                                  _hasUnsavedChanges = true;
                                  _recalculate();
                                },
                              ),

                              const SizedBox(height: 24),

                              // ── Totals Card ──
                              KooliMothangalKooru(
                                totals: _totals,
                                setharamGrams: _setharamGrams,
                                ahimsaPattuThogai: _ahimsaPattuThogai,
                                thabaalThogai: _thabaalThogai,
                                piraVarivugal: _piraVarivugal,
                                formatter: formatter,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
