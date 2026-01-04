// lib/features/auth/presentation/pages/signup_success_screen.dart
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/theme/main_layout.dart';
import '../../data/models/user_role.dart';

class SignUpSuccessScreen extends StatelessWidget {
  final UserRole role;

  const SignUpSuccessScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorPalette.systemGreen.withOpacity(0.3),
              ColorPalette.neutral0,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacePalette.base),
            child: Column(
              children: [
                Spacer(flex: 2),

                // チェックアイコン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ColorPalette.systemGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: SpacePalette.lg),

                // タイトル
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You\'re all set ', style: TextStylePalette.header),
                    Text('🎉', style: TextStyle(fontSize: 24)),
                  ],
                ),
                SizedBox(height: SpacePalette.sm),
                Text(
                  'Welcome to ZeroGrid. Let\'s get started.',
                  style: TextStylePalette.subText,
                ),

                Spacer(flex: 3),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                      backgroundColor: ColorPalette.neutral800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                      ),
                    ),
                    child: Text('Continue', style: TextStylePalette.buttonTextWhite),
                  ),
                ),
                SizedBox(height: SpacePalette.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}