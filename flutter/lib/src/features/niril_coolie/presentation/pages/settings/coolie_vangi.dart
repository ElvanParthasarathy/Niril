import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/data/vaniga_tharavugal_provider.dart';
import '../../../../settings/data/vaniga_tharavugal.dart';

class CoolieVangiPage extends ConsumerStatefulWidget {
  const CoolieVangiPage({super.key});

  @override
  ConsumerState<CoolieVangiPage> createState() => _CoolieVangiPageState();
}

class _CoolieVangiPageState extends ConsumerState<CoolieVangiPage> {
  String? _editingSection;

  // Temp State for editing
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
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  void _saveSingleField(VanigaTharavugal profile, String fieldName) {
    final updatedProfile = profile.copyWith();
    switch (fieldName) {
      case 'vangiKanakku':
        updatedProfile.vangiKanakku = _tempPrimary;
        break;
      case 'ifsc':
        updatedProfile.ifsc = _tempPrimary;
        break;
    }
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    final profile = ref.watch(vanigaTharavugalProvider);
    final currentProfile = profile ?? VanigaTharavugal();

    final vangiPeyarPrimary = currentProfile.getPrimary('vangiPeyar');
    final vangiPeyarSecondary = currentProfile.getSecondary('vangiPeyar');
    final vangiKilaiPrimary = currentProfile.getPrimary('vangiKilai');
    final vangiKilaiSecondary = currentProfile.getSecondary('vangiKilai');

    return ElvanSubpageShell(
      title: 'vangi'.tr(context, ref),
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
              ElvanSettingsSection(
                dividerIndent: 16.0,
                children: [
                  // --- BANK NAME ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'vangiPeyar',
                    keyPrefix: 'vangiPeyar',
                    editChild: _buildEditContainer(
                      title: 'bankName'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${'bankName'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'bankName'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (v) => _tempSecondary = v,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'vangiPeyar'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'bankName'.tr(context, ref),
                      primaryValue: vangiPeyarPrimary,
                      secondaryValue: isBilingual ? vangiPeyarSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'vangiPeyar', vangiPeyarPrimary, vangiPeyarSecondary),
                    ),
                  ),
                  // --- BRANCH NAME ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'vangiKilai',
                    keyPrefix: 'vangiKilai',
                    editChild: _buildEditContainer(
                      title: 'branchName'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${'branchName'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'branchName'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (v) => _tempSecondary = v,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'vangiKilai'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'branchName'.tr(context, ref),
                      primaryValue: vangiKilaiPrimary,
                      secondaryValue: isBilingual ? vangiKilaiSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'vangiKilai', vangiKilaiPrimary, vangiKilaiSecondary),
                    ),
                  ),
                  // --- ACCOUNT NUMBER ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'kanakkuEn',
                    keyPrefix: 'kanakkuEn',
                    editChild: _buildEditContainer(
                      title: 'accountNumber'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'accountNumber'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveSingleField(currentProfile, 'vangiKanakku'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'accountNumber'.tr(context, ref),
                      primaryValue: currentProfile.vangiKanakku,
                      onEdit: () => _beginEditSingle(
                          'vangiKanakku', currentProfile.vangiKanakku),
                    ),
                  ),
                  // --- IFSC CODE ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'ifscKuriyeedu',
                    keyPrefix: 'ifscKuriyeedu',
                    editChild: _buildEditContainer(
                      title: 'ifscCode'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'ifscCode'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveSingleField(currentProfile, 'ifsc'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'ifscCode'.tr(context, ref),
                      primaryValue: currentProfile.ifsc,
                      onEdit: () =>
                          _beginEditSingle('ifsc', currentProfile.ifsc),
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
