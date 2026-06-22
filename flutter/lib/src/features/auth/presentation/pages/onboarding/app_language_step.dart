import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../../core/preferences_service.dart';
import '../../widgets/auth_components.dart';

class AppLanguageStep extends ConsumerWidget {
  final VoidCallback onLanguageSelected;

  const AppLanguageStep({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeyedSubtree(
      key: const ValueKey('language'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Choose Language',
            subtitle: 'This will be the language of the application interface.',
          ),
          const SizedBox(height: 40),
          AuthAnimatedElement(
            delayIndex: 0,
            child: AuthButton(
              text: 'தமிழ்',
              onPressed: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('ta'));
                onLanguageSelected();
              },
            ),
          ),
          const SizedBox(height: 16),
          AuthAnimatedElement(
            delayIndex: 1,
            child: AuthButton(
              text: 'English',
              onPressed: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                onLanguageSelected();
              },
            ),
          ),
        ],
      ),
    );
  }
}
