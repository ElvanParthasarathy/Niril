

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;


import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';
import '../../../niril_podhu/kalanjiyam/patru_kalanjiyam.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import 'koorugal/patru_pattiyal_theervu_maeladukku.dart';


/// Shared Receipt Editor — used by both Coolie and Silk modes.
/// Three sections: ① Invoice picker, ② Receipt data, ③ Payment details.
class PatruThiruthi extends ConsumerStatefulWidget {
  final PatrugalEntry? editingEntry;

  const PatruThiruthi({super.key, this.editingEntry});

  @override
  ConsumerState<PatruThiruthi> createState() => _PatruThiruthiState();
}

class _PatruThiruthiState extends ConsumerState<PatruThiruthi> {
  // ── Company Profile ──
  int? _selectedNiruvanamId;
  NiruvanaTharavugalEntry? _selectedProfile;

  // ── Customer ──
  int? _selectedVanigarId;
  String _vanigarPeyar = '';
  String _vanigarMunvari = '';

  // ── Receipt Data ──
  DateTime _patruNaal = DateTime.now();
  String _patruEn = '';
  int _vanakkam = 1;

  // ── Payment ──
  double _thogai = 0.0;
  SeluthiVagai? _seluthiVagai;
  String _suttruEn = '';
  String _ullkurippu = '';

  // ── Linked Invoices ──
  List<PatrucheettuEntry> _selectedInvoices = [];
  Map<int, double> _invoicePaidAmounts = {};

