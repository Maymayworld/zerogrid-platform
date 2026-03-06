// lib/features/auth/presentation/pages/signup_success_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/theme/main_layout.dart';
import '../../data/models/user_role.dart';

class SignUpSuccessScreen extends StatelessWidget {
  final UserRole role;
  final String? username;
  final Uint8List? avatarBytes;

  const SignUpSuccessScreen({
    Key? key,
    required this.role,
    this.username,
    this.avatarBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              Spacer(flex: 3),

              // プロフィール画像 + デコレーション
              Stack(
                alignment: Alignment.center,
                children: [
                  // スパークル装飾（左上）
                  Positioned(
                    top: -10,
                    left: -10,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 24,
                      color: ColorPalette.smashedPumpkin400,
                    ),
                  ),
                  // スパークル装飾（右上）
                  Positioned(
                    top: -5,
                    right: -15,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: ColorPalette.positive400,
                    ),
                  ),
                  // プロフィール画像
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorPalette.neutral100,
                      border: Border.all(color: ColorPalette.neutral200, width: 2),
                    ),
                    child: avatarBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              avatarBytes!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: ColorPalette.neutral400,
                          ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),

              // Welcome text
              Text(
                AppLocalizations.of(context)!.signUpSuccessWelcome,
                style: TextStylePalette.header,
              ),
              if (username != null)
                Text(
                  '@$username',
                  style: TextStylePalette.header,
                ),
              SizedBox(height: SpacePalette.sm),
              Text(
                AppLocalizations.of(context)!.allSetMessage,
                style: TextStylePalette.subText,
              ),

              Spacer(flex: 4),

              // Let's Go Button
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainLayout(userRole: role),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.smashedPumpkin600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.letsGo, style: TextStylePalette.buttonTextWhite),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
            ],
          ),
        ),
      ),
    );
  }
}
