// lib/screens/select_role/widgets/role_card.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const RoleCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: EdgeInsets.all(SpacePalette.sm),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(
            color: ColorPalette.neutral400,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon(
            //   icon,
            //   size: FontSizePalette.size24,
            //   color: ColorPalette.neutral800,
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStylePalette.listTitle
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      size: FontSizePalette.size12,
                      color: ColorPalette.neutral800,
                    ),
                  ],
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  description,
                  style: TextStylePalette.listLeading
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}