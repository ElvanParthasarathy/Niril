import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/elvan_popup_menu.dart';

/// A reusable, independent Top Bar component that seamlessly handles the "Visual Hand-off"
/// and white pill background physics for the One UI design language.
class ElvanCollapsedBar extends ConsumerWidget {
  const ElvanCollapsedBar({
    super.key,
    required this.scrollController,
    required this.hideAnimation,
    required this.isHeaderExpandedNotifier,
    required this.dynamicPillHeightNotifier,
    required this.isSearchActiveNotifier,
    this.pillKey,
    required this.navActions,
    this.expandedHeight = 320.0,
    this.cardPadding = 21.0,
    this.leadingWidget,
    this.expandedSmallTitle,
  });

  final ScrollController scrollController;
  final Animation<double> hideAnimation;
  final ValueNotifier<bool> isHeaderExpandedNotifier;
  final ValueNotifier<double> dynamicPillHeightNotifier;
  final ValueNotifier<bool> isSearchActiveNotifier;
  final GlobalKey? pillKey;
  final List<Widget> navActions;
  final double expandedHeight;
  final double cardPadding;

  final Widget? leadingWidget;
  final Widget? expandedSmallTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(popupMenuOpenProvider);
    
    return AnimatedBuilder(
      animation: Listenable.merge([scrollController, hideAnimation, isSearchActiveNotifier]),
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
        
        // If there are no icons AND no leading widget to display, we don't need to draw anything!
        if (navActions.isEmpty && leadingWidget == null) return const SizedBox.shrink();
        
        double liftProgress = 0.0;
        
        // We use the dynamically measured pill height!
        // cardPadding is the user's specific sliver padding offset, but it adapts dynamically to the true pill height.
        final double currentPillHeight = dynamicPillHeightNotifier.value;
        final double collisionOffset = (expandedHeight + cardPadding) - (ceiling + currentPillHeight);
        final double liftStartOffset = collisionOffset - 4.0;
        
        if (shrinkOffset > liftStartOffset) {
          liftProgress = ((shrinkOffset - liftStartOffset) / 12.0).clamp(0.0, 1.0);
        }
        
        // DYNAMIC ISLAND IMPACT BUMP:
        // A parabola that peaks at 1.0 exactly halfway through the 12-pixel handoff.
        // It creates a 5% physical "squash and stretch" scaling effect to completely mask the seam!
        final double impactBump = 4.0 * liftProgress * (1.0 - liftProgress);
        final double impactScale = 1.0 + (impactBump * 0.05);
        
        // STANDARD LAYOUT: Native pill uses standard 8.0 internal spacing.
        const double collapsedXNudge = 8.0; 
        
        return Stack(
          children: [
            if (leadingWidget != null || expandedSmallTitle != null)
              Positioned(
                top: ceiling,
                left: 16,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: hideAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: liftProgress > 0 && leadingWidget != null ? [
                          BoxShadow(
                            blurRadius: 16 * liftProgress,
                            offset: Offset(0, 4 * liftProgress),
                            color: Colors.black.withAlpha((255 * 0.05 * liftProgress).round()),
                          )
                        ] : null,
                      ),
                      child: Material(
                        type: MaterialType.canvas,
                        color: leadingWidget != null 
                          ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white).withAlpha((255 * 0.88 * liftProgress).round())
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        clipBehavior: Clip.antiAlias,
                        child: expandedSmallTitle != null 
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // MICRO-NUDGE: Tune this value to perfectly match the Expanded Bar's AbsX.
                                  SizedBox(width: collapsedXNudge), // Change this number to adjust native text position
                                  Transform.scale(
                                    scale: impactScale,
                                    alignment: Alignment.centerLeft,
                                    child: Opacity(
                                      opacity: liftProgress,
                                      child: expandedSmallTitle!,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : leadingWidget,
                      ),
                    ),
                  ),
                ),
              ),

            if (navActions.isNotEmpty)
              Positioned(
                top: ceiling,
                right: 16,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: (isSearchActiveNotifier.value || isMenuOpen) ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: isSearchActiveNotifier.value || isMenuOpen,
                      child: Opacity(
                        opacity: hideAnimation.value, // Fade out when the page tells us to hide
                        child: Container(
                          key: pillKey,
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
                  ),
                ),
              ),

              // ── NATIVE TEXT DEV HUD ──
              if (expandedSmallTitle != null)
                Positioned(
                  top: ceiling + 60, // Moved down to not hide the text
                  left: 16,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Native AbsX: ${16 + 4 + collapsedXNudge}\n(16 + 4 + $collapsedXNudge)', // 16 (Positioned) + 4 (Padding) + Nudge
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}