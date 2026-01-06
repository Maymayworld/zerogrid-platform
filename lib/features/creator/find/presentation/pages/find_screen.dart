// lib/features/creator/find/presentation/pages/find_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../campaign/presentation/widgets/project_card.dart';
import '../../../../../shared/widgets/common_search_bar.dart';
import '../widgets/notification_sheet.dart';
import '../widgets/filter_chip_widget.dart';
import '../../../likes/presentation/providers/like_service_provider.dart';

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

    final filterCategories = ['All', 'Business', 'Entertainment', 'Music', 'Podcast'];

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
          ref.read(likedCampaignIdsProvider.notifier).state = 
              {...currentLiked}..remove(campaignId);
        } else {
          await likeService.likeCampaign(campaignId);
          ref.read(likedCampaignIdsProvider.notifier).state = 
              {...currentLiked, campaignId};
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    useEffect(() {
      loadCampaigns();
      loadLikedIds();
      return null;
    }, []);

    useEffect(() {
      loadCampaigns();
      return null;
    }, [selectedFilterIndex.value]);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'ZG',
                        style: TextStylePalette.title.copyWith(color: ColorPalette.neutral0),
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(child: CommonSearchBar()),
                  SizedBox(width: SpacePalette.sm),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => NotificationSheet(),
                      );
                    },
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color: ColorPalette.neutral800,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
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
                            color: ColorPalette.neutral0,
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Center(
                            child: Text(
                              'Ad Banner ${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: FontSizePalette.size16,
                              ),
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
                padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
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
                campaigns: campaigns.value,
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
            Text('Failed to load campaigns', style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(onPressed: onRefresh, child: Text('Retry')),
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
            Text('No campaigns found', style: TextStylePalette.subText),
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
              platformIcon: _getPlatformIcon(campaign.platforms),
              currentAmount: campaign.budget.toDouble() * 0.25,
              totalAmount: campaign.budget.toDouble(),
              pricePerView: campaign.pricePerThousand,
              viewCount: 1000,
              participants: 3,
              isLiked: isLiked,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailScreen(
                      campaign: campaign,  // ← campaignオブジェクトを渡す
                    ),
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

  IconData _getPlatformIcon(List<String> platforms) {
    if (platforms.contains('YouTube')) return Icons.play_arrow;
    if (platforms.contains('Instagram')) return Icons.camera_alt;
    if (platforms.contains('TikTok')) return Icons.music_note;
    return Icons.video_library;
  }

  String _formatDeadline(DateTime deadline) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }
}