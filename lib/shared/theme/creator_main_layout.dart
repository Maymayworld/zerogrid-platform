// lib/shared/theme/creator_main_layout.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'app_theme.dart';
import '../../features/creator/find/presentation/pages/find_screen.dart';
import '../../features/creator/feed/presentation/pages/feed_screen.dart';
import '../../features/creator/dashboard/dashboard_screen.dart';
import '../../features/creator/campaign/presentation/pages/campaign_screen.dart';
import '../../features/creator/profile/profile_screen.dart';

class CreatorMainLayout extends HookWidget {
  final int initialIndex;

  const CreatorMainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(initialIndex);

    final screens = [
      FindScreen(),
      FeedScreen(),
      DashboardScreen(),
      CampaignScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: Stack(
        children: [
          // メインコンテンツ
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex.value,
              children: screens,
            ),
          ),
          // Liquid Glass ボトムナビゲーション（浮かせて配置）
          Positioned(
            left: SpacePalette.base,
            right: SpacePalette.base,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                child: _LiquidGlassNavBar(
                  currentIndex: currentIndex.value,
                  onTap: (index) => currentIndex.value = index,
                ),
              ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusPalette.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: ColorPalette.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(RadiusPalette.full),
            border: Border.all(
              color: ColorPalette.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GlassNavItem(
                icon: Icons.search,
                selectedIcon: Icons.search,
                label: 'Find',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _GlassNavItem(
                icon: Icons.article_outlined,
                selectedIcon: Icons.article_rounded,
                label: 'Feed',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // 中央の黒いボタン
              _CenterBlackButton(
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _GlassNavItem(
                icon: Icons.campaign_outlined,
                selectedIcon: Icons.campaign_rounded,
                label: 'Campaigns',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _GlassNavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
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
class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
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
      child: SizedBox(
        width: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 選択時の白いガラスオーバーレイ
            AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                width: 52,
                height: 64,
                decoration: BoxDecoration(
                  color: ColorPalette.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.neutral800.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // アイコンとラベル（縦並び）
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        key: ValueKey(isSelected),
                        color: isSelected
                            ? ColorPalette.neutral800
                            : ColorPalette.neutral400,
                        size: 24,
                      ),
                    ),
                    // バッジ
                    if (showBadge && badgeCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: ColorPalette.critical500,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorPalette.white,
                              width: 2,
                            ),
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
                SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? ColorPalette.neutral800
                        : ColorPalette.neutral400,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 中央の黒いボタン（常に黒）
class _CenterBlackButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterBlackButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: ColorPalette.neutral800,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorPalette.neutral800.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isSelected ? Icons.dashboard_rounded : Icons.dashboard_outlined,
          color: ColorPalette.white,
          size: 24,
        ),
      ),
    );
  }
}
