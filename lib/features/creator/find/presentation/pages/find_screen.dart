// lib/features/creator/find/presentation/pages/find_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../campaign/presentation/widgets/project_card.dart';
import '../widgets/notification_sheet.dart';
import '../widgets/filter_chip_widget.dart';
import '../../../likes/presentation/providers/like_service_provider.dart';
import '../../../../../shared/presentation/providers/notification_provider.dart';
import '../../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../profile/presentation/pages/profile_detail_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class FindScreen extends HookConsumerWidget {
  const FindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final selectedFilterIndex = useState<int>(0);
    final bannerPageController = usePageController();
    final currentPage = useState(0);
    final scrollController = FixedExtentScrollController();

    final likedIds = ref.watch(likedCampaignIdsProvider);
    final showLikedOnly = useState(false);
    final profileState = ref.watch(userProfileProvider);
    final avatarUrl = profileState.profile?.avatarUrl;

    final filterCategories = [
      'All',
      'Business',
      'Entertainment',
      'Music',
      'Podcast',
    ];

    Future<void> loadLikedIds() async {
      try {
        final likeService = ref.read(likeServiceProvider);
        final ids = await likeService.getLikedCampaignIds();
        ref.read(likedCampaignIdsProvider.notifier).state = ids;
      } catch (e) {
        print('Failed to load liked IDs: $e');
      }
    }

    Future<void> loadCampaigns() async {
      isLoading.value = true;
      error.value = null;
      try {
        final campaignService = ref.read(campaignServiceProvider);
        List<Campaign> result;

        if (selectedFilterIndex.value == 0) {
          result = await campaignService.getAllActiveCampaigns();
        } else {
          final category = filterCategories[selectedFilterIndex.value];
          result = await campaignService.getCampaignsByCategory(category);
        }

        campaigns.value = result;
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> toggleLike(String campaignId) async {
      final likeService = ref.read(likeServiceProvider);
      final currentLiked = ref.read(likedCampaignIdsProvider);

      try {
        if (currentLiked.contains(campaignId)) {
          await likeService.unlikeCampaign(campaignId);
          ref.read(likedCampaignIdsProvider.notifier).state = {...currentLiked}
            ..remove(campaignId);
        } else {
          await likeService.likeCampaign(campaignId);
          ref.read(likedCampaignIdsProvider.notifier).state = {
            ...currentLiked,
            campaignId,
          };
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
        );
      }
    }

    useEffect(() {
      Future.wait([loadCampaigns(), loadLikedIds()]);
      return null;
    }, []);

    useEffect(() {
      loadCampaigns();
      return null;
    }, [selectedFilterIndex.value]);

    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  // アバターアイコン（タップでプロフィールへ遷移）
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileDetailScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ColorPalette.neutral200,
                        shape: BoxShape.circle,
                      ),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 22,
                                  color: ColorPalette.neutral400,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 22,
                              color: ColorPalette.neutral400,
                            ),
                    ),
                  ),
                  Spacer(),
                  // 検索ガラスボタン
                  _buildGlassButton(icon: Icons.search, onTap: () {}),
                  SizedBox(width: SpacePalette.sm),
                  // いいねフィルターガラスボタン
                  _buildGlassButton(
                    icon: showLikedOnly.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor: showLikedOnly.value
                        ? ColorPalette.critical500
                        : ColorPalette.neutral800,
                    onTap: () {
                      showLikedOnly.value = !showLikedOnly.value;
                    },
                  ),
                  SizedBox(width: SpacePalette.sm),
                  // 通知ガラスボタン（バッジ付き）
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildGlassButton(
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) => NotificationSheet(),
                          );
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: ColorPalette.critical500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorPalette.neutral100,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: TextStyle(
                                  color: ColorPalette.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Ad Banner（neutral200背景、テキストなし）
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacePalette.base,
              ),
              child: SizedBox(
                height: 144,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: bannerPageController,
                      onPageChanged: (index) => currentPage.value = index,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral200,
                            borderRadius: BorderRadius.circular(
                              RadiusPalette.base,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage.value == index
                                  ? ColorPalette.neutral800
                                  : ColorPalette.neutral400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: SpacePalette.base),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacePalette.base,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filterCategories.length, (index) {
                      final icons = [
                        Icons.all_inclusive,
                        Icons.business,
                        Icons.gamepad,
                        Icons.music_note,
                        Icons.podcasts,
                      ];
                      return Padding(
                        padding: EdgeInsets.only(right: SpacePalette.sm),
                        child: FilterButton(
                          icon: icons[index],
                          label: filterCategories[index],
                          isSelected: selectedFilterIndex.value == index,
                          onTap: () => selectedFilterIndex.value = index,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.base),

            Expanded(
              child: _buildCampaignList(
                context,
                ref,
                isLoading: isLoading.value,
                error: error.value,
                campaigns: showLikedOnly.value
                    ? campaigns.value
                          .where((c) => likedIds.contains(c.id))
                          .toList()
                    : campaigns.value,
                likedIds: likedIds,
                scrollController: scrollController,
                onRefresh: loadCampaigns,
                onToggleLike: toggleLike,
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// 円形ガラスボタン（width 40）
  Widget _buildGlassButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorPalette.white.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: ColorPalette.neutral200, width: 1),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.neutral800.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? ColorPalette.neutral800,
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignList(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
    required String? error,
    required List<Campaign> campaigns,
    required Set<String> likedIds,
    required FixedExtentScrollController scrollController,
    required VoidCallback onRefresh,
    required Future<void> Function(String) onToggleLike,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorPalette.neutral800),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.failedToLoadCampaigns, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(onPressed: onRefresh, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }

    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.noMatchingCampaigns, style: TextStylePalette.subText),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;
    final cardHeight = cardWidth * 9 / 16;

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: cardHeight + 8,
      diameterRatio: 2,
      perspective: 0.002,
      physics: FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index >= campaigns.length) return null;
          final campaign = campaigns[index];
          final isLiked = likedIds.contains(campaign.id);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
            child: ProjectCard(
              width: cardWidth,
              height: cardHeight,
              imageUrl: campaign.thumbnailUrl,
              platforms: campaign.platforms,
              currentViews: campaign.totalViews,
              targetViews: campaign.targetViews,
              pricePerView: campaign.pricePerThousand,
              isLiked: isLiked,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProjectDetailScreen(campaign: campaign),
                  ),
                );
              },
              onLike: () => onToggleLike(campaign.id),
            ),
          );
        },
        childCount: campaigns.length,
      ),
    );
  }
}
