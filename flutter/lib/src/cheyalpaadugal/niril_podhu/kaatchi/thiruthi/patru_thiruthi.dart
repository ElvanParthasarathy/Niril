

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;


import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../../../koorugal/podhu_koorugal/elvan_pagudhi_thalaipu_kooru.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_niruvanam_oadu.dart';
import '../../../niril_podhu/kalanjiyam/patru_kalanjiyam.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import 'koorugal/patru_pattiyal_theervu_maeladukku.dart';
import 'koorugal/patru_thiruthi_paguthigal.dart';
import '../koorugal/elvan_pattiyal_tharavugal_kooru.dart';
import '../koorugal/vanigar_thaedu_kooru.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';


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
  NiruvanaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVanigarId;
  Map<String, String> _vanigarPeyarMap = {};
  Map<String, String> _vanigarMunvariMap = {};

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
  final _patruEnCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;
  bool _paidAmountsLoaded = false;
  bool _isPatruEnEditing = false;
  String _previewPatruEn = '';

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
      _vanigarPeyarMap = entry.vanigarPeyar;
      _vanigarMunvariMap = entry.vanigarMunvari;
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
      _patruEnCtrl.text = _patruEn;
    }
  }

  @override
  void dispose() {
    _thogaiCtrl.dispose();
    _suttruEnCtrl.dispose();
    _ullkurippuCtrl.dispose();
    _patruEnCtrl.dispose();
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
    
    // Format is RCP/bizShort/01
    final formatted = kalanjiyam.formatPatruEn(bizShort, _vanakkam);
    if (_isPatruEnEditing) {
      _previewPatruEn = formatted;
    } else {
      _patruEn = formatted;
      _previewPatruEn = '';
    }

    if (mounted) setState(() {});
  }

  // ── Save ──
  Future<void> _handleSave() async {
    // Validation
    final peyarTamil = _vanigarPeyarMap['Tamil'] ?? '';
    if (peyarTamil.trim().isEmpty) {
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

      // Check for duplicate receipt number
      final isDuplicate = await kalanjiyam.isPatruEnDuplicate(
        seyaliVagai,
        _selectedNiruvanamId,
        _patruEn,
        excludeId: widget.editingEntry?.id,
      );

      if (isDuplicate) {
        if (mounted) {
          ElvanSnackbar.show(context, 'Receipt number $_patruEn already exists!');
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
        vanigarPeyar: Value(_vanigarPeyarMap),
        vanigarMunvari: Value(_vanigarMunvariMap),
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
        ref.invalidate(patrugalProvider);
        ref.invalidate(pattiyalgalProvider);
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
    final invoicesAsync = ref.watch(pattiyalgalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = ref.watch(appModeProvider);
    final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';

    if (widget.editingEntry == null && _patruEn.isEmpty && _selectedNiruvanamId != null) {
      _generatePatruEn();
    }

    final isEditing = widget.editingEntry != null;
    final title = isEditing ? 'பற்றுச்சீட்டுத் திருத்து' : 'புதிய பற்றுச்சீட்டு';

    return ElvanEditorShell(
      title: title,
      onSave: _isSaving ? null : _handleSave,
      child: ElvanThiruthiNiruvanamOadu(
        selectedNiruvanamId: _selectedNiruvanamId,
        onChanged: (p) {
          setState(() {
            _selectedNiruvanamId = p?.id;
            _selectedProfile = p;
          });
          if (p != null) {
            _generatePatruEn();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section 1: Against Invoice ──
            const ElvanPagudhiThalaipu(en: 1, thalaipu: 'எந்தப் பட்டியலுக்கு'),
            ElvanThiruthiAttai(
              child: _buildInvoicePickerSection(invoicesAsync, isDark),
            ),
            const SizedBox(height: 24),

            // ── Section 2: Receipt Data ──
            const ElvanPagudhiThalaipu(en: 2, thalaipu: 'பற்றுச்சீட்டு தரவுகள்'),
            ElvanThiruthiAttai(
              padding: const EdgeInsets.all(24),
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
      ),
    );
  }

  // ── Section 1: Invoice Picker ──
  Widget _buildInvoicePickerSection(
      AsyncValue<List<PatrucheettuEntry>> invoicesAsync, bool isDark) {
    return PatruPattiyalTheervuPagudhi(
      selectedInvoices: _selectedInvoices,
      isDark: isDark,
      onPickInvoices: () => _showInvoicePickerDialog(invoicesAsync),
      onRemoveInvoice: (inv) {
        setState(() {
          _selectedInvoices.remove(inv);
          _recalculateAmount();
        });
      },
    );
  }

  // ── Section 2: Receipt Data ──
  Widget _buildReceiptDataSection(String seyaliVagai, bool isDark) {
    final bizShort = (_selectedProfile?.kurumPeyar.isNotEmpty == true
            ? _selectedProfile!.kurumPeyar
            : 'BIZ')
        .toUpperCase();
    final profilePrefix = 'RCP/$bizShort/';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Receipt Number & Date
        ElvanPattiyalTharavugalKooru(
          customNumberTitle: 'பற்றுச்சீட்டு எண்', // Receipt Number
          customDateTitle: 'பற்றுச்சீட்டு தேதி', // Receipt Date
          isEditing: widget.editingEntry != null,
          invoiceNumberOverride: _patruEnCtrl.text,
          previewInvoiceNumber: _previewPatruEn,
          isInvNumberEditing: _isPatruEnEditing,
          invNumberController: _patruEnCtrl,
          profilePrefix: profilePrefix,
          pattiyalNaal: _patruNaal,
          onToggleEditInvNumber: () {
            setState(() {
              if (_isPatruEnEditing) {
                // Done editing: user typed custom number
                final numPart = _patruEnCtrl.text.trim();
                if (numPart.isNotEmpty) {
                  _patruEn = '$profilePrefix$numPart';
                } else {
                  _patruEn = '';
                }
                _isPatruEnEditing = false;
              } else {
                // Start editing
                _isPatruEnEditing = true;
                _patruEnCtrl.text = ''; // Clear so they type only the number
              }
            });
          },
          onInvNumberChanged: (val) {
            setState(() {
              _previewPatruEn = val.isEmpty ? '' : '$profilePrefix$val';
            });
          },
          onDateChanged: (date) {
            setState(() => _patruNaal = date);
          },
          onDirty: () {},
        ),
        const SizedBox(height: 24),
        
        // 2. Customer Selector
        Text(
          K.vanigar.tr(context, ref),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        VanigarThaeduKooru(
          seyaliVagai: seyaliVagai,
          selectedId: _selectedVanigarId,
          onSelected: (v) {
            setState(() {
              _selectedVanigarId = v.id;
              _vanigarPeyarMap = Map<String, String>.from(v.peyar);
              
              final tamilAddr = [
                if (v.oor['Tamil']?.isNotEmpty == true) v.oor['Tamil'],
                if (v.maavattam['Tamil']?.isNotEmpty == true) v.maavattam['Tamil'],
              ].where((e) => e != null).join(', ');
              
              final engAddr = [
                if (v.oor['English']?.isNotEmpty == true) v.oor['English'],
                if (v.maavattam['English']?.isNotEmpty == true) v.maavattam['English'],
              ].where((e) => e != null).join(', ');

              _vanigarMunvariMap = {
                'Tamil': tamilAddr.isNotEmpty ? tamilAddr : (v.mugavari['Tamil'] ?? ''),
                'English': engAddr.isNotEmpty ? engAddr : (v.mugavari['English'] ?? ''),
              };
            });
          },
        ),
      ],
    );
  }

  // ── Section 3: Payment Details ──
  Widget _buildPaymentSection(bool isDark) {
    return PatruSeluthiPagudhi(
      thogaiCtrl: _thogaiCtrl,
      suttruEnCtrl: _suttruEnCtrl,
      ullkurippuCtrl: _ullkurippuCtrl,
      seluthiVagai: _seluthiVagai,
      isDark: isDark,
      onThogaiChanged: (val) => _thogai = double.tryParse(val) ?? 0.0,
      onSeluthiVagaiChanged: (val) => setState(() => _seluthiVagai = val),
      onSuttruEnChanged: (val) => _suttruEn = val,
      onUllkurippuChanged: (val) => _ullkurippu = val,
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
      _vanigarPeyarMap = first.vanigarPeyar;
      _vanigarMunvariMap = first.vanigarMunvari;
    }
  }

  Future<void> _loadPaidAmounts() async {
    final kalanjiyam = ref.read(patruKalanjiyamProvider);
    final invoicesAsync = ref.read(pattiyalgalProvider);
    final invoices = invoicesAsync.value ?? [];
    if (invoices.isEmpty) return;

    final ids = invoices.map((i) => i.id).toList();
    final amounts = await kalanjiyam.getPaidAmountsForInvoices(ids);
    if (mounted && amounts != _invoicePaidAmounts) {
      setState(() => _invoicePaidAmounts = amounts);
    }
  }
}
