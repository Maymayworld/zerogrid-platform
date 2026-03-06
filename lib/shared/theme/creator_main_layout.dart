// lib/shared/theme/creator_main_layout.dart
import 'dart:ui';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app_theme.dart';
import '../widgets/common_search_bar.dart';
import '../widgets/platform_icon.dart';
import '../../features/creator/find/presentation/pages/find_screen.dart';
import '../../features/creator/feed/presentation/pages/feed_screen.dart';
import '../../features/creator/dashboard/dashboard_screen.dart';
import '../../features/creator/campaign/presentation/pages/campaign_screen.dart';
import '../../features/creator/campaign/presentation/pages/upload_screen.dart';
import '../../features/creator/campaign/presentation/providers/participation_service_provider.dart';
import '../../features/creator/profile/profile_screen.dart';
import '../../features/creator/feed/presentation/providers/creator_tab_index_provider.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import '../../features/organizer/campaign/data/models/campaign.dart';

class CreatorMainLayout extends HookConsumerWidget {
  final int initialIndex;

  const CreatorMainLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(creatorTabIndexProvider);

    final screens = [
      FindScreen(),
      FeedScreen(),
      DashboardScreen(),
      CampaignScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.white,
      extendBody: true,
      body: Stack(
        children: [
          // メインコンテンツ
          Positioned.fill(
            child: IndexedStack(index: currentIndex, children: screens),
          ),
          // ステータスバー背景（iOS対応）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: ColorPalette.black,
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
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(0, 1.15),
                      radius: 1.2,
                      colors: [Color(0xFF525252), Color(0xFF0A0A0A)],
                      stops: [0.0, 0.78],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.neutral800.withOpacity(0.35),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: ColorPalette.white, size: 28),
                ),
              ),
            ),
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
                    onTap: (index) => ref.read(creatorTabIndexProvider.notifier).state = index,
                  ),
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
    final searchQuery = useState('');
    final searchController = useTextEditingController();

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

    final filteredCampaigns = campaigns.value.where((campaign) {
      if (searchQuery.value.trim().isEmpty) return true;
      final q = searchQuery.value.toLowerCase();
      return campaign.name.toLowerCase().contains(q) ||
          campaign.description.toLowerCase().contains(q) ||
          campaign.platforms.join(' ').toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.94,
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
              padding: EdgeInsets.fromLTRB(
                SpacePalette.base,
                SpacePalette.base,
                SpacePalette.base,
                SpacePalette.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.selectCampaign,
                  style: TextStylePalette.smallHeader,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacePalette.base,
                0,
                SpacePalette.base,
                SpacePalette.base,
              ),
              child: CommonSearchBar(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value,
                hintText: AppLocalizations.of(context)!.search,
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
                  : filteredCampaigns.isEmpty
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
                            searchQuery.value.trim().isEmpty
                                ? AppLocalizations.of(context)!.noCampaignsYet
                                : AppLocalizations.of(context)!.noMatchingCampaigns,
                            style: TextStylePalette.subText,
                          ),
                          SizedBox(height: SpacePalette.xs),
                          Text(
                            searchQuery.value.trim().isEmpty
                                ? AppLocalizations.of(context)!.joinCampaignsFromFind
                                : AppLocalizations.of(context)!.tryDifferentKeyword,
                            style: TextStylePalette.smSubText,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(SpacePalette.base),
                      itemCount: filteredCampaigns.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: SpacePalette.sm),
                      itemBuilder: (context, index) {
                        final campaign = filteredCampaigns[index];
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
    final targetViews = campaign.targetViews;
    final currentViews = campaign.totalViews;
    final percentage =
        (targetViews == 0 ? 0 : (currentViews / targetViews * 100))
            .round()
            .clamp(0, 100);
    final displayedPlatforms = campaign.platforms.take(2).toList();
    final extraPlatformCount =
        campaign.platforms.length - displayedPlatforms.length;
    final imageUrl =
        (campaign.thumbnailUrl != null && campaign.thumbnailUrl!.isNotEmpty)
        ? campaign.thumbnailUrl!
        : 'https://picsum.photos/seed/${campaign.id}/684/400';

    return Padding(
      padding: EdgeInsets.only(bottom: SpacePalette.sm),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.lg),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                child: AspectRatio(
                  aspectRatio: 342 / 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: ColorPalette.neutral200,
                          child: Icon(
                            Icons.campaign,
                            size: 36,
                            color: ColorPalette.neutral400,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: SpacePalette.sm,
                        left: SpacePalette.sm,
                        child: _buildPlatformBadges(
                          displayedPlatforms,
                          extraPlatformCount,
                        ),
                      ),
                      Positioned(
                        right: SpacePalette.sm,
                        bottom: SpacePalette.sm,
                        child: _buildUserBadge(),
                      ),
                      Positioned(
                        left: SpacePalette.base,
                        right: SpacePalette.base,
                        bottom: SpacePalette.base,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.name,
                              style: TextStylePalette.title.copyWith(
                                color: ColorPalette.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: SpacePalette.xs),
                            Text(
                              '${_formatAmount(currentViews.toDouble())} / ${_formatAmount(targetViews.toDouble())} views ($percentage%)',
                              style: TextStylePalette.smSubText.copyWith(
                                color: ColorPalette.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button + 4,
                child: DuolingoButton(
                  onPressed: onTap,
                  isEnabled: true,
                  text:
                      '¥${campaign.pricePerThousand.toStringAsFixed(0)} / 1000 再生',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final value = amount.toInt().toString();
    return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Widget _buildPlatformBadges(List<String> platforms, int extraCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(RadiusPalette.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...platforms.map(
            (platform) => Padding(
              padding: EdgeInsets.only(right: SpacePalette.xs),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PlatformIcon.fromPlatform(platform, size: 12),
                ),
              ),
            ),
          ),
          if (extraCount > 0)
            Text(
              '+$extraCount',
              style: TextStylePalette.smSubText.copyWith(
                color: ColorPalette.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserBadge() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: ColorPalette.white, width: 1.5),
      ),
      child: Icon(Icons.person, size: 14, color: ColorPalette.neutral800),
    );
  }
}

class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _LiquidGlassNavBar({required this.currentIndex, required this.onTap});

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
                  icon: Icons.search,
                  selectedIcon: Icons.search,
                  label: AppLocalizations.of(context)!.navFind,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _GlassNavItem(
                  icon: Icons.article_outlined,
                  selectedIcon: Icons.article_rounded,
                  label: AppLocalizations.of(context)!.navFeed,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // 中央の黒いボタン
                Transform.translate(
                  offset: Offset(0, -16),
                  child: _CenterBlackButton(
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
                _GlassNavItem(
                  icon: Icons.work_outline,
                  selectedIcon: Icons.work_rounded,
                  label: AppLocalizations.of(context)!.navCampaign,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _GlassNavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: AppLocalizations.of(context)!.navProfile,
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

// 中央の黒いボタン（常に黒）
class _CenterBlackButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterBlackButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(0, 1.15),
            radius: 1.2,
            colors: [Color(0xFF525252), Color(0xFF0A0A0A)],
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
        child: Icon(
          isSelected ? Icons.dashboard_rounded : Icons.dashboard_outlined,
          color: ColorPalette.white,
          size: 24,
        ),
      ),
    );
  }
}
