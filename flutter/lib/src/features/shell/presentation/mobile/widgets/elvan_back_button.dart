import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A circular back button designed to be passed into ElvanShell as a [leadingWidget].
/// The shell's physics engine automatically handles its background, drop shadow, and scroll fading.
class ElvanBackButton extends StatelessWidget {
  const ElvanBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: InkResponse(
        onTap: () {
          Navigator.of(context).pop();
        },
        radius: 25,
        highlightShape: BoxShape.circle,
        splashFactory: NoSplash.splashFactory, // Instantly fills the circle, no growing!
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), // Instant full circle flash
        child: const Center(
          child: Icon(
            CupertinoIcons.chevron_back,
            size: 24,
          ),
        ),
      ),
    );
  }
}