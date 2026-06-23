import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';
import '../../../../settings/data/vaniga_tharavugal_provider.dart';
import '../../../../settings/data/vaniga_tharavugal.dart';

class CoolieMugavariPage extends ConsumerStatefulWidget {
  const CoolieMugavariPage({super.key});

  @override
  ConsumerState<CoolieMugavariPage> createState() => _CoolieMugavariPageState();
}

class _CoolieMugavariPageState extends ConsumerState<CoolieMugavariPage> {
  String? _editingSection;

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
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
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
      case 'anchalkuriyeedu':
        updatedProfile.anchalkuriyeedu = _tempPrimary;
        break;
    }
    ref.read(vanigaTharavugalListProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    final profile = ref.watch(vanigaTharavugalProvider);
    final currentProfile = profile ?? VanigaTharavugal();

    final mugavariPrimary = currentProfile.getPrimary('mugavari');
    final mugavariSecondary = currentProfile.getSecondary('mugavari');
    final oorPrimary = currentProfile.getPrimary('oor');
    final oorSecondary = currentProfile.getSecondary('oor');
    final maavattamPrimary = currentProfile.getPrimary('maavattam');
    final maavattamSecondary = currentProfile.getSecondary('maavattam');

    return ElvanSubpageShell(
      title: 'settings_mugavari'.tr(context, ref),
      slivers: [
        SliverPadding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 32),
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
                          label:
                              '${'mugavari'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          maxLines: 2,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'mugavari'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
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
                      title: 'mugavari'.tr(context, ref),
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
                      title: 'oor'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${'oor'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'oor'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveBilingualField(currentProfile, 'oor'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'oor'.tr(context, ref),
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
                      title: 'maavattam'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${'maavattam'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'maavattam'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'maavattam'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'maavattam'.tr(context, ref),
                      primaryValue: maavattamPrimary,
                      secondaryValue: isBilingual ? maavattamSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'maavattam', maavattamPrimary, maavattamSecondary),
                    ),
                  ),

                  // 4. Pincode
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'anchalkuriyeedu',
                    isEditing: _editingSection == 'anchalkuriyeedu',
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
                      onSave: () =>
                          _saveSingleField(currentProfile, 'anchalkuriyeedu'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'pincode'.tr(context, ref),
                      primaryValue: currentProfile.anchalkuriyeedu,
                      onEdit: () => _beginEditSingle(
                          'anchalkuriyeedu', currentProfile.anchalkuriyeedu),
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
