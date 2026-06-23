import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'login_page.dart';
import '../widgets/auth_components.dart';
import '../../../../core/preferences_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../settings/data/mock_profile.dart';
import '../../../../core/models/app_mode.dart';
import '../../../settings/data/vaniga_tharavugal_provider.dart';
import '../../../shell/presentation/mobile/widgets/elvan_page_route.dart';
import '../../../../localization/locale_provider.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AuthLayout(
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Seed the app with test data in both modes
                ref.read(appModeProvider.notifier).setMode(AppMode.silk);
                await ref.read(vanigaTharavugalListProvider.notifier).seedData();

                ref.read(appModeProvider.notifier).setMode(AppMode.coolie);
                await ref.read(vanigaTharavugalListProvider.notifier).seedData();

                if (context.mounted) {
                  ref.read(appModeProvider.notifier).setMode(AppMode.silk);
                  ref.read(isLoggedInProvider.notifier).setLoggedIn(true);
                }
              },
              label: const Text('Seed App (Dev)'),
              icon: const Icon(Icons.bug_report),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // LOGO SECTION
          AuthAnimatedElement(
            delayIndex: 0,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons
                      .square_stack_3d_up_fill, // Approximation of Database icon
                  size: 48,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // TEXT SECTION
          AuthHeader(
            title: 'welcomeTitle'.tr(context, ref),
            subtitle: 'welcomeSubtitle'.tr(context, ref),
          ),

          const SizedBox(height: 40),

          // BUTTON SECTION
          AuthAnimatedElement(
            delayIndex: 2,
            child: Text(
              'welcomeAgreeText'.tr(context, ref),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF999999),
                height: 1.5,
              ),
            ),
          ),

          AuthButton(
            text: 'agreeAndContinueBtn'.tr(context, ref),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
