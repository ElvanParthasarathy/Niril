import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../chattagam/kaatchi/kaipaesi/elvan_utpakkach_chattagam.dart';

/// The Universal Editor Shell — wraps all creator/editor forms.
///
/// Mobile: existing navbar with text save button.
/// Desktop: Cancel + Save pill buttons at the bottom of the form.
/// Content is constrained to maxWidth 1200 matching React's ElvanEditorLayout.
class ElvanEditorShell extends ConsumerWidget {
  const ElvanEditorShell({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return ElvanSubpageShell(
      title: title,
      navActions: [
        if (onSave != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: Text(K.chaemiPtn.tr(context, ref),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.only(
                  left: isDesktop ? 32 : 16,
                  right: isDesktop ? 32 : 16,
                  top: 8,
                  bottom: isDesktop ? 16 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Main Form Content ──
                    child,

                    // ── Desktop: Cancel + Save pills ──
                    if (isDesktop && onSave != null) ...[
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cancel pill
                          SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              child: Text(K.kaividuPtn.tr(context, ref)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save pill
                          SizedBox(
                            height: 40,
                            child: FilledButton.icon(
                              onPressed: onSave,
                              icon: const Icon(Icons.save_outlined, size: 20),
                              label: Text(K.chaemiPtn.tr(context, ref)),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
