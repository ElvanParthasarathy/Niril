import 'package:flutter/cupertino.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:flutter/material.dart';
import 'src/koorugal/podhu_koorugal/elvan_nagarvu_panbu.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/adippadai/viruppangal_paniyagam.dart';
import 'src/adippadai/thoatra_vazhanguthi.dart';
import 'src/adippadai/nilaimai/seyali_nilaimai.dart';
import 'src/adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'src/cheyalpaadugal/ulnuzhaivu/kaatchi/muraimai_thaervu_thirai.dart';
import 'src/cheyalpaadugal/ulnuzhaivu/kaatchi/thiraigal/nalvaravu_thirai.dart';
import 'src/cheyalpaadugal/ulnuzhaivu/kaatchi/thiraigal/nalvaravu_thirai_amaippu.dart';
import 'src/adippadai/panigal/niril_backup_service.dart';
import 'src/adippadai/panigal/elvan_pizhaipadhivu.dart';
import 'src/cheyalpaadugal/ulnuzhaivu/kaatchi/thiraigal/anumadhi_kaavalar_thirai.dart';

import 'src/cheyalpaadugal/chattagam/kaatchi/pinnaetrum_oadu.dart';
import 'src/cheyalpaadugal/chattagam/kaatchi/niril_seyali_thirai.dart';
import 'src/cheyalpaadugal/uruvakkunar_karuvigal/kaatchi/elvan_uruvakkunar_menu.dart';

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'src/adippadai/tharavuthalam/migration_udhavi.dart';

void main() {
  // ── Global Error Safety Net ──
  // Everything runs inside runZonedGuarded so ensureInitialized() and runApp()
  // share the same zone (prevents Flutter's "Zone mismatch" error).
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize global error logger
      await ElvanPizhaipadhivu.initialize();

      // 1. Catch all Flutter framework errors (layout, rendering, gestures)
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details); // Keep default red screen in debug
        ElvanPizhaipadhivu.logError(
          details.exception,
          stackTrace: details.stack,
          context: 'FlutterError: ${details.library}',
        );
      };

      // 2. Catch platform channel errors (method channel failures, etc.)
      PlatformDispatcher.instance.onError = (error, stack) {
        ElvanPizhaipadhivu.logError(
          error,
          stackTrace: stack,
          context: 'PlatformDispatcher',
        );
        return true; // Prevent the error from propagating
      };

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

      // ── MIGRATION CHECK ──
      // Check if we need to migrate the legacy unified database to the split databases.
      final hasMigrated = sharedPrefs.getBool('has_migrated_v3') ?? false;
      if (!hasMigrated) {
        final supportDir = await getApplicationSupportDirectory();
        final legacyFile = File(p.join(supportDir.path, 'elvan_niril.db'));
        
        if (await legacyFile.exists()) {
          debugPrint('Legacy database found. Initiating migration to split databases...');
          
          // Create a temporary container just to run the migration
          final container = ProviderContainer(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            ],
          );
          
          try {
            final migrationUdhavi = container.read(migrationUdhaviProvider);
            await migrationUdhavi.runMigration();
            await sharedPrefs.setBool('has_migrated_v3', true);
            debugPrint('Migration completed and flagged in SharedPreferences.');
          } catch (e, stack) {
            debugPrint('Migration error during startup: $e\n$stack');
            ElvanPizhaipadhivu.logError(e, stackTrace: stack, context: 'Database Migration');
          } finally {
            // Clean up the temporary container to release DB connections
            container.dispose();
          }
        } else {
          // If legacy doesn't exist, it's a fresh install. Mark as migrated so we don't check again.
          await sharedPrefs.setBool('has_migrated_v3', true);
        }
      }

      // Initialize backup service (தரவு பாதுகாப்பு)
      final backupService = await NirilBackupService.initialize();

      // 3. Launch the app
      runApp(
        // Wrap the entire app with ProviderScope for Riverpod state management
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            backupServiceProvider.overrideWithValue(backupService),
          ],
          child: const ElvanNirilApp(),
        ),
      );
    },
    (error, stack) {
      ElvanPizhaipadhivu.logError(
        error,
        stackTrace: stack,
        context: 'runZonedGuarded (uncaught async error)',
      );
    },
  );
}

class ElvanNirilApp extends ConsumerWidget {
  const ElvanNirilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep auto backup alive
    ref.watch(autoBackupProvider);

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      builder: (context, child) {
        return ElvanUruvakkunarMenu(child: child!);
      },
      onGenerateTitle: (context) => K.elvanNiril.tr(context, ref),
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
          width: (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ? 400.0 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        pageTransitionsTheme: Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? const PageTransitionsTheme(
                builders: {
                  TargetPlatform.windows: MinimalDesktopFadeTransitionBuilder(),
                  TargetPlatform.macOS: MinimalDesktopFadeTransitionBuilder(),
                  TargetPlatform.linux: MinimalDesktopFadeTransitionBuilder(),
                },
              )
            : null,
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
          width: (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ? 400.0 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        pageTransitionsTheme: Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? const PageTransitionsTheme(
                builders: {
                  TargetPlatform.windows: MinimalDesktopFadeTransitionBuilder(),
                  TargetPlatform.macOS: MinimalDesktopFadeTransitionBuilder(),
                  TargetPlatform.linux: MinimalDesktopFadeTransitionBuilder(),
                },
              )
            : null,
      ),
      home: PermissionGuardScreen(
        child: Consumer(
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
                final isSetupComplete = ref.watch(isSetupCompleteProvider);
                if (!isSetupComplete) {
                  // Always show NalvaravuWelcomePage. 
                  // It handles the Vanakkam greeting and then internally checks the backup.
                  child = const NalvaravuWelcomePage(key: ValueKey('setup'));
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
                    // 3.5. Ensure the chosen mode actually has a profile setup
                    final hasProfileForMode = ref.watch(hasProfileForCurrentModeProvider);
                    if (!hasProfileForMode) {
                      // Routes directly to the single business creation page
                      child = const NalvaravuWelcomePage(key: ValueKey('setup_missing'));
                    } else {
                      // 4. Main App Dashboard (Deferred to guarantee smooth 60fps mode transition)
                      child = const DeferredShellLoader(
                        key: ValueKey('shell_demo'),
                        child: NirilSeyaliThirai(),
                      );
                    }
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

      ),
    );
  }
}

/// A minimal, fast cross-fade transition typical of professional desktop apps.
/// Uses a custom curve to accelerate the default 300ms duration down to ~150ms.
class MinimalDesktopFadeTransitionBuilder extends PageTransitionsBuilder {
  const MinimalDesktopFadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Accelerate the fade to finish in the first half of the transition (150ms)
    final fastFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fastFade,
      child: child,
    );
  }
}
