import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import 'koorugal/elvan_thiruthi_paguthi.dart';
import 'koorugal/elvan_thiruthi_keezhvirivu.dart';
import '../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_oadu.dart';
import '../../../niril_podhu/kaatchi/thiruthi/elvan_thiruthi_niruvanam_oadu.dart';
import '../../../niril_podhu/kalanjiyam/patru_nilaimai.dart';
import '../../../niril_podhu/kalanjiyam/pattiyal_nilaimai.dart';
import '../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import 'koorugal/patru_pattiyal_theervu_maeladukku.dart';
import 'koorugal/patru_thiruthi_paguthigal.dart';
import '../koorugal/elvan_vaangunar_keezhvirivu_kooru.dart';
import '../koorugal/pattiyal_naal_kooru.dart';
import '../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../koorugal/ulleedugal/elvan_thiruthi_ulleedu.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// Shared Receipt Editor — used by both Coolie and Silk modes.
/// Three sections: ① Invoice picker, ② Receipt data, ③ Payment details.
class PatruThiruthi extends ConsumerStatefulWidget {
  final PatrugalTharavuru? editingEntry;

  const PatruThiruthi({super.key, this.editingEntry});

  @override
  ConsumerState<PatruThiruthi> createState() => _PatruThiruthiState();
}

enum PatruMode { againstInvoice, advance }

class _PatruThiruthiState extends ConsumerState<PatruThiruthi> {
  // ── Mode ──
  PatruMode _mode = PatruMode.againstInvoice;

  // ── Company Profile ──
  int? _selectedNiruvanamId;
  NiruvanaTharavugal? _selectedProfile;

  // ── Customer ──
  int? _selectedVaangunarId;
  Map<String, String> _vaangunarPeyarMap = {};
  Map<String, String> _vaangunarMunvariMap = {};

  // ── Receipt Data ──
  DateTime _patruNaal = DateTime.now();
  String _patruEn = '';
  int _vanakkam = 1;

  // ── Payment ──
  double _thogai = 0.0;
  SeluthiVagai? _seluthiVagai = SeluthiVagai.vangiMaatram;
  String _suttruEn = '';
  String _ullkurippu = '';

  // ── Linked Invoices ──
  List<PattiyalTharavuru> _selectedInvoices = [];

