import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/viruppangal_paniyagam.dart';
import '../../../chattagam/kaatchi/kaippaesi/elvan_utpakkach_chattagam.dart';
import '../koorugal/elvan_amaippu_pagudhi.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu.dart';
import '../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';

class PayanarAmaippugalPage extends ConsumerStatefulWidget {
  const PayanarAmaippugalPage({super.key});

  @override
  ConsumerState<PayanarAmaippugalPage> createState() =>
      _PayanarAmaippugalPageState();
}

class _PayanarAmaippugalPageState
    extends ConsumerState<PayanarAmaippugalPage> {
  late TextEditingController _mudhalPeyarController;
  late TextEditingController _irudhiPeyarController;
  String _pirandhaThaedhi = '';
  bool _hasChanges = false;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesServiceProvider);
    _mudhalPeyarController =
        TextEditingController(text: prefs.getPayanarMudhalPeyar());
    _irudhiPeyarController =
        TextEditingController(text: prefs.getPayanarIrudhiPeyar());
    _pirandhaThaedhi = prefs.getPayanarPirandhaThaedhi();

    _mudhalPeyarController.addListener(_markChanged);
    _irudhiPeyarController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _mudhalPeyarController.dispose();
    _irudhiPeyarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setPayanarMudhalPeyar(_mudhalPeyarController.text.trim());
    await prefs.setPayanarIrudhiPeyar(_irudhiPeyarController.text.trim());
    await prefs.setPayanarPirandhaThaedhi(_pirandhaThaedhi);
    // Update the reactive provider so VanakkamPill rebuilds
    ref.read(payanarKaatchiPeyarProvider.notifier).state =
        prefs.getPayanarKaatchiPeyar();
    setState(() => _hasChanges = false);
    if (mounted) {
      ElvanSnackbar.show(context, '✓');
    }
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();
    if (_pirandhaThaedhi.isNotEmpty) {
      try {
        initialDate = _dateFormat.parse(_pirandhaThaedhi);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _pirandhaThaedhi = _dateFormat.format(picked);
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return ElvanSubpageShell(
      title: K.payanarAmaippugal.tr(context, ref),
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: 32,
          ),
          sliver: SliverList.list(
            children: [
              // Description
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  K.payanarVilakkam.tr(context, ref),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),

              // Form section
              ElvanSettingsSection(
                children: [
                  // First Name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: ElvanTextField(
                      decoration: InputDecoration(
                        labelText: K.mudhalPeyar.tr(context, ref),
                      ),
                      controller: _mudhalPeyarController,
                    ),
                  ),

                  // Last Name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: ElvanTextField(
                      decoration: InputDecoration(
                        labelText: K.irudhiPeyar.tr(context, ref),
                      ),
                      controller: _irudhiPeyarController,
                    ),
                  ),

                  // Date of Birth
                  ElvanSimpleSettingsRow(
                    title: K.pirandhaThaedhi.tr(context, ref),
                    description: _pirandhaThaedhi.isNotEmpty
                        ? _pirandhaThaedhi
                        : null,
                    trailing: Icon(
                      CupertinoIcons.calendar,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onTap: _pickDate,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _hasChanges ? _save : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    K.payanarTharavugalaiMaetriduPtn.tr(context, ref),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
