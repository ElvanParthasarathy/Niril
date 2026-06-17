import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/preferences_service.dart';
import 'src/core/theme_provider.dart';
import 'src/localization/locale_provider.dart';
import 'src/features/pages/chaandru_page.dart';
import 'src/features/pages/mugappu_page.dart';
import 'src/features/pages/pattiyal_page.dart';
import 'src/features/pages/porul_page.dart';
import 'src/features/pages/vanigar_page.dart';
import 'src/features/printing/presentation/elvan_shell.dart';
import 'src/features/printing/presentation/widgets/elvan_popup_menu.dart';
import 'src/features/printing/presentation/widgets/elvan_top_bar_icon.dart';
import 'src/features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod state management
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
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
      themeMode: themeMode,
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
      ),
      darkTheme: ThemeData(
        fontFamily: 'ElvanSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black, // AMOLED Black
        useMaterial3: true,
      ),
      home: const ShellDemoScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMO SCREEN — Showcases OneUiTemplateShell with a sample album grid
// ─────────────────────────────────────────────────────────────────────────────

class ShellDemoScreen extends ConsumerStatefulWidget {
  const ShellDemoScreen({super.key});

  @override
  ConsumerState<ShellDemoScreen> createState() => _ShellDemoScreenState();
}

class _ShellDemoScreenState extends ConsumerState<ShellDemoScreen> {
  int _currentTab = 0; // Start on "Invoices" tab
  int _navItemCount = 5; // Dev testing count

