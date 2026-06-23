import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_mode.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/search_state.dart';
import '../../../localization/locale_provider.dart';
import '../../../navigation/navigation_destination.dart';
import '../../../navigation/navigation_provider.dart';

import '../../pages/mugappu_page.dart';
import '../../pages/uruvakku_page.dart';
import '../../pages/porul_page.dart';
import '../../pages/vanigar_page.dart';

import '../../niril_silk/presentation/pages/silk_invoices_page.dart';
import '../../niril_silk/presentation/pages/silk_receipts_page.dart';
import '../../niril_silk/presentation/editors/silk_invoice_editor.dart';
import '../../niril_silk/presentation/editors/silk_receipt_editor.dart';
import '../../niril_silk/presentation/editors/silk_merchant_editor.dart';
import '../../niril_silk/presentation/editors/silk_item_editor.dart';
import '../../niril_silk/presentation/pages/reports/silk_reports_page.dart';
import '../../niril_silk/presentation/pages/reports/silk_gst_returns_page.dart';

import '../../niril_coolie/presentation/pages/coolie_invoices_page.dart';
import '../../niril_coolie/presentation/pages/coolie_receipts_page.dart';
import '../../niril_coolie/presentation/editors/coolie_invoice_editor.dart';
import '../../niril_coolie/presentation/editors/coolie_receipt_editor.dart';
import '../../niril_coolie/presentation/editors/coolie_merchant_editor.dart';
import '../../niril_coolie/presentation/editors/coolie_item_editor.dart';

import '../../settings/presentation/settings_screen.dart';
import '../../settings/data/vaniga_tharavugal_provider.dart';

import '../presentation/mobile/elvan_shell.dart';
import '../presentation/mobile/elvan_navbar.dart';
import '../presentation/mobile/widgets/elvan_popup_menu.dart';
import '../presentation/mobile/widgets/elvan_top_bar_icon.dart';
import '../presentation/desktop/elvan_desktop_shell.dart';
import '../presentation/desktop/elvan_desktop_toolbar.dart';
import '../../../navigation/niril_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NIRIL APP SCREEN — The main app dashboard
// ─────────────────────────────────────────────────────────────────────────────
// Uses [NirilNavigationNotifier] as the single source of truth.
// Both mobile and desktop layouts read from the same state.

class NirilAppScreen extends ConsumerStatefulWidget {
  const NirilAppScreen({super.key});

  @override
  ConsumerState<NirilAppScreen> createState() => _NirilAppScreenState();
}

class _NirilAppScreenState extends ConsumerState<NirilAppScreen> {
  // ── Navigation helpers ─────────────────────────────────────────────

  void _onAddPressed() {
    final navState = ref.read(nirilNavigationProvider);
    final mode = ref.read(appModeProvider);
    final dest = navState.destination;
    Widget? editor;

    if (dest == NirilDestination.mugappu ||
        dest == NirilDestination.pattiyal) {
      editor = mode == AppMode.coolie
          ? const CoolieInvoiceEditor()
          : const SilkInvoiceEditor();
    } else if (dest == NirilDestination.raseethu) {
      editor = mode == AppMode.coolie
          ? const CoolieReceiptEditor()
          : const SilkReceiptEditor();
    } else if (dest == NirilDestination.vanigar) {
      editor = mode == AppMode.coolie
          ? const CoolieMerchantEditor()
          : const SilkMerchantEditor();
    } else if (dest == NirilDestination.porul) {
      editor = mode == AppMode.coolie
          ? const CoolieItemEditor()
          : const SilkItemEditor();
    }

    if (editor != null) {
      NirilNav.push(context, editor);
    }
  }

  // ── Mobile nav items (4 tabs) ──────────────────────────────────────

