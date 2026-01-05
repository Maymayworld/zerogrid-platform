// lib/features/creator/find/presentation/pages/find_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../campaign/presentation/widgets/project_card.dart';
import '../../../../../../../shared/widgets/common_search_bar.dart';
import '../widgets/notification_sheet.dart';
import '../widgets/filter_chip_widget.dart';

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

    final filterCategories = ['All', 'Business', 'Entertainment', 'Music', 'Podcast'];

    // 案件取得
    Future<void> loadCampaigns() async {
      isLoading.value = true;
      error.value = null;
      try {
        final campaignService = ref.read(campaignServiceProvider);
        List<Campaign> result;
        
        if (selectedFilterIndex.value == 0) {
          // All
          result = await campaignService.getAllActiveCampaigns();
        } else {
          // カテゴリフィルター
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

    // 初回読み込み
    useEffect(() {
      loadCampaigns();
      return null;
    }, []);

    // フィルター変更時に再取得
    useEffect(() {
      loadCampaigns();
      return null;
    }, [selectedFilterIndex.value]);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  // ロゴ
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
                  // 検索バー
                  Expanded(child: CommonSearchBar()),
                  SizedBox(width: SpacePalette.sm),
                  // 通知ボタン
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

            // 広告バナー
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

            // フィルターチップ
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

            // 案件リスト
            Expanded(
              child: _buildCampaignList(
                context,
                isLoading: isLoading.value,
                error: error.value,
                campaigns: campaigns.value,
                scrollController: scrollController,
                onRefresh: loadCampaigns,
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignList(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required List<Campaign> campaigns,
    required FixedExtentScrollController scrollController,
    required VoidCallback onRefresh,
  }) {
    // ローディング
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorPalette.neutral800),
      );
    }

    // エラー
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

    // 空
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

    // リスト表示
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
            child: ProjectCard(
              width: cardWidth,
              height: cardHeight,
              imageUrl: campaign.thumbnailUrl,
              platformIcon: _getPlatformIcon(campaign.platforms),
              currentAmount: campaign.budget.toDouble() * 0.25, // TODO: 実際の消費額
              totalAmount: campaign.budget.toDouble(),
              pricePerView: campaign.pricePerThousand,
              viewCount: 1000,
              participants: 3, // TODO: 実際の参加者数
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailScreen(
                      imageUrl: campaign.thumbnailUrl,
                      projectName: campaign.name,
                      pricePerView: campaign.pricePerThousand,
                      viewCount: 1000,
                      currentAmount: campaign.budget.toDouble() * 0.25,
                      totalAmount: campaign.budget.toDouble(),
                      campaignPeriod: _formatDeadline(campaign.deadline),
                      companyName: 'Company', // TODO: Organizerの名前取得
                      showAddReview: false,
                    ),
                  ),
                );
              },
              onLike: () {
                // TODO: いいね機能実装
                print('Liked: ${campaign.name}');
              },
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