import 'dart:ui';
import 'package:flutter/material.dart';

void showElvanLoadingOverlay({
  required BuildContext context,
  required String text,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) {
      final isDarkLoader = Theme.of(context).brightness == Brightness.dark;
      final bgLoader = isDarkLoader ? const Color(0xFF151515).withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.75);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: bgLoader,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      LinearProgressIndicator(
                        minHeight: 6,
                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                        backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
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
