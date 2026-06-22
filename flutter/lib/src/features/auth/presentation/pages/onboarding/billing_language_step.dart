import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../widgets/auth_components.dart';

class BillingLanguageStep extends ConsumerWidget {
  final VoidCallback onBack;
  final Function(String) onLanguageSelected;

  const BillingLanguageStep({
    super.key,
    required this.onBack,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeyedSubtree(
      key: const ValueKey('billing_language'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthBackButton(onPressed: onBack),
          AuthHeader(
            title: 'billingLanguageTitle'.tr(context, ref),
            subtitle: 'billingLanguageSubtitle'.tr(context, ref),
          ),
          const SizedBox(height: 40),
          AuthAnimatedElement(
            delayIndex: 0,
            child: AuthButton(
              text: 'தமிழ்',
              onPressed: () => onLanguageSelected('Tamil'),
            ),
          ),
          const SizedBox(height: 16),
          AuthAnimatedElement(
            delayIndex: 1,
            child: AuthButton(
              text: 'English',
              onPressed: () => onLanguageSelected('English'),
            ),
          ),
        ],
      ),
    );
  }
}
