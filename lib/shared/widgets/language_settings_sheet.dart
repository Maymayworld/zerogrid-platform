import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/locale_provider.dart';

class LanguageSettingsSheet extends ConsumerWidget {
  const LanguageSettingsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusPalette.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: SpacePalette.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  Text(
                    l10n.languageSettings,
                    style: TextStylePalette.smallHeader,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ColorPalette.neutral200),
            _LanguageOption(
              title: l10n.systemDefault,
              isSelected: currentLocale == null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.pop(context);
              },
            ),
            Divider(height: 1, color: ColorPalette.neutral200, indent: 56),
            _LanguageOption(
              title: l10n.english,
              subtitle: 'English',
              isSelected: currentLocale?.languageCode == 'en',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            Divider(height: 1, color: ColorPalette.neutral200, indent: 56),
            _LanguageOption(
              title: l10n.japanese,
              subtitle: '日本語',
              isSelected: currentLocale?.languageCode == 'ja',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('ja'));
                Navigator.pop(context);
              },
            ),
            SizedBox(height: SpacePalette.lg),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorPalette.neutral800.withOpacity(0.1)
                    : ColorPalette.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language,
                size: 18,
                color: isSelected
                    ? ColorPalette.neutral800
                    : ColorPalette.neutral400,
              ),
            ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStylePalette.bigText.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null && subtitle != title)
                    Text(
                      subtitle!,
                      style: TextStylePalette.smSubText,
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 22,
                color: ColorPalette.neutral800,
              ),
          ],
        ),
      ),
    );
  }
}
