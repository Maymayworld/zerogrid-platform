// lib/features/organizer/campaign/presentation/campaign_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../widgets/campaign_card.dart';
import 'edit_campaign_screen.dart';
import '../../data/models/campaign.dart';
import '../providers/campaign_service_provider.dart';
import '../../../approval/presentation/pages/approval_history_screen.dart';

class CampaignScreen extends HookConsumerWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final searchQuery = useState('');

    // 案件一覧を取得
    Future<void> loadCampaigns() async {
      isLoading.value = true;
      error.value = null;
      try {
        final campaignService = ref.read(campaignServiceProvider);
        final result = await campaignService.getMyCampaigns();
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

    // 検索フィルター
    final filteredCampaigns = campaigns.value.where((c) {
      if (searchQuery.value.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.navCampaign, style: TextStylePalette.header),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsRegular.clockCounterClockwise, color: ColorPalette.neutral800),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalHistoryScreen(),
                ),
              );
            },
            tooltip: AppLocalizations.of(context)!.approvalHistory,
          ),
          IconButton(
            icon: Icon(PhosphorIconsRegular.arrowClockwise, color: ColorPalette.neutral800),
            onPressed: loadCampaigns,
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
            child: Container(
              height: ButtonSizePalette.filter,
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: TextField(
                onChanged: (value) => searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  hintStyle: TextStylePalette.hintText,
                  prefixIcon: Icon(
                    PhosphorIconsRegular.magnifyingGlass,
                    color: ColorPalette.neutral400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: SpacePalette.sm,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),

          // コンテンツ
          Expanded(
            child: _buildContent(
              context,
              ref,
              isLoading: isLoading.value,
              error: error.value,
              campaigns: filteredCampaigns,
              onRefresh: loadCampaigns,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
    required String? error,
    required List<Campaign> campaigns,
    required VoidCallback onRefresh,
  }) {
    // ローディング中
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
            Icon(PhosphorIconsRegular.warningCircle, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.failedToLoadCampaigns, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(onPressed: onRefresh, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }

    // 空の場合
    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.megaphone,
              size: 48,
              color: ColorPalette.neutral400,
            ),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.noCampaignsYet, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.xs),
            Text(
              AppLocalizations.of(context)!.createFirstCampaign,
              style: TextStylePalette.smSubText,
            ),
          ],
        ),
      );
    }

    // 一覧表示
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (SpacePalette.base * 2);
    final cardHeight = cardWidth * 9 / 16;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: SpacePalette.base,
          right: SpacePalette.base,
          bottom: 80,
        ),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];

          return Padding(
            padding: EdgeInsets.only(bottom: SpacePalette.base),
            child: OrganizerCampaignCard(
              width: cardWidth,
              height: cardHeight,
              campaignName: campaign.name,
              budget: campaign.budget,
              imageUrl: campaign.thumbnailUrl,
              status: campaign.status,
              onEdit: () async {
                // 編集画面へ遷移
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditCampaignScreen(campaignId: campaign.id),
                  ),
                );

                // 更新があれば再読み込み
                if (result == true) {
                  onRefresh();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
