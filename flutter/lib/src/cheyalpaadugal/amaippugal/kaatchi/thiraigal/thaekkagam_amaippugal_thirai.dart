import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chattagam/kaatchi/kaippaesi/elvan_utpakkach_chattagam.dart';
import '../koorugal/thaekkagam_pagudhi.dart';

class ThaekkagamAmaippugalPage extends ConsumerWidget {
  const ThaekkagamAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElvanSubpageShell(
      title: 'Storage & Backup',
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF3F4F6),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: 32,
          ),
          sliver: SliverList.list(
            children: const [
              StorageManagerSection(),
            ],
          ),
        ),
      ],
    );
  }
}
