// lib/screens/creator/creator_main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../theme/app_theme.dart';
import 'find/find_screen.dart';
import 'likes/likes_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'campaign/campaign_screen.dart';
import 'profile/profile_screen.dart';

class CreatorMainLayout extends HookWidget {
  final int initialIndex;

  const CreatorMainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(initialIndex);
    final width = MediaQuery.of(context).size.width;

    final screens = [
      FindScreen(),
      LikesScreen(),
      DashboardScreen(),
      CampaignScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // メインコンテンツ
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex.value,
              children: screens,
            ),
          ),
          // フッター
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: currentIndex.value,
              onTap: (index) => currentIndex.value = index,
              width: width,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final double width;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.width,
  }) : super(key: key);

  // 各タブの位置を計算
  double _getIndicatorPosition() {
    switch (currentIndex) {
      case 0: // Find
        return width * 0.1 - 20; // インジケーター幅40の半分を引く
      case 1: // Likes
        return width * 0.3 - 20;
      case 2: // Dashboard
        return width * 0.5 - 20;
      case 3: // Campaigns
        return width * 0.7 - 20;
      case 4: // Profile
        return width * 0.9 - 20;
      default:
        return width * 0.1 - 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // フッター背景
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: ColorPalette.neutral800.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(height: 60),
          ),
        ),
        // Divider（フッター上部の線）
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 1,
            color: ColorPalette.neutral200,
          ),
        ),
        // 選択インジケーター（移動する線）
        AnimatedPositioned(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: _getIndicatorPosition(),
          top: 0,
          child: Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: ColorPalette.neutral800,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ),
        // ナビゲーションアイテム（Stackで配置）
        SafeArea(
          child: SizedBox(
            height: 60,
            child: Stack(
              children: [
                // Find - 左から10%の位置
                Positioned(
                  left: width * 0.1 - 30, // アイテム幅60の半分を引く
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.search,
                    label: 'Find',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                // Likes - 左から30%の位置
                Positioned(
                  left: width * 0.3 - 30,
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.favorite_border,
                    label: 'Likes',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                // Campaigns - 左から70%の位置
                Positioned(
                  left: width * 0.7 - 30,
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.campaign_outlined,
                    label: 'Campaigns',
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                // Profile - 左から90%の位置
                Positioned(
                  left: width * 0.9 - 30,
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dashboard - フッターに重ねる形で配置
        Positioned(
          left: width * 0.5 - 32, // ボタン幅64の半分を引く
          bottom: 40, // フッターから少し上
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: currentIndex == 2 ? ColorPalette.neutral800 : ColorPalette.neutral0,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.neutral800.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.dashboard_outlined,
                color: currentIndex == 2 ? ColorPalette.neutral0 : ColorPalette.neutral400,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60, // 固定幅
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey[400],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.black : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}