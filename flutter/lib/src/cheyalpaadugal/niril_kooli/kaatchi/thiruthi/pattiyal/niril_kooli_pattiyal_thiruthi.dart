import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';
import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kanakku.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal.dart';

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
  VanigaTharavugal? _selectedProfile;

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

  // ── Totals ──
  KooliMothangal _totals = const KooliMothangal();

  // ── Controllers ──
  final _setharamCtrl = TextEditingController();
  final _thapaalCtrl = TextEditingController();
  final _ahimsaCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEditingData();
    }
    // Auto-select first profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing) {
        final profiles = ref.read(vanigaTharavugalListProvider);
        if (profiles.isNotEmpty) {
          setState(() {
            _selectedProfile = profiles.first;
            _selectedNiruvanamId = profiles.first.id;
          });
        }
      }
    });
  }

  void _loadEditingData() {
    final e = widget.editingEntry!;
    _selectedVanigarId = e.vanigarId;
    _selectedVanigarPeyar = e.vanigarPeyar;
    _selectedNiruvanamId = e.niruvanamId;
    _pattiyalNaal = e.pattiyalNaal;

    // Load items
    _items = PattiyalUthavigal.kooliListFromJson(e.tharavugal);
    if (_items.isEmpty) _items = [const KooliUrupadi()];

    // Load charges
    _setharamGrams = e.setharamGrams;
    _thapaalThogai = e.thapaalThogai;
    _ahimsaPattuThogai = e.ahimsaPattuThogai;
    _piraVarivugal = PattiyalUthavigal.piraVarivuListFromJson(e.piravariVugal);

    _setharamCtrl.text = _setharamGrams > 0 ? _setharamGrams.toString() : '';
    _thapaalCtrl.text = _thapaalThogai > 0 ? _thapaalThogai.toString() : '';
    _ahimsaCtrl.text = _ahimsaPattuThogai > 0 ? _ahimsaPattuThogai.toString() : '';

    // Load profile match
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profiles = ref.read(vanigaTharavugalListProvider);
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
  }

  Future<void> _handleSave() async {
    if (_selectedProfile == null) {
      ElvanSnackbar.show(context, 'Select a company profile');
      return;
    }
    if (_selectedVanigarId == null && _selectedVanigarPeyar.isEmpty) {
      ElvanSnackbar.show(context, 'Select a customer');
      return;
    }
    final validItems = _items.where((i) => i.edai > 0 && i.vilai > 0).toList();
    if (validItems.isEmpty) {
      ElvanSnackbar.show(context, 'Add at least one item');
      return;
    }

    setState(() => _saving = true);

    try {
      final kalanjiyam = ref.read(pattiyalKalanjiyamProvider);
      final finYear = PattiyalKalanjiyam.getCurrentFinYear();
      final prefix = _selectedProfile!.kurumPeyar.isNotEmpty ? _selectedProfile!.kurumPeyar : 'CB';

      // Bank snapshot from profile
      final bankSnapshot = jsonEncode({
        'vangiPeyar': _selectedProfile!.vangiPeyar,
        'kilai': _selectedProfile!.kilai,
        'vangiKanakku': _selectedProfile!.vangiKanakku,
        'ifsc': _selectedProfile!.ifsc,
        'upiId': _selectedProfile!.upiId,
      });

      if (_isEditing) {
        await kalanjiyam.updatePattiyal(
          widget.editingEntry!.id,
          PatrucheettuTableCompanion(
            vanigarId: Value(_selectedVanigarId),
            vanigarPeyar: Value(_selectedVanigarPeyar),
            niruvanamId: Value(_selectedNiruvanamId),
            pattiyalNaal: Value(_pattiyalNaal),
            tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
            mothaThogai: Value(_totals.perumMothangal),
            mothaEdai: Value(_totals.mothaEdai),
            setharamGrams: Value(_setharamGrams),
            thapaalThogai: Value(_thapaalThogai),
            ahimsaPattuThogai: Value(_ahimsaPattuThogai),
            piravariVugal: Value(PattiyalUthavigal.piraVarivuListToJson(_piraVarivugal)),
            vangiTharavugal: Value(bankSnapshot),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        final vanakkam = await kalanjiyam.getNextVanakkam('coolie', _selectedNiruvanamId, finYear);
        final billNumber = kalanjiyam.formatPattiyalEn(prefix, vanakkam);

        await kalanjiyam.createPattiyal(
          PatrucheettuTableCompanion.insert(
            seyaliVagai: 'coolie',
            patrucheettuEn: billNumber,
            finYear: finYear,
            vanakkam: Value(vanakkam),
            niruvanamId: Value(_selectedNiruvanamId),
            vanigarPeyar: _selectedVanigarPeyar,
            vanigarId: Value(_selectedVanigarId),
            pattiyalNaal: Value(_pattiyalNaal),
            tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
            mothaThogai: Value(_totals.perumMothangal),
            mothaEdai: Value(_totals.mothaEdai),
            setharamGrams: Value(_setharamGrams),
            thapaalThogai: Value(_thapaalThogai),
            ahimsaPattuThogai: Value(_ahimsaPattuThogai),
            piravariVugal: Value(PattiyalUthavigal.piraVarivuListToJson(_piraVarivugal)),
            vangiTharavugal: Value(bankSnapshot),
          ),
        );
      }

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
  // BUILD — React CoolieInvoiceEditor.tsx layout
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profiles = ref.watch(vanigaTharavugalListProvider);
    final formatter = NumberFormat('#,##0', 'en_IN');

    return ElvanEditorShell(
      title: _isEditing
          ? K.koolipattiyalthiruthi.tr(context, ref)
          : K.pudhiyaKoolipPattiyal.tr(context, ref),
      onSave: _saving ? null : _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────────────────────────────────────────
          // Section 1: ① Customer
          // ─────────────────────────────────────────────────────────────────
          const ElvanPagudhiThalaipu(en: 1, thalaipu: 'Customer'),
          LayoutBuilder(builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 600;
            final customerColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption: Client Name
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 6),
                  child: Text('Client Name',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      )),
                ),
                VanigarThaeduKooru(
                  seyaliVagai: 'coolie',
                  selectedId: _selectedVanigarId,
                  onSelected: (entry) {
                    setState(() {
                      _selectedVanigarId = entry.id;
                      _selectedVanigarPeyar =
                          entry.peyar['Tamil'] ?? entry.peyar['English'] ?? '';
                    });
                  },
                ),
                // Saved details card when customer selected
                if (_selectedVanigarPeyar.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ElvanThiruthiAttai(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SAVED DETAILS',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.2,
                            )),
                        const SizedBox(height: 8),
                        Text(_selectedVanigarPeyar,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            );

            final companyColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 6),
                  child: Text('Company',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      )),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _selectedNiruvanamId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  items: profiles.map((p) {
                    final name = p.niruvanathinPeyar['Tamil'] ??
                        p.niruvanathinPeyar['English'] ??
                        'Company';
                    return DropdownMenuItem(value: p.id, child: Text(name));
                  }).toList(),
                  onChanged: (v) {
                    final match =
                        profiles.where((p) => p.id == v).firstOrNull;
                    setState(() {
                      _selectedNiruvanamId = v;
                      _selectedProfile = match;
                    });
                  },
                ),
              ],
            );

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: customerColumn),
                  const SizedBox(width: 24),
                  Expanded(flex: 7, child: companyColumn),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [customerColumn, companyColumn],
            );
          }),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Disabled wrapper when no company selected
          // ─────────────────────────────────────────────────────────────────
          Opacity(
            opacity: _selectedNiruvanamId == null ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _selectedNiruvanamId == null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────────────────────────────────────────────────────────
                  // Section 2: ② Invoice Details
                  // ───────────────────────────────────────────────────────────
                  const ElvanPagudhiThalaipu(en: 2, thalaipu: 'Invoice Details'),
                  LayoutBuilder(builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 600;
                    final billField = TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Bill No.',
                        hintText: 'Auto-generated',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    );
                    final dateField = PattiyalNaalKooru(
                      selectedDate: _pattiyalNaal,
                      onDateChanged: (d) =>
                          setState(() => _pattiyalNaal = d),
                    );

                    if (isDesktop) {
                      return Row(
                        children: [
                          Expanded(child: billField),
                          const SizedBox(width: 16),
                          dateField,
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        billField,
                        const SizedBox(height: 12),
                        Align(alignment: Alignment.centerRight, child: dateField),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // Section 3: ③ Items
                  // ───────────────────────────────────────────────────────────
                  const ElvanPagudhiThalaipu(en: 3, thalaipu: 'Items'),
                  ...List.generate(
                      _items.length, (i) => _buildItemRow(i, formatter)),

                  // Other charges item cards
                  ...List.generate(
                      _piraVarivugal.length, (i) => _buildPiraVarivuRow(i)),

                  const SizedBox(height: 12),

                  // Pill buttons row
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _pillButton(
                        icon: Icons.add_rounded,
                        label: 'Add Item',
                        onPressed: () => setState(
                            () => _items = [..._items, const KooliUrupadi()]),
                      ),
                      if (_piraVarivugal.isEmpty)
                        _pillButton(
                          icon: Icons.add_rounded,
                          label: 'Add Other Charges',
                          onPressed: () => setState(() => _piraVarivugal = [
                                ..._piraVarivugal,
                                const PiraVarivu()
                              ]),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // Extra Charges Bento Grid (no section badge)
                  // ───────────────────────────────────────────────────────────
                  LayoutBuilder(builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 600;
                    final gap = 12.0;

                    if (isDesktop) {
                      // 3-column grid
                      final colWidth =
                          (constraints.maxWidth - gap * 2) / 3;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                              width: colWidth,
                              child: _chargeField(
                                  'Setharam (grams)', _setharamCtrl, (v) {
                                _setharamGrams = double.tryParse(v) ?? 0;
                                _recalculate();
                              })),
                          SizedBox(
                              width: colWidth,
                              child: _chargeField(
                                  'Ahimsa Silk (₹)', _ahimsaCtrl, (v) {
                                _ahimsaPattuThogai =
                                    double.tryParse(v) ?? 0;
                                _recalculate();
                              })),
                          SizedBox(
                              width: colWidth,
                              child: _chargeField(
                                  'Courier (₹)', _thapaalCtrl, (v) {
                                _thapaalThogai = double.tryParse(v) ?? 0;
                                _recalculate();
                              })),
                        ],
                      );
                    }
                    // 2-column mobile: setharam full width, others half
                    final halfWidth = (constraints.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                            width: constraints.maxWidth,
                            child: _chargeField(
                                'Setharam (grams)', _setharamCtrl, (v) {
                              _setharamGrams = double.tryParse(v) ?? 0;
                              _recalculate();
                            })),
                        SizedBox(
                            width: halfWidth,
                            child: _chargeField(
                                'Ahimsa Silk (₹)', _ahimsaCtrl, (v) {
                              _ahimsaPattuThogai =
                                  double.tryParse(v) ?? 0;
                              _recalculate();
                            })),
                        SizedBox(
                            width: halfWidth,
                            child: _chargeField(
                                'Courier (₹)', _thapaalCtrl, (v) {
                              _thapaalThogai = double.tryParse(v) ?? 0;
                              _recalculate();
                            })),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // Bank Details
                  // ───────────────────────────────────────────────────────────
                  if (_selectedProfile != null)
                    ElvanThiruthiAttai(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Show Bank Details'),
                            value: _showBankDetails,
                            onChanged: (v) =>
                                setState(() => _showBankDetails = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_showBankDetails) ...[
                            const Divider(),
                            _bankRow('Bank', _selectedProfile!.vangiPeyar),
                            _bankRow('Branch', _selectedProfile!.kilai),
                            _bankRow('A/C No', _selectedProfile!.vangiKanakku),
                            _bankRow('IFSC', _selectedProfile!.ifsc),
                            if (_selectedProfile!.upiId.isNotEmpty)
                              _bankRow('UPI', _selectedProfile!.upiId),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ───────────────────────────────────────────────────────────
                  // Totals Card
                  // ───────────────────────────────────────────────────────────
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ElvanThiruthiAttai(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Sub Total
                          _totalsRow(
                            'Sub Total',
                            '₹${formatter.format(_totals.adippadaiMothangal)}',
                            labelWeight: FontWeight.w600,
                            labelColor: cs.onSurfaceVariant,
                            valueWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 12),
                          // Ahimsa Silk (conditional)
                          if (_ahimsaPattuThogai > 0) ...[
                            _totalsRow(
                              'Ahimsa Silk',
                              '₹${formatter.format(_ahimsaPattuThogai)}',
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Courier (conditional)
                          if (_thapaalThogai > 0) ...[
                            _totalsRow(
                              'Courier',
                              '₹${formatter.format(_thapaalThogai)}',
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Dynamic other charges
                          for (final charge in _piraVarivugal)
                            if (charge.thogai > 0) ...[
                              _totalsRow(
                                charge.peyar.isNotEmpty
                                    ? charge.peyar
                                    : 'Other',
                                '₹${formatter.format(charge.thogai)}',
                              ),
                              const SizedBox(height: 12),
                            ],
                          // Total Weight
                          _totalsRow(
                            'Total Weight',
                            '${_totals.mothaEdai.toStringAsFixed(3)} Kg',
                            labelWeight: FontWeight.w600,
                            valueWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 12),
                          // Setharam (conditional)
                          if (_setharamGrams > 0) ...[
                            _totalsRow(
                              '+ Setharam',
                              '${_setharamGrams.toStringAsFixed(1)} g',
                            ),
                            const SizedBox(height: 12),
                          ],
                          const Divider(),
                          const SizedBox(height: 12),
                          // Grand Total
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: tt.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  )),
                              Text(
                                '₹${formatter.format(_totals.perumMothangal)}',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Builds a single line-item row: header label + delete + ElvanUrupadiAttai.
  Widget _buildItemRow(int index, NumberFormat fmt) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final item = _items[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Item #N header + trash
          Row(
            children: [
              Text('Item #${index + 1}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: cs.error, size: 20),
                  onPressed: () {
                    setState(
                        () => _items = List.from(_items)..removeAt(index));
                    _recalculate();
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Product search — wider
                SizedBox(
                  width: 280,
                  child: PorulThaeduKooru(
                    seyaliVagai: 'coolie',
                    initialText: item.porulPeyar,
                    onSelected: (p) {
                      final updated = item.copyWith(
                        porulId: p.id.toString(),
                        porulPeyar: p.porulPeyar['Tamil'] ??
                            p.porulPeyar['English'] ??
                            '',
                        vilai: p.vilai,
                      );
                      setState(
                          () => _items = List.from(_items)..[index] = updated);
                      _recalculate();
                    },
                  ),
                ),
                // Weight
                SizedBox(
                  width: 120,
                  child: _numField('KG', item.edai, (v) {
                    _updateCoolieItem(
                        index, item.copyWith(edai: double.tryParse(v) ?? 0));
                  }),
                ),
                // Rate
                SizedBox(
                  width: 120,
                  child: _numField('Rate/KG', item.vilai, (v) {
                    _updateCoolieItem(
                        index, item.copyWith(vilai: double.tryParse(v) ?? 0));
                  }),
                ),
                // Row total (read-only)
                SizedBox(
                  width: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('₹${fmt.format(item.varisaiThogai)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateCoolieItem(int index, KooliUrupadi updated) {
    setState(() => _items = List.from(_items)..[index] = updated);
    _recalculate();
  }

  /// Builds a dynamic "other charge" row inside an ElvanUrupadiAttai.
  Widget _buildPiraVarivuRow(int index) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final charge = _piraVarivugal[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text('Other Charge #${index + 1}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: cs.error, size: 20),
                onPressed: () {
                  setState(() =>
                      _piraVarivugal = List.from(_piraVarivugal)..removeAt(index));
                  _recalculate();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: charge.peyar,
                    decoration: const InputDecoration(
                      hintText: 'Charge Name',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _piraVarivugal = List.from(_piraVarivugal)
                          ..[index] = charge.copyWith(peyar: v);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        charge.thogai > 0 ? charge.thogai.toString() : '',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '₹',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _piraVarivugal = List.from(_piraVarivugal)
                          ..[index] =
                              charge.copyWith(thogai: double.tryParse(v) ?? 0);
                      });
                      _recalculate();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact borderless number field for use inside item cards.
  Widget _numField(
      String label, double value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value > 0 ? value.toString() : '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  /// Extra-charge field wrapped in an ElvanThiruthiAttai (borderRadius 16).
  Widget _chargeField(
      String label, TextEditingController ctrl, ValueChanged<String> onChanged) {
    return ElvanThiruthiAttai(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }

  /// Bank detail key-value row.
  Widget _bankRow(String label, dynamic value) {
    String text = '';
    if (value is Map) {
      text = (value['Tamil'] ?? value['English'] ?? '').toString();
    } else {
      text = value?.toString() ?? '';
    }
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                )),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  /// Pill-shaped text button (borderRadius 24).
  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  /// Totals summary row (label | value).
  Widget _totalsRow(
    String label,
    String value, {
    FontWeight? labelWeight,
    FontWeight? valueWeight,
    Color? labelColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: labelWeight ?? FontWeight.w500,
              color: labelColor,
            )),
        Text(value,
            style: TextStyle(
              fontWeight: valueWeight ?? FontWeight.w600,
            )),
      ],
    );
  }
}

