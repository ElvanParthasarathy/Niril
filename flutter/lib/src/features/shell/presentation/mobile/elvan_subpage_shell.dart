import 'package:flutter/material.dart';
import 'dart:io';
import 'package:elvan_niril/src/features/shell/presentation/mobile/elvan_shell.dart';
import '../desktop/elvan_desktop_subpage_shell.dart';
import 'widgets/elvan_back_button.dart';

/// A wrapper around [ElvanShell] exclusively designed for subpages (e.g. Settings, PDF Viewer).
/// It inherently injects the [ElvanBackButton] into the shell's physics engine
/// and disables the bottom navigation bar.
class ElvanSubpageShell extends StatefulWidget {
  const ElvanSubpageShell({
    super.key,
    required this.title,
    required this.slivers,
    this.navActions = const [],
    this.startCollapsed = true,
    this.backgroundColor,
    this.hideHeaderOnDesktop = false,
    this.contentPadding,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget> navActions;
  final bool startCollapsed;
  final Color? backgroundColor;
  final bool hideHeaderOnDesktop;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<ElvanSubpageShell> createState() => _ElvanSubpageShellState();
}

class _ElvanSubpageShellState extends State<ElvanSubpageShell> {
  @override
  Widget build(BuildContext context) {
    // Always use desktop shell on desktop platforms to avoid jarring transitions to mobile AppBars
    final isDesktopPlatform =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final isDesktop =
        isDesktopPlatform || MediaQuery.sizeOf(context).width >= 800;

    if (isDesktop) {
      return ElvanDesktopSubpageShell(
        title: widget.title,
        slivers: widget.slivers,
        backgroundColor: widget.backgroundColor,
        hideHeaderOnDesktop: widget.hideHeaderOnDesktop,
        contentPadding: widget.contentPadding,
      );
    }

    // Mobile view uses the full ElvanShell with draggable physics
    return ElvanShell(
      title: widget.title,
      showNavbar: false,
      startCollapsed: widget.startCollapsed,
      navActions: widget.navActions,
      leadingWidget: const ElvanBackButton(),
      showLeadingWidgetInExpandedBar: true,
      slivers: widget.slivers,
      backgroundColor: widget.backgroundColor,
      syncWithGlobalHeader: false,
    );
  }
}
