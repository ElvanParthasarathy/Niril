import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/core/widgets/elvan_scroll_behavior.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/preferences_service.dart';
import 'src/core/theme_provider.dart';
import 'src/core/state/app_state.dart';
import 'src/core/models/app_mode.dart';
import 'src/localization/locale_provider.dart';
import 'src/features/auth/presentation/mode_selector_screen.dart';
import 'src/features/auth/presentation/pages/welcome_page.dart';
import 'src/features/auth/presentation/pages/nalvaravu_welcome_page.dart';
import 'src/core/database/app_database.dart';
import 'src/features/settings/data/vaniga_tharavugal_provider.dart';

import 'src/features/shell/presentation/deferred_shell_loader.dart';
import 'src/features/shell/presentation/niril_app_screen.dart';

import 'dart:io';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force 120Hz display mode on supported Android devices (Samsung, OnePlus, Xiaomi)
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      // Ignore if device doesn't support it
    }
  }

  // Set minimum window size on desktop platforms.
  // This prevents the window from shrinking below the desktop breakpoint (800px),
  // so the app never switches to mobile layout on desktop.
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const minSize = Size(800, 600);
    await windowManager.setMinimumSize(minSize);
    // Maximize the window by default on startup
    await windowManager.maximize();
    await windowManager.show();
  }

  final sharedPrefs = await SharedPreferences.getInstance();

  // Initialize Drift (SQLite) database
  final database = AppDatabase(AppDatabase.openConnection());

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod state management
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const ElvanNirilApp(),
    ),
  );
}

class ElvanNirilApp extends ConsumerWidget {
  const ElvanNirilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Elvan Niril Next-Gen',
      debugShowCheckedModeBanner: false,
      scrollBehavior: ElvanScrollBehavior(),
      themeMode: Platform.isWindows ? ThemeMode.dark : themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'ElvanSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'ElvanSans'),
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'ElvanSans', color: Colors.black),
            actionTextStyle: TextStyle(
                fontFamily: 'ElvanSans', color: CupertinoColors.activeBlue),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'ElvanSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black, // AMOLED Black
        useMaterial3: true,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'ElvanSans'),
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'ElvanSans', color: Colors.white),
            actionTextStyle: TextStyle(
                fontFamily: 'ElvanSans', color: CupertinoColors.activeBlue),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      home: Consumer(
        builder: (context, ref, _) {
          Widget child;

          // 1. Authentication Check
          final isLoggedIn = ref.watch(isLoggedInProvider);
          if (!isLoggedIn) {
            child = const WelcomePage(key: ValueKey('welcome'));
          } else {
            // 1.5. Prevent UI flashing by waiting for database stream to initialize
            final isLoadingProfiles = ref.watch(profilesLoadingProvider);
            if (isLoadingProfiles) {
              child = const Scaffold(
                  key: ValueKey('loading'), backgroundColor: Colors.black);
            } else {
              // 2. Smart Onboarding Check
              final hasBothProfiles = ref.watch(hasBothProfilesProvider);
              if (!hasBothProfiles) {
                child = const NalvaravuWelcomePage(key: ValueKey('onboarding'));
              } else {
                // 3. Mode Selection
                final mode = ref.watch(appModeProvider);
                if (mode == null) {
                  child = ModeSelectorScreen(
                    key: const ValueKey('mode_selector'),
                    onModeSelected: (newMode) {
                      ref.read(appModeProvider.notifier).setMode(newMode);
                    },
                  );
                } else {
                  // 4. Main App Dashboard (Deferred to guarantee smooth 60fps mode transition)
                  child = const DeferredShellLoader(
                    key: ValueKey('shell_demo'),
                    child: NirilAppScreen(),
                  );
                }
              }
            }
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}
