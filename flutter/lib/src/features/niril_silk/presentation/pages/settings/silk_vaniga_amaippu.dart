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
import '../../../../settings/presentation/widgets/elvan_delete_confirm_modal.dart';
import '../../../../../core/widgets/elvan_bottom_sheet.dart';
import '../../../../../core/widgets/elvan_text_field.dart';
import '../../../../settings/data/vaniga_tharavugal_provider.dart';
import '../../../../settings/data/vaniga_tharavugal.dart';

class SilkVanigaAmaippuPage extends ConsumerStatefulWidget {
  const SilkVanigaAmaippuPage({super.key});

  @override
  ConsumerState<SilkVanigaAmaippuPage> createState() =>
      _SilkVanigaAmaippuPageState();
}

class _SilkVanigaAmaippuPageState extends ConsumerState<SilkVanigaAmaippuPage> {
  String? _editingSection;

  String _tempPrimary = '';
  String _tempSecondary = '';
  bool _showExtraPhone = false;

  void _savePhoneNumbers(VanigaTharavugal currentProfile) {
    currentProfile.tholaipesi1 = _tempPrimary;
    currentProfile.tholaipesi2 = _showExtraPhone ? _tempSecondary : '';
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(currentProfile);
    setState(() {
      _editingSection = null;
      _showExtraPhone = false;
    });
    _showSuccessToast();
  }

  void _showSuccessToast() {
    ElvanSnackbar.show(context, 'profileSaved'.tr(context, ref));
  }