  // ── Controllers ──
  final _thogaiCtrl = TextEditingController();
  final _suttruEnCtrl = TextEditingController();
  final _ullkurippuCtrl = TextEditingController();
  final _patruEnCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;
  bool _isLoadingInvoices = false;
  bool _isPatruEnEditing = false;
  String _previewPatruEn = '';

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLinkedInvoices();
  }

  void _initializeForm() {
    final entry = widget.editingEntry;
    if (entry != null) {
      _selectedNiruvanamId = entry.niruvanamId;
      _selectedVaangunarId = entry.vaangunarId;
      _vaangunarPeyarMap = entry.vaangunarPeyar.cast<String, String>();
      _patruNaal = entry.patruNaal;
      _patruEn = entry.patruEn;
      _vanakkam = entry.vanakkam;
      _thogai = entry.thogai;
      _seluthiVagai = SeluthiVagaiX.fromStored(entry.seluthumMurai);
      _suttruEn = entry.parivarthanaiEn; // Map parivarthanaiEn to UI's suttruEn
      _ullkurippu = entry.ullkurippu;

      _thogaiCtrl.text = _thogai > 0 ? _thogai.toStringAsFixed(2) : '';
      _suttruEnCtrl.text = _suttruEn;
      _ullkurippuCtrl.text = _ullkurippu;
      _patruEnCtrl.text = _patruEn;
    } else {
      // New receipt: Do NOT pre-select business profile (user requested manual selection)
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

    if (mounted) setState(() => _isLoadingInvoices = true);

    final kalanjiyam = ref.read(patruKalanjiyamProvider);
    final links = await kalanjiyam.getLinksForPatru(widget.editingEntry!.id);
    final pattiyalKal = ref.read(pattiyalKalanjiyamProvider);

    final futures = links.map((link) => pattiyalKal.getById(link.pattiyalId));
    final results = await Future.wait(futures);
    final invoices = results.whereType<PattiyalTharavuru>().toList();

    if (mounted) {
      setState(() {
        _selectedInvoices = invoices;
        _mode =
            invoices.isNotEmpty ? PatruMode.againstInvoice : PatruMode.advance;
        _isLoadingInvoices = false;
      });
      _autoFillFromInvoices();
    }
  }

  // ── Auto-generate receipt number ──
  Future<void> _generatePatruEn() async {
    if (widget.editingEntry != null) return; // Don't regenerate for edits

    final kalanjiyam = ref.read(patruKalanjiyamProvider);

    String bizShort = '';
    if (_selectedProfile?.kurumPeyar.isNotEmpty == true) {
      bizShort = _selectedProfile!.kurumPeyar;
    } else {
      final bizName = _selectedProfile?.niruvanathinPeyar['English'] ??
          _selectedProfile?.niruvanathinPeyar['Tamil'] ??
          'BIZ';
      bizShort = bizName
          .split(' ')
          .where((w) => w.trim().isNotEmpty)
          .map((w) => w[0])
          .join('')
          .toUpperCase();
      if (bizShort.length > 4) bizShort = bizShort.substring(0, 4);
      if (bizShort.isEmpty) bizShort = 'BIZ';
    }

    _vanakkam = await kalanjiyam.getNextVanakkam(_selectedNiruvanamId);

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
    if (_selectedProfile == null ||
        _selectedProfile!.kurumPeyar.trim().isEmpty) {
      ElvanSnackbar.show(context,
          '${K.amaippugal.tr(context, ref)} - Kurum Peyar is required to save receipts.');
      return;
    }

    final peyarTamil = _vaangunarPeyarMap['Tamil'] ?? '';
    if (peyarTamil.trim().isEmpty) {
      ElvanSnackbar.show(context, K.vaangunarPeyarThaevai.tr(context, ref));
      return;
    }
    if (_thogai <= 0) {
      ElvanSnackbar.show(context,
          K.thogaiChuzhiyaththaiVidaMigudhiyaagaIrukkaVaendum.tr(context, ref));
      return;
    }
    if (_seluthiVagai == null) {
      ElvanSnackbar.show(context, K.cheluthumMuraiThaernhedu.tr(context, ref));
      return;
    }

    if (_seluthiVagai == SeluthiVagai.panam) {
      _suttruEn = ''; // Cash logic: clear reference number
    }

    setState(() => _isSaving = true);

    try {
      final kalanjiyam = ref.read(patruKalanjiyamProvider);

      // Build junction links — distribute amount across invoices (oldest first)
      final links = <PatruPattiyalInaippuTharavuru>[];
      double remaining = _thogai;

      for (final inv in _selectedInvoices) {
        if (remaining <= 0) break;

        final apply = remaining.clamp(0.0, inv.mothaThogai);

        if (apply > 0) {
          links.add(PatruPattiyalInaippuTharavuru(
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
        _selectedNiruvanamId,
        _patruEn,
        excludeId: widget.editingEntry?.id,
      );

      if (isDuplicate) {
        if (mounted) {
          ElvanSnackbar.show(context,
              '$_patruEn - ${K.patrucheettuEnYaerkanavaeUlladhu.tr(context, ref)}');
          setState(() => _isSaving = false);
        }
        return;
      }

      // Build receipt companion
      final companion = PatrugalTharavuru(
        id: widget.editingEntry?.id ?? 0,
        niruvanamId: _selectedNiruvanamId,
        patruEn: _patruEn,
        vanakkam: _vanakkam,
        finYear: widget.editingEntry?.finYear ?? DateTime.now().year,
        vaangunarId: _selectedVaangunarId,
        vaangunarPeyar: _vaangunarPeyarMap,
        patruNaal: _patruNaal,
        thogai: _thogai,
        seluthumMurai: _seluthiVagai!.storedValue,
        vangiPeyar: widget.editingEntry?.vangiPeyar ?? '',
        parivarthanaiEn: widget.editingEntry?.parivarthanaiEn ?? '',
        ullkurippu: _ullkurippu,
        createdAt: widget.editingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
      );

      if (widget.editingEntry != null) {
        await kalanjiyam.updatePatru(widget.editingEntry!.id, companion, links);
      } else {
        await kalanjiyam.insertPatru(companion, links);
      }

      if (mounted) {
        ref.invalidate(patrugalProvider);
        ref.invalidate(pattiyalgalProvider);
        ElvanSnackbar.show(
          context,
          K.patrucheettuChaemikkappattadhu.tr(context, ref),
          showAboveNavbar: true,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ElvanSnackbar.show(
            context, '${K.chaemikkaIyalavillai.tr(context, ref)} $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(pattiyalgalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.editingEntry == null &&
        _patruEn.isEmpty &&
        _selectedNiruvanamId != null) {
      _generatePatruEn();
    }

    final isEditing = widget.editingEntry != null;
    final title = isEditing
        ? K.maatriyamai.tr(context, ref)
        : K.pudhiyaAakkam.tr(context, ref);

    final profiles = ref.watch(NiruvanaTharavugalListProvider);
    final baseIndex = profiles.length > 1 ? 1 : 0;

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
            // ── Mode Dropdown ──
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: LayoutBuilder(builder: (context, constraints) {
                final isDesktop = MediaQuery.sizeOf(context).width >= 800;
                final width = isDesktop
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: width,
                    child: ElvanThiruthiKeezhvirivu<String>(
                      label: K.patrucheettuVagai.tr(context, ref),
                      value: _mode == PatruMode.advance
                          ? K.munthogai.tr(context, ref)
                          : K.pattiyal.tr(context, ref),
                      items: [
                        K.pattiyal.tr(context, ref),
                        K.munthogai.tr(context, ref),
                      ],
                      itemLabelBuilder: (ctx, ref, item) => item,
                      onChanged: (String newValue) {
                        setState(() {
                          _mode = newValue == K.munthogai.tr(context, ref)
                              ? PatruMode.advance
                              : PatruMode.againstInvoice;
                          if (_mode == PatruMode.advance) {
                            _selectedInvoices.clear();
                            _recalculateAmount();
                          }
                        });
                      },
                    ),
                  ),
                );
              }),
            ),

            // ── Section 1: Against Invoice ──
            if (_mode == PatruMode.againstInvoice) ...[
              ElvanEditorSection(
                index: baseIndex,
                title: K.endhapPattiyalukku.tr(context, ref),
                displayChild: const SizedBox(),
                initiallyExpanded: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: _isLoadingInvoices
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _buildInvoicePickerSection(invoicesAsync, isDark),
                  ),
                ],
              ),
            ],

            // ── Section 2: Receipt Data ──
            ElvanEditorSection(
              index: baseIndex + (_mode == PatruMode.againstInvoice ? 1 : 0),
              title: K.patrucheettuTharavugal.tr(context, ref),
              displayChild: const SizedBox(),
              initiallyExpanded: true,
              children: _buildReceiptDataFields(isDark),
            ),

            // ── Section 3: Payment Details ──
            ElvanEditorSection(
              index: baseIndex + (_mode == PatruMode.againstInvoice ? 2 : 1),
              title: K.cheluthiyaTharavu.tr(context, ref),
              displayChild: const SizedBox(),
              initiallyExpanded: true,
              children: _buildPaymentFields(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 1: Invoice Picker ──
  Widget _buildInvoicePickerSection(
      AsyncValue<List<PattiyalTharavuru>> invoicesAsync, bool isDark) {
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
  List<Widget> _buildReceiptDataFields(bool isDark) {
    final bizShort = (_selectedProfile?.kurumPeyar.isNotEmpty == true
            ? _selectedProfile!.kurumPeyar
            : 'BIZ')
        .toUpperCase();
    final profilePrefix = 'RCP/$bizShort/';

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return [
      // 1. Receipt Date
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            K.patrucheettuNaal.tr(context, ref),
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          PattiyalNaalKooru(
            selectedDate: _patruNaal,
            onDateChanged: (date) {
              setState(() => _patruNaal = date);
            },
          ),
        ],
      ),

      // 2. Customer Selector / Info
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              K.vaangunar.tr(context, ref),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          if (_mode == PatruMode.againstInvoice) ...[
            if (_selectedInvoices.isNotEmpty)
              _buildCustomerCard(isDark, isLocked: true)
            else
              InputDecorator(
                decoration: InputDecoration(
                  constraints: const BoxConstraints(minHeight: 48),
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.info_circle_fill,
                        size: 18,
                        color: isDark ? Colors.white54 : Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        K.pattiyalThaervukkuPinVaangunarTharavugalNirappappadum
                            .tr(context, ref),
                        style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              )
          ] else ...[
            // Advance Mode — manual selection
            if (_selectedVaangunarId == null)
              ElvanVaangunarKeezhvirivuKooru(
                selectedVaangunarId: _selectedVaangunarId,
                hideLabel: true,
                showClearButton: true,
                onChanged: (v) {
                  if (v == null) {
                    setState(() {
                      _selectedVaangunarId = null;
                      _vaangunarPeyarMap = {};
                      _vaangunarMunvariMap = {};
                    });
                  } else {
                    setState(() {
                      _selectedVaangunarId = v.id;
                      _vaangunarPeyarMap = Map<String, String>.from(v.peyar);

                      final tamilAddr = [
                        if (v.oor['Tamil']?.isNotEmpty == true) v.oor['Tamil'],
                        if (v.maavattam['Tamil']?.isNotEmpty == true)
                          v.maavattam['Tamil'],
                      ].where((e) => e != null).join(', ');

                      final engAddr = [
                        if (v.oor['English']?.isNotEmpty == true)
                          v.oor['English'],
                        if (v.maavattam['English']?.isNotEmpty == true)
                          v.maavattam['English'],
                      ].where((e) => e != null).join(', ');

                      _vaangunarMunvariMap = {
                        'Tamil': tamilAddr.isNotEmpty
                            ? tamilAddr
                            : (v.mugavari['Tamil'] ?? ''),
                        'English': engAddr.isNotEmpty
                            ? engAddr
                            : (v.mugavari['English'] ?? ''),
                      };
                    });
                  }
                },
              )
            else
              _buildCustomerCard(isDark, isLocked: false),
          ],
        ],
      ),

      // 3. Receipt Number
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Text(
                  K.patrucheettuEn.tr(context, ref),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    setState(() {
                      if (_isPatruEnEditing) {
                        final numPart = _patruEnCtrl.text.trim();
                        if (numPart.isNotEmpty) {
                          _patruEn = '$profilePrefix$numPart';
                        } else {
                          _patruEn = '';
                        }
                        _isPatruEnEditing = false;
                      } else {
                        _isPatruEnEditing = true;
                        _patruEnCtrl.text = '';
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _isPatruEnEditing ? Icons.check : Icons.edit_outlined,
                      size: 16,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (_isPatruEnEditing)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(100)),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    profilePrefix,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _patruEnCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: ElvanVadivamaippigal.enngalMattum,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '01',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(100)),
                        borderSide: BorderSide(
                          color: cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _previewPatruEn =
                            val.isEmpty ? '' : '$profilePrefix$val';
                      });
                    },
                  ),
                ),
              ],
            )
          else
            InputDecorator(
              decoration: InputDecoration(
                constraints: const BoxConstraints(minHeight: 48),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
              ),
              child: _patruEnCtrl.text.isNotEmpty ||
                      (_patruEn.isNotEmpty ? _patruEn : _previewPatruEn)
                          .isNotEmpty
                  ? Text(
                      _patruEnCtrl.text.isNotEmpty
                          ? _patruEnCtrl.text
                          : (_patruEn.isNotEmpty ? _patruEn : _previewPatruEn),
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      K.thaaniyangkiUruvaam.tr(context, ref),
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
        ],
      ),
    ];
  }

  // ── Helper: Customer Info Card ──
  Widget _buildCustomerCard(bool isDark, {required bool isLocked}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(CupertinoIcons.person_solid,
                size: 28, color: isDark ? Colors.white54 : Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vaangunarPeyarMap['Tamil'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (_vaangunarMunvariMap['Tamil']?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      _vaangunarMunvariMap['Tamil'] ?? '',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLocked)
              Icon(CupertinoIcons.lock_fill,
                  size: 16, color: isDark ? Colors.white30 : Colors.black26)
            else
              IconButton(
                icon: const Icon(CupertinoIcons.clear_circled_solid),
                color: isDark ? Colors.white54 : Colors.black45,
                tooltip: K.maatru.tr(context, ref), // Change
                onPressed: () {
                  setState(() {
                    _selectedVaangunarId = null;
                    _vaangunarPeyarMap.clear();
                    _vaangunarMunvariMap.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Payment Details ──
  List<Widget> _buildPaymentFields(bool isDark) {
    return [
      // Amount field
      ElvanThiruthiUlleedu(
        controller: _thogaiCtrl,
        label: K.thogaiVinmeen.tr(context, ref),
        prefixText: '₹ ',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: ElvanVadivamaippigal.thasamamEnngal,
        onChanged: (val) {
          _thogai = double.tryParse(val) ?? 0.0;
        },
      ),

      // Payment mode dropdown
      ElvanThiruthiKeezhvirivu<SeluthiVagai>(
        label: K.cheluthumMuraiVinmeen.tr(context, ref),
        value: _seluthiVagai,
        items: SeluthiVagai.values,
        itemLabelBuilder: (ctx, ref, mode) => mode.label(ctx, ref),
        leadingBuilder: (ctx, ref, mode) => Icon(mode.icon,
            size: 14,
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7)),
        onChanged: (val) {
          setState(() => _seluthiVagai = val);
        },
      ),

      // Reference number (shown only when not Cash)
      if (_seluthiVagai != null && _seluthiVagai!.needsReference)
        ElvanThiruthiUlleedu(
          controller: _suttruEnCtrl,
          label: K.kurippuEnParimaatraEn.tr(context, ref),
          onChanged: (val) => _suttruEn = val,
        ),

      // Note
      ElvanThiruthiUlleedu(
        controller: _ullkurippuCtrl,
        label: K.kurippu.tr(context, ref),
        maxLines: 3,
        onChanged: (val) => _ullkurippu = val,
      ),
    ];
  }

  // ── Invoice Picker Dialog ──
  void _showInvoicePickerDialog(
      AsyncValue<List<PattiyalTharavuru>> invoicesAsync) {
    final allInvoices = invoicesAsync.value ?? [];
    final filteredByBusiness = _selectedNiruvanamId != null
        ? allInvoices
            .where((i) => i.niruvanamId == _selectedNiruvanamId)
            .toList()
        : allInvoices;

    PatruPattiyalTheervuMaeladukku.show(
      context: context,
      ref: ref,
      invoices: filteredByBusiness,
      initialSelectedIds: Set<int>.from(_selectedInvoices.map((i) => i.id)),
      onConfirmed: (selected) {
        setState(() {
          _selectedInvoices = selected;
          _recalculateAmount();
          _autoFillFromInvoices();
        });
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
      total += inv.mothaThogai;
    }

    _thogai = total;
    _thogaiCtrl.text = total > 0
        ? (total.truncateToDouble() == total
            ? total.toInt().toString()
            : total.toStringAsFixed(2))
        : '';
  }

  void _autoFillFromInvoices() {
    if (_selectedInvoices.isEmpty) return;
    final first = _selectedInvoices.first;

    // Auto-fill customer from first invoice (if not already set)
    if (_selectedVaangunarId == null && first.vaangunarId != null) {
      _selectedVaangunarId = first.vaangunarId;
      _vaangunarPeyarMap = first.vaangunarPeyar.cast<String, String>();
      _vaangunarMunvariMap = first.vaangunarMunvari.cast<String, String>();
    }
  }
}
