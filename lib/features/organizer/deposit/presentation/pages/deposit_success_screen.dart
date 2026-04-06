// lib/screens/organizer/deposit/presentation/pages/deposit_success_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../../shared/theme/app_theme.dart';
import '../../../../../../shared/theme/main_layout.dart';
import '../../../../../../features/auth/data/models/user_role.dart';

class DepositSuccessScreen extends StatelessWidget {
  final int amount;
  
  const DepositSuccessScreen({
    Key? key,
    required this.amount,
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
                  PhosphorIconsRegular.check,
                  size: 60,
                  color: ColorPalette.white,
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // タイトル
              Text(
                AppLocalizations.of(context)!.depositSuccessful,
                style: TextStylePalette.header
              ),
              SizedBox(height: SpacePalette.sm),
              Text(
                AppLocalizations.of(context)!.addedToBalance(
                  '¥${amount.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
                ),
                style: TextStylePalette.title
              ),
              SizedBox(height: SpacePalette.base),
              
              // 説明文
              Text(
                AppLocalizations.of(context)!.depositProcessed,
                textAlign: TextAlign.center,
                style: TextStylePalette.subText
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Back to Homeボタン
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: () {
                    // ホームに戻る（ボトムバー付き）
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainLayout(
                          userRole: UserRole.organizer,
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
                    AppLocalizations.of(context)!.navHome,
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