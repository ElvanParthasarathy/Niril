import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

export 'elvan_navbar.dart';
import 'elvan_navbar.dart';
import 'elvan_collapsed_bar.dart';
import 'elvan_expanded_bar.dart';
import 'elvan_page_content.dart';

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
class ElvanShell extends StatefulWidget {
  const ElvanShell({
    super.key,
    required this.slivers,
    required this.title,
    this.navActions = const [],
    this.navItems = const [],
    this.currentIndex = 0,
    this.onTabSelected,
    this.showNavbar = true,
    this.leadingWidget,
    this.showLeadingWidgetInExpandedBar = true,
  });

  /// The scrollable content placed inside the [CustomScrollView] as slivers.
  final List<Widget> slivers;

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
  final ValueChanged<int>? onTabSelected;

  /// Whether to render the floating bottom navbar and its associated fade mask.
  final bool showNavbar;

  /// Optional widget rendered on the leading edge (e.g., Back button or Page Title)
  final Widget? leadingWidget;

  /// Whether the leadingWidget should also be rendered flat in the expanded header.
  /// Set to true for Back buttons. Set to false for floating page titles.
  final bool showLeadingWidgetInExpandedBar;

  @override
  State<ElvanShell> createState() => _ElvanShellState();
}

class _ElvanShellState extends State<ElvanShell>
    with SingleTickerProviderStateMixin {
  // ── Navbar hide / show animation ──────────────────────────────────────
  late final AnimationController _navbarController;
  late final Animation<double> _navbarOpacity;
  
  // ── Scroll tracking for One UI Physics ────────────────────────────────
  late ScrollController _scrollController;
  bool _isScrollInitialized = false;

  /// Navbar total height including internal padding.
  static const double _kNavbarHeight = 60.0;

  /// Bottom margin between the pill and the screen edge.
  static const double _kNavbarBottomMargin = 28.0;

  /// Horizontal margin for the floating pill.
  static const double _kNavbarHorizontalMargin = 20.0;

  /// Height of the gradient fade mask at each boundary.
  static const double _kFadeMaskHeight = 96.0;

  /// Expanded header height for the One UI style large title.
  static const double _kExpandedHeight = 320.0;

  bool _isNavbarVisible = true;
  final ValueNotifier<bool> _isHeaderExpandedNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<double> _dynamicPillHeightNotifier = ValueNotifier<double>(50.0);
  final GlobalKey _pillKey = GlobalKey();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScrollInitialized) {
      _scrollController = ScrollController();
      _isScrollInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final double statusBarHeight = MediaQuery.paddingOf(context).top;
        final double handOffOffset = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(handOffOffset);
          _isHeaderExpandedNotifier.value = false; // Initialize to collapsed state on start
        }
      });
    }
  }

  @override
  void dispose() {
    _navbarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll direction listener ─────────────────────────────────────────

  bool _handleScrollNotification(ScrollNotification notification) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double snapThreshold = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
    
    // ── Update State Flags ──
    if (_scrollController.hasClients) {
      final double offset = _scrollController.offset;
      if (_isHeaderExpandedNotifier.value && offset >= snapThreshold) {
        _isHeaderExpandedNotifier.value = false; // Flagged as hidden/collapsed
      } else if (!_isHeaderExpandedNotifier.value) {
        // Detect explicit manual pull down against the brick wall!
        if (notification is OverscrollNotification && notification.overscroll < 0) {
          _isHeaderExpandedNotifier.value = true;
        } else if (offset < snapThreshold && notification is ScrollUpdateNotification && notification.dragDetails != null) {
          // Fallback just in case physics allowed a slight sub-pixel crossing
          _isHeaderExpandedNotifier.value = true;
        }
      }
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final double offset = _scrollController.offset;
      
      // ── BRICK WALL: Stop momentum if it tries to expand the header ──
      // This is now mathematically handled by BrickWallScrollPhysics!
      // But we still snap it perfectly just in case.
      if (!_isHeaderExpandedNotifier.value && offset < snapThreshold && notification.dragDetails == null) {
         _scrollController.position.hold(() {});
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (_scrollController.hasClients) {
             _scrollController.jumpTo(snapThreshold);
           }
         });
      }

      // ── Navbar hide/show logic ──
      if (delta > 0) {
        // Scrolling DOWN (finger moving up)
        final double ceiling = statusBarHeight + 20.0;
        final double collisionOffset = (_kExpandedHeight + 40.0) - (ceiling + 50.0);
        final double liftStartOffset = collisionOffset - 4.0;
        
        final bool isTruePill = _scrollController.offset > liftStartOffset;

        // Hide ONLY if it's a momentum fling (finger off screen) AND it is a TRUE pill!
        final bool isMomentumFling = notification.dragDetails == null;
        if (isMomentumFling && delta > 2.0 && _isNavbarVisible && isTruePill) {
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

      // ── Samsung One UI Physics: Snapping the Header ──
      // Snap to the hand-off point where icons first stick to ceiling
      final double statusBarHeight = MediaQuery.paddingOf(context).top;
      final double snapThreshold = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
      
      final currentOffset = _scrollController.offset;
      if (currentOffset > 0 && currentOffset < snapThreshold) {
        // We are caught in the middle! Snap to the closest stage.
        final targetOffset = currentOffset > (snapThreshold / 2) ? snapThreshold : 0.0;
        final double distance = (currentOffset - targetOffset).abs();
        
        // Adaptive duration: longer minimum duration for a gentle settle, softer scaling
        final int durationMs = (250 + (distance * 0.5)).toInt().clamp(250, 450);
        
        Future.microtask(() {
          _scrollController.animateTo(
            targetOffset,
            duration: Duration(milliseconds: durationMs),
            curve: Curves.decelerate, // Soft, natural deceleration like a weak magnet
          );
        });
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
            child: ElvanPageContent(
              scrollController: _scrollController,
              title: widget.title,
              navActions: widget.navActions,
              slivers: widget.slivers,
              expandedHeight: _kExpandedHeight,
              isHeaderExpandedNotifier: _isHeaderExpandedNotifier, // Passed to content
              leadingWidget: widget.leadingWidget,
              showLeadingWidgetInExpandedBar: widget.showLeadingWidgetInExpandedBar,
            ),
          ),

          // ─── Layer 2: Bottom boundary gradient fade mask ──────────────
          if (widget.showNavbar)
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

          // ─── Layer 2.5: Top boundary gradient fade mask ───────────────
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _kFadeMaskHeight, // 96 pixels of smooth top fade
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor, // Solid at the very top edge
                      backgroundColor.withAlpha(140),
                      backgroundColor.withAlpha(40),
                      backgroundColor.withAlpha(0), // Fully transparent below
                    ],
                    stops: const [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ─── Layer 3: Floating pill navbar ────────────────────────────
          if (widget.showNavbar)
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
                    child: ElvanNavbar(
                      items: widget.navItems,
                      currentIndex: widget.currentIndex,
                      onTabSelected: widget.onTabSelected ?? (_) {},
                    ),
                  ),
                ),
              ),
            ),

          // ── Component B: Independent Top Bar (Pill) ──
          ElvanCollapsedBar(
            scrollController: _scrollController,
            hideAnimation: _navbarOpacity,
            navActions: widget.navActions,
            expandedHeight: _kExpandedHeight,
            isHeaderExpandedNotifier: _isHeaderExpandedNotifier,
            dynamicPillHeightNotifier: _dynamicPillHeightNotifier,
            pillKey: _pillKey,
            leadingWidget: widget.leadingWidget,
            expandedSmallTitle: (widget.title != null && widget.leadingWidget == null) ? Text(
              widget.title!,
              style: TextStyle(
                fontSize: 20, // Slightly larger and bolder
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.95) 
                    : Colors.black,
                height: 1.15,
              ),
            ) : null,
          ),

          // ── Dev Scroll Offset Badge ──
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(200),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Offset: ${offset.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}