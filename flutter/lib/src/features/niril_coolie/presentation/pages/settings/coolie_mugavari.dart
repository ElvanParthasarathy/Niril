import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';

class CoolieMugavariPage extends ConsumerStatefulWidget {
  const CoolieMugavariPage({super.key});

  @override
  ConsumerState<CoolieMugavariPage> createState() => _CoolieMugavariPageState();
}

class _CoolieMugavariPageState extends ConsumerState<CoolieMugavariPage> {
  String? _editingSection;

  // All blank by default
  String _mugavariPrimary = '';
  String _mugavariSecondary = '';
  String _oorPrimary = '';
  String _oorSecondary = '';
  String _maavattamPrimary = '';
  String _maavattamSecondary = '';
  String _pincode = '';

  String _tempPrimary = '';
  String _tempSecondary = '';

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

  void _beginEditPrimarySecondary(String section, String p, String s) {
    setState(() {
      _tempPrimary = p;
      _tempSecondary = s;
      _editingSection = section;
    });
  }

  void _beginEditSingle(String section, String val) {
    setState(() {
      _tempPrimary = val;
      _editingSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElvanSubpageShell(
      title: 'settings_mugavari'.tr(context, ref),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 32),
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
                          label: '${'mugavari'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
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
                      secondaryValue: _mugavariSecondary,
                      onEdit: () => _beginEditPrimarySecondary('mugavari', _mugavariPrimary, _mugavariSecondary),
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
                        const SizedBox(height: 16),
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
                      secondaryValue: _oorSecondary,
                      onEdit: () => _beginEditPrimarySecondary('oor', _oorPrimary, _oorSecondary),
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
                        const SizedBox(height: 16),
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
                      secondaryValue: _maavattamSecondary,
                      onEdit: () => _beginEditPrimarySecondary('maavattam', _maavattamPrimary, _maavattamSecondary),
                    ),
                  ),

                  // 4. Pincode
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'pincode',
                    isEditing: _editingSection == 'pincode',
                    editChild: _buildEditContainer(
                      title: 'pincode'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'pincode'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _pincode = _tempPrimary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'pincode'.tr(context, ref),
                      primaryValue: _pincode,
                      onEdit: () => _beginEditSingle('pincode', _pincode),
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