  void _showBusinessSelectorModal() {
    final profile = ref.read(vanigaTharavugalProvider);
    final primaryName = profile?.getPrimary('niruvanathinPeyar') ?? '';
    final displayName =
        primaryName.isEmpty ? 'activeProfile'.tr(context, ref) : primaryName;

    final List<String> businesses = [displayName];

    showElvanSelectionBottomSheet(
      context: context,
      title: 'activeProfile'.tr(context, ref),
      items: businesses,
      currentValue: displayName,
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
                      _showNewProfileModal();
                    },
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.add),
                  ),
                ),
                body: Consumer(builder: (context, ref, child) {
                  final profile = ref.watch(vanigaTharavugalProvider);
                  final hasProfile = profile != null;

                  return ElvanFullscreenPopup(
                    title: 'vaniga_nirvagam'.tr(context, ref),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: !hasProfile
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      'noSavedProfiles'.tr(context, ref),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ElvanSettingsSection(
                                      children: [
                                        ElvanSettingsDisplayRow(
                                          title:
                                              'activeProfile'.tr(context, ref),
                                          primaryValue: profile
                                                  .getPrimary(
                                                      'niruvanathinPeyar')
                                                  .isEmpty
                                              ? 'activeProfile'.tr(context, ref)
                                              : profile.getPrimary(
                                                  'niruvanathinPeyar'),
                                          icon: CupertinoIcons.delete_solid,
                                          onEdit: () =>
                                              showElvanDeleteConfirmModal(
                                                  context, ref, () {
                                            ref
                                                .read(vanigaTharavugalProvider
                                                    .notifier)
                                                .clearProfile();
                                            ElvanSnackbar.show(
                                                context,
                                                'profileDeleted'
                                                    .tr(context, ref));
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          filled: true,
          fillColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.12);
            }
            return Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08);
          }),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          final newProfile = VanigaTharavugal();
          newProfile.setBilingual(
              'niruvanathinPeyar', newProfile.mudhanMozhi, newName);
          ref.read(vanigaTharavugalProvider.notifier).updateProfile(newProfile);
          _showSuccessToast();
        }
      },
    );
  }

  Widget _buildProfileSwitcher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final profile = ref.watch(vanigaTharavugalProvider);
    final primaryName = profile?.getPrimary('niruvanathinPeyar') ?? '';
    final displayName =
        primaryName.isEmpty ? 'activeProfile'.tr(context, ref) : primaryName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _showManageProfilesModal,
            icon: Icon(
              CupertinoIcons.briefcase_fill,
              size: 24,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            style: IconButton.styleFrom(
              backgroundColor: cardColor,
              foregroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayName,
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
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
      case 'kurumPeyar':
        updatedProfile.kurumPeyar = _tempPrimary;
        break;
      case 'tholaipesi_1':
        updatedProfile.tholaipesi1 = _tempPrimary;
        break;
      case 'tholaipesi_2':
        updatedProfile.tholaipesi2 = _tempPrimary;
        break;
      case 'minnanchal':
        updatedProfile.minnanchal = _tempPrimary;
        break;
      case 'gstin':
        updatedProfile.gstin = _tempPrimary;
        break;
    }
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'vanigam'.tr(context, ref);
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider).toLowerCase();
    final secondaryLang = ref.watch(secondaryLanguageProvider).toLowerCase();

    final profile = ref.watch(vanigaTharavugalProvider);
    final currentProfile = profile ?? VanigaTharavugal();

    final niruvanathinPeyarPrimary =
        currentProfile.getPrimary('niruvanathinPeyar');
    final niruvanathinPeyarSecondary =
        currentProfile.getSecondary('niruvanathinPeyar');

    final adaimozhiPrimary = currentProfile.getPrimary('adaimozhi');
    final adaimozhiSecondary = currentProfile.getSecondary('adaimozhi');

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
                          label:
                              '${'businessNameLabel'.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'businessNameLabel'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveBilingualField(
                          currentProfile, 'niruvanathinPeyar'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'businessNameLabel'.tr(context, ref),
                      primaryValue: niruvanathinPeyarPrimary,
                      secondaryValue:
                          isBilingual ? niruvanathinPeyarSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'niruvanathinPeyar',
                          niruvanathinPeyarPrimary,
                          niruvanathinPeyarSecondary),
                    ),
                  ),

                  // 2. Short Business Name
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'short_business_name',
                    isEditing: _editingSection == 'kurumPeyar',
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
                      onSave: () =>
                          _saveSingleField(currentProfile, 'kurumPeyar'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'shortBusinessName'.tr(context, ref),
                      primaryValue: currentProfile.kurumPeyar,
                      onEdit: () => _beginEditSingle(
                          'kurumPeyar', currentProfile.kurumPeyar),
                    ),
                  ),

                  // Tagline
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'adaimozhi',
                    isEditing: _editingSection == 'adaimozhi',
                    editChild: _buildEditContainer(
                      title: 'adaimozhi'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: isBilingual
                              ? '${'adaimozhi'.tr(context, ref)} (${primaryLang.tr(context, ref)})'
                              : 'adaimozhi'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${'adaimozhi'.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'adaimozhi'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'adaimozhi'.tr(context, ref),
                      primaryValue: adaimozhiPrimary,
                      secondaryValue: isBilingual ? adaimozhiSecondary : null,
                      onEdit: () => _beginEditPrimarySecondary(
                          'adaimozhi', adaimozhiPrimary, adaimozhiSecondary),
                    ),
                  ),

                  // 3. Phone Numbers
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'tholaipesigal',
                    isEditing: _editingSection == 'tholaipesigal',
                    editChild: _buildEditContainer(
                      title: 'phoneNumbers'.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'tholaipesiLabel'.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.phone,
                        ),
                        if (_showExtraPhone) const SizedBox(height: 16),
                        if (_showExtraPhone)
                          ElvanSettingsTextField(
                            label: 'mobileLabel'.tr(context, ref),
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                            keyboardType: TextInputType.phone,
                          ),
                        if (!_showExtraPhone) const SizedBox(height: 16),
                        if (!_showExtraPhone)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _showExtraPhone = true),
                              icon: const Icon(CupertinoIcons.add_circled),
                              label: Text('addAlternateMobile'.tr(context, ref)),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                      onCancel: () => setState(() {
                        _editingSection = null;
                        _showExtraPhone = false;
                      }),
                      onSave: () => _savePhoneNumbers(currentProfile),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'phoneNumbers'.tr(context, ref),
                      primaryValue: currentProfile.tholaipesi1,
                      secondaryValue: currentProfile.tholaipesi2.isNotEmpty ? currentProfile.tholaipesi2 : null,
                      onEdit: () => setState(() {
                        _editingSection = 'tholaipesigal';
                        _tempPrimary = currentProfile.tholaipesi1;
                        _tempSecondary = currentProfile.tholaipesi2;
                        _showExtraPhone = currentProfile.tholaipesi2.isNotEmpty;
                      }),
                    ),
                  ),

                  // 5. Email
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'email',
                    isEditing: _editingSection == 'minnanchal',
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
                      onSave: () =>
                          _saveSingleField(currentProfile, 'minnanchal'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'email'.tr(context, ref),
                      primaryValue: currentProfile.minnanchal,
                      onEdit: () => _beginEditSingle(
                          'minnanchal', currentProfile.minnanchal),
                    ),
                  ),

                  // 6. GSTIN
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'gstin',
                    isEditing: _editingSection == 'gstin',
                    editChild: _buildEditContainer(
                      title: 'GSTIN / Tax ID',
                      inputFields: [
                        ElvanSettingsTextField(
                          label: 'GSTIN / Tax ID',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveSingleField(currentProfile, 'gstin'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: 'GSTIN / Tax ID',
                      primaryValue: currentProfile.gstin,
                      onEdit: () =>
                          _beginEditSingle('gstin', currentProfile.gstin),
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
