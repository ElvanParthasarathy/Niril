import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL — Fully decoupled nav item descriptor
// ─────────────────────────────────────────────────────────────────────────────

/// Describes a single tab entry for the custom floating pill navbar.
///
/// Each [CustomNavItem] carries its own [icon], [activeIcon], and [label]
/// so the shell remains completely agnostic of domain logic.
class CustomNavItem {
  const CustomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  /// Icon rendered when this tab is **not** selected.
  final IconData icon;

  /// Optional override icon rendered when this tab **is** selected.
  /// Falls back to [icon] if null.
  final IconData? activeIcon;

  /// Human-readable label displayed beneath the icon.
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// ONE UI TEMPLATE SHELL — The reusable page scaffold
// ─────────────────────────────────────────────────────────────────────────────

/// A production-grade, Samsung One UI-inspired page shell featuring:
///
/// 1. **One-handed collapsible header** — large title low on screen that
///    shrinks into a pinned centered toolbar on scroll.
/// 2. **Boundary gradient fade masks** — soft fade at top/bottom edges so
///    list items melt away before reaching hard panel borders.
/// 3. **100 % custom floating pill navbar** — capsule-shaped bottom bar
///    positioned with [AnimatedPositioned] inside a [Stack].
/// 4. **Scroll-to-hide engine** — the pill slides off-screen on downward
///    scroll and slides back on upward scroll.
///
/// This widget is **fully decoupled** — pass any [body], [title],
/// [navActions], [navItems], [currentIndex], and [onTabSelected] callback.
class OneUiTemplateShell extends StatefulWidget {
  const OneUiTemplateShell({
    super.key,
    required this.body,
    required this.title,
    required this.navActions,
    required this.navItems,
    required this.currentIndex,
    required this.onTabSelected,
  });

  /// The scrollable content placed inside the [CustomScrollView] as a sliver.
  final Widget body;

  /// Large title shown in the expanded header area.
  final String title;

  /// Action widgets rendered below the title in the expanded header
  /// (e.g. add, search, overflow menu icons).
  final List<Widget> navActions;

  /// Tab descriptors for the floating pill navbar.
  final List<CustomNavItem> navItems;

  /// Zero-based index of the currently active tab.
  final int currentIndex;

  /// Callback fired when the user taps a different tab.
  final ValueChanged<int> onTabSelected;

