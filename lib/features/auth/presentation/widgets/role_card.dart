// lib/features/auth/presentation/widgets/role_card.dart
// 確認済み
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const RoleCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        color: ColorPalette.neutral0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          child: Padding(
            padding: EdgeInsets.all(SpacePalette.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: TextStylePalette.listTitle),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: FontSizePalette.size14,
                          color: ColorPalette.neutral800,
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.xs),
                    Text(description, style: TextStylePalette.listLeading),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}