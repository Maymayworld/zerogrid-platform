// lib/features/organizer/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../organizer/deposit/presentation/pages/select_amount_screen.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBalanceVisible = useState(true);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              SizedBox(height: SpacePalette.lg),
              
              // プロフィール写真
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: ColorPalette.neutral400,
                    child: Text(
                      'ZG',
                      style: TextStylePalette.header.copyWith(
                        color: ColorPalette.neutral0,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // 画像編集処理
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit profile image...')),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral0,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.neutral200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: ColorPalette.neutral800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Organizer Name
              Text(
                'Zero Grid Inc.',
                style: TextStylePalette.smallHeader
              ),
              SizedBox(height: SpacePalette.sm),
              
              // Organizer Badge
              Text(
                'Organizer',
                style: TextStylePalette.subText
              ),
              SizedBox(height: SpacePalette.lg),
              
              // My Wallet Card
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
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: ColorPalette.neutral0,
                        ),
                        SizedBox(width: SpacePalette.xs),
                        Text(
                          'My Wallet',
                          style: TextStylePalette.smText.copyWith(
                            color: ColorPalette.neutral0
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.base),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isBalanceVisible.value ? '¥400,500' : '¥******',
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.neutral0
                          )
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                isBalanceVisible.value = !isBalanceVisible.value;
                              },
                              child: Icon(
                                isBalanceVisible.value 
                                  ? Icons.visibility_outlined 
                                  : Icons.visibility_off_outlined,
                                size: 20,
                                color: ColorPalette.neutral0,
                              ),
                            ),
                            SizedBox(width: SpacePalette.base),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectAmountScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SpacePalette.inner,
                                  vertical: SpacePalette.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPalette.neutral0.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      color: ColorPalette.neutral0,
                                    ),
                                    SizedBox(width: SpacePalette.xs),
                                    Text(
                                      'Deposit',
                                      style: TextStylePalette.smText.copyWith(
                                        color: ColorPalette.neutral0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Payment Methods
              _ProfileMenuItem(
                icon: Icons.payment_outlined,
                label: 'Payment Methods',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment Methods coming soon...')),
                  );
                },
              ),
              
              // Notification Preferences
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notification Preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification Preferences coming soon...')),
                  );
                },
              ),
              
              // Give Feedback
              _ProfileMenuItem(
                icon: Icons.feedback_outlined,
                label: 'Give Feedback',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Give Feedback coming soon...')),
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
                        color: ColorPalette.systemRed,
                      ),
                      SizedBox(width: SpacePalette.base),
                      Text(
                        'Logout',
                        style: TextStylePalette.bigText.copyWith(
                          color: ColorPalette.systemRed,
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