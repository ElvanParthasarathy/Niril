import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'elvan_expanded_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE CONTENT (Scroll View & Slivers)
// ─────────────────────────────────────────────────────────────────────────────

class ElvanPageContent extends StatelessWidget {
  const ElvanPageContent({
    super.key,
    required this.scrollController,
    required this.title,
    required this.navActions,
    required this.slivers,
    required this.expandedHeight,
    required this.isHeaderExpandedNotifier,
    this.leadingWidget,
    this.showLeadingWidgetInExpandedBar = true,
    this.isSearchActiveNotifier,
  });

  final ScrollController scrollController;
  final String title;
  final List<Widget> navActions;
  final List<Widget> slivers;
  final double expandedHeight;
  final ValueNotifier<bool> isHeaderExpandedNotifier;
  final Widget? leadingWidget;
  final bool showLeadingWidgetInExpandedBar;
  final ValueNotifier<bool>? isSearchActiveNotifier;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double snapThreshold = expandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          cacheExtent: 1500, // Pre-builds items off-screen to prevent frame drops during slow scrolling!
          dragStartBehavior: DragStartBehavior.down, // Forces scroll to start instantly, ignoring Cupertino back-swipe delay!
          physics: ElvanBrickWallPhysics(
            isHeaderExpandedNotifier: isHeaderExpandedNotifier,
            snapThreshold: snapThreshold,
            parent: const AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ElvanExpandedBarDelegate(
                title: title,
                navActions: navActions,
                statusBarHeight: MediaQuery.paddingOf(context).top,
                expandedHeight: expandedHeight,
                leadingWidget: showLeadingWidgetInExpandedBar ? leadingWidget : null,
                isSearchActiveNotifier: isSearchActiveNotifier ?? ValueNotifier(false),
              ),
            ),

            // ── Small gap so cards sit slightly below the naked icons ──
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            // ── Body content slivers ──
            ...slivers,

            // ── Smart Bottom Padding ──
            // Only adds empty space if the cards aren't tall enough to allow the header to collapse.
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final double statusBarHeight = MediaQuery.paddingOf(context).top;
                final double handOffOffset = expandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;
                
                // The absolute minimum total scroll height required to collapse the header
                final double requiredTotalHeight = constraints.viewportMainAxisExtent + handOffOffset;
                final double currentSliversHeight = constraints.precedingScrollExtent;
                
                final double missingHeight = requiredTotalHeight - currentSliversHeight;
                
                return SliverToBoxAdapter(
                  child: SizedBox(height: missingHeight > 0 ? missingHeight : 0),
                );
              },
            ),
          ],
        ),

        // ── EDGE SCROLL BLOCKERS ──
        // These invisible shields sit on the far left and right edges.
        // They swallow vertical gestures so the ScrollView doesn't wobble,
        // but they let horizontal gestures pass through for the system back-swipe!
        Positioned(
          left: 0, top: 0, bottom: 0, width: 24,
          child: GestureDetector(
            onVerticalDragUpdate: (_) {}, // Catch and kill vertical drags
            behavior: HitTestBehavior.translucent, // Let horizontal drags pass to system
          ),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0, width: 24,
          child: GestureDetector(
            onVerticalDragUpdate: (_) {},
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

/// A custom ScrollPhysics that acts as a mathematical "Brick Wall".
/// When the header is collapsed (isHeaderExpandedNotifier is false),
/// this completely prevents the CustomScrollView from scrolling below the snapThreshold.
/// This guarantees zero 1-frame visual leaks because the layout engine never even
/// receives an offset below the threshold.
class ElvanBrickWallPhysics extends ScrollPhysics {
  const ElvanBrickWallPhysics({
    required this.isHeaderExpandedNotifier,
    required this.snapThreshold,
    super.parent,
  });

  final ValueNotifier<bool> isHeaderExpandedNotifier;
  final double snapThreshold;

  @override
  ElvanBrickWallPhysics applyTo(ScrollPhysics? ancestor) {
    return ElvanBrickWallPhysics(
      isHeaderExpandedNotifier: isHeaderExpandedNotifier,
      snapThreshold: snapThreshold,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (!isHeaderExpandedNotifier.value) {
      // Enforce our custom hard boundary!
      if (value < snapThreshold && position.pixels <= snapThreshold) {
        return value - position.pixels; // Prevent overscroll past threshold
      }
      if (value < snapThreshold && position.pixels > snapThreshold) {
        return value - snapThreshold; // Prevent momentum past threshold
      }
    }
    
    // Normal bounds
    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (!isHeaderExpandedNotifier.value) {
      // If we are at or below the threshold, and trying to go further up (velocity < 0), stop it immediately.
      if (position.pixels <= snapThreshold && velocity <= 0.0) {
        return null; // returning null kills momentum perfectly!
      }
    }
    return super.createBallisticSimulation(position, velocity);
  }
}