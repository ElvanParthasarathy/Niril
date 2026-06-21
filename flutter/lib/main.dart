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
import 'src/features/shell/presentation/mobile/widgets/elvan_page_route.dart';
import 'src/features/auth/presentation/mode_selector_screen.dart';
import 'src/features/auth/presentation/pages/welcome_page.dart';
import 'src/features/auth/presentation/pages/nalvaravu_welcome_page.dart';
import 'src/features/pages/mugappu_page.dart';
import 'src/features/pages/uruvakku_page.dart';
import 'src/features/shell/presentation/mobile/elvan_navbar.dart';
import 'src/features/pages/porul_page.dart';
import 'src/features/pages/vanigar_page.dart';
import 'src/features/shell/presentation/mobile/elvan_shell.dart';
import 'src/features/auth/presentation/mode_selector_screen.dart';
import 'src/features/niril_silk/presentation/pages/silk_invoices_page.dart';
import 'src/features/niril_silk/presentation/pages/silk_receipts_page.dart';
import 'src/features/niril_coolie/presentation/pages/coolie_invoices_page.dart';
import 'src/features/niril_coolie/presentation/pages/coolie_receipts_page.dart';
import 'src/features/niril_silk/presentation/editors/silk_invoice_editor.dart';
import 'src/features/niril_silk/presentation/editors/silk_receipt_editor.dart';
import 'src/features/niril_silk/presentation/editors/silk_merchant_editor.dart';
import 'src/features/niril_silk/presentation/editors/silk_item_editor.dart';
import 'src/features/niril_coolie/presentation/pages/settings/coolie_vaniga_amaippu.dart';
import 'src/features/niril_silk/presentation/pages/settings/silk_vaniga_amaippu.dart';
import 'src/features/niril_coolie/presentation/editors/coolie_invoice_editor.dart';
import 'src/features/niril_coolie/presentation/editors/coolie_receipt_editor.dart';
import 'src/features/settings/data/vaniga_tharavugal_provider.dart';
import 'src/core/database/app_database.dart';

import 'src/core/state/search_state.dart';
import 'src/features/niril_coolie/presentation/editors/coolie_merchant_editor.dart';
import 'src/features/niril_coolie/presentation/editors/coolie_item_editor.dart';
import 'src/features/shell/presentation/desktop/elvan_desktop_shell.dart';
import 'src/features/shell/presentation/mobile/widgets/elvan_popup_menu.dart';
import 'src/features/shell/presentation/mobile/widgets/elvan_top_bar_icon.dart';
import 'src/features/shell/presentation/mobile/widgets/float_elvan_title.dart';
import 'src/features/settings/presentation/settings_screen.dart';

