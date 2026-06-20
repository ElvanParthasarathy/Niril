import 'package:flutter/material.dart';
import '../../../../../localization/locale_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../../core/widgets/elvan_fullscreen_popup.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';
import '../../../../../core/widgets/elvan_action_sheet.dart';
import '../../../../settings/presentation/widgets/elvan_delete_confirm_modal.dart';
import '../../../../../core/widgets/elvan_bottom_sheet.dart';
import '../../../../../core/widgets/elvan_text_field.dart';

class CoolieVanigaAmaippuPage extends ConsumerStatefulWidget {
  const CoolieVanigaAmaippuPage({super.key});

  @override
  ConsumerState<CoolieVanigaAmaippuPage> createState() => _CoolieVanigaAmaippuPageState();
}

class _CoolieVanigaAmaippuPageState extends ConsumerState<CoolieVanigaAmaippuPage> {
  String? _editingSection;

  // State – blank by default
  String _niruvanathinPeyarPrimary = '';
  String _niruvanathinPeyarSecondary = '';
  String _shortBusinessName = '';
  List<String> _phones = [];
  String _email = '';

  String _tempPrimary = '';
  String _tempSecondary = '';
  List<String> _tempPhones = [];

  final ValueNotifier<bool> _hasProfiles = ValueNotifier(false);

  void _showSuccessToast() {
    ElvanSnackbar.show(context, 'profileSaved'.tr(context, ref));
  }

  void _showBusinessSelectorModal() {
    final List<String> businesses = [
      _niruvanathinPeyarPrimary.isEmpty ? 'activeProfile'.tr(context, ref) : _niruvanathinPeyarPrimary,
    ];

    showElvanSelectionBottomSheet(
      context: context,
      title: 'activeProfile'.tr(context, ref),
      items: businesses,
      currentValue: _niruvanathinPeyarPrimary.isEmpty ? 'activeProfile'.tr(context, ref) : _niruvanathinPeyarPrimary,
      onSelected: (val) {},
    );
  }



