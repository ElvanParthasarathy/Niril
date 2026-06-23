import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';

class SilkHomePage extends ConsumerWidget {
  const SilkHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      sliver: ElvanResponsiveGrid(
        itemCount: 50,
        desktopCrossAxisCount: 2,
        childAspectRatio: 2.5,
        itemBuilder: (context, index) {
          return Container(
            height: 100, // Used by mobile list
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('${K.pattuMugappupPakkam.tr(context, ref)} - Item $index',
                  style: TextStyle(
                      color: Colors.blue.withOpacity(0.8), fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
