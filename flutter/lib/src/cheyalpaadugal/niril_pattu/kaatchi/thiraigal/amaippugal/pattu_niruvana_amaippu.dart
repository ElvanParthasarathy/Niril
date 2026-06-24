import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../chattagam/kaatchi/kaippaesi/elvan_utpakkach_chattagam.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_muzhuthirai_maeladukku.dart';
import '../../../../../koorugal/maeladukkugal/elvan_cheyal_maeladukku.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_amaippu_pagudhi.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_amaippu_thirutha_attai.dart';
import '../../../../amaippugal/kaatchi/koorugal/elvan_azhippu_urudhi_maeladukku.dart';
import '../../../../../koorugal/maeladukkugal/elvan_kizh_maeladukku.dart';
import '../../../../../koorugal/ulleedugal/elvan_ulleedu.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal_provider.dart';
import '../../../../amaippugal/tharavu/vaniga_tharavugal.dart';

class SilkNiruvanaAmaippuPage extends ConsumerStatefulWidget {
  const SilkNiruvanaAmaippuPage({super.key});

  @override
  ConsumerState<SilkNiruvanaAmaippuPage> createState() =>
      _SilkNiruvanaAmaippuPageState();
}

class _SilkNiruvanaAmaippuPageState extends ConsumerState<SilkNiruvanaAmaippuPage> {
  String? _editingSection;

  String _tempPrimary = '';
  String _tempSecondary = '';
  bool _showExtraPhone = false;

  void _savePhoneNumbers(VanigaTharavugal currentProfile) {
    currentProfile.tholaipaesi1 = _tempPrimary;
    currentProfile.tholaipaesi2 = _showExtraPhone ? _tempSecondary : '';
    ref.read(vanigaTharavugalListProvider.notifier).updateProfile(currentProfile);
    setState(() {
      _editingSection = null;
      _showExtraPhone = false;
    });
    _showSuccessToast();
  }

  void _showSuccessToast() {
    ElvanSnackbar.show(context, K.thannuruChaemikkappattadhu.tr(context, ref));
  }

