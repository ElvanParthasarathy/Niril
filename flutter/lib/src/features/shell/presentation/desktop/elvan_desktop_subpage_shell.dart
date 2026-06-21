import 'package:flutter/material.dart';
import '../../../../core/widgets/elvan_smooth_scroll.dart';

class ElvanSubpagePadding extends InheritedWidget {
  final EdgeInsetsGeometry padding;
  const ElvanSubpagePadding({super.key, required this.padding, required super.child});

  static EdgeInsetsGeometry? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElvanSubpagePadding>()?.padding;
  }

  @override
  bool updateShouldNotify(ElvanSubpagePadding oldWidget) => padding != oldWidget.padding;
}

class ElvanDesktopSubpageShell extends StatefulWidget {
  const ElvanDesktopSubpageShell({
    super.key,
    required this.title,
    required this.slivers,
    this.backgroundColor,
    this.hideHeaderOnDesktop = false,
    this.contentPadding,
  });

  final String title;
  final List<Widget> slivers;
  final Color? backgroundColor;
  final bool hideHeaderOnDesktop;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<ElvanDesktopSubpageShell> createState() => _ElvanDesktopSubpageShellState();
}

class _ElvanDesktopSubpageShellState extends State<ElvanDesktopSubpageShell> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    bool isInsideSettingsSplitView = false;
    context.visitAncestorElements((element) {
      final typeName = element.widget.runtimeType.toString();
      if (typeName == 'SettingsScreen' || typeName == '_SettingsScreenState') {
        isInsideSettingsSplitView = true;
        return false;
      }
      return true;
    });

    final isWideDesktop = MediaQuery.sizeOf(context).width >= 1100;
    final isSplitView = isInsideSettingsSplitView && isWideDesktop;
    final showBackButton = canPop && !isSplitView;

    return Material(
      color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: ElvanSmoothScroll(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (!widget.hideHeaderOnDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 56, left: 60, bottom: 24),
                child: Row(
                  children: [
                    if (showBackButton) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                    ] else ...[
                      const SizedBox(width: 20),
                    ],
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
            
            ...widget.slivers.map((sliver) => SliverPadding(
                  padding: widget.contentPadding ?? ElvanSubpagePadding.of(context) ?? const EdgeInsets.symmetric(horizontal: 24),
                  sliver: sliver,
                )),
          ],
        ),
      ),
    );
  }
}
