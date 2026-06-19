import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'header_state.dart';

export 'elvan_navbar.dart';
import 'elvan_navbar.dart';
import 'elvan_collapsed_bar.dart';
import 'elvan_expanded_bar.dart';
import 'elvan_page_content.dart';
import 'widgets/elvan_top_bar_icon.dart';
import 'elvan_search_bar.dart';

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
class ElvanShell extends ConsumerStatefulWidget {
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
    this.showSearchIcon = false,
    this.onSearchChanged,
    this.assignedIndex,
    this.startCollapsed = false,
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

  /// Determines if the search icon should be automatically injected
  final bool showSearchIcon;

  /// Callback when search query changes
  final ValueChanged<String>? onSearchChanged;

  /// Optional index of this shell in a tabbed environment. Used to detect when this shell becomes active.
  final int? assignedIndex;

  /// Whether to start the page with the header already collapsed.
  final bool startCollapsed;

  @override
  ConsumerState<ElvanShell> createState() => _ElvanShellState();
}

class _ElvanShellState extends ConsumerState<ElvanShell>
    with SingleTickerProviderStateMixin {
  // ── Navbar hide / show animation ──────────────────────────────────────
  // ── State for sequential search animation ──
  bool _searchStep1HideIcons = false;
  bool _searchStep2ShowSearchContainer = false;
  bool _searchStep3ExpandSearch = false;
  
  // Controls the fade and hit-testing of the entire Layer 3 bottom floating pill
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
  final ValueNotifier<bool> _isSearchActiveNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _dynamicPillHeightNotifier = ValueNotifier<double>(50.0);
  final GlobalKey _pillKey = GlobalKey();
  final FocusNode _searchFocusNode = FocusNode();

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

  void _activateSearch() {
    // Auto-Collapse logic
    if (!_scrollController.hasClients) {
      _isSearchActiveNotifier.value = true;
      return;
    }
    
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double snapThreshold = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
    
    // Scroll slightly past the threshold to perfectly snap the header to its collapsed pill state
    final double targetOffset = snapThreshold + 20.0;
    
    // Animate the scroll, but start the choreography immediately!
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    
    // --- The Choreographed Container Transform Sequence ---
    
    // Step 1: Smoothly fade out the Navbar icons (leaves empty glassy pill)
    setState(() => _searchStep1HideIcons = true);
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      // Step 2: Render the small Search container precisely on top of the empty Navbar
      setState(() => _searchStep2ShowSearchContainer = true);
      
      // Step 3: Now stretch the Search container to full width and fade in its contents
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        setState(() {
          _searchStep3ExpandSearch = true;
          _isSearchActiveNotifier.value = true;
        });
        _searchFocusNode.requestFocus();
      });
    });
  }

  void _closeSearchSequence() {
    _searchFocusNode.unfocus();
    
    // Reverse Step 3: Shrink the Search container and fade out its contents
    setState(() {
      _searchStep3ExpandSearch = false;
      _isSearchActiveNotifier.value = false;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      // Reverse Step 2: Remove the small Search container to reveal the empty Navbar below
      setState(() => _searchStep2ShowSearchContainer = false);
      
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        // Reverse Step 1: Fade the Navbar icons back in
        setState(() => _searchStep1HideIcons = false);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScrollInitialized) {
      // Determine initial state:
      // If we are given an explicit startCollapsed directive, use that.
      // Otherwise, sync with the global hive mind.
      final bool isGlobalExpanded = ref.read(headerExpandedProvider);
      final bool shouldStartExpanded = widget.startCollapsed ? false : isGlobalExpanded;
      
      final double statusBarHeight = MediaQuery.paddingOf(context).top;
      final double handOffOffset = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
      
      _scrollController = ScrollController(
        initialScrollOffset: shouldStartExpanded ? 0.0 : handOffOffset,
      );
      _isHeaderExpandedNotifier.value = shouldStartExpanded;
      _isScrollInitialized = true;
    }
  }

  @override
  void didUpdateWidget(ElvanShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if we are in a tabbed environment and this specific tab just became active!
    if (widget.assignedIndex != null &&
        oldWidget.currentIndex != widget.currentIndex &&
        widget.currentIndex == widget.assignedIndex) {
      if (_scrollController.hasClients) {
        final isGlobalExpanded = ref.read(headerExpandedProvider);
        if (isGlobalExpanded) {
          _isHeaderExpandedNotifier.value = true;
          _scrollController.jumpTo(0.0);
        } else {
          _isHeaderExpandedNotifier.value = false;
          final double statusBarHeight = MediaQuery.paddingOf(context).top;
          final double handOffOffset = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
          _scrollController.jumpTo(handOffOffset);
        }
      }
    }
  }

  @override
  void dispose() {
    _navbarController.dispose();
    _scrollController.dispose();
    _isHeaderExpandedNotifier.dispose();
    _isSearchActiveNotifier.dispose();
    _dynamicPillHeightNotifier.dispose();
    _searchFocusNode.dispose();
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
        ref.read(headerExpandedProvider.notifier).state = false;
      } else if (!_isHeaderExpandedNotifier.value) {
        // Detect explicit manual pull down against the brick wall!
        if (notification is OverscrollNotification && notification.overscroll < 0) {
          _isHeaderExpandedNotifier.value = true;
          ref.read(headerExpandedProvider.notifier).state = true;
        } else if (offset < snapThreshold && notification is ScrollUpdateNotification && notification.dragDetails != null) {
          // Fallback just in case physics allowed a slight sub-pixel crossing
          _isHeaderExpandedNotifier.value = true;
          ref.read(headerExpandedProvider.notifier).state = true;
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
           if (!mounted) return;
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
          if (!mounted) return;
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              targetOffset,
              duration: Duration(milliseconds: durationMs),
              curve: Curves.decelerate, // Soft, natural deceleration like a weak magnet
            );
          }
        });
      }
    }
    return false; // allow notification to continue bubbling
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── Global Header State Sync (For IndexedStack) ──
    ref.listen<bool>(headerExpandedProvider, (previous, isGlobalExpanded) {
      if (!isGlobalExpanded && _isHeaderExpandedNotifier.value) {
        _isHeaderExpandedNotifier.value = false;
        final double statusBarHeight = MediaQuery.paddingOf(context).top;
        final double handOffOffset = _kExpandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
        if (_scrollController.hasClients && _scrollController.offset < handOffOffset) {
          _scrollController.jumpTo(handOffOffset);
        }
      } else if (isGlobalExpanded && !_isHeaderExpandedNotifier.value) {
        _isHeaderExpandedNotifier.value = true;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      }
    });

    final backgroundColor =
        Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_isSearchActiveNotifier.value) {
            _searchFocusNode.unfocus();
            // We intentionally do NOT set _isSearchActiveNotifier.value to false
            // so the search pill stays visible while scrolling results!
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
          // ─── Layer 1: Scrollable content ────────────
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ElvanPageContent(
              scrollController: _scrollController,
              title: widget.title,
              navActions: _buildEffectiveNavActions(),
              slivers: widget.slivers,
              expandedHeight: _kExpandedHeight,
              isHeaderExpandedNotifier: _isHeaderExpandedNotifier, // Passed to content
              isSearchActiveNotifier: _isSearchActiveNotifier,
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The base Navbar (icons fade out on command, but background stays!)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _searchStep3ExpandSearch ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: _searchStep2ShowSearchContainer,
                            child: ElvanNavbar(
                              items: widget.navItems,
                              currentIndex: widget.currentIndex,
                              onTabSelected: (index) {
                                if (index == widget.currentIndex) {
                                  // Scroll to top if tapping the already active tab!
                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOutCubic,
                                    );
                                  }
                                } else {
                                  widget.onTabSelected?.call(index);
                                }
                              },
                              hideContent: _searchStep1HideIcons,
                            ),
                          ),
                        ),
                        
                        // The Search Overlay (appears exactly on top of Navbar, then stretches!)
                        if (_searchStep2ShowSearchContainer)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            // Exact mathematical width of the Navbar vs full screen
                            width: _searchStep3ExpandSearch
                                ? MediaQuery.of(context).size.width - 32
                                : ((widget.navItems.length <= 4 ? 67.0 : 61.0) * widget.navItems.length + 16.0),
                            child: ElvanSearchBar(
                              focusNode: _searchFocusNode,
                              onChanged: widget.onSearchChanged,
                              onClose: () {
                                _closeSearchSequence();
                                widget.onSearchChanged?.call(''); // Clear query
                              },
                              isExpanded: _searchStep3ExpandSearch,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Component B: Independent Top Bar (Pill) ──
          ElvanCollapsedBar(
            scrollController: _scrollController,
            hideAnimation: _navbarOpacity,
            navActions: _buildEffectiveNavActions(),
            expandedHeight: _kExpandedHeight,
            isHeaderExpandedNotifier: _isHeaderExpandedNotifier,
            dynamicPillHeightNotifier: _dynamicPillHeightNotifier,
            pillKey: _pillKey,
            leadingWidget: widget.leadingWidget,
            expandedSmallTitle: widget.title != null ? Text(
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
            isSearchActiveNotifier: _isSearchActiveNotifier,
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildEffectiveNavActions() {
    if (widget.navActions.isEmpty && !widget.showSearchIcon) return [];

    final actions = List<Widget>.from(widget.navActions);
    
    // THE OPTIMIZATION: We NEVER unmount the search icon. It stays permanently in the widget tree.
    // By using a simple SizedBox that instantly toggles width, we completely remove the "sliding" animation
    // so it perfectly matches the instant snap of the page switch, while STILL preventing mount lag!
    // Wrapping the icon in a SingleChildScrollView ensures it never gets squeezed or forced to re-layout!
    final searchWidget = SizedBox(
      width: widget.showSearchIcon ? 26.0 : 0.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: SizedBox(
          width: 26.0,
          child: Opacity(
            opacity: widget.showSearchIcon ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !widget.showSearchIcon,
              child: ElvanTopBarIcon(
                icon: CupertinoIcons.search,
                onTap: _activateSearch,
              ),
            ),
          ),
        ),
      ),
    );
    
    // The padding between the search icon and the next icon
    final searchPadding = SizedBox(
      width: widget.showSearchIcon ? 14.0 : 0.0,
    );
    
    // Insert search icon and its padding before the popup menu (which is at the end)
    if (actions.length > 1) {
      actions.insert(actions.length - 2, searchWidget); 
      actions.insert(actions.length - 2, searchPadding);
    } else {
      actions.add(searchWidget);
      actions.add(searchPadding);
    }
    
    return actions;
  }
}