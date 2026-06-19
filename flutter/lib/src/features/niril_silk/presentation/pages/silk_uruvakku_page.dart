import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/locale_provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../shell/presentation/mobile/widgets/elvan_pill_shifter.dart';
import '../../../shell/presentation/mobile/elvan_navbar.dart';
import 'silk_invoices_page.dart';
import 'silk_receipts_page.dart';

class SilkUruvakkuPage extends ConsumerStatefulWidget {
  const SilkUruvakkuPage({super.key});

  @override
  ConsumerState<SilkUruvakkuPage> createState() => _SilkUruvakkuPageState();
}

class _SilkUruvakkuPageState extends ConsumerState<SilkUruvakkuPage> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(uruvakkuSegmentProvider);

    return SliverMainAxisGroup(
      slivers: [
        // The inline Pill Shifter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 32.0, bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElvanPillShifter(
                  items: [
                    CustomNavItem(
                      icon: CupertinoIcons.doc_text,
                      activeIcon: CupertinoIcons.doc_text_fill,
                      label: 'pill_invoices'.tr(context, ref),
                    ),
                    CustomNavItem(
                      svgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M72,104a8,8,0,0,1,8-8h96a8,8,0,0,1,0,16H80A8,8,0,0,1,72,104Zm8,40h96a8,8,0,0,0,0-16H80a8,8,0,0,0,0,16ZM232,56V208a8,8,0,0,1-11.58,7.15L192,200.94l-28.42,14.21a8,8,0,0,1-7.16,0L128,200.94,99.58,215.15a8,8,0,0,1-7.16,0L64,200.94,35.58,215.15A8,8,0,0,1,24,208V56A16,16,0,0,1,40,40H216A16,16,0,0,1,232,56Zm-16,0H40V195.06l20.42-10.22a8,8,0,0,1,7.16,0L96,199.06l28.42-14.22a8,8,0,0,1,7.16,0L160,199.06l28.42-14.22a8,8,0,0,1,7.16,0L216,195.06Z"></path></svg>',
                      activeSvgString: '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M216,40H40A16,16,0,0,0,24,56V208a8,8,0,0,0,11.58,7.15L64,200.94l28.42,14.21a8,8,0,0,0,7.16,0L128,200.94l28.42,14.21a8,8,0,0,0,7.16,0L192,200.94l28.42,14.21A8,8,0,0,0,232,208V56A16,16,0,0,0,216,40ZM176,144H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Zm0-32H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Z"></path></svg>',
                      label: 'pill_receipts'.tr(context, ref),
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onValueChanged: (int value) {
                    ref.read(uruvakkuSegmentProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
        ),
        // The actual content based on segment
        selectedIndex == 0 ? const SilkInvoicesPage() : const SilkReceiptsPage(),
      ],
    );
  }
}
