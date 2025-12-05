// lib/widgets/project/success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../screens/creator/creator_main_layout.dart';

class ProjectSuccessScreen extends StatelessWidget {
  const ProjectSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1FAE5), // ミントグリーン
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // チェックマークアイコン
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ColorPalette().systemGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: ColorPalette().neutral0,
                ),
              ),
              SizedBox(height: SpacePalette.xl),
              
              // タイトル
              Text(
                "You're in!",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette().neutral900,
                ),
              ),
              Text(
                'Time to start earning.',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette().neutral900,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              
              // 説明文
              Text(
                'Start now. The sooner you create, the faster your views start climbing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: FontSizePalette.base,
                  color: ColorPalette().neutral600,
                ),
              ),
              SizedBox(height: SpacePalette.xl),
              
              // Jump to Listボタン
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.heightMd,
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
                    backgroundColor: ColorPalette().neutral900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.sm),
                    ),
                  ),
                  child: Text(
                    'Jump to List',
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
      ),
    );
  }
}