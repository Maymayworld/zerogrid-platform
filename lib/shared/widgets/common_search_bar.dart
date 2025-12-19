// lib/shared/widgets/common_search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CommonSearchBar extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CommonSearchBar({
    Key? key,
    this.hintText = 'Search',
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorPalette = ColorPalette();
    
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: FontSizePalette.size14,
          color: ColorPalette.neutral800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: FontSizePalette.size14,
            color: ColorPalette.neutral400,
          ),
          // 虫眼鏡アイコン
          prefixIcon: Icon(
            Icons.search,
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