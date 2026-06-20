import 'package:flutter/material.dart';
import 'package:elvan_niril/src/features/shell/presentation/mobile/elvan_shell.dart';
import '../../features/shell/presentation/mobile/widgets/elvan_close_button.dart';

/// A wrapper around [ElvanShell] exclusively designed for fullscreen popups (modals).
/// It inherently injects the [ElvanCloseButton] into the shell's physics engine
/// and disables the bottom navigation bar.
class ElvanFullscreenPopup extends StatelessWidget {
  const ElvanFullscreenPopup({
    super.key,
    required this.title,
    required this.slivers,
    this.navActions = const [],
    this.startCollapsed = true,
    this.backgroundColor,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget> navActions;
  final bool startCollapsed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElvanShell(
      title: title,
      slivers: slivers,
      showNavbar: false,
      leadingWidget: const ElvanCloseButton(),
      navActions: navActions,
      startCollapsed: startCollapsed,
      backgroundColor: backgroundColor,
      syncWithGlobalHeader: false,
    );
  }
}
