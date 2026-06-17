import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/preferences_service.dart';
import 'src/core/theme_provider.dart';
import 'src/localization/locale_provider.dart';
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
  int _currentTab = 1; // Start on "Invoices" tab
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

  // ── Sample album data for the mockup grid ─────────────────────────────
  static const List<_AlbumMock> _albums = [
    _AlbumMock('Camera', 4350, Color(0xFFE8D5C4)),
    _AlbumMock('GANTH', 106, Color(0xFFC5E1A5)),
    _AlbumMock('Nive akka', 776, Color(0xFFB3E5FC)),
    _AlbumMock('Quick Share', 116, Color(0xFFFFCDD2)),
    _AlbumMock('Album 3', 2, Color(0xFFD1C4E9)),
    _AlbumMock('Bell', 6, Color(0xFFFFE0B2)),
    _AlbumMock('Collage', 26, Color(0xFFB2DFDB)),
    _AlbumMock('Facebook', 17, Color(0xFFF8BBD0)),
    _AlbumMock('Happy birthday', 178, Color(0xFFC8E6C9)),
    _AlbumMock('Jai', 8, Color(0xFFBBDEFB)),
    _AlbumMock('Messenger', 3, Color(0xFFFFECB3)),
    _AlbumMock('Map Camera', 94, Color(0xFFD7CCC8)),
    _AlbumMock('New folder', 6, Color(0xFFCFD8DC)),
    _AlbumMock('Pa', 12, Color(0xFFE1BEE7)),
    _AlbumMock('Pendrive', 17, Color(0xFFB2EBF2)),
    _AlbumMock('Pictures', 233, Color(0xFFF0F4C3)),
    _AlbumMock('Downloads', 89, Color(0xFFFFCCBC)),
    _AlbumMock('Screenshots', 512, Color(0xFFE0E0E0)),
    // Duplicated dummy data for long scroll testing
    _AlbumMock('Test Folder 1', 10, Color(0xFFD1C4E9)),
    _AlbumMock('Test Folder 2', 20, Color(0xFFFFE0B2)),
    _AlbumMock('Test Folder 3', 30, Color(0xFFB2DFDB)),
    _AlbumMock('Test Folder 4', 40, Color(0xFFF8BBD0)),
    _AlbumMock('Test Folder 5', 50, Color(0xFFC8E6C9)),
    _AlbumMock('Test Folder 6', 60, Color(0xFFBBDEFB)),
    _AlbumMock('Test Folder 7', 70, Color(0xFFFFECB3)),
    _AlbumMock('Test Folder 8', 80, Color(0xFFD7CCC8)),
    _AlbumMock('Test Folder 9', 90, Color(0xFFCFD8DC)),
    _AlbumMock('Test Folder 10', 100, Color(0xFFE1BEE7)),
    _AlbumMock('Test Folder 11', 110, Color(0xFFB2EBF2)),
    _AlbumMock('Test Folder 12', 120, Color(0xFFF0F4C3)),
    _AlbumMock('Test Folder 13', 130, Color(0xFFFFCCBC)),
    _AlbumMock('Test Folder 14', 140, Color(0xFFE0E0E0)),
    _AlbumMock('Test Folder 15', 150, Color(0xFFC5E1A5)),
    _AlbumMock('Test Folder 16', 160, Color(0xFFB3E5FC)),
    _AlbumMock('Test Folder 17', 170, Color(0xFFFFCDD2)),
    _AlbumMock('Test Folder 18', 180, Color(0xFFE8D5C4)),
    _AlbumMock('Test Folder 19', 190, Color(0xFFD1C4E9)),
    _AlbumMock('Test Folder 20', 200, Color(0xFFFFE0B2)),
    _AlbumMock('Test Folder 21', 210, Color(0xFFB2DFDB)),
    _AlbumMock('Test Folder 22', 220, Color(0xFFF8BBD0)),
    _AlbumMock('Test Folder 23', 230, Color(0xFFC8E6C9)),
    _AlbumMock('Test Folder 24', 240, Color(0xFFBBDEFB)),
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
            const SizedBox(width: 12), // Left padding inside the pill
            ElvanTopBarIcon(
              icon: CupertinoIcons.add,
              onTap: () {
                // Real action here
              },
            ),
            const SizedBox(width: 14), // Tighter gap between icons
            ElvanTopBarIcon(
              icon: CupertinoIcons.search,
              onTap: () {
                // Real action here
              },
            ),
            const SizedBox(width: 14), // Tighter gap between icons
            const ElvanPopupMenu(), // Our brand new custom popup trigger!
            const SizedBox(width: 12), // Right padding inside the pill
          ],
          navItems: _masterNavItems.take(_navItemCount).toList(),
          // Load ALL 5 screens into memory instantly!
          slivers: List.generate(_navItemCount, (index) {
            Widget body;
            if (index == 1) {
              // Albums Tab
              body = SliverPadding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 32,
                  bottom: 120, // clearance for the floating pill
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, gridIndex) => _AlbumCard(album: _albums[gridIndex]),
                    childCount: _albums.length,
                  ),
                ),
              );
            } else {
              // Dummy Screens for all other tabs
              final item = _masterNavItems[index];
              body = SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.activeIcon ?? item.icon,
                        size: 80,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Dummy screen for ${item.label}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Hide the inactive screens but keep them fully loaded in memory!
            return SliverOffstage(
              offstage: _currentTab != index,
              sliver: body,
            );
          }),
        ),

      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumMock {
  const _AlbumMock(this.name, this.count, this.color);

  final String name;
  final int count;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// ALBUM CARD — Sample grid tile mimicking the Samsung Gallery look
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final _AlbumMock album;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: album.color,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Placeholder gradient fill ──
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  album.color,
                  Color.lerp(album.color, Colors.black, 0.15)!,
                ],
              ),
            ),
          ),
          // ── Icon placeholder ──
          Center(
            child: Icon(
              CupertinoIcons.photo,
              size: 36,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          // ── Bottom label overlay ──
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  album.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${album.count}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


