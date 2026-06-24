import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../niril_podhu/kaatchi/thiruthi/patru_thiruthi.dart';

/// Silk Receipt Editor — thin wrapper around the shared PatruThiruthi.
class SilkReceiptEditor extends ConsumerWidget {
  final PatrugalEntry? editingEntry;

  const SilkReceiptEditor({super.key, this.editingEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PatruThiruthi(editingEntry: editingEntry);
  }
}