import 'dart:io';
import 'package:flutter_displaymode/flutter_displaymode.dart';

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
            actionTextStyle: TextStyle(fontFamily: 'ElvanSans', color: CupertinoColors.activeBlue),
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
            actionTextStyle: TextStyle(fontFamily: 'ElvanSans', color: CupertinoColors.activeBlue),
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
          // 1. Authentication Check
          final isLoggedIn = ref.watch(isLoggedInProvider);
          if (!isLoggedIn) {
            return const WelcomePage();
          }

          // 1.5. Prevent UI flashing by waiting for database stream to initialize
          final isLoadingProfiles = ref.watch(profilesLoadingProvider);
          if (isLoadingProfiles) {
            return const Scaffold(backgroundColor: Colors.black);
          }

          // 2. Smart Onboarding Check
          final hasBothProfiles = ref.watch(hasBothProfilesProvider);
          if (!hasBothProfiles) {
            return const NalvaravuWelcomePage();
          }

          // 3. Mode Selection
          final mode = ref.watch(appModeProvider);
          if (mode == null) {
            return ModeSelectorScreen(
              onModeSelected: (newMode) {
                ref.read(appModeProvider.notifier).setMode(newMode);
              },
            );
          }

          // 4. Main App Dashboard
          return const ShellDemoScreen();
        },
      ),
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
  int _navItemCount = 4; // Finalized count without debug
  bool _isSettingsOpen = false;

  void _onAddPressed() {
    final mode = ref.read(appModeProvider);
    Widget? editor;

    if (_currentTab == 0 || _currentTab == 1) {
      // Home Screen or Uruvakku (Invoices/Receipts)
      final uruvakkuSegment = ref.read(uruvakkuSegmentProvider);
      if (_currentTab == 1 && uruvakkuSegment == 1) {
        // Uruvakku Tab -> Receipts segment active
        editor = mode == AppMode.coolie ? const CoolieReceiptEditor() : const SilkReceiptEditor();
      } else {
        // Home Screen OR Uruvakku Tab -> Invoices segment active
        editor = mode == AppMode.coolie ? const CoolieInvoiceEditor() : const SilkInvoiceEditor();
      }
    } else if (_currentTab == 2) {
      // Merchants
      editor = mode == AppMode.coolie ? const CoolieMerchantEditor() : const SilkMerchantEditor();
    } else if (_currentTab == 3) {
      // Items/Inventory
      editor = mode == AppMode.coolie ? const CoolieItemEditor() : const SilkItemEditor();
    }

    if (editor != null) {
      Navigator.of(context).push(ElvanPageRoute(builder: (_) => editor!));
    }
  }

  // ── 5 Tabs for the React app port ───────────────────────────────
  List<CustomNavItem> get _masterNavItems => [
    CustomNavItem(
      svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M219.31,108.68l-80-80a16,16,0,0,0-22.62,0l-80,80A15.87,15.87,0,0,0,32,120v96a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V160h32v56a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V120A15.87,15.87,0,0,0,219.31,108.68ZM208,208H160V152a8,8,0,0,0-8-8H104a8,8,0,0,0-8,8v56H48V120l80-80,80,80Z"></path></svg>',
      activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M224,120v96a8,8,0,0,1-8,8H160a8,8,0,0,1-8-8V164a4,4,0,0,0-4-4H108a4,4,0,0,0-4,4v52a8,8,0,0,1-8,8H40a8,8,0,0,1-8-8V120a16,16,0,0,1,4.69-11.31l80-80a16,16,0,0,1,22.62,0l80,80A16,16,0,0,1,224,120Z"></path></svg>',
      label: 'home'.tr(context, ref),
      headerLabel: 'appName'.tr(context, ref),
    ),
    CustomNavItem(
      icon: CupertinoIcons.plus_app,
      activeIcon: CupertinoIcons.plus_app_fill,
      label: 'aakku'.tr(context, ref),
      headerLabel: 'uruvakku'.tr(context, ref),
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
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure current tab doesn't overflow if we reduce item count
    if (_currentTab >= _navItemCount) {
      _currentTab = _navItemCount > 0 ? _navItemCount - 1 : 0;
    }


    final currentItem = _masterNavItems[_currentTab];
    final String currentTitle = currentItem.headerLabel ?? currentItem.label;

    return PopScope(
      canPop: _currentTab == 0 && !_isSettingsOpen,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isSettingsOpen) {
          setState(() {
            _isSettingsOpen = false;
          });
          return;
        }

        // If we are in the Uruvakku tab and viewing Receipts, go back to Invoices first
        if (_currentTab == 1) {
          final uruvakkuSegment = ref.read(uruvakkuSegmentProvider);
          if (uruvakkuSegment == 1) {
            ref.read(uruvakkuSegmentProvider.notifier).state = 0;
            return;
          }
        }

        // Otherwise, always fall back to the Home tab
        setState(() {
          _currentTab = 0;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          final mode = ref.watch(appModeProvider);

          if (isDesktop) {
            int desktopIndex = 0;
            if (_currentTab == 0) desktopIndex = 0;
            else if (_currentTab == 1) {
              final segment = ref.read(uruvakkuSegmentProvider);
              desktopIndex = segment == 0 ? 1 : 2;
            } else if (_currentTab == 2) desktopIndex = 3;
            else if (_currentTab == 3) desktopIndex = 4;

            final desktopNavItems = [
              _masterNavItems[0], // Home
              CustomNavItem(
                icon: CupertinoIcons.doc_text,
                activeIcon: CupertinoIcons.doc_text_fill,
                label: 'invoices'.tr(context, ref),
                headerLabel: 'pill_invoices'.tr(context, ref),
              ),
              CustomNavItem(
                svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M72,104a8,8,0,0,1,8-8h96a8,8,0,0,1,0,16H80A8,8,0,0,1,72,104Zm8,40h96a8,8,0,0,0,0-16H80a8,8,0,0,0,0,16ZM232,56V208a8,8,0,0,1-11.58,7.15L192,200.94l-28.42,14.21a8,8,0,0,1-7.16,0L128,200.94,99.58,215.15a8,8,0,0,1-7.16,0L64,200.94,35.58,215.15A8,8,0,0,1,24,208V56A16,16,0,0,1,40,40H216A16,16,0,0,1,232,56Zm-16,0H40V195.06l20.42-10.22a8,8,0,0,1,7.16,0L96,199.06l28.42-14.22a8,8,0,0,1,7.16,0L160,199.06l28.42-14.22a8,8,0,0,1,7.16,0L216,195.06Z"></path></svg>',
                activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M216,40H40A16,16,0,0,0,24,56V208a8,8,0,0,0,11.58,7.15L64,200.94l28.42,14.21a8,8,0,0,0,7.16,0L128,200.94l28.42,14.21a8,8,0,0,0,7.16,0L192,200.94l28.42,14.21A8,8,0,0,0,232,208V56A16,16,0,0,0,216,40ZM176,144H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Zm0-32H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Z"></path></svg>',
                label: 'receipt'.tr(context, ref),
                headerLabel: 'pill_receipts'.tr(context, ref),
              ),
              _masterNavItems[2], // Merchants
              _masterNavItems[3], // Products
            ];

            return ElvanDesktopShell(
              currentIndex: desktopIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  setState(() { _currentTab = 0; _isSettingsOpen = false; });
                } else if (index == 1) {
                  ref.read(uruvakkuSegmentProvider.notifier).state = 0;
                  setState(() { _currentTab = 1; _isSettingsOpen = false; });
                } else if (index == 2) {
                  ref.read(uruvakkuSegmentProvider.notifier).state = 1;
                  setState(() { _currentTab = 1; _isSettingsOpen = false; });
                } else if (index == 3) {
                  setState(() { _currentTab = 2; _isSettingsOpen = false; });
                } else if (index == 4) {
                  setState(() { _currentTab = 3; _isSettingsOpen = false; });
                }
              },
              onSettingsPressed: () {
                setState(() {
                  _isSettingsOpen = true;
                });
              },
              customContent: _isSettingsOpen ? const SettingsScreen() : null,
              title: _isSettingsOpen ? 'settings'.tr(context, ref) : (desktopNavItems[desktopIndex].headerLabel ?? desktopNavItems[desktopIndex].label),
              navItems: desktopNavItems,
              slivers: [
                SliverOffstage(
                  offstage: desktopIndex != 0,
                  sliver: const MugappuPage(),
                ),
                SliverOffstage(
                  offstage: desktopIndex != 1,
                  sliver: mode == AppMode.coolie ? const CoolieInvoicesPage() : const SilkInvoicesPage(),
                ),
                SliverOffstage(
                  offstage: desktopIndex != 2,
                  sliver: mode == AppMode.coolie ? const CoolieReceiptsPage() : const SilkReceiptsPage(),
                ),
                SliverOffstage(
                  offstage: desktopIndex != 3,
                  sliver: const VanigarPage(),
                ),
                SliverOffstage(
                  offstage: desktopIndex != 4,
                  sliver: const PorulPage(),
                ),
              ],
            );
          }

          return Scaffold(
            body: IndexedStack(
              index: _currentTab,
              children: [
                for (int i = 0; i < 4; i++)
                  ElvanShell(
                    assignedIndex: i,
                  title: _masterNavItems[i].headerLabel ?? _masterNavItems[i].label,
                  currentIndex: _currentTab,
                  onTabSelected: (index) => setState(() => _currentTab = index),
                  showSearchIcon: i != 0,
                  onSearchChanged: (query) {
                    final mode = ref.read(appModeProvider);
                    if (i == 1) { // Uruvakku
                      final segment = ref.read(uruvakkuSegmentProvider);
                      if (mode == AppMode.coolie) {
                        if (segment == 0) ref.read(coolieInvoicesSearchQueryProvider.notifier).state = query;
                        else ref.read(coolieReceiptsSearchQueryProvider.notifier).state = query;
                      } else {
                        if (segment == 0) ref.read(silkInvoicesSearchQueryProvider.notifier).state = query;
                        else ref.read(silkReceiptsSearchQueryProvider.notifier).state = query;
                      }
                    } else if (i == 2) { // Viyabarigal
                      if (mode == AppMode.coolie) ref.read(coolieMerchantsSearchQueryProvider.notifier).state = query;
                      else ref.read(silkMerchantsSearchQueryProvider.notifier).state = query;
                    } else if (i == 3) { // Porul
                      if (mode == AppMode.coolie) ref.read(coolieItemsSearchQueryProvider.notifier).state = query;
                      else ref.read(silkItemsSearchQueryProvider.notifier).state = query;
                    }
                  },
                  navActions: [
                    const SizedBox(width: 7),
                    ElvanTopBarIcon(
                      icon: CupertinoIcons.add,
                      onTap: _onAddPressed,
                    ),
                    const SizedBox(width: 14),
                    ElvanPopupMenu(
                      showSelectOption: i > 0,
                      isSilkHome: ref.watch(appModeProvider) != AppMode.coolie && i == 0,
                    ),
                    const SizedBox(width: 7),
                  ],
                  navItems: _masterNavItems.take(_navItemCount).toList(),
                  slivers: [
                    if (i == 0) const MugappuPage(),
                    if (i == 1) const UruvakkuPage(),
                    if (i == 2) const VanigarPage(),
                    if (i == 3) const PorulPage(),
                  ],
                ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'dev_seed',
                  onPressed: () {
                    ref.read(vanigaTharavugalProvider.notifier).seedData();
                  },
                  label: const Text('Dev: Seed'),
                  icon: const Icon(CupertinoIcons.rocket),
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'dev_erase',
                  onPressed: () {
                    ref.read(vanigaTharavugalProvider.notifier).clearProfile();
                    ref.read(appModeProvider.notifier).setMode(null); // Sign out
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  label: const Text('Dev: Erase'),
                  icon: const Icon(CupertinoIcons.trash),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
