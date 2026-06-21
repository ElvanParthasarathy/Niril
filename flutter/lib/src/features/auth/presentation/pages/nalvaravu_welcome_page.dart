import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/preferences_service.dart';
import 'vanakkam_page.dart';
import '../widgets/auth_components.dart';

const List<String> _greetings = ["வணக்கம்!", "Hello!", "നമസ്കാരം!"];

enum WelcomePhase { greeting, language, billingLanguage }

class NalvaravuWelcomePage extends ConsumerStatefulWidget {
  const NalvaravuWelcomePage({super.key});

  @override
  ConsumerState<NalvaravuWelcomePage> createState() => _NalvaravuWelcomePageState();
}

class _NalvaravuWelcomePageState extends ConsumerState<NalvaravuWelcomePage> {
  WelcomePhase _phase = WelcomePhase.greeting;
  int _greetingIndex = 0;
  double _greetingOpacity = 0.0;
  String _billingLanguage = 'Tamil'; // 'Tamil' or 'English'
  Timer? _greetingTimer;

  @override
  void initState() {
    super.initState();
    _startGreetingSequence();
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startGreetingSequence() async {
    for (int i = 0; i < _greetings.length; i++) {
      if (!mounted) return;

      // Fade in
      setState(() {
        _greetingIndex = i;
        _greetingOpacity = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      // Fade out
      setState(() {
        _greetingOpacity = 0.0;
      });

      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;

    // Move to language phase
    setState(() {
      _phase = WelcomePhase.language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);
    final currentLang = locale?.languageCode ?? 'en';

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF666666);
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE0E0E0);

    return AuthLayout(
      hideLogo: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: _buildPhaseContent(
          theme,
          textColor,
          textSecondary,
          inputBg,
          dividerColor,
          currentLang,
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    ThemeData theme,
    Color textColor,
    Color textSecondary,
    Color inputBg,
    Color dividerColor,
    String currentLang,
  ) {
    switch (_phase) {
      case WelcomePhase.greeting:
        return Center(
          key: const ValueKey('greeting'),
          child: AnimatedOpacity(
            opacity: _greetingOpacity,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: Text(
              _greetings[_greetingIndex],
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: textColor,
                letterSpacing: -1,
              ),
            ),
          ),
        );
      
      case WelcomePhase.language:
        return KeyedSubtree(
          key: const ValueKey('language'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.globe,
                size: 80,
                color: textColor,
              ),
              const SizedBox(height: 24),
              AuthHeader(
                title: 'selectLanguageTitle'.tr(context, ref) != 'selectLanguageTitle' 
                    ? 'selectLanguageTitle'.tr(context, ref) 
                    : 'Select Language',
                subtitle: 'selectLanguageSubtitle'.tr(context, ref) != 'selectLanguageSubtitle' 
                    ? 'selectLanguageSubtitle'.tr(context, ref) 
                    : 'Choose your preferred language',
              ),
              const SizedBox(height: 32),
              AuthAnimatedElement(
                delayIndex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildLanguageTile(
                        title: 'தமிழ்',
                        isSelected: currentLang == 'ta',
                        textColor: textColor,
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(const Locale('ta'));
                        },
                      ),
                      Divider(height: 1, color: dividerColor, indent: 24, endIndent: 24),
                      _buildLanguageTile(
                        title: 'English',
                        isSelected: currentLang == 'en',
                        textColor: textColor,
                        onTap: () {
                          ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: currentLang == 'ta' ? 'தொடரவும்' : 'Continue',
                onPressed: () {
                  setState(() {
                    _phase = WelcomePhase.billingLanguage;
                  });
                },
              ),
            ],
          ),
        );

      case WelcomePhase.billingLanguage:
        return KeyedSubtree(
          key: const ValueKey('billingLanguage'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.doc_text_fill,
                size: 80,
                color: textColor,
              ),
              const SizedBox(height: 24),
              AuthHeader(
                title: currentLang == 'ta' ? 'பில் முதன்மை மொழி' : 'Select Primary Billing Language',
                subtitle: currentLang == 'ta' 
                    ? 'பில்களுக்கு எந்த மொழியைப் பயன்படுத்த விரும்புகிறீர்கள்?' 
                    : 'Which language would you like to use for your bills?',
              ),
              const SizedBox(height: 32),
              AuthAnimatedElement(
                delayIndex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildLanguageTile(
                        title: 'தமிழ்',
                        isSelected: _billingLanguage == 'Tamil',
                        textColor: textColor,
                        onTap: () {
                          setState(() {
                            _billingLanguage = 'Tamil';
                          });
                        },
                      ),
                      Divider(height: 1, color: dividerColor, indent: 24, endIndent: 24),
                      _buildLanguageTile(
                        title: 'English',
                        isSelected: _billingLanguage == 'English',
                        textColor: textColor,
                        onTap: () {
                          setState(() {
                            _billingLanguage = 'English';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: _billingLanguage == 'Tamil' || currentLang == 'ta' ? 'தொடரவும்' : 'Continue',
                onPressed: () async {
                  final prefs = ref.read(sharedPreferencesProvider);
                  await prefs.setString('elvanniril_setup_billingLang', _billingLanguage);
                  
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const VanakkamPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLanguageTile({
    required String title,
    required bool isSelected,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: textColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
