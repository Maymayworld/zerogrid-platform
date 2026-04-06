import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class ProfileMenuSection extends StatelessWidget {
  final String? header;
  final List<ProfileMenuItem> children;

  const ProfileMenuSection({
    Key? key,
    this.header,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: SpacePalette.xs,
              bottom: SpacePalette.sm,
            ),
            child: Text(
              header!,
              style: TextStylePalette.smSubText.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: ColorPalette.white,
            borderRadius: BorderRadius.circular(RadiusPalette.lg),
            boxShadow: [
              BoxShadow(
                color: ColorPalette.neutral800.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadiusPalette.lg),
            child: Column(
              children: List.generate(children.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Divider(
                    height: 1,
                    thickness: 1,
                    color: ColorPalette.neutral200,
                    indent: 56,
                  );
                }
                return children[index ~/ 2];
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  const ProfileMenuItem({
    Key? key,
    this.icon,
    this.iconAsset,
    this.iconBackgroundColor,
    this.iconColor,
    required this.label,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconBg = iconBackgroundColor ?? ColorPalette.neutral100;
    final effectiveIconColor = isDestructive
        ? ColorPalette.critical500
        : (iconColor ?? ColorPalette.neutral800);
    final effectiveLabelStyle = isDestructive
        ? TextStylePalette.bigText.copyWith(color: ColorPalette.critical500)
        : TextStylePalette.bigText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.inner,
        ),
        child: Row(
          children: [
            if (iconAsset != null)
              SizedBox(
                width: 36,
                height: 36,
                child: Image.asset(
                  iconAsset!,
                  width: 36,
                  height: 36,
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? ColorPalette.critical500.withOpacity(0.1)
                      : effectiveIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: effectiveIconColor,
                ),
              ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Text(label, style: effectiveLabelStyle),
            ),
            if (trailing != null) ...[
              trailing!,
              SizedBox(width: SpacePalette.xs),
            ],
            if (showChevron)
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 20,
                color: ColorPalette.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}