  void _showBusinessSelectorModal() {
    final profiles = ref.read(vanigaTharavugalListProvider);
    final activeProfile = ref.read(vanigaTharavugalProvider);

    final items = profiles.map((p) {
      final name = p.getPrimary('niruvanathinPeyar');
      return name.isEmpty ? K.tharpoadhaiyaNiruvanam.tr(context, ref) : name;
    }).toList();

    final activeName = activeProfile != null
        ? (activeProfile.getPrimary('niruvanathinPeyar').isEmpty
            ? K.tharpoadhaiyaNiruvanam.tr(context, ref)
            : activeProfile.getPrimary('niruvanathinPeyar'))
        : '';

    showElvanSelectionBottomSheet(
      context: context,
      title: K.tharpoadhaiyaNiruvanam.tr(context, ref),
      items: items,
      currentValue: activeName,
      onSelected: (val) {
        final idx = items.indexOf(val);
        if (idx >= 0 && profiles[idx].id != null) {
          ref.read(vanigaTharavugalListProvider.notifier).setActiveProfile(profiles[idx].id!);
        }
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog.fullscreen(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: Consumer(builder: (context, ref, _) {
                  final profiles = ref.watch(vanigaTharavugalListProvider);
                  if (profiles.length >= maxProfiles) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        _showNewProfileModal();
                      },
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.add),
                    ),
                  );
                }),
                body: Consumer(builder: (context, ref, child) {
                  final profiles = ref.watch(vanigaTharavugalListProvider);
                  final activeProfile = ref.watch(vanigaTharavugalProvider);
                  final hasProfiles = profiles.isNotEmpty;

                  return ElvanFullscreenPopup(
                    title: K.neriyuga.tr(context, ref),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: !hasProfiles
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      K.thannurukkalIllai.tr(context, ref),
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
                                        for (final profile in profiles)
                                          ElvanSettingsDisplayRow(
                                            title: profile.id == activeProfile?.id
                                                ? K.tharpoadhaiyaNiruvanam.tr(context, ref)
                                                : '',
                                            primaryValue: profile
                                                    .getPrimary(
                                                        'niruvanathinPeyar')
                                                    .isEmpty
                                                ? K.tharpoadhaiyaNiruvanam.tr(context, ref)
                                                : profile.getPrimary(
                                                    'niruvanathinPeyar'),
                                            icon: CupertinoIcons.delete_solid,
                                            onTap: profile.id != activeProfile?.id
                                                ? () {
                                                    ref.read(vanigaTharavugalListProvider.notifier)
                                                        .setActiveProfile(profile.id!);
                                                  }
                                                : null,
                                            onEdit: () =>
                                                showElvanDeleteConfirmModal(
                                                    context, ref, () {
                                              ref
                                                  .read(vanigaTharavugalListProvider
                                                      .notifier)
                                                  .deleteProfile(profile.id!);
                                              ElvanSnackbar.show(
                                                  context,
                                                  K.thannuruNeekkappattadhu
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
      title: K.pudhiyaThannuruChaer.tr(context, ref),
      cancelText: K.kaividuPtn.tr(context, ref),
      confirmText: K.uruvaakkuPtn.tr(context, ref),
      customContent: ElvanTextField(
        textAlign: TextAlign.center,
        onChanged: (val) => newName = val,
        decoration: InputDecoration(
          hintText: K.niruvanathinPeyar.tr(context, ref),
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
          final profiles = ref.read(vanigaTharavugalListProvider);
          if (profiles.length >= maxProfiles) {
            ElvanSnackbar.show(context, K.perumalavu5thannuru.tr(context, ref));
            return;
          }

          final newProfile = VanigaTharavugal();
          newProfile.iruMozhi = true;
          newProfile.setBilingual(
              'niruvanathinPeyar', newProfile.mudhanMozhi, newName);
          ref.read(vanigaTharavugalListProvider.notifier).createProfile(newProfile);
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
        primaryName.isEmpty ? K.tharpoadhaiyaNiruvanam.tr(context, ref) : primaryName;

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
                    const EdgeInsets.symmetric(horizontal: 20),
                fixedSize: const Size.fromHeight(48),
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
    Widget? extraAction,
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
              if (extraAction != null) ...[
                extraAction,
              ],
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                child: Text(K.kaividuPtn.tr(context, ref)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: Text(K.chaemiPtn.tr(context, ref)),
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
      case 'kurumPeyar':
        updatedProfile.kurumPeyar = _tempPrimary;
        break;
      case 'tholaipesi_1':
        updatedProfile.tholaipaesi1 = _tempPrimary;
        break;
      case 'tholaipesi_2':
        updatedProfile.tholaipaesi2 = _tempPrimary;
        break;
      case 'minnanjal':
        updatedProfile.minnanjal = _tempPrimary;
        break;
      case 'gstin':
        updatedProfile.gstin = _tempPrimary;
        break;
    }
    ref.read(vanigaTharavugalListProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  @override
  Widget build(BuildContext context) {
    final title = K.niruvanam.tr(context, ref);
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
                      title: K.niruvanathinPeyar.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label:
                              '${K.niruvanathinPeyar.tr(context, ref)} (${primaryLang.tr(context, ref)})',
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${K.niruvanathinPeyar.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveBilingualField(
                          currentProfile, 'niruvanathinPeyar'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.niruvanathinPeyar.tr(context, ref),
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
                      title: K.kurugiyaNiruvanaPeyar.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: K.kurugiyaNiruvanaPeyar.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveSingleField(currentProfile, 'kurumPeyar'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.kurugiyaNiruvanaPeyar.tr(context, ref),
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
                      title: K.adaimozhi.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: isBilingual
                              ? '${K.adaimozhi.tr(context, ref)} (${primaryLang.tr(context, ref)})'
                              : K.adaimozhi.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                        if (isBilingual) const SizedBox(height: 16),
                        if (isBilingual)
                          ElvanSettingsTextField(
                            label:
                                '${K.adaimozhi.tr(context, ref)} (${secondaryLang.tr(context, ref)})',
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                          ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveBilingualField(currentProfile, 'adaimozhi'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.adaimozhi.tr(context, ref),
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
                      title: K.paesiEnkal.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: K.paesiEn.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.phone,
                        ),
                        if (_showExtraPhone) const SizedBox(height: 16),
                        if (_showExtraPhone)
                          ElvanSettingsTextField(
                            label: K.maatruPaesiEn.tr(context, ref),
                            initialValue: _tempSecondary,
                            onChanged: (val) => _tempSecondary = val,
                            keyboardType: TextInputType.phone,
                            suffixIcon: IconButton(
                              icon: const Icon(CupertinoIcons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _tempSecondary = '';
                                  _showExtraPhone = false;
                                });
                              },
                            ),
                          ),
                      ],
                      extraAction: !_showExtraPhone
                          ? TextButton(
                              onPressed: () => setState(() => _showExtraPhone = true),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              child: Text(K.chaer.tr(context, ref)),
                            )
                          : null,
                      onCancel: () => setState(() {
                        _editingSection = null;
                        _showExtraPhone = false;
                      }),
                      onSave: () => _savePhoneNumbers(currentProfile),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.paesiEnkal.tr(context, ref),
                      primaryValue: currentProfile.tholaipaesi1,
                      secondaryValue: currentProfile.tholaipaesi2.isNotEmpty ? currentProfile.tholaipaesi2 : null,
                      onEdit: () => setState(() {
                        _editingSection = 'tholaipesigal';
                        _tempPrimary = currentProfile.tholaipaesi1;
                        _tempSecondary = currentProfile.tholaipaesi2;
                        _showExtraPhone = currentProfile.tholaipaesi2.isNotEmpty;
                      }),
                    ),
                  ),

                  // 5. Email
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'minnanjal',
                    isEditing: _editingSection == 'minnanjal',
                    editChild: _buildEditContainer(
                      title: K.minnanjal.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: K.minnanjal.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () =>
                          _saveSingleField(currentProfile, 'minnanjal'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.minnanjal.tr(context, ref),
                      primaryValue: currentProfile.minnanjal,
                      onEdit: () => _beginEditSingle(
                          'minnanjal', currentProfile.minnanjal),
                    ),
                  ),

                  // 6. GSTIN
                  ElvanSettingsAnimatedExpand(
                    keyPrefix: 'gstin',
                    isEditing: _editingSection == 'gstin',
                    editChild: _buildEditContainer(
                      title: K.gstinVariAdaiyaalaEn.tr(context, ref),
                      inputFields: [
                        ElvanSettingsTextField(
                          label: K.gstinVariAdaiyaalaEn.tr(context, ref),
                          initialValue: _tempPrimary,
                          onChanged: (val) => _tempPrimary = val,
                        ),
                      ],
                      onCancel: () => setState(() => _editingSection = null),
                      onSave: () => _saveSingleField(currentProfile, 'gstin'),
                    ),
                    displayChild: ElvanSettingsDisplayRow(
                      title: K.gstinVariAdaiyaalaEn.tr(context, ref),
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
