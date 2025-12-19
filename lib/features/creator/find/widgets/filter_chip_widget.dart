import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 36, // 高さを固定
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 10,
          vertical: 0, // 縦方向のpaddingは0に（高さで調整）
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral0,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? ColorPalette.neutral0 : ColorPalette.neutral800,
            ),
            if (isSelected) ...[
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorPalette.neutral100,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}