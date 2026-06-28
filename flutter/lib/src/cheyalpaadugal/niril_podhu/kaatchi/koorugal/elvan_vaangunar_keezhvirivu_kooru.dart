import 'package:flutter/material.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_marabu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../adippadai/nilaimai/achu_mozhi_facade.dart';
import '../../../../adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import '../../../../adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import '../../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';
import '../../kalanjiyam/vaangunar_nilaimai.dart';
import '../../../../koorugal/maeladukkugal/elvan_kizh_maeladukku/elvan_kizh_maeladukku.dart';

class ElvanVaangunarKeezhvirivuKooru extends ConsumerWidget {
  final int? selectedVaangunarId;
  final ValueChanged<VaangunarTharavuru?> onChanged;
  final VoidCallback? onRequestAddNew;
  final bool hideLabel;
  final bool showClearButton;

  const ElvanVaangunarKeezhvirivuKooru({
    super.key,
    required this.selectedVaangunarId,
    required this.onChanged,
    this.onRequestAddNew,
    this.hideLabel = false,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final vaangunargalAsync = ref.watch(vaangunargalProvider);
    
    // Silk
    final isBilingual = ref.watch(bilingualProvider);
    final mudhanmaiMozhi = ref.watch(primaryLanguageProvider);
    final irandaamMozhi = ref.watch(secondaryLanguageProvider);
    
    // Kooli
    final kooliAchuMozhi = ref.watch(kooliAchuMozhiProvider);

    // Helpers to get Vaangunar fields
    String _getDisplayString(Map<String, dynamic>? dataMap, String targetLang, {String fallbackLang = 'English'}) {
      if (dataMap == null) return '';
      if (dataMap[targetLang] != null && dataMap[targetLang].toString().trim().isNotEmpty) {
        return dataMap[targetLang].toString();
      }
      if (dataMap[fallbackLang] != null && dataMap[fallbackLang].toString().trim().isNotEmpty) {
        return dataMap[fallbackLang].toString();
      }
      if (dataMap.values.isNotEmpty) {
        return dataMap.values.first?.toString() ?? '';
      }
      return '';
    }

    String getPrimaryName(VaangunarTharavuru v) {
      if (mode == AppMode.silk) {
        return _getDisplayString(v.peyar, mudhanmaiMozhi, fallbackLang: irandaamMozhi);
      } else {
        return _getDisplayString(v.peyar, kooliAchuMozhi);
      }
    }

    String getSecondaryName(VaangunarTharavuru v) {
      if (mode == AppMode.silk && isBilingual) {
        return _getDisplayString(v.peyar, irandaamMozhi, fallbackLang: mudhanmaiMozhi);
      }
      return '';
    }

    String getOor(VaangunarTharavuru v) {
      if (mode == AppMode.silk) {
        // User requested: "the oor names can stay onlt primary lang supported by irumozhi in the silk"
        return _getDisplayString(v.oor, mudhanmaiMozhi);
      } else {
        return _getDisplayString(v.oor, kooliAchuMozhi);
      }
    }

    String getSubtitle(VaangunarTharavuru v) {
      final secondary = getSecondaryName(v);
      final oor = getOor(v);
      
      if (secondary.isNotEmpty && secondary != getPrimaryName(v)) {
        if (oor.isNotEmpty) {
          return '$secondary - $oor';
        }
        return secondary;
      }
      return oor;
    }

    bool filterSearch(VaangunarTharavuru v, String query) {
      final lowerQuery = query.toLowerCase();
      // Search in peyar (Tamil and English)
      final peyarMatches = v.peyar.values.any((val) => val != null && val.toString().toLowerCase().contains(lowerQuery));
      // Search in oor
      final oorMatches = v.oor.values.any((val) => val != null && val.toString().toLowerCase().contains(lowerQuery));
      
      return peyarMatches || oorMatches;
    }

    final placeholder = K.vaangunaraiThaerodhu.tr(context, ref);
    
    return vaangunargalAsync.when(
      data: (vaangunargal) {
        final selectedVaangunar = vaangunargal.where((v) => v.id == selectedVaangunarId).firstOrNull;
        final currentValue = selectedVaangunar != null ? getPrimaryName(selectedVaangunar) : placeholder;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideLabel)
              ElvanThiruthiMarabu.buildLabel(context, placeholder),
            InkWell(
              onTap: () {
                showElvanSelectionBottomSheet<VaangunarTharavuru>(
                  context: context,
                  title: placeholder,
                  items: vaangunargal,
                  currentValue: selectedVaangunar,
                  onSelected: (val) => onChanged(val),
                  itemLabelBuilder: (ctx, ref, item) => getPrimaryName(item),
                  subtitleBuilder: (ctx, ref, item) => getSubtitle(item),
                  searchFilter: filterSearch,
                  showSearch: true,
                  onRequestAddNew: onRequestAddNew,
                );
              },
              borderRadius: BorderRadius.circular(ElvanThiruthiMarabu.borderRadius),
              child: InputDecorator(
                decoration: InputDecoration(
                  constraints: ElvanThiruthiMarabu.singleLineConstraints,
                  isDense: true,
                  filled: true,
                  fillColor: ElvanThiruthiMarabu.buildFillColor(context),
                  contentPadding: ElvanThiruthiMarabu.contentPadding,
                  border: ElvanThiruthiMarabu.border,
                  enabledBorder: ElvanThiruthiMarabu.border,
                  focusedBorder: ElvanThiruthiMarabu.border,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentValue,
                            style: TextStyle(
                              fontSize: ElvanThiruthiMarabu.fontSize,
                              fontWeight: selectedVaangunarId == null ? FontWeight.w400 : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(
                                    alpha: selectedVaangunarId == null ? 0.3 : 1.0,
                                  ),
                            ),
                          ),
                          if (selectedVaangunar != null && getSubtitle(selectedVaangunar).isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              getSubtitle(selectedVaangunar),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (showClearButton && selectedVaangunarId != null)
                          InkWell(
                            onTap: () => onChanged(null),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.close_rounded,
                                size: ElvanThiruthiMarabu.iconSize,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: ElvanThiruthiMarabu.iconSize,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (e, st) => Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(K.pizhai.tr(context, ref)),
      ),
    );
  }
}