  List<CustomNavItem> get _mobileNavItems => [
        CustomNavItem(
          svgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M219.31,108.68l-80-80a16,16,0,0,0-22.62,0l-80,80A15.87,15.87,0,0,0,32,120v96a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V160h32v56a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V120A15.87,15.87,0,0,0,219.31,108.68ZM208,208H160V152a8,8,0,0,0-8-8H104a8,8,0,0,0-8,8v56H48V120l80-80,80,80Z"></path></svg>',
          activeSvgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M224,120v96a8,8,0,0,1-8,8H160a8,8,0,0,1-8-8V164a4,4,0,0,0-4-4H108a4,4,0,0,0-4,4v52a8,8,0,0,1-8,8H40a8,8,0,0,1-8-8V120a16,16,0,0,1,4.69-11.31l80-80a16,16,0,0,1,22.62,0l80,80A16,16,0,0,1,224,120Z"></path></svg>',
          label: 'home'.tr(context, ref),
          headerLabel: 'appName'.tr(context, ref),
        ),
        CustomNavItem(
          icon: CupertinoIcons.plus_app,
          activeIcon: CupertinoIcons.plus_app_fill,
          label: 'aakku'.tr(context, ref),
          headerLabel: 'uruvakku'.tr(context, ref),
        ),
        CustomNavItem(
          svgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M117.25,157.92a60,60,0,1,0-66.5,0A95.83,95.83,0,0,0,3.53,195.63a8,8,0,1,0,13.4,8.74,80,80,0,0,1,134.14,0,8,8,0,0,0,13.4-8.74A95.83,95.83,0,0,0,117.25,157.92ZM40,108a44,44,0,1,1,44,44A44.05,44.05,0,0,1,40,108Zm210.14,98.7a8,8,0,0,1-11.07-2.33A79.83,79.83,0,0,0,172,168a8,8,0,0,1,0-16,44,44,0,1,0-16.34-84.87,8,8,0,1,1-5.94-14.85,60,60,0,0,1,55.53,105.64,95.83,95.83,0,0,1,47.22,37.71A8,8,0,0,1,250.14,206.7Z"></path></svg>',
          activeSvgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M164.47,195.63a8,8,0,0,1-6.7,12.37H10.23a8,8,0,0,1-6.7-12.37,95.83,95.83,0,0,1,47.22-37.71,60,60,0,1,1,66.5,0A95.83,95.83,0,0,1,164.47,195.63Zm87.91-.15a95.87,95.87,0,0,0-47.13-37.56A60,60,0,0,0,144.7,54.59a4,4,0,0,0-1.33,6A75.83,75.83,0,0,1,147,150.53a4,4,0,0,0,1.07,5.53,112.32,112.32,0,0,1,29.85,30.83,23.92,23.92,0,0,1,3.65,16.47,4,4,0,0,0,3.95,4.64h60.3a8,8,0,0,0,7.73-5.93A8.22,8.22,0,0,0,252.38,195.48Z"></path></svg>',
          label: 'merchants'.tr(context, ref),
          headerLabel: 'header_merchants'.tr(context, ref),
        ),
        CustomNavItem(
          icon: CupertinoIcons.cube_box,
          activeIcon: CupertinoIcons.cube_box_fill,
          label: 'inventory'.tr(context, ref),
          headerLabel: 'header_inventory'.tr(context, ref),
        ),
      ];

  // ── Desktop nav items (5 items — Uruvakku splits) ──────────────────

  List<CustomNavItem> _desktopNavItems(BuildContext context) => [
        _mobileNavItems[0], // Home
        CustomNavItem(
          icon: CupertinoIcons.doc_text,
          activeIcon: CupertinoIcons.doc_text_fill,
          label: 'invoices'.tr(context, ref),
          headerLabel: 'pill_invoices'.tr(context, ref),
        ),
        CustomNavItem(
          svgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M72,104a8,8,0,0,1,8-8h96a8,8,0,0,1,0,16H80A8,8,0,0,1,72,104Zm8,40h96a8,8,0,0,0,0-16H80a8,8,0,0,0,0,16ZM232,56V208a8,8,0,0,1-11.58,7.15L192,200.94l-28.42,14.21a8,8,0,0,1-7.16,0L128,200.94,99.58,215.15a8,8,0,0,1-7.16,0L64,200.94,35.58,215.15A8,8,0,0,1,24,208V56A16,16,0,0,1,40,40H216A16,16,0,0,1,232,56Zm-16,0H40V195.06l20.42-10.22a8,8,0,0,1,7.16,0L96,199.06l28.42-14.22a8,8,0,0,1,7.16,0L160,199.06l28.42-14.22a8,8,0,0,1,7.16,0L216,195.06Z"></path></svg>',
          activeSvgString:
              '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M216,40H40A16,16,0,0,0,24,56V208a8,8,0,0,0,11.58,7.15L64,200.94l28.42,14.21a8,8,0,0,0,7.16,0L128,200.94l28.42,14.21a8,8,0,0,0,7.16,0L192,200.94l28.42,14.21A8,8,0,0,0,232,208V56A16,16,0,0,0,216,40ZM176,144H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Zm0-32H80a8,8,0,0,1,0-16h96a8,8,0,0,1,0,16Z"></path></svg>',
          label: 'receipt'.tr(context, ref),
          headerLabel: 'pill_receipts'.tr(context, ref),
        ),
        _mobileNavItems[2], // Merchants
        _mobileNavItems[3], // Products
      ];

