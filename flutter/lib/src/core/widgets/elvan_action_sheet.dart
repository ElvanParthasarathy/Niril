import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

Future<T?> showElvanActionSheet<T>({
  required BuildContext context,
  required String title,
  required String cancelText,
  required String confirmText,
  required VoidCallback onConfirm,
  Color? confirmColor,
  Widget? customContent,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF151515).withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.75); // Transparent background
  final mainColor = confirmColor ?? Theme.of(context).colorScheme.onSurface;
  final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (customContent != null) ...[
                    const SizedBox(height: 16),
                    customContent,
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            cancelText,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          child: Text(
                            confirmText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
      ],
    );
  }

  if (isDesktop) {
    return showDialog<T>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 24),
                    child: buildContent(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    elevation: 0,
    builder: (BuildContext context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 24 + bottomInset),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
                  child: buildContent(context),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
