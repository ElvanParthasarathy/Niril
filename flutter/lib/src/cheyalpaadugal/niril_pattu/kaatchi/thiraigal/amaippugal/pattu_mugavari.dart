import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../chattagam/kaatchi/kaippaesi/elvan_utpakkach_chattagam.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_amaippu_pagudhi.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_amaippu_thirutha_attai.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_amaippu_kattupadugal.dart';
import 'pattu_mugavari_tharavu.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal.dart';

class SilkMugavariPage extends ConsumerStatefulWidget {
  const SilkMugavariPage({super.key});

  @override
  ConsumerState<SilkMugavariPage> createState() => _SilkMugavariPageState();
}

class _SilkMugavariPageState extends ConsumerState<SilkMugavariPage> {
  String? _editingSection;

  // Temp State for editing
  String _tempPrimary = '';
  String _tempSecondary = '';

  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _showSuccessToast() {
    ElvanSnackbar.show(context, K.tharavugalChaemippuVetri.tr(context, ref));
  }

  Widget _buildEditContainer({
    required String title,
    required List<Widget> inputFields,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return ElvanSettingsEditContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...inputFields,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                child: Text(K.kaividuPtn.tr(context, ref)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: Text(K.chaemiPtn.tr(context, ref)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _beginEditPrimarySecondary(String section, String p, String s) {
    setState(() {
      _tempPrimary = p;
      _tempSecondary = s;
      _primaryController.text = p;
      _secondaryController.text = s;
      _editingSection = section;
    });
  }

  void _beginEditSingle(String section, String val) {
    setState(() {
      _tempPrimary = val;
      _editingSection = section;
    });
  }

  void _handleAutoFill(
      String val,
      bool isPrimary,
      List<Map<String, String>> dataSet,
      String primaryKey,
      String secondaryKey) {
    if (isPrimary) {
      final match = dataSet.where((d) => d[primaryKey] == val).firstOrNull;
      if (match != null) {
        setState(() {
          _tempSecondary = match[secondaryKey]!;
          _secondaryController.text = _tempSecondary;
        });
      }
    } else {
      final match = dataSet.where((d) => d[secondaryKey] == val).firstOrNull;
      if (match != null) {
        setState(() {
          _tempPrimary = match[primaryKey]!;
          _primaryController.text = _tempPrimary;
        });
      }
    }
  }

  void _saveBilingualField(VanigaTharavugal profile, String fieldName) {
    final updatedProfile = profile.copyWith();
    updatedProfile.setBilingual(fieldName, profile.mudhanMozhi, _tempPrimary);
    updatedProfile.setBilingual(fieldName, profile.thunaiMozhi, _tempSecondary);
    ref.read(vanigaTharavugalListProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  void _saveSingleField(VanigaTharavugal profile, String fieldName) {
    final updatedProfile = profile.copyWith();
    switch (fieldName) {
      case 'anjalKuriyeedu':
        updatedProfile.anjalKuriyeedu = _tempPrimary;
        break;
    }
    ref.read(vanigaTharavugalListProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    final title = K.mugavari.tr(context, ref);
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    final primaryKey = primaryLang == 'aangilam' ? 'en' : 'ta';
    final secondaryKey = secondaryLang == 'aangilam' ? 'en' : 'ta';

    final profile = ref.watch(vanigaTharavugalProvider);
    final currentProfile = profile ?? VanigaTharavugal();

    final mugavariPrimary = currentProfile.getPrimary('mugavari');
    final mugavariSecondary = currentProfile.getSecondary('mugavari');
    final oorPrimary = currentProfile.getPrimary('oor');
    final oorSecondary = currentProfile.getSecondary('oor');
    final maavattamPrimary = currentProfile.getPrimary('maavattam');
    final maavattamSecondary = currentProfile.getSecondary('maavattam');
    final maanilamPrimary = currentProfile.getPrimary('maanilam');
    final maanilamSecondary = currentProfile.getSecondary('maanilam');
    final naaduPrimary = currentProfile.getPrimary('naadu');
    final naaduSecondary = currentProfile.getSecondary('naadu');

    return ElvanSubpageShell(
      title: title,
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
              ElvanSettingsSection(
                dividerIndent: 16.0,
                children: [
                  // 1. Address (Mugavari)
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'mugavari',
                    isEditing: _editingSection == 'mugavari',
                    editChild: _buildEditContainer(
                      title: K.mugavari.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${K.mugavari.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          maxLines: 2,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${K.mugavari.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                            maxLines: 2,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'mugavari'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.mugavari.tr(context, ref),
                      primaryValue: mugavariPrimary,
                      secondaryValue: isBilingual ? mugavariSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'mugavari', mugavariPrimary, mugavariSecondary),
                    ),
                  ),

                  // 2. City (Oor)
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'oor',
                    isEditing: _editingSection == 'oor',
                    editChild: _buildEditContainer(
                      title: K.oor.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${K.oor.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${K.oor.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveBilingualField(currentProfile, 'oor'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.oor.tr(context, ref),
                      primaryValue: oorPrimary,
                      secondaryValue: isBilingual ? oorSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'oor', oorPrimary, oorSecondary),
                    ),
                  ),

                  // 3. District (Maavattam)
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'maavattam',
                    isEditing: _editingSection == 'maavattam',
                    editChild: _buildEditContainer(
                      title: K.maavattam.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${K.maavattam.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${K.maavattam.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'maavattam'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.maavattam.tr(context, ref),
                      primaryValue: maavattamPrimary,
                      secondaryValue: isBilingual ? maavattamSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'maavattam', maavattamPrimary, maavattamSecondary),
                    ),
                  ),

                  // 4. State (Maanilam)
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'maanilam',
                    isEditing: _editingSection == 'maanilam',
                    editChild: _buildEditContainer(
                      title: K.maanilam.tr(context, ref),
                      inputFields: [
                        ElvanSettingsAutocomplete(
                          label:
                              '${K.maanilam.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          controller: _primaryController,
                          options: silkIndianStates
                              .map((d) => d[primaryKey]!)
                              .toList(),
                          onChanged: (val) {
                            _tempPrimary = val;
                            if (val.isEmpty && isBilingual) {
                              _tempSecondary = '';
                              _secondaryController.clear();
                            }
                          },
                          onSelected: (val) => _handleAutoFill(val, true,
                              silkIndianStates, primaryKey, secondaryKey),
                          searchMatch: (option, query) {
                            final match = silkIndianStates.firstWhere(
                                (d) => d[primaryKey] == option,
                                orElse: () => {});
                            if (match.isEmpty) return false;
                            final q = query.toLowerCase();
                            return match['ta']!.toLowerCase().contains(q) ||
                                match['en']!.toLowerCase().contains(q);
                          },
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsAutocomplete(
                            label:
                                '${K.maanilam.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            controller: _secondaryController,
                            options: silkIndianStates
                                .map((d) => d[secondaryKey]!)
                                .toList(),
                            onChanged: (val) => _tempSecondary = val,
                            onSelected: (val) => _handleAutoFill(val, false,
                                silkIndianStates, primaryKey, secondaryKey),
                            enabled: false,
                            searchMatch: (option, query) {
                              final match = silkIndianStates.firstWhere(
                                  (d) => d[secondaryKey] == option,
                                  orElse: () => {});
                              if (match.isEmpty) return false;
                              final q = query.toLowerCase();
                              return match['ta']!.toLowerCase().contains(q) ||
                                  match['en']!.toLowerCase().contains(q);
                            },
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'maanilam'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.maanilam.tr(context, ref),
                      primaryValue: maanilamPrimary,
                      secondaryValue: isBilingual ? maanilamSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'maanilam', maanilamPrimary, maanilamSecondary),
                    ),
                  ),

                  // 5. Country
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'naadu',
                    isEditing: _editingSection == 'naadu',
                    editChild: _buildEditContainer(
                      title: K.naadu.tr(context, ref),
                      inputFields: [
                        ElvanSettingsAutocomplete(
                          label:
                              '${K.naadu.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          controller: _primaryController,
                          options:
                              silkCountries.map((d) => d[primaryKey]!).toList(),
                          onChanged: (val) => _tempPrimary = val,
                          onSelected: (val) => _handleAutoFill(val, true,
                              silkCountries, primaryKey, secondaryKey),
                          enabled: false,
                          searchMatch: (option, query) {
                            final match = silkCountries.firstWhere(
                                (d) => d[primaryKey] == option,
                                orElse: () => {});
                            if (match.isEmpty) return false;
                            final q = query.toLowerCase();
                            return match['ta']!.toLowerCase().contains(q) ||
                                match['en']!.toLowerCase().contains(q);
                          },
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsAutocomplete(
                            label:
                                '${K.naadu.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            controller: _secondaryController,
                            options: silkCountries
                                .map((d) => d[secondaryKey]!)
                                .toList(),
                            onChanged: (val) => _tempSecondary = val,
                            onSelected: (val) => _handleAutoFill(val, false,
                                silkCountries, primaryKey, secondaryKey),
                            enabled: false,
                            searchMatch: (option, query) {
                              final match = silkCountries.firstWhere(
                                  (d) => d[secondaryKey] == option,
                                  orElse: () => {});
                              if (match.isEmpty) return false;
                              final q = query.toLowerCase();
                              return match['ta']!.toLowerCase().contains(q) ||
                                  match['en']!.toLowerCase().contains(q);
                            },
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'naadu'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.naadu.tr(context, ref),
                      primaryValue: naaduPrimary,
                      secondaryValue: isBilingual ? naaduSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'naadu', naaduPrimary, naaduSecondary),
                    ),
                  ),

                  // 6. Pincode
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'anjalKuriyeedu',
                    isEditing: _editingSection == 'anjalKuriyeedu',
                    editChild: _buildEditContainer(
                      title: K.anjalKuriyeedu.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: K.anjalKuriyeedu.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveSingleField(currentProfile, 'anjalKuriyeedu'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.anjalKuriyeedu.tr(context, ref),
                      primaryValue: currentProfile.anjalKuriyeedu,
                      onEdit: () => _beginEditSingle(
                          'anjalKuriyeedu', currentProfile.anjalKuriyeedu),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