  // ── Search routing ─────────────────────────────────────────────────

  void _routeSearchQuery(String query, NirilDestination dest) {
    final mode = ref.read(appModeProvider);
    switch (dest) {
      case NirilDestination.pattiyal:
        if (mode == AppMode.coolie)
          ref.read(coolieInvoicesSearchQueryProvider.notifier).state = query;
        else
          ref.read(silkInvoicesSearchQueryProvider.notifier).state = query;
        break;
      case NirilDestination.raseethu:
        if (mode == AppMode.coolie)
          ref.read(coolieReceiptsSearchQueryProvider.notifier).state = query;
        else
          ref.read(silkReceiptsSearchQueryProvider.notifier).state = query;
        break;
      case NirilDestination.vanigar:
        if (mode == AppMode.coolie)
          ref.read(coolieMerchantsSearchQueryProvider.notifier).state = query;
        else
          ref.read(silkMerchantsSearchQueryProvider.notifier).state = query;
        break;
      case NirilDestination.porul:
        if (mode == AppMode.coolie)
          ref.read(coolieItemsSearchQueryProvider.notifier).state = query;
        else
          ref.read(silkItemsSearchQueryProvider.notifier).state = query;
        break;
      default:
        break;
    }
  }

  // ── Mobile search routing via tab index ─────────────────────────────

