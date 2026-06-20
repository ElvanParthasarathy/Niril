import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';
import '../../../../../localization/locale_provider.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../../core/widgets/elvan_fullscreen_popup.dart';
import '../../../../../core/widgets/elvan_action_sheet.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';
import '../../../../settings/presentation/widgets/elvan_delete_confirm_modal.dart';
import '../../../../../core/widgets/elvan_bottom_sheet.dart';
import '../../../../../core/widgets/elvan_text_field.dart';

class SilkVanigaAmaippuPage extends ConsumerStatefulWidget {
  const SilkVanigaAmaippuPage({super.key});

  @override
  ConsumerState<SilkVanigaAmaippuPage> createState() => _SilkVanigaAmaippuPageState();
}

class _SilkVanigaAmaippuPageState extends ConsumerState<SilkVanigaAmaippuPage> {
  String? _editingSection;

  // State
  String _niruvanathinPeyarPrimary = '';
  String _niruvanathinPeyarSecondary = '';
  String _shortBusinessName = '';
  String _tholaipesi = '';
  String _mobileNumber = '';
  String _email = '';
  String _gstin = '';

  String _tempPrimary = '';
  String _tempSecondary = '';
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
                onPressed: () {
                  // Do not pop the manage modal!
                  _showNewProfileModal();
                },
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
    String newName = '';
    showElvanActionSheet(
      context: context,
      title: 'addNewProfile'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'createBtn'.tr(context, ref),
      customContent: ElvanTextField(
        textAlign: TextAlign.center,
        onChanged: (val) => newName = val,
        decoration: InputDecoration(
          hintText: 'businessNameLabel'.tr(context, ref),
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
      onConfirm: () {
        if (newName.trim().isNotEmpty) {
          setState(() {
            _niruvanathinPeyarPrimary = newName;
            _niruvanathinPeyarSecondary = '';
            _shortBusinessName = '';
            _tholaipesi = '';
            _mobileNumber = '';
            _email = '';
            _gstin = '';
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
    required List<Widget> inputFields,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return ElvanSettingsEditContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
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
    final title = 'vanigam'.tr(context, ref);
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    ref.listen<String>(primaryLanguageProvider, (previous, next) {
      if (previous != null && previous != next) {
        setState(() {
          final t = _niruvanathinPeyarPrimary;
          _niruvanathinPeyarPrimary = _niruvanathinPeyarSecondary;
          _niruvanathinPeyarSecondary = t;
        });
      }
    });

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
              _buildProfileSwitcher(),
              ElvanSettingsSection(
                  dividerIndent: 16.0,
                  children: [
                    // 1. Business Name (Niruvanathin Peyar)
                    ElvanSettingsAnimatedExpand(
                  keyPrefix: 'business_name',
                  isEditing: _editingSection == 'niruvanathinPeyar',
                  editChild: _buildEditContainer(
                    title: 'businessNameLabel'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: '${'businessNameLabel'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
                        ElvanSettingsTextField(
                          label: '${'businessNameLabel'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                          initialValue: _tempSecondary,
                          onChanged: (val) => _tempSecondary = val,
                        ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _niruvanathinPeyarPrimary = _tempPrimary;
                        _niruvanathinPeyarSecondary = _tempSecondary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'businessNameLabel'.tr(context, ref),
                    primaryValue: _niruvanathinPeyarPrimary,
                    secondaryValue: isBilingual ? _niruvanathinPeyarSecondary : null,
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

                // 3. Phone (Tholaipesi)
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'tholaipesi',
                  isEditing: _editingSection == 'tholaipesi',
                  editChild: _buildEditContainer(
                    title: 'tholaipesiLabel'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: 'tholaipesiLabel'.tr(context, ref),
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _tholaipesi = _tempPrimary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'tholaipesiLabel'.tr(context, ref),
                    primaryValue: _tholaipesi,
                    onEdit: () => _beginEditSingle('tholaipesi', _tholaipesi),
                  ),
                ),

                // 4. Mobile
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'mobile_number',
                  isEditing: _editingSection == 'mobileNumber',
                  editChild: _buildEditContainer(
                    title: 'mobileLabel'.tr(context, ref),
                    inputFields: [
                      ElvanSettingsTextField(
                        label: 'mobileLabel'.tr(context, ref),
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _mobileNumber = _tempPrimary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'mobileLabel'.tr(context, ref),
                    primaryValue: _mobileNumber,
                    onEdit: () => _beginEditSingle('mobileNumber', _mobileNumber),
                  ),
                ),

                // 5. Email
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

                // 6. GSTIN
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'gstin',
                  isEditing: _editingSection == 'gstin',
                  editChild: _buildEditContainer(
                    title: 'GSTIN / Tax ID', // Default fallback string like React
                    inputFields: [
                      ElvanSettingsTextField(
                        label: 'GSTIN / Tax ID',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                    ],
                    onCancel: () => setState(() => _editingSection = null),
                    onSave: () {
                      setState(() {
                        _gstin = _tempPrimary;
                        _editingSection = null;
                      });
                      _showSuccessToast();
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'GSTIN / Tax ID',
                    primaryValue: _gstin,
                    onEdit: () => _beginEditSingle('gstin', _gstin),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ],
    ); // Closes ElvanSubpageShell
  }
}
