import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

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

  const SilkInvoiceEditor({super.key, this.editingEntry});

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
  bool _saving = false;

  bool get _isEditing => widget.editingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEditingData();
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

    // Load settings JSON for global discount
    try {
      final settings = jsonDecode(e.sonthaViruppangal) as Map<String, dynamic>;
      _globalDiscountValue = (settings['globalDiscountValue'] as num?)?.toDouble() ?? 0;
      _globalDiscountType = settings['globalDiscountType'] as String? ?? 'percentage';
      _globalDiscountController.text = _globalDiscountValue > 0 ? _globalDiscountValue.toString() : '';
    } catch (_) {}

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
    _termsController.dispose();
    _notesController.dispose();
    _globalDiscountController.dispose();
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

    setState(() {
      _totals = PattuKanakku.calculate(
        items: _items,
        globalDiscountValue: _globalDiscountValue,
        globalDiscountType: _globalDiscountType,
        businessState: businessState,
        customerState: _customerState,
        country: country,
      );
    });
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

      // Settings JSON
      final settingsJson = jsonEncode({
        'globalDiscountValue': _globalDiscountValue,
        'globalDiscountType': _globalDiscountType,
      });

      if (_isEditing) {
        // Update existing
        await kalanjiyam.updatePattiyal(
          widget.editingEntry!.id,
          PatrucheettuTableCompanion(
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
        // Create new — get next number
        final vanakkam = await kalanjiyam.getNextVanakkam('silk', _selectedNiruvanamId, finYear);
        final invoiceNumber = kalanjiyam.formatPattiyalEn(prefix, vanakkam);

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
                    });
                    _recalculate();
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
                          Text(
                            _selectedVanigarPeyar,
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (selectedVanigar.gstin.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'GSTIN: ${selectedVanigar.gstin}',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                          if ((selectedVanigar.maanilam['English'] ??
                                      selectedVanigar.maanilam['Tamil'] ??
                                      '')
                                  .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              selectedVanigar.maanilam['English'] ??
                                  selectedVanigar.maanilam['Tamil'] ??
                                  '',
                              style: tt.bodySmall?.copyWith(
                                color: cs.outline,
                              ),
                            ),
                          ],
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
                Text(
                  'Invoice Number',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                ElvanThiruthiAttai(
                  child: Text(
                    _isEditing
                        ? (widget.editingEntry!.patrucheettuEn)
                        : 'Auto-generated on save',
                    style: tt.bodyLarge?.copyWith(
                      color: _isEditing ? cs.onSurface : cs.onSurfaceVariant,
                      fontWeight:
                          _isEditing ? FontWeight.w600 : FontWeight.w400,
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
              onChanged: (v) =>
                  setState(() => _pattiyalVagai = v ?? 'tax-invoice'),
            ),
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────────────
          // Terms & Notes
          // ─────────────────────────────────────────────────────────────────
          ElvanThiruthiAttai(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Notes',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _termsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Terms & Conditions',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => _nibandhanaigal = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Internal Note',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => _ullkurippu = v,
                ),
              ],
            ),
          ),
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
    final rowTotal = item.adippadaiThogai - item.thallupadiThogai;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: "Item #N" + trash icon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  'Item #${index + 1}',
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
              );

              // Build field widgets
              final qtyField = _itemField('Qty', item.alavu, (v) {
                _updateItem(
                    index, item.copyWith(alavu: double.tryParse(v) ?? 0));
              });

              final unitDropdown = DropdownButtonFormField<String>(
                initialValue: item.alagu,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'Nos', child: Text('Nos')),
                  DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                  DropdownMenuItem(value: 'Mtr', child: Text('Mtr')),
                  DropdownMenuItem(value: 'Pcs', child: Text('Pcs')),
                ],
                onChanged: (v) =>
                    _updateItem(index, item.copyWith(alagu: v ?? 'Nos')),
              );

              final rateField = _itemField('Rate', item.vilai, (v) {
                _updateItem(
                    index, item.copyWith(vilai: double.tryParse(v) ?? 0));
              });

              final taxField =
                  _itemField('Tax %', item.variVizhukkaadu, (v) {
                _updateItem(index,
                    item.copyWith(variVizhukkaadu: double.tryParse(v) ?? 0));
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

              if (isWide) {
                // Desktop: bento wrap layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    productSearch,
                    vGap,
                    Row(
                      children: [
                        Expanded(child: qtyField),
                        gap,
                        Expanded(child: unitDropdown),
                        gap,
                        Expanded(child: rateField),
                      ],
                    ),
                    vGap,
                    Row(
                      children: [
                        Expanded(child: taxField),
                        gap,
                        Expanded(child: discField),
                        gap,
                        Expanded(child: totalDisplay),
                      ],
                    ),
                  ],
                );
              }

              // Mobile: stacked
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productSearch,
                  vGap,
                  Row(children: [
                    Expanded(child: qtyField),
                    gap,
                    Expanded(child: unitDropdown),
                  ]),
                  vGap,
                  Row(children: [
                    Expanded(child: rateField),
                    gap,
                    Expanded(child: taxField),
                  ]),
                  vGap,
                  discField,
                  vGap,
                  totalDisplay,
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Borderless numeric field used inside item cards.
  Widget _itemField(
      String label, double value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value == 0 ? '' : value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        isDense: true,
      ),
      onChanged: onChanged,
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
        },
      ),
    );
  }
}