  void _routeMobileSearch(String query, int tabIndex) {
    final navState = ref.read(nirilNavigationProvider);
    switch (tabIndex) {
      case 1: // Uruvakku tab — depends on segment
        if (navState.uruvakkuSegment == 1) {
          _routeSearchQuery(query, NirilDestination.raseethu);
        } else {
          _routeSearchQuery(query, NirilDestination.pattiyal);
        }
        break;
      case 2:
        _routeSearchQuery(query, NirilDestination.vanigar);
        break;
      case 3:
        _routeSearchQuery(query, NirilDestination.porul);
        break;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(nirilNavigationProvider);
    final nav = ref.read(nirilNavigationProvider.notifier);
    final mode = ref.watch(appModeProvider);

    return PopScope(
      canPop: navState.destination == NirilDestination.mugappu,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        nav.goBack();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On desktop OS, always use desktop layout.
          // LayoutBuilder breakpoint only matters for tablets.
          final isDesktopOS =
              Platform.isWindows || Platform.isMacOS || Platform.isLinux;
          final isDesktop = isDesktopOS || constraints.maxWidth >= 800;

          if (isDesktop) {
            return _buildDesktopLayout(context, navState, mode);
          } else {
            return _buildMobileLayout(context, navState, mode);
          }
        },
      ),
    );
  }

  // ── Desktop Layout ─────────────────────────────────────────────────

  Widget _buildDesktopLayout(
    BuildContext context,
    NirilNavigationState navState,
    AppMode? mode,
  ) {
    final nav = ref.read(nirilNavigationProvider.notifier);
    final dest = navState.destination;
    final desktopIndex = navState.desktopSidebarIndex;
    final desktopNavItems = _desktopNavItems(context);


    // Build desktop toolbar for non-home, non-custom-view pages
    Widget? desktopToolbar;
    if (!navState.isCustomView && desktopIndex != 0) {
      String btnText = 'add'.tr(context, ref);
      if (desktopIndex == 1) {
        btnText = mode == AppMode.coolie
            ? 'newBill'.tr(context, ref)
            : 'newInvoiceBtn'.tr(context, ref);
      } else if (desktopIndex == 2) {
        btnText = 'newReceiptBtn'.tr(context, ref);
      } else if (desktopIndex == 3) {
        btnText = 'addClient'.tr(context, ref);
      } else if (desktopIndex == 4) {
        btnText = 'addProductBtn'.tr(context, ref);
      }

      desktopToolbar = ElvanDesktopToolbar(
        searchPlaceholder: 'search'.tr(context, ref),
        addButtonText: btnText,
        onSearchChanged: (query) =>
            _routeSearchQuery(query, dest),
        onAdd: _onAddPressed,
      );
    }

    // Resolve custom content (state-driven for desktop only)
    Widget? customContent;
    String? title;
    if (dest == NirilDestination.settings) {
      customContent = const SettingsScreen();
      title = 'settings'.tr(context, ref);
    } else if (dest == NirilDestination.reports) {
      customContent = const SilkReportsPage();
      title = 'reports'.tr(context, ref);
    } else if (dest == NirilDestination.gstReturns) {
      customContent = const SilkGstReturnsPage();
      title = 'gstReturns'.tr(context, ref);
    } else {
      title = desktopIndex >= 0 && desktopIndex < desktopNavItems.length
          ? (desktopIndex == 0
              ? desktopNavItems[desktopIndex].label
              : (desktopNavItems[desktopIndex].headerLabel ??
                  desktopNavItems[desktopIndex].label))
          : '';
    }

    return ElvanDesktopShell(
      currentIndex: navState.isCustomView ? -1 : desktopIndex,
      onTabSelected: (index) {
        // Map desktop sidebar index to NirilDestination
        final destinations = [
          NirilDestination.mugappu,
          NirilDestination.pattiyal,
          NirilDestination.raseethu,
          NirilDestination.vanigar,
          NirilDestination.porul,
        ];
        if (index >= 0 && index < destinations.length) {
          nav.goTo(destinations[index]);
        }
      },
      onSettingsPressed: () => nav.goTo(NirilDestination.settings),
      onReportsPressed: () => nav.goTo(NirilDestination.reports),
      onGstReturnsPressed: () => nav.goTo(NirilDestination.gstReturns),
      isReportsSelected: dest == NirilDestination.reports,
      isGstReturnsSelected: dest == NirilDestination.gstReturns,
      customContent: customContent,
      title: title,
      toolbar: desktopToolbar,
      navItems: desktopNavItems,
      slivers: [
        SliverOffstage(
          offstage: desktopIndex != 0,
          sliver: const MugappuPage(),
        ),
        SliverOffstage(
          offstage: desktopIndex != 1,
          sliver: mode == AppMode.coolie
              ? const CoolieInvoicesPage()
              : const SilkInvoicesPage(),
        ),
        SliverOffstage(
          offstage: desktopIndex != 2,
          sliver: mode == AppMode.coolie
              ? const CoolieReceiptsPage()
              : const SilkReceiptsPage(),
        ),
        SliverOffstage(
          offstage: desktopIndex != 3,
          sliver: const VanigarPage(),
        ),
        SliverOffstage(
          offstage: desktopIndex != 4,
          sliver: const PorulPage(),
        ),
      ],
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context,
    NirilNavigationState navState,
    AppMode? mode,
  ) {
    final nav = ref.read(nirilNavigationProvider.notifier);

    final mobileTabIndex = navState.mobileTabIndex;
    final navItems = _mobileNavItems;

    return Scaffold(
      body: Stack(
        children: [
          // Tab-based shell
          IndexedStack(
            index: mobileTabIndex,
              children: [
                for (int i = 0; i < 4; i++)
                  ElvanShell(
                    assignedIndex: i,
                    title: navItems[i].headerLabel ?? navItems[i].label,
                    currentIndex: mobileTabIndex,
                    onTabSelected: (index) {
                      // Map mobile tab index to NirilDestination
                      final destinations = [
                        NirilDestination.mugappu,
                        navState.uruvakkuSegment == 1
                            ? NirilDestination.raseethu
                            : NirilDestination.pattiyal,
                        NirilDestination.vanigar,
                        NirilDestination.porul,
                      ];
                      if (index >= 0 && index < destinations.length) {
                        nav.goTo(destinations[index]);
                      }
                    },
                    showSearchIcon: i != 0,
                    onSearchChanged: (query) => _routeMobileSearch(query, i),
                    navActions: [
                      const SizedBox(width: 7),
                      ElvanTopBarIcon(
                        icon: CupertinoIcons.add,
                        onTap: _onAddPressed,
                      ),
                      const SizedBox(width: 14),
                      ElvanPopupMenu(
                        showSelectOption: i > 0,
                        isSilkHome:
                            ref.watch(appModeProvider) != AppMode.coolie &&
                                i == 0,
                      ),
                      const SizedBox(width: 7),
                    ],
                    navItems: navItems,
                    slivers: [
                      if (i == 0) const MugappuPage(),
                      if (i == 1) const UruvakkuPage(),
                      if (i == 2) const VanigarPage(),
                      if (i == 3) const PorulPage(),
                    ],
                  ),
              ],
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'dev_seed',
                    onPressed: () {
                      ref
                          .read(vanigaTharavugalListProvider.notifier)
                          .seedData();
                    },
                    label: Text('devSeedData'.tr(context, ref)),
                    icon: const Icon(CupertinoIcons.rocket),
                    backgroundColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.extended(
                    heroTag: 'dev_erase',
                    onPressed: () {
                      ref
                          .read(vanigaTharavugalListProvider.notifier)
                          .clearProfile();
                      ref
                          .read(appModeProvider.notifier)
                          .setMode(null);
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                    label: Text('devEraseData'.tr(context, ref)),
                    icon: const Icon(CupertinoIcons.trash),
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }
}



