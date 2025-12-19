// lib/features/creator/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import 'widgets/edit_profile_screen.dart';
import 'widgets/give_feedback_sheet.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              SizedBox(height: SpacePalette.lg),
              
              // プロフィール写真（1つのみ）
              CircleAvatar(
                radius: 50,
                backgroundColor: ColorPalette.neutral400,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Creator Name
              Text(
                'Creator Name',
                style: TextStylePalette.smallHeader
              ),
              SizedBox(height: SpacePalette.sm),
              
              // Creator Badge
              Text(
                'Creator',
                style: TextStylePalette.subText
              ),
              SizedBox(height: SpacePalette.base),
              
              // Bio
              Text(
                'man of culture',
                style: TextStylePalette.normalText
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Bank Account Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(SpacePalette.base),
                decoration: BoxDecoration(
                  color: ColorPalette.neutral800,
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 16,
                          color: ColorPalette.neutral100,
                        ),
                        SizedBox(width: SpacePalette.xs),
                        Text(
                          'Bank Account',
                          style: TextStylePalette.smText.copyWith(
                            color: ColorPalette.neutral100
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.base),
                    Text(
                      'Account Name',
                      style: TextStylePalette.smallHeader.copyWith(
                        color: ColorPalette.neutral100
                      )
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '**** 1084',
                          style: TextStylePalette.normalText.copyWith(
                            color: ColorPalette.neutral100
                          )
                        ),
                        Text(
                          'VISA',
                          style: TextStylePalette.header
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Edit Profile Button
              _ProfileMenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
              ),
              
              // Give Feedback Button
              _ProfileMenuItem(
                icon: Icons.feedback_outlined,
                label: 'Give Feedback',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => GiveFeedbackSheet(),
                  );
                },
              ),
              
              SizedBox(height: SpacePalette.base),
              
              // Logout Button
              GestureDetector(
                onTap: () {
                  // ログアウト処理（後で実装）
                  print('Logout tapped');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: SpacePalette.base),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.red,
                      ),
                      SizedBox(width: SpacePalette.base),
                      Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.size16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 80), // フッター分の余白
            ],
          ),
        ),
      ),
    );
  }
}

// プロフィールメニューアイテム
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SpacePalette.base),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorPalette.neutral200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: ColorPalette.neutral800,
            ),
            SizedBox(width: SpacePalette.base),
            Expanded(
              child: Text(
                label,
                style: TextStylePalette.bigText
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: ColorPalette.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}