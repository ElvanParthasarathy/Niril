import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
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
    _countryPrimary = 'இந்தியா';
    _countrySecondary = 'India';
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

  void _handleAutoFill(String val, bool isPrimary, List<Map<String, String>> dataSet) {
    if (isPrimary) {
      final match = dataSet.where((d) => d['ta'] == val).firstOrNull;
      if (match != null) {
        setState(() {
          _tempSecondary = match['en']!;
          _secondaryController.text = _tempSecondary;
        });
      }
    } else {
      final match = dataSet.where((d) => d['en'] == val).firstOrNull;
      if (match != null) {
        setState(() {
          _tempPrimary = match['ta']!;
          _primaryController.text = _tempPrimary;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'settings_mugavari'.tr(context, ref);
    final isBilingual = true; // Assume bilingual is enabled for now

    return ElvanSubpageShell(
      title: title,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElvanSettingsSection(
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
                        label: '${'mugavari'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                        maxLines: 2,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'mugavari'.tr(context, ref)} (${'english'.tr(context, ref)})',
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
                        label: '${'oor'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'oor'.tr(context, ref)} (${'english'.tr(context, ref)})',
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
                        label: '${'maavattam'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'maavattam'.tr(context, ref)} (${'english'.tr(context, ref)})',
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
                        label: '${'maanilam'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        controller: _primaryController,
                        options: silkIndianStates.map((d) => d['ta']!).toList(),
                        onChanged: (val) {
                          _tempPrimary = val;
                          if (val.isEmpty && isBilingual) {
                            _tempSecondary = '';
                            _secondaryController.clear();
                          }
                        },
                        onSelected: (val) => _handleAutoFill(val, true, silkIndianStates),
                        searchMatch: (option, query) {
                          final match = silkIndianStates.firstWhere((d) => d['ta'] == option, orElse: () => {});
                          if (match.isEmpty) return false;
                          final q = query.toLowerCase();
                          return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                        },
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsAutocomplete(
                          label: '${'maanilam'.tr(context, ref)} (${'english'.tr(context, ref)})',
                          controller: _secondaryController,
                          options: silkIndianStates.map((d) => d['en']!).toList(),
                          onChanged: (val) => _tempSecondary = val,
                          onSelected: (val) => _handleAutoFill(val, false, silkIndianStates),
                          enabled: false,
                          searchMatch: (option, query) {
                            final match = silkIndianStates.firstWhere((d) => d['en'] == option, orElse: () => {});
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
                        label: '${'countryLabel'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        controller: _primaryController,
                        options: silkCountries.map((d) => d['ta']!).toList(),
                        onChanged: (val) => _tempPrimary = val,
                        onSelected: (val) => _handleAutoFill(val, true, silkCountries),
                        enabled: false,
                        searchMatch: (option, query) {
                          final match = silkCountries.firstWhere((d) => d['ta'] == option, orElse: () => {});
                          if (match.isEmpty) return false;
                          final q = query.toLowerCase();
                          return match['ta']!.toLowerCase().contains(q) || match['en']!.toLowerCase().contains(q);
                        },
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsAutocomplete(
                          label: '${'countryLabel'.tr(context, ref)} (${'english'.tr(context, ref)})',
                          controller: _secondaryController,
                          options: silkCountries.map((d) => d['en']!).toList(),
                          onChanged: (val) => _tempSecondary = val,
                          onSelected: (val) => _handleAutoFill(val, false, silkCountries),
                          enabled: false,
                          searchMatch: (option, query) {
                            final match = silkCountries.firstWhere((d) => d['en'] == option, orElse: () => {});
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
          ),
        ),
      ],
    );
  }
}
