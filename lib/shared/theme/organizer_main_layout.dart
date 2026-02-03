// lib/shared/theme/organizer_main_layout.dart
import 'dart:ui';
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

    final screens = [
      HomeScreen(),
      CampaignScreen(),
      CreateScreen(),
      ChatListScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: Stack(
        children: [
          // メインコンテンツ
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex.value,
              children: screens,
            ),
          ),
          // Liquid Glass ボトムナビゲーション
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _LiquidGlassNavBar(
              currentIndex: currentIndex.value,
              onTap: (index) => currentIndex.value = index,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LiquidNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _LiquidNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Campaigns',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // 中央の＋ボタン
              _CenterAddButton(
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _LiquidNavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
                showBadge: true,
                badgeCount: 1,
              ),
              _LiquidNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Liquid Glass スタイルのナビゲーションアイテム
class _LiquidNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _LiquidNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? SpacePalette.inner : SpacePalette.sm,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.neutral100 : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusPalette.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
                  size: 24,
                ),
                // バッジ
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: ColorPalette.critical500,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount.toString(),
                          style: TextStyle(
                            color: ColorPalette.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // 選択時にラベルを表示
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: EdgeInsets.only(left: SpacePalette.sm),
                      child: Text(
                        label,
                        style: TextStylePalette.miniTitle.copyWith(
                          color: ColorPalette.neutral800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// 中央の＋ボタン
class _CenterAddButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterAddButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral100,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorPalette.neutral800.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: isSelected ? ColorPalette.white : ColorPalette.neutral600,
          size: 28,
        ),
      ),
    );
  }
}
