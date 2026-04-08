// lib/features/creator/project/presentation/pages/success_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/theme/creator_main_layout.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class ProjectSuccessScreen extends StatelessWidget {
  final String? campaignName;
  
  const ProjectSuccessScreen({
    Key? key,
    this.campaignName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1FAE5), // ミントグリーン
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // チェックマークアイコン
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ColorPalette.positive500,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsBold.check,
                  size: 60,
                  color: ColorPalette.neutral100,
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // タイトル
              Text(
                AppLocalizations.of(context)!.joinSuccess,
                style: TextStylePalette.header
              ),
              SizedBox(height: SpacePalette.base),
              
              Text(
                AppLocalizations.of(context)!.joinSuccessMessage,
                textAlign: TextAlign.center,
                style: TextStylePalette.subText
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Jump to Listボタン
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: () {
                    // キャンペーンリストに戻る（ボトムバー付き）
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatorMainLayout(
                          initialIndex: 3, // Campaignタブを表示
                        ),
                      ),
                      (route) => false, // すべての履歴をクリア
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.jumpToList,
                    style: TextStylePalette.buttonTextWhite
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}