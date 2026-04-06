// lib/shared/widgets/common_search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class CommonSearchBar extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CommonSearchBar({
    Key? key,
    this.hintText,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hint = hintText ?? AppLocalizations.of(context)!.search;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontFamily: 'NotoSansJP', 
          fontSize: FontSizePalette.size14,
          color: ColorPalette.neutral800,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'NotoSansJP', 
            fontSize: FontSizePalette.size14,
            color: ColorPalette.neutral400,
          ),
          // 虫眼鏡アイコン
          prefixIcon: Icon(
            PhosphorIconsRegular.magnifyingGlass,
            color: ColorPalette.neutral400,
            size: 24,
          ),
          // ボーダー設定
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SpacePalette.base,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusPalette.base),
            borderSide: BorderSide(color: ColorPalette.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusPalette.base),
            borderSide: BorderSide(color: ColorPalette.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusPalette.base),
            borderSide: BorderSide(color: ColorPalette.neutral200),
          ),
        ),
      ),
    );
  }
}