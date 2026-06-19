import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../shell/presentation/mobile/elvan_fullscreen_popup.dart';
import '../../../../settings/presentation/widgets/elvan_action_sheet.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';
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
  final ValueNotifier<bool> _hasProfiles = ValueNotifier(true);

  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle, 
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              'profileSaved'.tr(context, ref),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        elevation: 8,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      ),
    );
  }

  void _showBusinessSelectorModal() {
    final List<String> businesses = [
      _niruvanathinPeyarPrimary.isEmpty ? 'ஸ்ரீ ஜெய்பிரியா சில்க்ஸ்' : _niruvanathinPeyarPrimary,
      'Test Business 1',
      'Test Business 2',
      'Test Business 3',
    ];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF111111) 
          : Colors.white,
      builder: (BuildContext context) {
        return ElvanSettingsSelectionBottomSheet(
          title: 'switchProfile'.tr(context, ref),
          items: businesses,
          currentValue: businesses.first,
          onSelected: (value) {
            Navigator.pop(context);
            // State update logic for business switching goes here in the future
          },
        );
      },
    );
  }

  void _showDeleteConfirmModal() {
    showElvanActionSheet(
      context: context,
      title: 'permanentlyDeleteProfile'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'deleteBtn'.tr(context, ref),
      customContent: ElvanTextField(
        textAlign: TextAlign.center,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'password'.tr(context, ref),
          hintStyle: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
        _hasProfiles.value = false;
      },
    );
  }

  void _showManageProfilesModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Manage Profiles',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
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
                                  primaryValue: _niruvanathinPeyarPrimary.isEmpty ? 'ஸ்ரீ ஜெய்பிரியா சில்க்ஸ்' : _niruvanathinPeyarPrimary,
                                  icon: CupertinoIcons.delete_solid,
                                  onEdit: _showDeleteConfirmModal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElvanSettingsSection(
                              children: [
                                ElvanSettingsDisplayRow(
                                  title: 'profile'.tr(context, ref),
                                  primaryValue: 'Test Business 1',
                                  icon: CupertinoIcons.delete_solid,
                                  onEdit: _showDeleteConfirmModal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElvanSettingsSection(
                              children: [
                                ElvanSettingsDisplayRow(
                                  title: 'profile'.tr(context, ref),
                                  primaryValue: 'Test Business 2',
                                  icon: CupertinoIcons.delete_solid,
                                  onEdit: _showDeleteConfirmModal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElvanSettingsSection(
                              children: [
                                ElvanSettingsDisplayRow(
                                  title: 'profile'.tr(context, ref),
                                  primaryValue: 'Test Business 3',
                                  icon: CupertinoIcons.delete_solid,
                                  onEdit: _showDeleteConfirmModal,
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
          fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
                          _niruvanathinPeyarPrimary.isEmpty ? 'ஸ்ரீ ஜெய்பிரியா சில்க்ஸ்' : _niruvanathinPeyarPrimary,
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
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showManageProfilesModal,
                icon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M237.94,107.21a8,8,0,0,0-3.89-5.4l-29.83-17-.12-33.62a8,8,0,0,0-2.83-6.08,111.91,111.91,0,0,0-36.72-20.67,8,8,0,0,0-6.46.59L128,41.85,97.88,25a8,8,0,0,0-6.47-.6A111.92,111.92,0,0,0,54.73,45.15a8,8,0,0,0-2.83,6.07l-.15,33.65-29.83,17a8,8,0,0,0-3.89,5.4,106.47,106.47,0,0,0,0,41.56,8,8,0,0,0,3.89,5.4l29.83,17,.12,33.63a8,8,0,0,0,2.83,6.08,111.91,111.91,0,0,0,36.72,20.67,8,8,0,0,0,6.46-.59L128,214.15,158.12,231a7.91,7.91,0,0,0,3.9,1,8.09,8.09,0,0,0,2.57-.42,112.1,112.1,0,0,0,36.68-20.73,8,8,0,0,0,2.83-6.07l.15-33.65,29.83-17a8,8,0,0,0,3.89-5.4A106.47,106.47,0,0,0,237.94,107.21ZM128,168a40,40,0,1,1,40-40A40,40,0,0,1,128,168Z"></path></svg>',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fixedSize: const Size(48, 48),
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
    final isBilingual = true;

    return ElvanSubpageShell(
      title: title,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
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
                        label: '${'businessNameLabel'.tr(context, ref)} (${'tamil'.tr(context, ref)})',
                        initialValue: _tempPrimary,
                        onChanged: (val) => _tempPrimary = val,
                      ),
                      if (isBilingual) const SizedBox(height: 16),
                      if (isBilingual)
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
              ], // Closes Column children
            ), // Closes Column
          ), // Closes Padding
        ), // Closes SliverToBoxAdapter
      ], // Closes slivers
    ); // Closes ElvanSubpageShell
  }
}
