// lib/features/creator/project/presentation/pages/success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/theme/creator_main_layout.dart';

class ProjectSuccessScreen extends StatelessWidget {
  const ProjectSuccessScreen({Key? key}) : super(key: key);

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
                  color: ColorPalette.systemGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: ColorPalette.neutral100,
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // タイトル
              Text(
                "You're in!",
                style: TextStylePalette.header
              ),
              Text(
                'Time to start earning.',
                style: TextStylePalette.header
              ),
              SizedBox(height: SpacePalette.base),
              
              // 説明文
              Text(
                'Start now. The sooner you create, the faster your views start climbing.',
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
                    'Jump to List',
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