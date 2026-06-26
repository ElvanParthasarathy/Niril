import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../chattagam/kaatchi/kaippaesi/elvan_utpakkach_chattagam.dart';

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
  Future<void> _showUnsavedChangesDialog() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(K.chaemippuNiluvai.tr(context, ref)),
        content: Text(K.chaemippuNiluvai.tr(context, ref)),
        actions: [
          // Cancel — stay on editor
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('cancel'),
            child: Text(K.thodarPtn.tr(context, ref)),
          ),
          // Discard — lose changes
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('discard'),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: Text(K.purakkaniPtn.tr(context, ref)),
          ),
          // Save — real save
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('save'),
            child: Text(K.chaemiPtn.tr(context, ref)),
          ),
        ],
      ),
    );

    if (!mounted || result == null || result == 'cancel') return;

    if (result == 'save') {
      widget.onSave?.call();
    } else if (result == 'discard') {
      widget.onDiscard?.call();
      Navigator.of(context).pop();
    }
  }

  /// Handles Cancel button / back-nav: if unsaved → dialog, else pop.
  void _handleCancel() {
    if (widget.hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    final shell = PopScope(
      canPop: !widget.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: ElvanSubpageShell(
        title: widget.title,
        maxWidth: double.infinity,
        hideHeaderOnDesktop: true,
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
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: isDesktop ? 32 : 8,
                    bottom: isDesktop ? 16 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // ── Desktop React-Style Header ──
                  if (isDesktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: _handleCancel,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.onSave != null) ...[
                          const Spacer(),
                          SizedBox(
                            height: 40,
                            child: FilledButton(
                              onPressed: widget.onSave,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                              child: Text(K.chaemiPtn.tr(context, ref)),
                            ),
                          ),
                        ],
                      ],
                    ),
                        const SizedBox(height: 32),
                      ],

                      // ── Main Form Content ──
                      widget.child,
                      
                      if (isDesktop) const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return shell;
  }
}
