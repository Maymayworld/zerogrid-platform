// lib/shared/theme/organizer_main_layout.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import '../../features/organizer/home/presentation/home_screen.dart';
import '../../features/organizer/home/presentation/providers/organizer_tab_index_provider.dart';
import '../../features/organizer/campaign/presentation/pages/campaign_screen.dart';
import '../../features/organizer/campaign/presentation/pages/create/create_screen.dart';
import '../../features/organizer/chat/presentation/chat_list_screen.dart';
import '../../features/organizer/profile/presentation/profile_screen.dart';
import '../../features/organizer/approval/presentation/pages/approval_request_screen.dart';
import '../../features/organizer/approval/presentation/providers/approval_provider.dart';

class OrganizerMainLayout extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(organizerTabIndexProvider);
    final hasPendingRequests = ref.watch(hasPendingRequestsProvider);

    // 中央ボタン（index 2）の画面を動的に切り替え
    final screens = [
      HomeScreen(),
      CampaignScreen(),
      hasPendingRequests ? ApprovalRequestScreen() : CreateScreen(),
      ChatListScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      extendBody: true,
      body: Stack(
        children: [
          // メインコンテンツ
          Positioned.fill(
            child: IndexedStack(index: currentIndex, children: screens),
          ),
          // Liquid Glass ボトムナビゲーション（浮かせて配置）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                child: Center(
                  child: _LiquidGlassNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) =>
                        ref.read(organizerTabIndexProvider.notifier).state =
                            index,
                    hasPendingRequests: hasPendingRequests,
                  ),
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
  final bool hasPendingRequests;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.hasPendingRequests,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 374,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusPalette.full),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  border: Border.all(
                    color: ColorPalette.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GlassNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _GlassNavItem(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: 'Campaigns',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // 中央の黒いボタン（リクエストの有無でアイコン切り替え）
                Transform.translate(
                  offset: Offset(0, -16),
                  child: _CenterBlackButton(
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                    hasPendingRequests: hasPendingRequests,
                  ),
                ),
                _GlassNavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                  showBadge: true,
                  badgeCount: 1,
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
        ],
      ),
    );
  }
}

// Liquid Glass スタイルのナビゲーションアイテム（縦並び、常に表示）
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
        width: 73.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 選択時の白いガラスオーバーレイ
            AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                width: 73.2,
                height: 56,
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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

// 中央の黒いボタン（リクエストの有無でアイコン切り替え）
class _CenterBlackButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasPendingRequests;

  const _CenterBlackButton({
    required this.isSelected,
    required this.onTap,
    required this.hasPendingRequests,
  });

  @override
  Widget build(BuildContext context) {
    // リクエストあり → スマホアイコン（Approval画面）
    // リクエストなし → プラスアイコン（案件作成画面）
    final IconData icon;
    if (isSelected) {
      icon = Icons.check_rounded;
    } else if (hasPendingRequests) {
      icon = Icons.smartphone_rounded;
    } else {
      icon = Icons.add_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(0, 1.15),
                radius: 1.2,
                colors: [
                  Color(0xFF525252),
                  Color(0xFF0A0A0A),
                ],
                stops: [0.0, 0.78],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.neutral800.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: ColorPalette.white, size: 24),
          ),
          // リクエストありの場合、バッジ表示
          if (hasPendingRequests && !isSelected)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: ColorPalette.critical500,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorPalette.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
