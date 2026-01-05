// lib/shared/theme/organizer_main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../shared/theme/app_theme.dart';
import '../../features/organizer/home/presentation/home_screen.dart';
import '../../features/organizer/campaign/presentation/pages/campaign_screen.dart';
import '../../features/organizer/campaign/presentation/pages/create/create_screen.dart';
import '../../features/organizer/chat/presentation/chat_list_screen.dart';
import '../../features/organizer/profile/presentation/profile_screen.dart';

class OrganizerMainLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final width = MediaQuery.of(context).size.width;

    final screens = [
      HomeScreen(),
      CampaignScreen(),
      CreateScreen(),
      ChatListScreen(),
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
            child: _OrganizerBottomNavBar(
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

class _OrganizerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final double width;

  const _OrganizerBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.width,
  }) : super(key: key);

  // 各タブの位置を計算
  double _getIndicatorPosition() {
    switch (currentIndex) {
      case 0: // Home
        return width * 0.1 - 20; // インジケーター幅40の半分を引く
      case 1: // Campaign
        return width * 0.3 - 20;
      case 2: // Create
        return width * 0.5 - 20;
      case 3: // Chat
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
                // Home - 左から10%の位置
                Positioned(
                  left: width * 0.1 - 30, // アイテム幅60の半分を引く
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                // Campaign - 左から30%の位置
                Positioned(
                  left: width * 0.3 - 30,
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.campaign_outlined,
                    label: 'Campaign',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                // Chat - 左から70%の位置
                Positioned(
                  left: width * 0.7 - 30,
                  top: 0,
                  bottom: 0,
                  child: _NavItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
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
        // Create - フッターに重ねる形で配置（真ん中の浮いたボタン）
        Positioned(
          left: width * 0.5 - 32, // ボタン幅64の半分を引く
          bottom: 40, // フッターから少し上
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: currentIndex == 2 ? ColorPalette.neutral800 : ColorPalette.neutral100,
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
                Icons.add,
                color: currentIndex == 2 ? ColorPalette.neutral100 : ColorPalette.neutral400,
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