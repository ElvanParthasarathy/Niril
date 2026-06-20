import 'package:flutter/material.dart';
import 'package:elvan_niril/src/features/shell/presentation/mobile/elvan_shell.dart';
import 'widgets/elvan_back_button.dart';

/// A wrapper around [ElvanShell] exclusively designed for subpages (e.g. Settings, PDF Viewer).
/// It inherently injects the [ElvanBackButton] into the shell's physics engine
/// and disables the bottom navigation bar.
class ElvanSubpageShell extends StatelessWidget {
  const ElvanSubpageShell({
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
      leadingWidget: const ElvanBackButton(),
      navActions: navActions,
      startCollapsed: true,
      backgroundColor: backgroundColor,
      syncWithGlobalHeader: false,
    );
  }
}