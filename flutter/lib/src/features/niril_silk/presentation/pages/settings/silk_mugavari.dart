import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';
import 'silk_address_data.dart';

class SilkMugavariPage extends ConsumerStatefulWidget {
  const SilkMugavariPage({super.key});

  @override
  ConsumerState<SilkMugavariPage> createState() => _SilkMugavariPageState();
}

class _SilkMugavariPageState extends ConsumerState<SilkMugavariPage> {
  String? _editingSection;

  // State
  String _mugavariPrimary = '';
  String _mugavariSecondary = '';
  String _oorPrimary = '';
  String _oorSecondary = '';
  String _maavattamPrimary = '';
  String _maavattamSecondary = '';
  String _maanilamPrimary = '';
  String _maanilamSecondary = '';
  String _countryPrimary = '';
  String _countrySecondary = '';

  // Temp State for editing
  String _tempPrimary = '';
  String _tempSecondary = '';
  
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final primaryLang = ref.read(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.read(secondaryLanguageProvider).toLowerCase();
    
    _countryPrimary = primaryLang == 'english' ? 'India' : 'இந்தியா';
    _countrySecondary = secondaryLang == 'english' ? 'India' : 'இந்தியா';
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _showSuccessToast() {
    ElvanSnackbar.show(context, 'detailsSaved'.tr(context, ref));
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
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                child: Text('cancelBtn'.tr(context, ref)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: Text('saveBtn'.tr(context, ref)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _beginEdit(String section, String p, String s) {
    setState(() {
      _tempPrimary = p;
      _tempSecondary = s;
      _primaryController.text = p;
      _secondaryController.text = s;
      _editingSection = section;
    });
  }

  void _handleAutoFill(String val, bool isPrimary, List<Map<String, String>> dataSet, String primaryKey, String secondaryKey) {
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

  @override
  Widget build(BuildContext context) {
    final title = 'settings_mugavari'.tr(context, ref);
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();
    
    ref.listen<String>(primaryLanguageProvider, (previous, next) {
      if (previous != null && previous != next) {
        setState(() {
          final tMug = _mugavariPrimary; _mugavariPrimary = _mugavariSecondary; _mugavariSecondary = tMug;
          final tOor = _oorPrimary; _oorPrimary = _oorSecondary; _oorSecondary = tOor;
          final tMaav = _maavattamPrimary; _maavattamPrimary = _maavattamSecondary; _maavattamSecondary = tMaav;
          final tMaan = _maanilamPrimary; _maanilamPrimary = _maanilamSecondary; _maanilamSecondary = tMaan;
          final tCoun = _countryPrimary; _countryPrimary = _countrySecondary; _countrySecondary = tCoun;
        });
      }
    });

    final primaryKey = primaryLang == 'english' ? 'en' : 'ta';
    final secondaryKey = secondaryLang == 'english' ? 'en' : 'ta';

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
                    title: 'mugavari'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: '${'mugavari'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                        maxLines: 2,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'mugavari'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          initialValue: _tempSecondary,
                          onChanged: (val) => _tempSecondary = val,
                          maxLines: 2,
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _mugavariPrimary = _tempPrimary;
                        _mugavariSecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'mugavari'.tr(context, ref),
                    primaryValue: _mugavariPrimary,
                    secondaryValue: isBilingual ? _mugavariSecondary : null,
                    onEdit: () => _beginEdit('mugavari', _mugavariPrimary, _mugavariSecondary),
                  ),
                ),

                // 2. City (Oor)
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'oor',
                  isEditing: _editingSection == 'oor',
                  editChild: _buildEditContainer(
                    title: 'oor'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: '${'oor'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'oor'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          initialValue: _tempSecondary,
                          onChanged: (val) => _tempSecondary = val,
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _oorPrimary = _tempPrimary;
                        _oorSecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'oor'.tr(context, ref),
                    primaryValue: _oorPrimary,
                    secondaryValue: isBilingual ? _oorSecondary : null,
                    onEdit: () => _beginEdit('oor', _oorPrimary, _oorSecondary),
                  ),
                ),

                // 3. District (Maavattam)
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'maavattam',
                  isEditing: _editingSection == 'maavattam',
                  editChild: _buildEditContainer(
                    title: 'maavattam'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: '${'maavattam'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'maavattam'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          initialValue: _tempSecondary,
                          onChanged: (val) => _tempSecondary = val,
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _maavattamPrimary = _tempPrimary;
                        _maavattamSecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'maavattam'.tr(context, ref),
                    primaryValue: _maavattamPrimary,
                    secondaryValue: isBilingual ? _maavattamSecondary : null,
                    onEdit: () => _beginEdit('maavattam', _maavattamPrimary, _maavattamSecondary),
                  ),
                ),

                // 4. State (Maanilam)
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'maanilam',
                  isEditing: _editingSection == 'maanilam',
                  editChild: _buildEditContainer(
                    title: 'maanilam'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsAutocomplete(
                        label: '${'maanilam'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        controller: _primaryController,
                        options: silkIndianStates.map((d) => d[primaryKey]!).toList(),
                        onChanged: (val) {
                          _tempPrimary = val;
                          if (val.isEmpty && isBilingual) {
                            _tempSecondary = '';
                            _secondaryController.clear();
                          }
                        },
                        onSelected: (val) => _handleAutoFill(val, true, silkIndianStates, primaryKey, secondaryKey),
                        searchMatch: (option, query) {
                          final match = silkIndianStates.firstWhere((d) => d[primaryKey] == option, orElse: () => {});
                          if (match.isEmpty) return false;
                          final q = query.toLowerCase();
                          return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                        },
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsAutocomplete(
                          label: '${'maanilam'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          controller: _secondaryController,
                          options: silkIndianStates.map((d) => d[secondaryKey]!).toList(),
                          onChanged: (val) => _tempSecondary = val,
                          onSelected: (val) => _handleAutoFill(val, false, silkIndianStates, primaryKey, secondaryKey),
                          enabled: false,
                          searchMatch: (option, query) {
                            final match = silkIndianStates.firstWhere((d) => d[secondaryKey] == option, orElse: () => {});
                            if (match.isEmpty) return false;
                            final q = query.toLowerCase();
                            return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                          },
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _maanilamPrimary = _tempPrimary;
                        _maanilamSecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'maanilam'.tr(context, ref),
                    primaryValue: _maanilamPrimary,
                    secondaryValue: isBilingual ? _maanilamSecondary : null,
                    onEdit: () => _beginEdit('maanilam', _maanilamPrimary, _maanilamSecondary),
                  ),
                ),

                // 5. Country
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'country',
                  isEditing: _editingSection == 'country',
                  editChild: _buildEditContainer(
                    title: 'countryLabel'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsAutocomplete(
                        label: '${'countryLabel'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        controller: _primaryController,
                        options: silkCountries.map((d) => d[primaryKey]!).toList(),
                        onChanged: (val) => _tempPrimary = val,
                        onSelected: (val) => _handleAutoFill(val, true, silkCountries, primaryKey, secondaryKey),
                        enabled: false,
                        searchMatch: (option, query) {
                          final match = silkCountries.firstWhere((d) => d[primaryKey] == option, orElse: () => {});
                          if (match.isEmpty) return false;
                          final q = query.toLowerCase();
                          return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                        },
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsAutocomplete(
                          label: '${'countryLabel'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          controller: _secondaryController,
                          options: silkCountries.map((d) => d[secondaryKey]!).toList(),
                          onChanged: (val) => _tempSecondary = val,
                          onSelected: (val) => _handleAutoFill(val, false, silkCountries, primaryKey, secondaryKey),
                          enabled: false,
                          searchMatch: (option, query) {
                            final match = silkCountries.firstWhere((d) => d[secondaryKey] == option, orElse: () => {});
                            if (match.isEmpty) return false;
                            final q = query.toLowerCase();
                            return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                          },
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _countryPrimary = _tempPrimary;
                        _countrySecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'countryLabel'.tr(context, ref),
                    primaryValue: _countryPrimary,
                    secondaryValue: isBilingual ? _countrySecondary : null,
                    onEdit: () => _beginEdit('country', _countryPrimary, _countrySecondary),
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
