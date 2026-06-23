import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../niril_podhu/kaatchi/thiruthi/patru_thiruthi.dart';

/// Coolie Receipt Editor — thin wrapper around the shared PatruThiruthi.
class CoolieReceiptEditor extends ConsumerWidget {
  final PatrugalEntry? editingEntry;

  const CoolieReceiptEditor({super.key, this.editingEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PatruThiruthi(editingEntry: editingEntry);
  }
}
