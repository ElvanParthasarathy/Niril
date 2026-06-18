import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A reusable, independent Top Bar component that seamlessly handles the "Visual Hand-off"
/// and white pill background physics for the One UI design language.
class ElvanCollapsedBar extends StatelessWidget {
  const ElvanCollapsedBar({
    super.key,
    required this.scrollController,
    required this.hideAnimation,
    required this.navActions,
    required this.isHeaderExpandedNotifier,
    this.expandedHeight = 320.0,
  });

  /// The scroll controller attached to the page's CustomScrollView.
  /// Used to calculate hand-off thresholds and collision physics.
  final ScrollController scrollController;

  /// The animation controller that dictates when the top bar should fade out.
  /// (e.g., synchronized with the bottom navbar hiding).
  final Animation<double> hideAnimation;

  /// The list of icon buttons to display inside the pill.
  final List<Widget> navActions;

  /// The maximum physical height of the page header before scrolling.
  final double expandedHeight;

  /// Flag indicating if the expanded header is logically visible.
  final ValueNotifier<bool> isHeaderExpandedNotifier;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scrollController, hideAnimation]),
      builder: (context, child) {
        if (!scrollController.hasClients) return const SizedBox.shrink();
        
        final double shrinkOffset = scrollController.offset;
        final double statusBarHeight = MediaQuery.paddingOf(context).top;
        final double ceiling = statusBarHeight + 20.0;
        
        // 1. Hand-off logic: Calculate where Component A (the naked icons) is currently positioned
        final double currentTop = expandedHeight - shrinkOffset - 8.0 - kToolbarHeight;
        final bool isPinned = currentTop <= ceiling;
        
        // If the hand-off hasn't happened yet (the icons haven't reached the ceiling),
        // Component B remains completely invisible.
        if (!isPinned) return const SizedBox.shrink(); 
        
        double liftProgress = 0.0;
        
        final bool isExpanded = isHeaderExpandedNotifier.value;
        if (!isExpanded) {
           // We are in collapsed mode. Ignore physics and fully lock the pill!
           liftProgress = 1.0;
        } else {
           // 2. True Pill Logic: Calculate when the gallery cards physically collide with the pill
           // +40 = 32 (original card margin) + 8 (extra card padding gap)
           // 50.0 is the exact physical height of the new, tighter pill
           final double collisionOffset = (expandedHeight + 40.0) - (ceiling + 50.0);
           final double liftStartOffset = collisionOffset - 4.0;
           
           if (shrinkOffset > liftStartOffset) {
             liftProgress = ((shrinkOffset - liftStartOffset) / 12.0).clamp(0.0, 1.0);
           }
        }
        
        return Positioned(
          top: ceiling,
          right: 16,
          child: Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: hideAnimation.value, // Fade out when the page tells us to hide
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: liftProgress > 0 ? [
                    BoxShadow(
                      blurRadius: 16 * liftProgress,
                      offset: Offset(0, 4 * liftProgress),
                      color: Colors.black.withValues(alpha: 0.05 * liftProgress),
                    )
                  ] : null,
                ),
                child: Material(
                  type: MaterialType.canvas,
                  color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white).withValues(alpha: 0.88 * liftProgress),
                  borderRadius: BorderRadius.circular(100),
                  clipBehavior: Clip.antiAlias, // Clips the beautiful circular ripples smoothly to the pill border!
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12), // Tighter vertical padding for 50px pill
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: navActions,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A reusable back button component that follows the exact same "Visual Hand-off"
/// and white circle background physics as ElvanCollapsedBar, but positioned on the left.
class ElvanBackButton extends StatelessWidget {
  const ElvanBackButton({
    super.key,
    required this.scrollController,
    required this.hideAnimation,
    required this.isHeaderExpandedNotifier,
    this.expandedHeight = 320.0,
  });

  final ScrollController scrollController;
  final Animation<double> hideAnimation;
  final ValueNotifier<bool> isHeaderExpandedNotifier;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scrollController, hideAnimation, isHeaderExpandedNotifier]),
      builder: (context, child) {
        if (!scrollController.hasClients) return const SizedBox.shrink();
        if (!Navigator.canPop(context)) return const SizedBox.shrink();
        
        final double shrinkOffset = scrollController.offset;
        final double statusBarHeight = MediaQuery.paddingOf(context).top;
        final double ceiling = statusBarHeight + 20.0;
        
        // 1. Hand-off logic
        final double currentTop = expandedHeight - shrinkOffset - 8.0 - kToolbarHeight;
        final bool isPinned = currentTop <= ceiling;
        
        if (!isPinned) return const SizedBox.shrink(); 
        
        double liftProgress = 0.0;
        
        final bool isExpanded = isHeaderExpandedNotifier.value;
        if (!isExpanded) {
           liftProgress = 1.0;
        } else {
           // 2. True Pill Logic
           // +40 = 32 (original card margin) + 8 (extra card padding gap)
           // 50.0 is the exact physical height of the new, tighter pill
           final double collisionOffset = (expandedHeight + 40.0) - (ceiling + 50.0);
           final double liftStartOffset = collisionOffset - 4.0;
           
           if (shrinkOffset > liftStartOffset) {
             liftProgress = ((shrinkOffset - liftStartOffset) / 12.0).clamp(0.0, 1.0);
           }
        }
        
        return Positioned(
          top: ceiling,
          left: 16,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: hideAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white).withValues(alpha: 0.88 * liftProgress),
                  shape: BoxShape.circle,
                  boxShadow: liftProgress > 0 ? [
                    BoxShadow(
                      blurRadius: 16 * liftProgress,
                      offset: Offset(0, 4 * liftProgress),
                      color: Colors.black.withValues(alpha: 0.05 * liftProgress),
                    )
                  ] : null,
                ),
                padding: const EdgeInsets.all(7),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.back),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
