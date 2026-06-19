import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../localization/locale_provider.dart';
import '../widgets/elvan_settings_controls.dart';
import '../../../../core/widgets/elvan_text_field.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../widgets/elvan_settings_section.dart';
import '../widgets/elvan_settings_edit_card.dart';
import '../widgets/elvan_settings_controls.dart';

class SilkVanigaAdaiyalangalPage extends ConsumerStatefulWidget {
  const SilkVanigaAdaiyalangalPage({super.key});

  @override
  ConsumerState<SilkVanigaAdaiyalangalPage> createState() => _SilkVanigaAdaiyalangalPageState();
}

class _SilkVanigaAdaiyalangalPageState extends ConsumerState<SilkVanigaAdaiyalangalPage> {
  String? _editingSection;
  final ImagePicker _picker = ImagePicker();

  // Local state for our mocked branding values
  String _headerStyle = 'small'; // 'small' or 'wide'
  String _tempHeaderStyle = 'small';

  String _signatoryName = 'பா. வனிதாஶ்ரீ';
  String _tempSignatoryName = 'பா. வனிதாஶ்ரீ';

  String? _logoPath;
  String? _wideLogoPath;
  String? _signaturePath;

  void _beginEdit(String sectionId) {
    setState(() {
      _editingSection = sectionId;
      _tempHeaderStyle = _headerStyle;
      _tempSignatoryName = _signatoryName;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingSection = null;
    });
  }

  void _showHeaderStyleActionSheet() {
    final smallLabel = 'smallLogoBusinessName'.tr(context, ref);
    final wideLabel = 'wideLogoOnly'.tr(context, ref);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF111111) 
          : Colors.white,
      builder: (BuildContext context) {
        return ElvanSettingsSelectionBottomSheet(
          title: 'billHeaderStyle'.tr(context, ref),
          items: [smallLabel, wideLabel],
          currentValue: _tempHeaderStyle == 'wide' ? wideLabel : smallLabel,
          onSelected: (val) {
            setState(() {
              _tempHeaderStyle = val == wideLabel ? 'wide' : 'small';
            });
            Navigator.pop(context);
          },
        );
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
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildImageUploader({required String? imagePath, required Function(String?) onChange}) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;
    
    return Stack(
      children: [
        Material(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
                image: hasImage ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.contain,
                ) : null,
              ),
              child: hasImage ? null : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.cloud_upload,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'upload'.tr(context, ref),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
    return ElvanSubpageShell(
      title: 'adaiyalam'.tr(context, ref),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElvanSettingsSection(
              children: [
                // 1. Logo
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'logo',
                  isEditing: _editingSection == 'logo',
                  editChild: _buildEditContainer(
                    title: 'businessLogo'.tr(context, ref),
                    customContent: _buildImageUploader(
                      imagePath: _logoPath,
                      onChange: (path) => setState(() => _logoPath = path),
                    ),
                    onSave: () => setState(() => _editingSection = null),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'businessLogo'.tr(context, ref),
                    primaryValue: _logoPath != null ? 'logoUploaded'.tr(context, ref) : 'noLogo'.tr(context, ref),
                    onEdit: () => _beginEdit('logo'),
                  ),
                ),

                // 2. Wide Logo
                ElvanSettingsAnimatedExpand(
                  keyPrefix: 'wide_logo',
                  isEditing: _editingSection == 'wide_logo',
                  editChild: _buildEditContainer(
                    title: 'wideLogoLabel'.tr(context, ref),
                    customContent: _buildImageUploader(
                      imagePath: _wideLogoPath,
                      onChange: (path) => setState(() => _wideLogoPath = path),
                    ),
                    onSave: () => setState(() => _editingSection = null),
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'wideLogoLabel'.tr(context, ref),
                    primaryValue: _wideLogoPath != null ? 'wideLogoUploaded'.tr(context, ref) : 'noneLabel'.tr(context, ref),
                    onEdit: () => _beginEdit('wide_logo'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tempHeaderStyle == 'wide' ? 'wideLogoOnly'.tr(context, ref) : 'smallLogoBusinessName'.tr(context, ref),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_down, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ],
                        ),
                      ),
                    ),
                    onSave: () {
                      setState(() {
                        _headerStyle = _tempHeaderStyle;
                        _editingSection = null;
                      });
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'billHeaderStyle'.tr(context, ref),
                    primaryValue: _headerStyle == 'wide' ? 'wideLogoOnly'.tr(context, ref) : 'smallLogoBusinessName'.tr(context, ref),
                    onEdit: () => _beginEdit('header_style'),
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
                          imagePath: _signaturePath,
                          onChange: (path) => setState(() => _signaturePath = path),
                        ),
                        const SizedBox(height: 16),
                        ElvanTextField(
                          textAlign: TextAlign.center,
                          controller: TextEditingController(text: _tempSignatoryName),
                          decoration: InputDecoration(
                            hintText: 'authorizedSignatoryName'.tr(context, ref),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    onSave: () {
                      setState(() {
                        _signatoryName = _tempSignatoryName;
                        _editingSection = null;
                      });
                    },
                  ),
                  displayChild: ElvanSettingsDisplayRow(
                    title: 'signature'.tr(context, ref),
                    primaryValue: _signaturePath != null ? _signatoryName : 'noSignature'.tr(context, ref),
                    onEdit: () => _beginEdit('signature'),
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
