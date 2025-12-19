// lib/screens/select_role/select_role_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widgets/role_card.dart';
import 'login_screen.dart';
import '../data/models/user_role.dart';
import '../../../shared/theme/app_theme.dart';

class SelectRoleScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          style: TextStylePalette.header,
                        ),
                        Text('👋', style: TextStyle(fontSize: FontSizePalette.size24)),
                      ],
                    ),
                    Text(
                      'How would you like to get\nstarted?',
                      style: TextStyle(
                        fontSize: FontSizePalette.size16,
                        color: ColorPalette.neutral100,
                      ),
                    ),
                    SizedBox(height: SpacePalette.inner),
                  ],
                ),
              ),
            ),
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
                      style: TextStyle(
                        fontSize: FontSizePalette.size16,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.neutral800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: RoleCard(
                            icon: Icons.campaign_outlined,
                            title: 'Organizer',
                            description: 'For brands, teams, and\ncampaign owners',
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
                        SizedBox(width: SpacePalette.base),
                        Expanded(
                          child: RoleCard(
                            icon: Icons.videocam_outlined,
                            title: 'Creator',
                            description: 'For content-makers and\nstorytelling pros',
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