  // ── Controllers ──
  final _thogaiCtrl = TextEditingController();
  final _suttruEnCtrl = TextEditingController();
  final _ullkurippuCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;
  bool _paidAmountsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLinkedInvoices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_paidAmountsLoaded) {
      _paidAmountsLoaded = true;
      _loadPaidAmounts();
    }
  }

  void _initializeForm() {
    final entry = widget.editingEntry;
    if (entry != null) {
      _selectedNiruvanamId = entry.niruvanamId;
      _selectedVanigarId = entry.vanigarId;
      _vanigarPeyar = entry.vanigarPeyar;
      _vanigarMunvari = entry.vanigarMunvari;
      _patruNaal = entry.patruNaal;
      _patruEn = entry.patruEn;
      _vanakkam = entry.vanakkam;
      _thogai = entry.thogai;
      _seluthiVagai = SeluthiVagaiX.fromStored(entry.seluthiVagai);
      _suttruEn = entry.suttruEn;
      _ullkurippu = entry.ullkurippu;

      _thogaiCtrl.text = _thogai > 0 ? _thogai.toStringAsFixed(2) : '';
      _suttruEnCtrl.text = _suttruEn;
      _ullkurippuCtrl.text = _ullkurippu;
    }
  }

  @override
  void dispose() {
    _thogaiCtrl.dispose();
    _suttruEnCtrl.dispose();
    _ullkurippuCtrl.dispose();
    super.dispose();
  }

  // ── Load linked invoices for editing ──
  Future<void> _loadLinkedInvoices() async {
    if (widget.editingEntry == null || _isInitialized) return;
    _isInitialized = true;

    final kalanjiyam = ref.read(patruKalanjiyamProvider);
    final links = await kalanjiyam.getLinksForPatru(widget.editingEntry!.id);
    final pattiyalKal = ref.read(pattiyalKalanjiyamProvider);

    final invoices = <PatrucheettuEntry>[];
    for (final link in links) {
      final inv = await pattiyalKal.getById(link.pattiyalId);
      if (inv != null) invoices.add(inv);
    }

    if (mounted) {
      setState(() => _selectedInvoices = invoices);
    }
  }

  // ── Auto-assign profile ──
  void _autoAssignProfile(List<NiruvanaTharavugalEntry> profiles) {
    if (_selectedProfile != null) return;
    if (profiles.isEmpty) return;

    if (widget.editingEntry != null && _selectedNiruvanamId != null) {
      final match =
          profiles.where((p) => p.id == _selectedNiruvanamId).firstOrNull;
      if (match != null) {
        _selectedProfile = match;
        return;
      }
    }

    // Auto-select first profile
    _selectedProfile = profiles.first;
    _selectedNiruvanamId = profiles.first.id;
  }

  // ── Auto-generate receipt number ──
  Future<void> _generatePatruEn() async {
    if (widget.editingEntry != null) return; // Don't regenerate for edits

    final kalanjiyam = ref.read(patruKalanjiyamProvider);
    final mode = ref.read(appModeProvider);
    final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';

    final bizShort =
        (_selectedProfile?.kurumPeyar.isNotEmpty == true
            ? _selectedProfile!.kurumPeyar
            : 'BIZ').toUpperCase();
    _vanakkam =
        await kalanjiyam.getNextVanakkam(seyaliVagai, _selectedNiruvanamId);
    _patruEn = kalanjiyam.formatPatruEn(bizShort, _vanakkam);

    if (mounted) setState(() {});
  }

  // ── Save ──
  Future<void> _handleSave() async {
    // Validation
    if (_vanigarPeyar.trim().isEmpty) {
      ElvanSnackbar.show(context, 'வாடிக்கையாளர் பெயர் தேவை');
      return;
    }
    if (_thogai <= 0) {
      ElvanSnackbar.show(context, 'தொகை 0-ஐ விட அதிகமாக இருக்க வேண்டும்');
      return;
    }
    if (_seluthiVagai == null) {
      ElvanSnackbar.show(context, 'செலுத்தி வகையைத் தேர்ந்தெடுக்கவும்');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final kalanjiyam = ref.read(patruKalanjiyamProvider);
      final mode = ref.read(appModeProvider);
      final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';

      // Build junction links — distribute amount across invoices (oldest first)
      final links = <PatruPattiyalLink>[];
      double remaining = _thogai;

      for (final inv in _selectedInvoices) {
        if (remaining <= 0) break;

        final paidAlready = _invoicePaidAmounts[inv.id] ?? 0.0;
        // When editing, exclude current receipt's contribution
        double adjustedPaid = paidAlready;
        if (widget.editingEntry != null) {
          final existingLinks =
              await kalanjiyam.getLinksForPatru(widget.editingEntry!.id);
          for (final el in existingLinks) {
            if (el.pattiyalId == inv.id) {
              adjustedPaid -= el.poruthiyaThogai;
            }
          }
        }

        final balance = (inv.mothaThogai - adjustedPaid).clamp(0.0, double.infinity);
        final apply = remaining.clamp(0.0, balance);

        if (apply > 0) {
          links.add(PatruPattiyalLink(
            pattiyalId: inv.id,
            poruthiyaThogai: apply,
          ));
          remaining -= apply;
        }
      }

      // Validate links
      final validationError = await kalanjiyam.validateLinks(
        links,
        excludePatruId: widget.editingEntry?.id,
      );
      if (validationError != null) {
        if (mounted) {
          ElvanSnackbar.show(context, validationError);
          setState(() => _isSaving = false);
        }
        return;
      }

      // Build receipt companion
      final companion = PatrugalTableCompanion(
        seyaliVagai: Value(seyaliVagai),
        niruvanamId: Value(_selectedNiruvanamId),
        patruEn: Value(_patruEn),
        vanakkam: Value(_vanakkam),
        vanigarId: Value(_selectedVanigarId),
        vanigarPeyar: Value(_vanigarPeyar),
        vanigarMunvari: Value(_vanigarMunvari),
        patruNaal: Value(_patruNaal),
        thogai: Value(_thogai),
        seluthiVagai: Value(_seluthiVagai!.storedValue),
        suttruEn: Value(_seluthiVagai!.needsReference ? _suttruEn : ''),
        ullkurippu: Value(_ullkurippu),
        updatedAt: Value(DateTime.now()),
      );

      if (widget.editingEntry != null) {
        await kalanjiyam.updatePatru(
            widget.editingEntry!.id, companion, links);
      } else {
        await kalanjiyam.insertPatru(companion, links);
      }

      if (mounted) {
        ElvanSnackbar.show(context, 'பற்றுச்சீட்டு சேமிக்கப்பட்டது');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ElvanSnackbar.show(context, 'சேமிக்க இயலவில்லை: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(currentModeProfilesStreamProvider);
    final invoicesAsync = ref.watch(pattiyalgalStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = ref.watch(appModeProvider);
    final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';

    // Auto-assign profile
    profilesAsync.whenData((profiles) {
      _autoAssignProfile(profiles);
      if (widget.editingEntry == null && _patruEn.isEmpty) {
        _generatePatruEn();
      }
    });



    final isEditing = widget.editingEntry != null;
    final title = isEditing ? 'பற்றுச்சீட்டுத் திருத்து' : 'புதிய பற்றுச்சீட்டு';

    return ElvanEditorShell(
      title: title,
      onSave: _isSaving ? null : _handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Profile Switcher (if 2+ profiles) ──
          profilesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (profiles) {
              if (profiles.length < 2) return const SizedBox.shrink();
              return _buildProfileSwitcher(profiles, isDark);
            },
          ),

          // ── Section 1: Against Invoice ──
          const ElvanPagudhiThalaipu(en: 1, thalaipu: 'எந்தப் பட்டியலுக்கு'),
          ElvanThiruthiAttai(
            child: _buildInvoicePickerSection(invoicesAsync, isDark),
          ),
          const SizedBox(height: 24),

          // ── Section 2: Receipt Data ──
          const ElvanPagudhiThalaipu(en: 2, thalaipu: 'பற்றுச்சீட்டு தரவுகள்'),
          ElvanThiruthiAttai(
            child: _buildReceiptDataSection(seyaliVagai, isDark),
          ),
          const SizedBox(height: 24),

          // ── Section 3: Payment Details ──
          const ElvanPagudhiThalaipu(en: 3, thalaipu: 'செலுத்திய விவரம்'),
          ElvanThiruthiAttai(
            child: _buildPaymentSection(isDark),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Profile Switcher ──
  Widget _buildProfileSwitcher(List<NiruvanaTharavugalEntry> profiles, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: profiles.map((p) {
            final isActive = p.id == _selectedNiruvanamId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.kurumPeyar.isNotEmpty ? p.kurumPeyar : (p.niruvanathinPeyar.values.firstOrNull ?? '')),
                selected: isActive,
                onSelected: (_) {
                  setState(() {
                    _selectedNiruvanamId = p.id;
                    _selectedProfile = p;
                  });
                  _generatePatruEn();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Section 1: Invoice Picker ──
  Widget _buildInvoicePickerSection(
      AsyncValue<List<PatrucheettuEntry>> invoicesAsync, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Select Invoices" button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showInvoicePickerDialog(invoicesAsync),
            icon: const Icon(CupertinoIcons.doc_text, size: 18),
            label: Text(
              _selectedInvoices.isEmpty
                  ? 'பட்டியலைத் தேர்ந்தெடு'
                  : '${_selectedInvoices.length} பட்டியல்கள்',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              foregroundColor: isDark ? Colors.white : Colors.black87,
              elevation: 0,
            ),
          ),
        ),

        // Selected invoice chips
        if (_selectedInvoices.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedInvoices.map((inv) {
              return Chip(
                label: Text(inv.patrucheettuEn,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                deleteIcon: const Icon(CupertinoIcons.xmark, size: 14),
                onDeleted: () {
                  setState(() {
                    _selectedInvoices.remove(inv);
                    _recalculateAmount();
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Section 2: Receipt Data ──
  Widget _buildReceiptDataSection(String seyaliVagai, bool isDark) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Date picker
        SizedBox(
          width: isDesktop ? 280 : double.infinity,
          child: PattiyalNaalKooru(
            selectedDate: _patruNaal,
            onDateChanged: (date) => setState(() => _patruNaal = date),
          ),
        ),
        // Customer picker
        SizedBox(
          width: isDesktop ? 380 : double.infinity,
          child: VanigarThaeduKooru(
            seyaliVagai: seyaliVagai,
            selectedId: _selectedVanigarId,
            onSelected: (vanigar) {
              setState(() {
                _selectedVanigarId = vanigar.id;
                final peyarMap = vanigar.peyar;
                _vanigarPeyar =
                    peyarMap['Tamil'] ?? peyarMap['English'] ?? peyarMap.values.firstOrNull ?? '';
                final mugavariMap = vanigar.mugavari;
                _vanigarMunvari = [
                  mugavariMap['Tamil'] ?? mugavariMap['English'] ?? '',
                  vanigar.oor['Tamil'] ?? vanigar.oor['English'] ?? '',
                ].where((s) => s.isNotEmpty).join(', ');
              });
            },
          ),
        ),
        // Receipt number (read-only display)
        if (_patruEn.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.number, size: 16,
                    color: isDark ? Colors.white38 : Colors.black38),
                const SizedBox(width: 8),
                Text(
                  _patruEn,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Section 3: Payment Details ──
  Widget _buildPaymentSection(bool isDark) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Amount field
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: TextField(
                controller: _thogaiCtrl,
                decoration: InputDecoration(
                  labelText: 'தொகை *',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  _thogai = double.tryParse(val) ?? 0.0;
                },
              ),
            ),
            // Payment mode dropdown
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: DropdownButtonFormField<SeluthiVagai>(
                initialValue: _seluthiVagai,
                decoration: InputDecoration(
                  labelText: 'செலுத்தி வகை *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: SeluthiVagai.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(mode.icon, size: 18,
                            color: mode.badgeColor(isDark)),
                        const SizedBox(width: 10),
                        Text(mode.tamilLabel),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _seluthiVagai = val),
              ),
            ),
          ],
        ),

        // Reference number (shown only when not Cash)
        if (_seluthiVagai != null && _seluthiVagai!.needsReference) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: isDesktop ? 380 : double.infinity,
            child: TextField(
              controller: _suttruEnCtrl,
              decoration: InputDecoration(
                labelText: 'குறிப்பு எண் / Transaction ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => _suttruEn = val,
            ),
          ),
        ],

        // Note
        const SizedBox(height: 16),
        TextField(
          controller: _ullkurippuCtrl,
          decoration: InputDecoration(
            labelText: 'குறிப்பு',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          onChanged: (val) => _ullkurippu = val,
        ),
      ],
    );
  }

  // ── Invoice Picker Dialog ──
  void _showInvoicePickerDialog(
      AsyncValue<List<PatrucheettuEntry>> invoicesAsync) {
    PatruPattiyalTheervuMaeladukku.show(
      context: context,
      invoices: invoicesAsync.value ?? [],
      initialSelectedIds: Set<int>.from(_selectedInvoices.map((i) => i.id)),
      paidAmounts: _invoicePaidAmounts,
      onConfirmed: (selected) {
        setState(() {
          _selectedInvoices = selected;
          _recalculateAmount();
          _autoFillFromInvoices();
        });
        _loadPaidAmounts();
      },
    );
  }

  // ── Helpers ──

  void _recalculateAmount() {
    if (_selectedInvoices.isEmpty) {
      _thogaiCtrl.text = '';
      _thogai = 0.0;
      return;
    }

    double total = 0;
    for (final inv in _selectedInvoices) {
      final paid = _invoicePaidAmounts[inv.id] ?? 0.0;
      final balance = (inv.mothaThogai - paid).clamp(0.0, double.infinity);
      total += balance;
    }

    _thogai = total;
    _thogaiCtrl.text = total > 0 ? total.toStringAsFixed(2) : '';
  }

  void _autoFillFromInvoices() {
    if (_selectedInvoices.isEmpty) return;
    final first = _selectedInvoices.first;

    // Auto-fill customer from first invoice (if not already set)
    if (_selectedVanigarId == null && first.vanigarId != null) {
      _selectedVanigarId = first.vanigarId;
      _vanigarPeyar = first.vanigarPeyar;
    }
  }

  Future<void> _loadPaidAmounts() async {
    final kalanjiyam = ref.read(patruKalanjiyamProvider);
    final invoicesAsync = ref.read(pattiyalgalStreamProvider);
    final invoices = invoicesAsync.value ?? [];
    if (invoices.isEmpty) return;

    final ids = invoices.map((i) => i.id).toList();
    final amounts = await kalanjiyam.getPaidAmountsForInvoices(ids);
    if (mounted && amounts != _invoicePaidAmounts) {
      setState(() => _invoicePaidAmounts = amounts);
    }
  }
}
