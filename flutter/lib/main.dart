import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/printing/presentation/elvan_shell.dart';

void main() {
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod state management
    const ProviderScope(
      child: ElvanNirilApp(),
    ),
  );
}

class ElvanNirilApp extends StatelessWidget {
  const ElvanNirilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elvan Niril Next-Gen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ElvanSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        useMaterial3: true,
      ),
      home: const ShellDemoScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMO SCREEN — Showcases OneUiTemplateShell with a sample album grid
// ─────────────────────────────────────────────────────────────────────────────

class ShellDemoScreen extends StatefulWidget {
  const ShellDemoScreen({super.key});

  @override
  State<ShellDemoScreen> createState() => _ShellDemoScreenState();
}

class _ShellDemoScreenState extends State<ShellDemoScreen> {
  int _currentTab = 1; // Start on "Albums" tab
  int _navItemCount = 5; // Dev testing count

  // ── Master list of 6 nav items for testing dynamic scaling ───────────────
  static const List<CustomNavItem> _masterNavItems = [
    CustomNavItem(
      icon: Icons.photo_outlined,
      activeIcon: Icons.photo,
      label: 'Pictures',
    ),
    CustomNavItem(
      icon: Icons.photo_album_outlined,
      activeIcon: Icons.photo_album,
      label: 'Albums',
    ),
    CustomNavItem(
      icon: Icons.collections_bookmark_outlined,
      activeIcon: Icons.collections_bookmark,
      label: 'Collections',
    ),
    CustomNavItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Menu',
    ),
    CustomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: 'Search',
    ),
    CustomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
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
    final String currentTitle = currentItem.label;

    return Stack(
      children: [
        ElvanShell(
          title: currentTitle,
          currentIndex: _currentTab,
          onTabSelected: (index) => setState(() => _currentTab = index),
          navActions: const [
            _ActionIcon(icon: Icons.add, tooltip: 'Create album'),
            _ActionIcon(icon: Icons.search_rounded, tooltip: 'Search'),
            _ActionIcon(icon: Icons.more_vert_rounded, tooltip: 'More options'),
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
              Icons.photo_rounded,
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTION ICON BUTTON — Reusable header action widget
// ─────────────────────────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon),
      iconSize: 24,
      color: Colors.black,
      tooltip: tooltip,
      splashRadius: 22,
      constraints: const BoxConstraints(), // Strips the hidden 48x48 minimum size
      style: IconButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removes extra margin
      ),
    );
  }
}
