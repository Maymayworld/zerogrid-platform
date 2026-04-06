// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'platform_icon.dart';

class FilterBottomSheet extends HookWidget {
  final Set<String> selectedPlatforms;
  final double minPay;
  final double maxPay;
  final Function(Set<String>, double, double) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.selectedPlatforms,
    required this.minPay,
    required this.maxPay,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platforms = useState<Set<String>>(selectedPlatforms);
    final payRange = useState<RangeValues>(RangeValues(minPay, maxPay));

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.neutral100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      padding: EdgeInsets.all(SpacePalette.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.filter,
                  style: TextStylePalette.smallHeader
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    PhosphorIconsRegular.x,
                    size: 24,
                    color: ColorPalette.neutral800,
                  ),
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            // プラットフォーム選択
            Text(
              AppLocalizations.of(context)!.platform,
              style: TextStylePalette.miniTitle
            ),
            SizedBox(height: SpacePalette.base),
            Row(
              children: [
                _PlatformChip(
                  iconWidget: PlatformIcon.tiktok(size: 16),
                  label: AppLocalizations.of(context)!.tiktok,
                  isSelected: platforms.value.contains('tiktok'),
                  onTap: () {
                    final newSet = Set<String>.from(platforms.value);
                    if (newSet.contains('tiktok')) {
                      newSet.remove('tiktok');
                    } else {
                      newSet.add('tiktok');
                    }
                    platforms.value = newSet;
                  },
                ),
                SizedBox(width: SpacePalette.sm),
                _PlatformChip(
                  iconWidget: PlatformIcon.instagram(size: 16),
                  label: AppLocalizations.of(context)!.instagram,
                  isSelected: platforms.value.contains('instagram'),
                  onTap: () {
                    final newSet = Set<String>.from(platforms.value);
                    if (newSet.contains('instagram')) {
                      newSet.remove('instagram');
                    } else {
                      newSet.add('instagram');
                    }
                    platforms.value = newSet;
                  },
                ),
                SizedBox(width: SpacePalette.sm),
                _PlatformChip(
                  iconWidget: PlatformIcon.youtube(size: 16),
                  label: AppLocalizations.of(context)!.youtube,
                  isSelected: platforms.value.contains('youtube'),
                  onTap: () {
                    final newSet = Set<String>.from(platforms.value);
                    if (newSet.contains('youtube')) {
                      newSet.remove('youtube');
                    } else {
                      newSet.add('youtube');
                    }
                    platforms.value = newSet;
                  },
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            // Pay per View
            Text(
              AppLocalizations.of(context)!.payPerView,
              style: TextStylePalette.title
            ),
            SizedBox(height: SpacePalette.base),
            RangeSlider(
              values: payRange.value,
              min: 0,
              max: 500000,
              divisions: 100,
              activeColor: ColorPalette.neutral800,
              inactiveColor: ColorPalette.neutral400,
              onChanged: (RangeValues values) {
                payRange.value = values;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥${payRange.value.start.toInt()}',
                  style: TextStylePalette.subText
                ),
                Text(
                  '¥${payRange.value.end.toInt()}',
                  style: TextStylePalette.subText
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            // Applyボタン
            SizedBox(
              width: double.infinity,
              height: ButtonSizePalette.button,
              child: ElevatedButton(
                onPressed: () {
                  onApply(
                    platforms.value,
                    payRange.value.start,
                    payRange.value.end,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.neutral800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.submit,
                  style: TextStylePalette.buttonTextWhite
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// プラットフォーム選択チップ
class _PlatformChip extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformChip({
    required this.iconWidget,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.inner,
        ),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          border: Border.all(
            color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Column(
          children: [
            SizedBox(width: 24, height: 24, child: iconWidget),
            SizedBox(height: SpacePalette.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: FontSizePalette.size14,
                color: ColorPalette.neutral800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}