import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/elvan_snackbar.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';

class CoolieUruvakkuAmaippuPage extends ConsumerStatefulWidget {
  const CoolieUruvakkuAmaippuPage({super.key});

  @override
  ConsumerState<CoolieUruvakkuAmaippuPage> createState() => _CoolieUruvakkuAmaippuPageState();
}

class _CoolieUruvakkuAmaippuPageState extends ConsumerState<CoolieUruvakkuAmaippuPage> {
  bool _isEditingLanguages = false;
  String _primaryLanguage = 'Tamil';
  String _tempPrimaryLanguage = 'Tamil';

  bool _isEditingTheme = false;
  String _themeColor = '#388e3c'; // Green
  String _tempThemeColor = '#388e3c';
  
  String getThemeName(String val) {
    if (val == '#388e3c') return 'pachai'.tr(context, ref);
    if (val == '#6a1b9a') return 'uudha'.tr(context, ref);
    return val;
  }

  Widget _buildEditState() {
    return ElvanSettingsEditContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElvanSettingsDropdown(
            label: 'cooliePrintLanguage'.tr(context, ref),
            value: _tempPrimaryLanguage,
            items: const ['Tamil', 'English'],
            onChanged: (val) {
              setState(() => _tempPrimaryLanguage = val);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditingLanguages = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: const StadiumBorder(),
                ),
                child: Text('cancelBtn'.tr(context, ref), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _primaryLanguage = _tempPrimaryLanguage;
                    _isEditingLanguages = false;
                  });
                  ElvanSnackbar.show(context, 'savedSuccessfully'.tr(context, ref));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: const StadiumBorder(),
                ),
                child: Text('saveBtn'.tr(context, ref), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeSelectorSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'cooliePdfTheme'.tr(context, ref),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOptionSheet('#388e3c', 'pachai'.tr(context, ref)),
                _buildThemeOptionSheet('#6a1b9a', 'uudha'.tr(context, ref)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionSheet(String colorHex, String name) {
    final isSelected = _tempThemeColor == colorHex;
    final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    
    return InkWell(
      onTap: () {
        setState(() {
          _tempThemeColor = colorHex;
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeEditState() {
    return ElvanSettingsEditContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'cooliePdfTheme'.tr(context, ref),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              InkWell(
                onTap: _showThemeSelectorSheet,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(int.parse(_tempThemeColor.replaceAll('#', '0xFF'))),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getThemeName(_tempThemeColor),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded, 
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditingTheme = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: const StadiumBorder(),
                ),
                child: Text('cancelBtn'.tr(context, ref), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _themeColor = _tempThemeColor;
                    _isEditingTheme = false;
                  });
                  ElvanSnackbar.show(context, 'savedSuccessfully'.tr(context, ref));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: const StadiumBorder(),
                ),
                child: Text('saveBtn'.tr(context, ref), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

    return ElvanSubpageShell(
      title: 'uruvakku'.tr(context, ref),
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
                  ElvanSettingsAnimatedExpand(
                    isEditing: _isEditingLanguages,
                    keyPrefix: 'langs',
                    editChild: _buildEditState(),
                    displayChild: ElvanSimpleSettingsRow(
                      title: 'cooliePrintLanguage'.tr(context, ref),
                      description: _primaryLanguage.toLowerCase().tr(context, ref),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _tempPrimaryLanguage = _primaryLanguage;
                            _isEditingLanguages = true;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                          fixedSize: const Size(40, 40),
                        ),
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  ElvanSettingsAnimatedExpand(
                    isEditing: _isEditingTheme,
                    keyPrefix: 'theme',
                    editChild: _buildThemeEditState(),
                    displayChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'cooliePdfTheme'.tr(context, ref),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(_themeColor.replaceAll('#', '0xFF'))),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      getThemeName(_themeColor),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _tempThemeColor = _themeColor;
                                _isEditingTheme = true;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                              fixedSize: const Size(40, 40),
                            ),
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
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
