import 'package:flutter/material.dart';

/// A component that renders the page title inside the leadingWidget slot of the Collapsed Bar.
/// This gives the user context of the current page when they have scrolled down and the main
/// large header title has faded away.
class FloatElvanTitle extends StatelessWidget {
  const FloatElvanTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
