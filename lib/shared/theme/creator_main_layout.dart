// lib/shared/theme/creator_main_layout.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app_theme.dart';
import '../../features/creator/find/presentation/pages/find_screen.dart';
import '../../features/creator/feed/presentation/pages/feed_screen.dart';
import '../../features/creator/dashboard/dashboard_screen.dart';
import '../../features/creator/campaign/presentation/pages/campaign_screen.dart';
import '../../features/creator/campaign/presentation/pages/upload_screen.dart';
import '../../features/creator/campaign/presentation/providers/participation_service_provider.dart';
import '../../features/creator/profile/profile_screen.dart';
import '../../features/organizer/campaign/data/models/campaign.dart';

class CreatorMainLayout extends HookConsumerWidget {
  final int initialIndex;

  const CreatorMainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // FAB（プラスボタン）
          Positioned(
            right: SpacePalette.base + 4,
            bottom: 100,
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap: () => _showCampaignSelector(context, ref),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ColorPalette.smashedPumpkin600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.smashedPumpkin600.withOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: ColorPalette.white,
                    size: 28,
                  ),
                ),
              ),
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

  void _showCampaignSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CampaignSelectorSheet(ref: ref),
    );
  }
}

class _CampaignSelectorSheet extends HookWidget {
  final WidgetRef ref;

  const _CampaignSelectorSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);

    useEffect(() {
      Future<void> load() async {
        try {
          final service = ref.read(participationServiceProvider);
          final result = await service.getParticipatingCampaigns();
          campaigns.value = result;
        } catch (e) {
          debugPrint('Failed to load campaigns: $e');
        } finally {
          isLoading.value = false;
        }
      }
      load();
      return null;
    }, []);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadiusPalette.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Padding(
            padding: EdgeInsets.only(top: SpacePalette.sm),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorPalette.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // タイトル
          Padding(
            padding: EdgeInsets.all(SpacePalette.base),
            child: Row(
              children: [
                Icon(Icons.upload, color: ColorPalette.neutral800, size: 24),
                SizedBox(width: SpacePalette.sm),
                Text('Submit Video', style: TextStylePalette.header),
              ],
            ),
          ),
          Divider(height: 1, color: ColorPalette.neutral200),
          // コンテンツ
          Flexible(
            child: isLoading.value
                ? Padding(
                    padding: EdgeInsets.all(SpacePalette.lg),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorPalette.neutral800,
                      ),
                    ),
                  )
                : campaigns.value.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(SpacePalette.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.campaign_outlined,
                              size: 48,
                              color: ColorPalette.neutral400,
                            ),
                            SizedBox(height: SpacePalette.base),
                            Text(
                              'No campaigns yet',
                              style: TextStylePalette.subText,
                            ),
                            SizedBox(height: SpacePalette.xs),
                            Text(
                              'Join campaigns from the Find tab!',
                              style: TextStylePalette.smSubText,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(
                          vertical: SpacePalette.sm,
                        ),
                        itemCount: campaigns.value.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: SpacePalette.base + 48 + SpacePalette.sm,
                          color: ColorPalette.neutral200,
                        ),
                        itemBuilder: (context, index) {
                          final campaign = campaigns.value[index];
                          return _CampaignTile(
                            campaign: campaign,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectUploadScreen(
                                    campaignId: campaign.id,
                                    campaignName: campaign.name,
                                    organizerId: campaign.organizerId,
                                    platforms: campaign.platforms,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const _CampaignTile({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        child: Row(
          children: [
            // サムネイル
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              child: Container(
                width: 48,
                height: 48,
                color: ColorPalette.neutral200,
                child: campaign.thumbnailUrl != null &&
                        campaign.thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        campaign.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.campaign,
                          color: ColorPalette.neutral400,
                        ),
                      )
                    : Icon(
                        Icons.campaign,
                        color: ColorPalette.neutral400,
                      ),
              ),
            ),
            SizedBox(width: SpacePalette.sm),
            // キャンペーン情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.name,
                    style: TextStylePalette.listTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    campaign.platforms.join(' · '),
                    style: TextStylePalette.smSubText,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ColorPalette.neutral400,
            ),
          ],
        ),
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
                icon: Icons.work_outline,
                selectedIcon: Icons.work_rounded,
                label: 'Campaign',
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