  void _showManageProfilesModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Manage Profiles',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: FloatingActionButton(
                onPressed: _showNewProfileModal,
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.add),
              ),
            ),
            body: ElvanFullscreenPopup(
              title: 'vaniga_nirvagam'.tr(context, ref),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _hasProfiles,
                      builder: (context, hasProfiles, _) {
                        if (!hasProfiles) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'noSavedProfiles'.tr(context, ref),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            ElvanSettingsSection(
                              children: [
                                ElvanSettingsDisplayRow(
                                  title: 'activeProfile'.tr(context, ref),
                                  primaryValue: _niruvanathinPeyarPrimary.isEmpty ? 'activeProfile'.tr(context, ref) : _niruvanathinPeyarPrimary,
                                  icon: CupertinoIcons.delete_solid,
                                  onEdit: () => showElvanDeleteConfirmModal(context, ref, () {
                                    _hasProfiles.value = false;
                                    setState(() {
                                      _niruvanathinPeyarPrimary = '';
                                    });
                                    setModalState(() {});
                                    ElvanSnackbar.show(context, 'profileDeleted'.tr(context, ref));
                                  }),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _showNewProfileModal() {
    String newNamePrimary = '';
    String newNameSecondary = '';
    showElvanActionSheet(
      context: context,
      title: 'createNewProfileModalTitle'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'createBtn'.tr(context, ref),
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElvanTextField(
            textAlign: TextAlign.center,
            onChanged: (val) => newNamePrimary = val,
            decoration: InputDecoration(
              hintText: '${'businessNameLabel'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);
                }
                return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
              }),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ElvanTextField(
            textAlign: TextAlign.center,
            onChanged: (val) => newNameSecondary = val,
            decoration: InputDecoration(
              hintText: '${'businessNameLabel'.tr(context, ref)} (${'english'.tr(context, ref)})',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);
                }
                return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
              }),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      onConfirm: () {
        if (newNamePrimary.trim().isNotEmpty) {
          setState(() {
            _niruvanathinPeyarPrimary = newNamePrimary;
            _niruvanathinPeyarSecondary = newNameSecondary;
            _shortBusinessName = '';
            _phones = [];
            _email = '';
            _hasProfiles.value = true;
          });
          _showSuccessToast();
        }
      },
    );
  }

  Widget _buildProfileSwitcher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _showManageProfilesModal,
            icon: Icon(
              CupertinoIcons.briefcase_fill,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            style: IconButton.styleFrom(
              backgroundColor: cardColor,
              foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fixedSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: _showBusinessSelectorModal,
              style: TextButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _niruvanathinPeyarPrimary.isEmpty ? 'activeProfile'.tr(context, ref) : _niruvanathinPeyarPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditContainer({
    required String title,
    Widget? titleTrailing,
    Widget? bottomLeading,
    required List<Widget> inputFields,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return ElvanSettingsEditContainer(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (titleTrailing != null) titleTrailing,
            ],
          ),
          const SizedBox(height: 16),
          ...inputFields,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (bottomLeading != null) ...[
                bottomLeading,
                const SizedBox(width: 8),
              ],
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

  void _beginEditPhones(List<String> phones) {
    setState(() {
      _tempPhones = List.from(phones);
      if (_tempPhones.isEmpty) {
        _tempPhones.add('');
      }
      _editingSection = 'phone';
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = 'vanigam'.tr(context, ref);

    return ElvanSubpageShell(
      title: title,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 32),
          sliver: SliverList.list(
            children: [
              _buildProfileSwitcher(),
              ElvanSettingsSection(
                dividerIndent: 16.0,
                children: [
                  // 1. Business Name
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'business_name',
                    isEditing: _editingSection == 'niruvanathinPeyar',
                    editChild: _buildEditContainer(
                      title: 'businessNameLabel'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: '${'businessNameLabel'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        const SizedBox(height: 16),
                        ElvanSettingsTextField(
                          label: '${'businessNameLabel'.tr(context, ref)} (${'english'.tr(context, ref)})',
                          initialValue: _tempSecondary,
                          onChanged: (val) => _tempSecondary = val,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _niruvanathinPeyarPrimary = _tempPrimary;
                          _niruvanathinPeyarSecondary = _tempSecondary;
                          _hasProfiles.value = _tempPrimary.isNotEmpty;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'businessNameLabel'.tr(context, ref),
                      primaryValue: _niruvanathinPeyarPrimary,
                      secondaryValue: _niruvanathinPeyarSecondary,
                      onEdit: () => _beginEditPrimarySecondary('niruvanathinPeyar', _niruvanathinPeyarPrimary, _niruvanathinPeyarSecondary),
                    ),
                  ),

                  // 2. Short Business Name
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'short_business_name',
                    isEditing: _editingSection == 'shortBusinessName',
                    editChild: _buildEditContainer(
                      title: 'shortBusinessName'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'shortBusinessName'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _shortBusinessName = _tempPrimary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'shortBusinessName'.tr(context, ref),
                      primaryValue: _shortBusinessName,
                      onEdit: () => _beginEditSingle('shortBusinessName', _shortBusinessName),
                    ),
                  ),

                  // 3. Phone
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'phone',
                    isEditing: _editingSection == 'phone',
                    editChild: _buildEditContainer(
                      title: 'tholaipesiLabel'.tr(context, ref),
                      bottomLeading: _tempPhones.length < 2
                          ? TextButton(
                              onPressed: () {
                                setState(() {
                                  _tempPhones.add('');
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              child: Text('add'.tr(context, ref)),
                            )
                          : null,
                      inputFields: [
                        ..._tempPhones.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final phone = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ElvanSettingsTextField(
                              label: 'tholaipesiLabel'.tr(context, ref),
                              initialValue: phone,
                              onChanged: (val) {
                                _tempPhones[idx] = val;
                              },
                              keyboardType: TextInputType.phone,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _tempPhones.removeAt(idx);
                                    });
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  style: IconButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _phones = List.from(_tempPhones);
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'tholaipesiLabel'.tr(context, ref),
                      primaryValue: _phones.where((p) => p.trim().isNotEmpty).join(', '),
                      onEdit: () => _beginEditPhones(_phones),
                    ),
                  ),

                  // 4. Email
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'email',
                    isEditing: _editingSection == 'email',
                    editChild: _buildEditContainer(
                      title: 'email'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'email'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () {
                        setState(() {
                          _email = _tempPrimary;
                          _editingSection = null;
                        });
                        _showSuccessToast();
                      },
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'email'.tr(context, ref),
                      primaryValue: _email,
                      onEdit: () => _beginEditSingle('email', _email),
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
