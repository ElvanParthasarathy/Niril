import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../settings/presentation/widgets/elvan_settings_section.dart';
import '../../../../settings/presentation/widgets/elvan_settings_edit_card.dart';
import '../../../../settings/presentation/widgets/elvan_settings_controls.dart';

class SilkUruvakkuAmaippuPage extends ConsumerStatefulWidget {
  const SilkUruvakkuAmaippuPage({super.key});

  @override
  ConsumerState<SilkUruvakkuAmaippuPage> createState() => _SilkUruvakkuAmaippuPageState();
}

class _SilkUruvakkuAmaippuPageState extends ConsumerState<SilkUruvakkuAmaippuPage> {
  bool _bilingualEnabled = false;
  bool _showGstSplits = false;
  
  bool _isEditingLanguages = false;
  String _primaryLanguage = 'Tamil';
  String _secondaryLanguage = 'English';
  
  String _tempPrimaryLanguage = 'Tamil';
  String _tempSecondaryLanguage = 'English';

  Widget _buildEditState() {
    return ElvanSettingsEditContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElvanSettingsDropdown(
            label: 'primary_language'.tr(context, ref),
            value: _tempPrimaryLanguage,
            items: const ['Tamil', 'English'],
            onChanged: (val) {
              setState(() => _tempPrimaryLanguage = val);
            },
          ),
          const SizedBox(height: 20),
          ElvanSettingsDropdown(
            label: 'secondary_language'.tr(context, ref),
            value: _tempSecondaryLanguage,
            items: const ['Tamil', 'English'],
            onChanged: (val) {
              setState(() => _tempSecondaryLanguage = val);
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
                    _secondaryLanguage = _tempSecondaryLanguage;
                    _isEditingLanguages = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle, 
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black87, 
                            size: 20
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'savedSuccessfully'.tr(context, ref),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black87, 
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context).brightness == Brightness.light 
                          ? Colors.grey.shade800 
                          : Colors.white,
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
                    displayChild: Column(
                      children: [
                        ElvanSimpleSettingsRow(
                          title: 'primary_language'.tr(context, ref),
                          description: _primaryLanguage.toLowerCase().tr(context, ref),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _tempPrimaryLanguage = _primaryLanguage;
                                _tempSecondaryLanguage = _secondaryLanguage;
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
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16.0,
                          endIndent: 20.0,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white.withValues(alpha: 0.04) 
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        // Second row with no edit button
                        ElvanSimpleSettingsRow(
                          title: 'secondary_language'.tr(context, ref),
                          description: _secondaryLanguage.toLowerCase().tr(context, ref),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElvanSettingsSection(
                children: [
                  ElvanSimpleSettingsRow(
                    title: 'bilingual_entry'.tr(context, ref),
                    trailing: ElvanSettingsSwitch(
                      value: _bilingualEnabled,
                      onChanged: (val) {
                        setState(() {
                          _bilingualEnabled = val;
                        });
                      },
                    ),
                  ),
                  ElvanSimpleSettingsRow(
                    title: 'showItemizedGstTable'.tr(context, ref),
                    trailing: ElvanSettingsSwitch(
                      value: _showGstSplits,
                      onChanged: (val) {
                        setState(() {
                          _showGstSplits = val;
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
