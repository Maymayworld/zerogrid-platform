// lib/features/auth/presentation/pages/select_role_screen.dart
// 確認済み
import 'package:flutter/material.dart';
import '../widgets/role_card.dart';
import 'login_screen.dart';
import '../../data/models/user_role.dart';
import '../../../../shared/theme/app_theme.dart';

class SelectRoleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorPalette.neutral800,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(SpacePalette.base),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome! ',
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.neutral0,
                          ),
                        ),
                        Text(
                          '👋',
                        style: TextStyle(
                          fontSize: FontSizePalette.size24)),
                      ],
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Text(
                      'How would you like to get\nstarted?',
                      style: TextStylePalette.bigText.copyWith(
                        color: ColorPalette.neutral0,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                  ],
                ),
              ),
            ),

            // 下部コンテナ
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(RadiusPalette.lg),
                  topRight: Radius.circular(RadiusPalette.lg),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: SpacePalette.base,
                  right: SpacePalette.base,
                  top: SpacePalette.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select your role:',
                      style: TextStylePalette.title
                    ),
                    SizedBox(height: SpacePalette.base),
                    Row(
                      children: [
                        Expanded(
                          // カード1
                          child: RoleCard(
                            title: 'Organizer',
                            description: 'For brands, teams, and campaign owners',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    role: UserRole.organizer,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          // カード2
                          child: RoleCard(
                            title: 'Creator',
                            description: 'For content-makers and storytelling pros',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    role: UserRole.creator,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.lg),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: width * 0.3,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral800,
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.xs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}