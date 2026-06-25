import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../niril_podhu/kaatchi/thiruthi/patru_thiruthi.dart';

/// Coolie Receipt Editor — thin wrapper around the shared PatruThiruthi.
class CoolieReceiptEditor extends ConsumerWidget {
  final PatrugalTharavuru? editingEntry;

  const CoolieReceiptEditor({super.key, this.editingEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PatruThiruthi(editingEntry: editingEntry);
  }
}
