import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';

class SilkVangiPage extends ConsumerStatefulWidget {
  const SilkVangiPage({super.key});

  @override
  ConsumerState<SilkVangiPage> createState() => _SilkVangiPageState();
}

class _SilkVangiPageState extends ConsumerState<SilkVangiPage> {
  String? _editingSection;

  // Empty State
  String _bankNameTamil = '';
  String _bankNameEnglish = '';
  String _branchNameTamil = '';
  String _branchNameEnglish = '';
  String _accountNumber = '';
  String _ifscCode = '';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    ref.listen<String>(primaryLanguageProvider, (previous, next) {
      if (previous != null && previous != next) {
        setState(() {
          final t1 = _bankNameTamil;
          _bankNameTamil = _bankNameEnglish;
          _bankNameEnglish = t1;

          final t2 = _branchNameTamil;
          _branchNameTamil = _branchNameEnglish;
          _branchNameEnglish = t2;
        });
      }
    });

    return ElvanSubpageShell(
      title: 'vangi'.tr(context, ref),
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
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
                    isEditing: _editingSection == 'bankName',
                    keyPrefix: 'bankName',
                    editChild: _buildEditContainer(
                      title: 'bankName'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: '${'bankName'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label: '${'bankName'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (v) => _tempSecondary = v,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _bankNameTamil = _tempPrimary;
                          _bankNameEnglish = _tempSecondary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'bankName'.tr(context, ref),
                      primaryValue: _bankNameTamil,
                      secondaryValue: isBilingual ? _bankNameEnglish : null,
                      onEdit: () {
                        setState(() {
                          _tempPrimary = _bankNameTamil;
                          _tempSecondary = _bankNameEnglish;
                          _editingSection = 'bankName';
                        });
                      },
                    ),
                  ),
                  // --- BRANCH NAME ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'branchName',
                    keyPrefix: 'branchName',
                    editChild: _buildEditContainer(
                      title: 'branchName'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: '${'branchName'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (v) => _tempPrimary = v,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label: '${'branchName'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (v) => _tempSecondary = v,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _branchNameTamil = _tempPrimary;
                          _branchNameEnglish = _tempSecondary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'branchName'.tr(context, ref),
                      primaryValue: _branchNameTamil,
                      secondaryValue: isBilingual ? _branchNameEnglish : null,
                      onEdit: () {
                        setState(() {
                          _tempPrimary = _branchNameTamil;
                          _tempSecondary = _branchNameEnglish;
                          _editingSection = 'branchName';
                        });
                      },
                    ),
                  ),
                  // --- ACCOUNT NUMBER ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'accountNumber',
                    keyPrefix: 'accountNumber',
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
                      onSave: () {
                        setState(() {
                          _accountNumber = _tempPrimary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'accountNumber'.tr(context, ref),
                      primaryValue: _accountNumber,
                      onEdit: () {
                        setState(() {
                          _tempPrimary = _accountNumber;
                          _editingSection = 'accountNumber';
                        });
                      },
                    ),
                  ),
                  // --- IFSC CODE ---
                  ElvanSettingsAnimatedExpand(
                    isEditing: _editingSection == 'ifsc',
                    keyPrefix: 'ifsc',
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
                      onSave: () {
                        setState(() {
                          _ifscCode = _tempPrimary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'ifscCode'.tr(context, ref),
                      primaryValue: _ifscCode,
                      onEdit: () {
                        setState(() {
                          _tempPrimary = _ifscCode;
                          _editingSection = 'ifsc';
                        });
                      },
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
