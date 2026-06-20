import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as dart_ui;
import 'package:flutter/cupertino.dart';
import '../../../../core/widgets/elvan_snackbar.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../localization/locale_provider.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';
import '../../../../core/widgets/elvan_text_field.dart';
import '../widgets/elvan_settings_section.dart';
import '../widgets/elvan_action_sheet.dart';

class PathugappuAmaippugalPage extends ConsumerWidget {
  const PathugappuAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);

    return ElvanSubpageShell(
      title: 'pathugappu'.tr(context, ref),
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
                children: [
                  ElvanSettingsRow(
                    iconWidget: Icon(
                      Icons.exit_to_app_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    iconBgColor: iconBgColor,
                    title: 'logout'.tr(context, ref),
                    description: 'logout_desc'.tr(context, ref),
                    onTap: () {
                      showElvanActionSheet(
                        context: context,
                        title: 'signOutConfirmTitle'.tr(context, ref),
                        cancelText: 'cancel'.tr(context, ref),
                        confirmText: 'signOutBtn'.tr(context, ref),
                        onConfirm: () {
                          // Perform actual logout here later
                        },
                      );
                    },
                  ),
                  ElvanSettingsRow(
                    iconWidget: Icon(
                      CupertinoIcons.delete_solid,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    iconBgColor: iconBgColor,
                    title: 'erase_data'.tr(context, ref),
                    description: 'erase_data_desc'.tr(context, ref),
                    onTap: () {
                      showElvanActionSheet(
                        context: context,
                        title: 'eraseAppDataTitle'.tr(context, ref),
                        cancelText: 'cancel'.tr(context, ref),
                        confirmText: 'eraseDataBtn'.tr(context, ref),
                        onConfirm: () {
                          // Step 2: Ask for password using the same Elvan Action Sheet design
                          showElvanActionSheet(
                            context: context,
                            title: 'enterPassword'.tr(context, ref),
                            cancelText: 'cancel'.tr(context, ref),
                            confirmText: 'eraseDataBtn'.tr(context, ref),
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
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onConfirm: () {
                              // Step 3: Show Loading Animation
                              // Step 3: Show Loading Animation matching Action Sheet
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isDismissible: false,
                                enableDrag: false,
                                builder: (context) {
                                  final isDarkLoader = Theme.of(context).brightness == Brightness.dark;
                                  final bgLoader = isDarkLoader ? const Color(0xFF151515).withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.75);

                                  return SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: BackdropFilter(
                                          filter: dart_ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: bgLoader,
                                              borderRadius: BorderRadius.circular(32),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'erasing'.tr(context, ref),
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  LinearProgressIndicator(
                                                    minHeight: 6,
                                                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                                                    backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );

                              // Step 4: Wait 2 seconds, pop and show success
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pop(context); // Close loading
                                if (context.mounted) {
                                  ElvanSnackbar.show(context, 'dataErasedSuccess'.tr(context, ref));
                                }
                              });
                            },
                          );
                        },
                      );
                    },
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
