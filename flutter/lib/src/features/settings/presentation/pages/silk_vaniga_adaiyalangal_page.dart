import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/widgets/elvan_bottom_sheet.dart';
import '../../../../core/widgets/elvan_text_field.dart';
import '../../../../core/widgets/elvan_snackbar.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../widgets/elvan_settings_section.dart';
import '../widgets/elvan_settings_edit_card.dart';
import '../../data/vaniga_tharavugal_provider.dart';
import '../../data/vaniga_tharavugal.dart';

class SilkVanigaAdaiyalangalPage extends ConsumerStatefulWidget {
  const SilkVanigaAdaiyalangalPage({super.key});

  @override
  ConsumerState<SilkVanigaAdaiyalangalPage> createState() =>
      _SilkVanigaAdaiyalangalPageState();
}

class _SilkVanigaAdaiyalangalPageState
    extends ConsumerState<SilkVanigaAdaiyalangalPage> {
  String? _editingSection;
  final ImagePicker _picker = ImagePicker();

  String _tempHeaderStyle = '';
  String _tempSignatoryName = '';
  String? _tempImagePath;

  void _beginEditSingle(String sectionId, String val) {
    setState(() {
      _editingSection = sectionId;
      if (sectionId == 'header_style') {
        _tempHeaderStyle = val;
      } else if (sectionId == 'signature') {
        _tempSignatoryName = val;
      }
    });
  }

  void _beginEditImage(String sectionId, String? currentPath) {
    setState(() {
      _editingSection = sectionId;
      _tempImagePath = currentPath;
    });
  }

  void _beginEditSignature(String currentPath, String currentName) {
    setState(() {
      _editingSection = 'signature';
      _tempImagePath = currentPath;
      _tempSignatoryName = currentName;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingSection = null;
    });
  }

  void _showSuccessToast() {
    if (context.mounted) {
      ElvanSnackbar.show(context, 'detailsSaved'.tr(context, ref));
    }
  }

  void _saveSingleField(
      VanigaTharavugal profile, String fieldName, String value) {
    final updatedProfile = profile.copyWith();
    switch (fieldName) {
      case 'thallaippuVadivu':
        updatedProfile.thallaippuVadivu = value;
        break;
      case 'ovuru':
        updatedProfile.ovuru = value;
        break;
      case 'agalaOvuru':
        updatedProfile.agalaOvuru = value;
        break;
    }
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  void _saveSignatureField(VanigaTharavugal profile, String path, String name) {
    final updatedProfile = profile.copyWith();
    updatedProfile.kaiyoppam = path;
    updatedProfile.oppamPeyar = name;
    ref.read(vanigaTharavugalProvider.notifier).updateProfile(updatedProfile);
    setState(() => _editingSection = null);
    _showSuccessToast();
  }

  void _showHeaderStyleActionSheet() {
    final smallLabel = 'smallLogoBusinessName'.tr(context, ref);
    final wideLabel = 'wideLogoOnly'.tr(context, ref);

    showElvanSelectionBottomSheet(
      context: context,
      title: 'billHeaderStyle'.tr(context, ref),
      items: [smallLabel, wideLabel],
      currentValue: _tempHeaderStyle == 'wide' ? wideLabel : smallLabel,
      onSelected: (val) {
        setState(() {
          _tempHeaderStyle = val == wideLabel ? 'wide' : 'small';
        });
      },
    );
  }

  Widget _buildEditContainer({
    required String title,
    required Widget customContent,
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
          customContent,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelEdit,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                child: Text('cancel'.tr(context, ref)),
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

  Future<void> _pickImage(Function(String?) onPicked) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onPicked(image.path);
    }
  }

  Widget _buildImageUploader(
      {required String? imagePath, required Function(String?) onChange}) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    return Stack(
      children: [
        Material(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              if (!hasImage) {
                _pickImage(onChange);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: hasImage
                    ? DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              child: hasImage
                  ? null
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.cloud_upload,
                            size: 32,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'upload'.tr(context, ref),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        if (hasImage)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => onChange(null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.delete_solid,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(vanigaTharavugalProvider);
    final currentProfile = profile ?? VanigaTharavugal();

    final headerStyle = currentProfile.thallaippuVadivu.isEmpty
        ? 'small'
        : currentProfile.thallaippuVadivu;
    final logoPath = currentProfile.ovuru.isEmpty ? null : currentProfile.ovuru;
    final wideLogoPath =
        currentProfile.agalaOvuru.isEmpty ? null : currentProfile.agalaOvuru;
    final signaturePath =
        currentProfile.kaiyoppam.isEmpty ? null : currentProfile.kaiyoppam;
    final signatoryName = currentProfile.oppamPeyar;

    return ElvanSubpageShell(
      title: 'adaiyalam'.tr(context, ref),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 32),
            child: ElvanSettingsSection(
              children: [
                // 1. Logo
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'logo',
                  isEditing: _editingSection == 'logo',
                  editChild: _buildEditContainer(
                    title: 'businessLogo'.tr(context, ref),
                    customContent: _buildImageUploader(
                      imagePath: _tempImagePath,
                      onChange: (path) => setState(() => _tempImagePath = path),
                    ),
                    onSave: () => _saveSingleField(
                        currentProfile, 'ovuru', _tempImagePath ?? ''),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'businessLogo'.tr(context, ref),
                    primaryValue:
                        logoPath != null ? '' : 'noLogo'.tr(context, ref),
                    primaryWidget: logoPath != null
                        ? Image.file(
                            File(logoPath),
                            height: 36,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          )
                        : null,
                    onEdit: () => _beginEditImage('logo', logoPath),
                  ),
                ),

                // 2. Wide Logo
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'wide_logo',
                  isEditing: _editingSection == 'wide_logo',
                  editChild: _buildEditContainer(
                    title: 'wideLogoLabel'.tr(context, ref),
                    customContent: _buildImageUploader(
                      imagePath: _tempImagePath,
                      onChange: (path) => setState(() => _tempImagePath = path),
                    ),
                    onSave: () => _saveSingleField(
                        currentProfile, 'agalaOvuru', _tempImagePath ?? ''),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'wideLogoLabel'.tr(context, ref),
                    primaryValue: wideLogoPath != null
                        ? ''
                        : 'noneLabel'.tr(context, ref),
                    primaryWidget: wideLogoPath != null
                        ? Image.file(
                            File(wideLogoPath),
                            height: 36,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          )
                        : null,
                    onEdit: () => _beginEditImage('wide_logo', wideLogoPath),
                  ),
                ),

                // 3. Header Style
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'header_style',
                  isEditing: _editingSection == 'header_style',
                  editChild: _buildEditContainer(
                    title: 'billHeaderStyle'.tr(context, ref),
                    customContent: InkWell(
                      onTap: _showHeaderStyleActionSheet,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tempHeaderStyle == 'wide'
                                  ? 'wideLogoOnly'.tr(context, ref)
                                  : 'smallLogoBusinessName'.tr(context, ref),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_down,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6)),
                          ],
                        ),
                      ),
                    ),
                    onSave: () => _saveSingleField(
                        currentProfile, 'thallaippuVadivu', _tempHeaderStyle),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'billHeaderStyle'.tr(context, ref),
                    primaryValue: headerStyle == 'wide'
                        ? 'wideLogoOnly'.tr(context, ref)
                        : 'smallLogoBusinessName'.tr(context, ref),
                    onEdit: () => _beginEditSingle('header_style', headerStyle),
                  ),
                ),

                // 4. Signature
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'signature',
                  isEditing: _editingSection == 'signature',
                  editChild: _buildEditContainer(
                    title: 'signature'.tr(context, ref),
                    customContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImageUploader(
                          imagePath: _tempImagePath,
                          onChange: (path) =>
                              setState(() => _tempImagePath = path),
                        ),
                        const SizedBox(height: 16),
                        ElvanTextField(
                          textAlign: TextAlign.center,
                          controller:
                              TextEditingController(text: _tempSignatoryName),
                          decoration: InputDecoration(
                            hintText:
                                'authorizedSignatoryName'.tr(context, ref),
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3),
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (val) => _tempSignatoryName = val,
                        ),
                      ],
                    ),
                    onSave: () => _saveSignatureField(currentProfile,
                        _tempImagePath ?? '', _tempSignatoryName),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'signature'.tr(context, ref),
                    primaryValue: signaturePath != null
                        ? signatoryName
                        : 'noSignature'.tr(context, ref),
                    primaryWidget: signaturePath != null
                        ? Image.file(
                            File(signaturePath),
                            height: 48,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          )
                        : null,
                    onEdit: () =>
                        _beginEditSignature(signaturePath ?? '', signatoryName),
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