  @override
  State<OneUiTemplateShell> createState() => _OneUiTemplateShellState();
}

class _OneUiTemplateShellState extends State<OneUiTemplateShell>
    with SingleTickerProviderStateMixin {
  // ── Navbar hide / show animation ──────────────────────────────────────
  late final AnimationController _navbarController;
  late final Animation<double> _navbarOpacity;

  /// Navbar total height including internal padding.
  static const double _kNavbarHeight = 60.0;

  /// Bottom margin between the pill and the screen edge.
  static const double _kNavbarBottomMargin = 28.0;

  /// Horizontal margin for the floating pill.
  static const double _kNavbarHorizontalMargin = 20.0;

  /// Height of the gradient fade mask at each boundary.
  static const double _kFadeMaskHeight = 96.0;

  /// Expanded header height for the One UI style large title.
  static const double _kExpandedHeight = 240.0;

  bool _isNavbarVisible = true;

  @override
  void initState() {
    super.initState();
    _navbarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _navbarOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navbarController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _navbarController.dispose();
    super.dispose();
  }

  // ── Scroll direction listener ─────────────────────────────────────────

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      
      if (delta > 0) {
        // Scrolling DOWN (finger moving up)
        
        // Hide ONLY if it's a momentum fling (finger off screen) with a little speed
        final bool isMomentumFling = notification.dragDetails == null;
        if (isMomentumFling && delta > 2.0 && _isNavbarVisible) {
          _isNavbarVisible = false;
          _navbarController.forward();
        }
      } else if (delta < 0) {
        // Scrolling UP (finger moving down) -> Show immediately!
        if (!_isNavbarVisible) {
          _isNavbarVisible = true;
          _navbarController.reverse();
        }
      }
    } else if (notification is ScrollEndNotification) {
      // Show immediately when scrolling comes to a complete stop
      if (!_isNavbarVisible) {
        _isNavbarVisible = true;
        _navbarController.reverse();
      }
    }
    return false; // allow notification to continue bubbling
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Layer 1: Scrollable content with SliverAppBar ────────────
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: _buildScrollView(context, backgroundColor),
          ),

          // ─── Layer 2: Bottom boundary gradient fade mask ──────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _kFadeMaskHeight + _kNavbarHeight + _kNavbarBottomMargin,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withAlpha(0),
                      backgroundColor.withAlpha(40),
                      backgroundColor.withAlpha(140),
                      backgroundColor,
                    ],
                    stops: const [0.0, 0.3, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ─── Layer 3: Floating pill navbar ────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: _kNavbarBottomMargin,
            child: Center(
              child: FadeTransition(
              opacity: _navbarOpacity,
              child: AnimatedBuilder(
                animation: _navbarOpacity,
                builder: (context, child) {
                  return IgnorePointer(
                    ignoring: _navbarOpacity.value < 0.5,
                    child: child,
                  );
                },
                child: _TranslucentPillNavbar(
                  items: widget.navItems,
                  currentIndex: widget.currentIndex,
                  onTabSelected: widget.onTabSelected,
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  // ── CustomScrollView with SliverAppBar + body ─────────────────────────

  Widget _buildScrollView(BuildContext context, Color bg) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: _kExpandedHeight,
          pinned: false,
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 56.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // ── Large title for one-handed reach ──
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ── Action buttons row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.navActions,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Body content sliver ──
        widget.body,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSLUCENT PILL NAVBAR — Clear floating capsule that fades on scroll
// ─────────────────────────────────────────────────────────────────────────────

class _TranslucentPillNavbar extends StatelessWidget {
  const _TranslucentPillNavbar({
    required this.items,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final List<CustomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        // ── Translucent white — content is clearly visible beneath ──
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Perfect 4px gap all around with reduced overlap
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Force items to stretch vertically

          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            return _TranslucentNavItem(
              item: items[index],
              isActive: isActive,
              onTap: () => onTabSelected(index),
              itemCount: items.length,
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSLUCENT NAV ITEM — Individual tab with solid capsule highlight
// ─────────────────────────────────────────────────────────────────────────────

class _TranslucentNavItem extends StatelessWidget {
  const _TranslucentNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.itemCount,
  });

  final CustomNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final icon = isActive ? (item.activeIcon ?? item.icon) : item.icon;
    final color = isActive
        ? const Color(0xFF1A1A1A)
        : const Color(0xFF7C7C80);

    // Uniform Apple pattern: large icons, small labels regardless of item count.
    const double iconSize = 23.0;
    const double fontSize = 9.5;
    
    // The visual layout width. Increased spacing stretches the main white pill and makes room.
    final double layoutWidth = itemCount <= 4 ? 67.0 : 61.0;
    
    // The width of the active grey background pill. Restored to its beautiful elongated shape!
    // Overlap remains a perfectly safe 4px.
    final double bgWidth = itemCount <= 4 ? 75.0 : 69.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: layoutWidth,
        // Removed hardcoded height to allow vertical stretching
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow the background to bleed out!
          children: [
            // ── Background Pill (Detached from layout bounds) ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              // Center the overlapping background by shifting it left by half the overlap distance
              left: isActive ? (layoutWidth - bgWidth) / 2 : 0,
              width: isActive ? bgWidth : layoutWidth,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE5E5E5).withValues(alpha: 0.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                            color: Colors.black.withValues(alpha: 0.04),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            
            // ── Foreground Content ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: color,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
