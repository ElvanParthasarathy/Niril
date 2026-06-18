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
  });

  final ScrollController scrollController;
  final String title;
  final List<Widget> navActions;
  final List<Widget> slivers;
  final double expandedHeight;
  final ValueNotifier<bool> isHeaderExpandedNotifier;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double snapThreshold = expandedHeight - 8.0 - kToolbarHeight - statusBarHeight - 20.0;

    return CustomScrollView(
      controller: scrollController,
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
            final double currentHeight = constraints.precedingScrollExtent;
            
            final double missingHeight = requiredTotalHeight - currentHeight;
            
            return SliverToBoxAdapter(
              child: SizedBox(height: missingHeight > 0 ? missingHeight : 0),
            );
          },
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
