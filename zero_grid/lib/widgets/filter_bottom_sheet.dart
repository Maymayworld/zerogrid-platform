// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

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
        color: ColorPalette().neutral0,
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
                  'Filter',
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.lg,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette().neutral900,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: ColorPalette().neutral800,
                  ),
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            // プラットフォーム選択
            Text(
              'Platform',
              style: GoogleFonts.inter(
                fontSize: FontSizePalette.md,
                fontWeight: FontWeight.w600,
                color: ColorPalette().neutral900,
              ),
            ),
            SizedBox(height: SpacePalette.base),
            Row(
              children: [
                _PlatformChip(
                  icon: Icons.music_note,
                  label: 'TikTok',
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
                  icon: Icons.camera_alt,
                  label: 'Instagram',
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
                  icon: Icons.play_arrow,
                  label: 'YouTube',
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
              'Pay per View',
              style: GoogleFonts.inter(
                fontSize: FontSizePalette.md,
                fontWeight: FontWeight.w600,
                color: ColorPalette().neutral900,
              ),
            ),
            SizedBox(height: SpacePalette.base),
            RangeSlider(
              values: payRange.value,
              min: 0,
              max: 500000,
              divisions: 100,
              activeColor: ColorPalette().neutral800,
              inactiveColor: ColorPalette().neutral300,
              onChanged: (RangeValues values) {
                payRange.value = values;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥${payRange.value.start.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.base,
                    color: ColorPalette().neutral600,
                  ),
                ),
                Text(
                  '¥${payRange.value.end.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.base,
                    color: ColorPalette().neutral600,
                  ),
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            // Applyボタン
            SizedBox(
              width: double.infinity,
              height: ButtonSizePalette.heightMd,
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
                  backgroundColor: ColorPalette().neutral900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.md,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette().neutral0,
                  ),
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
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformChip({
    required this.icon,
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
          vertical: SpacePalette.md,
        ),
        decoration: BoxDecoration(
          color: ColorPalette().neutral0,
          border: Border.all(
            color: isSelected ? ColorPalette().neutral900 : ColorPalette().neutral300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: ColorPalette().neutral900,
            ),
            SizedBox(height: SpacePalette.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: FontSizePalette.sm,
                color: ColorPalette().neutral900,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}