  // ── 5 Tabs for the React app port ───────────────────────────────
  List<CustomNavItem> get _masterNavItems => [
    CustomNavItem(
      svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M219.31,108.68l-80-80a16,16,0,0,0-22.62,0l-80,80A15.87,15.87,0,0,0,32,120v96a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V160h32v56a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V120A15.87,15.87,0,0,0,219.31,108.68ZM208,208H160V152a8,8,0,0,0-8-8H104a8,8,0,0,0-8,8v56H48V120l80-80,80,80Z"></path></svg>',
      activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M224,120v96a8,8,0,0,1-8,8H160a8,8,0,0,1-8-8V164a4,4,0,0,0-4-4H108a4,4,0,0,0-4,4v52a8,8,0,0,1-8,8H40a8,8,0,0,1-8-8V120a16,16,0,0,1,4.69-11.31l80-80a16,16,0,0,1,22.62,0l80,80A16,16,0,0,1,224,120Z"></path></svg>',
      label: 'home'.tr(context, ref),
      headerLabel: 'appName'.tr(context, ref),
    ),
    CustomNavItem(
      icon: CupertinoIcons.doc_text,
      activeIcon: CupertinoIcons.doc_text_fill,
      label: 'invoices'.tr(context, ref),
      headerLabel: 'header_invoices'.tr(context, ref),
    ),
    CustomNavItem(
      svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M117.25,157.92a60,60,0,1,0-66.5,0A95.83,95.83,0,0,0,3.53,195.63a8,8,0,1,0,13.4,8.74,80,80,0,0,1,134.14,0,8,8,0,0,0,13.4-8.74A95.83,95.83,0,0,0,117.25,157.92ZM40,108a44,44,0,1,1,44,44A44.05,44.05,0,0,1,40,108Zm210.14,98.7a8,8,0,0,1-11.07-2.33A79.83,79.83,0,0,0,172,168a8,8,0,0,1,0-16,44,44,0,1,0-16.34-84.87,8,8,0,1,1-5.94-14.85,60,60,0,0,1,55.53,105.64,95.83,95.83,0,0,1,47.22,37.71A8,8,0,0,1,250.14,206.7Z"></path></svg>',
      activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M164.47,195.63a8,8,0,0,1-6.7,12.37H10.23a8,8,0,0,1-6.7-12.37,95.83,95.83,0,0,1,47.22-37.71,60,60,0,1,1,66.5,0A95.83,95.83,0,0,1,164.47,195.63Zm87.91-.15a95.87,95.87,0,0,0-47.13-37.56A60,60,0,0,0,144.7,54.59a4,4,0,0,0-1.33,6A75.83,75.83,0,0,1,147,150.53a4,4,0,0,0,1.07,5.53,112.32,112.32,0,0,1,29.85,30.83,23.92,23.92,0,0,1,3.65,16.47,4,4,0,0,0,3.95,4.64h60.3a8,8,0,0,0,7.73-5.93A8.22,8.22,0,0,0,252.38,195.48Z"></path></svg>',
      label: 'merchants'.tr(context, ref),
      headerLabel: 'header_merchants'.tr(context, ref),
    ),
    CustomNavItem(
      icon: CupertinoIcons.cube_box,
      activeIcon: CupertinoIcons.cube_box_fill,
      label: 'inventory'.tr(context, ref),
      headerLabel: 'header_inventory'.tr(context, ref),
    ),
    CustomNavItem(
      svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M72,104a8,8,0,0,1,8-8h96a8,8,0,0,1,0,16H80A8,8,0,0,1,72,104Zm8,40h96a8,8,0,0,0,0-16H80a8,8,0,0,0,0,16ZM232,56V208a8,8,0,0,1-11.58,7.15L192,200.94l-28.42,14.21a8,8,0,0,1-7.16,0L128,200.94,99.58,215.15a8,8,0,0,1-7.16,0L64,200.94,35.58,215.15A8,8,0,0,1,24,208V56A16,16,0,0,1,40,40H216A16,16,0,0,1,232,56Zm-16,0H40V195.06l20.42-10.22a8,8,0,0,1,7.16,0L96,199.06l28.42-14.22a8,8,0,0,1,7.16,0L160,199.06l28.42-14.22a8,8,0,0,1,7.16,0L216,195.06Z"></path></svg>',
      activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M216,40H40A16,16,0,0,0,24,56V208a8,8,0,0,0,11.58,7.15L64,200.94l28.42,14.21a8,8,0,0,0,7.16,0L128,200.94l28.42,14.21a8,8,0,0,0,7.16,0L192,200.94l28.42,14.21A8,8,0,0,0,232,208V56A16,16,0,0,0,216,40ZM176,144H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Zm0-32H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Z"></path></svg>',
      label: 'receipts'.tr(context, ref),
      headerLabel: 'header_receipts'.tr(context, ref),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure current tab doesn't overflow if we reduce item count
    if (_currentTab >= _navItemCount) {
      _currentTab = _navItemCount > 0 ? _navItemCount - 1 : 0;
    }


    final currentItem = _masterNavItems[_currentTab];
    final String currentTitle = currentItem.headerLabel ?? currentItem.label;

    return Stack(
      children: [
        ElvanShell(
          title: currentTitle,
          currentIndex: _currentTab,
          onTabSelected: (index) => setState(() => _currentTab = index),
          navActions: [
            const SizedBox(width: 7), // Left padding inside the pill (adjusted to perfectly kiss the pill edge)
            ElvanTopBarIcon(
              icon: CupertinoIcons.add,
              onTap: () {
                // Real action here
              },
            ),
            if (_currentTab != 0) ...[
              const SizedBox(width: 14), // Tighter gap between icons
              ElvanTopBarIcon(
                icon: CupertinoIcons.search,
                onTap: () {
                  // Real action here
                },
              ),
            ],
            const SizedBox(width: 14), // Tighter gap between icons
            const ElvanPopupMenu(), // Our brand new custom popup trigger!
            const SizedBox(width: 7), // Right padding inside the pill (adjusted to perfectly kiss the pill edge)
          ],
          navItems: _masterNavItems.take(_navItemCount).toList(),
          // Load ALL screens into memory instantly, using SliverOffstage to show the active one!
          slivers: [
            SliverOffstage(
              offstage: _currentTab != 0,
              sliver: const MugappuPage(),
            ),
            SliverOffstage(
              offstage: _currentTab != 1,
              sliver: const PattiyalPage(),
            ),
            SliverOffstage(
              offstage: _currentTab != 2,
              sliver: const VanigarPage(),
            ),
            SliverOffstage(
              offstage: _currentTab != 3,
              sliver: const PorulPage(),
            ),
            SliverOffstage(
              offstage: _currentTab != 4,
              sliver: const ChaandruPage(),
            ),
          ],
        ),

      ],
    );
  }
}


