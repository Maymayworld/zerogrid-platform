// lib/features/creator/campaign/presentation/pages/campaign_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/common_search_bar.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../widgets/project_card.dart';
import '../providers/participation_service_provider.dart';
import '../../../find/presentation/widgets/notification_sheet.dart';
import 'menu_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class CampaignScreen extends HookConsumerWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final searchQuery = useState<String>('');
    final searchController = useTextEditingController();

    // 参加中の案件IDをwatch
    final participatingIds = ref.watch(participatingCampaignIdsProvider);

    // 参加中の案件を取得
    Future<void> loadParticipatingCampaigns() async {
      isLoading.value = true;
      error.value = null;
      try {
        final participationService = ref.read(participationServiceProvider);
        final result = await participationService.getParticipatingCampaigns();
        campaigns.value = result;
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    // 初回ロード + 外部からの参加/離脱で再取得
    useEffect(() {
      loadParticipatingCampaigns();
      return null;
    }, [participatingIds.length]);

    // 検索フィルター
    final filteredCampaigns = campaigns.value.where((c) {
      if (searchQuery.value.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  Expanded(
                    child: CommonSearchBar(
                      controller: searchController,
                      hintText: AppLocalizations.of(context)!.searchCampaigns,
                      onChanged: (value) => searchQuery.value = value,
                    ),
                  ),
                  SizedBox(width: SpacePalette.base),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
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

            // タイトル
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.myCampaigns, style: TextStylePalette.header),
                  IconButton(
                    icon: Icon(Icons.refresh, color: ColorPalette.neutral800),
                    onPressed: loadParticipatingCampaigns,
                  ),
                ],
              ),
            ),
            SizedBox(height: SpacePalette.sm),

            // リスト
            Expanded(
              child: _buildContent(
                context,
                isLoading: isLoading.value,
                error: error.value,
                campaigns: filteredCampaigns,
                onRefresh: loadParticipatingCampaigns,
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required List<Campaign> campaigns,
    required VoidCallback onRefresh,
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
            Text(AppLocalizations.of(context)!.failedToLoad, style: TextStylePalette.subText),
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
            Icon(Icons.campaign_outlined, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.noCampaignsYet, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.xs),
            Text(AppLocalizations.of(context)!.joinCampaignsFromFind, style: TextStylePalette.smSubText),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (SpacePalette.base * 2);
    final cardHeight = cardWidth * 9 / 16;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];

          return Padding(
            padding: EdgeInsets.only(bottom: SpacePalette.base),
            child: ProjectCard(
              width: cardWidth,
              height: cardHeight,
              imageUrl: campaign.thumbnailUrl,
              platforms: campaign.platforms,
              currentViews: campaign.totalViews,
              targetViews: campaign.targetViews,
              pricePerView: campaign.pricePerThousand,
              isLiked: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectMenuScreen(
                      campaign: campaign,
                    ),
                  ),
                );
              },
              onLike: () {},
            ),
          );
        },
      ),
    );
  }

}