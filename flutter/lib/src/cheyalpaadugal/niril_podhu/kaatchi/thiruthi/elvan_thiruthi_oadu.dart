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
///
/// Set [hasUnsavedChanges] to `true` to guard against accidental back-nav.
/// When the user confirms discard, [onDiscard] is called before popping.
class ElvanEditorShell extends ConsumerStatefulWidget {
  const ElvanEditorShell({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.hasUnsavedChanges = false,
    this.onDiscard,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  /// Whether the form has unsaved edits. When `true`, back-nav shows a
  /// confirmation dialog instead of popping immediately.
  final bool hasUnsavedChanges;

  /// Called when the user confirms discarding unsaved changes.
  final VoidCallback? onDiscard;

  @override
  ConsumerState<ElvanEditorShell> createState() => _ElvanEditorShellState();
}

class _ElvanEditorShellState extends ConsumerState<ElvanEditorShell> {
  // ── Unsaved-changes confirmation dialog ──
  Future<void> _showDiscardDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('மாற்றங்கள் சேமிக்கப்படவில்லை'),
        content: const Text('சேமிக்காத மாற்றங்கள் உள்ளன. நிராகரிக்கவா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('தொடர்'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('நிராகரி'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDiscard?.call();
      Navigator.of(context).pop();
    }
  }

  /// Handles Cancel button / back-nav: if unsaved → dialog, else pop.
  void _handleCancel() {
    if (widget.hasUnsavedChanges) {
      _showDiscardDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return PopScope(
      canPop: !widget.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.hasUnsavedChanges) {
          _showDiscardDialog();
        }
      },
      child: ElvanSubpageShell(
        title: widget.title,
        navActions: [
          if (widget.onSave != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onSave,
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
                      widget.child,

                      // ── Desktop: Cancel + Save pills ──
                      if (isDesktop && widget.onSave != null) ...[
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cancel pill
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: _handleCancel,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
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
                                onPressed: widget.onSave,
                                icon:
                                    const Icon(Icons.save_outlined, size: 20),
                                label: Text(K.chaemiPtn.tr(context, ref)),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
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
      ),
    );
  }
}
