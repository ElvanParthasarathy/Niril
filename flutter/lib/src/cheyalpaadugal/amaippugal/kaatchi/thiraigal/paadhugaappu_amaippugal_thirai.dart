import 'package:flutter/material.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/locale_provider.dart';
import '../../../chattagam/kaatchi/kaipaesi/elvan_utpakkach_chattagam.dart';
import '../koorugal/kanakku_paadhugaappu_pagudhi.dart';

class PathugappuAmaippugalPage extends ConsumerWidget {
  const PathugappuAmaippugalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElvanSubpageShell(
      title: K.paadhugaappu.tr(context, ref),
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
            children: [
              const AccountSecuritySection(),
            ],
          ),
        ),
      ],
    );
  }
}
