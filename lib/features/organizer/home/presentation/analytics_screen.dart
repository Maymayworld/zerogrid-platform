// lib/features/organizer/home/presentation/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../data/services/organizer_stats_service.dart';
import 'providers/organizer_stats_provider.dart';

class AnalyticsScreen extends HookConsumerWidget {
  final String campaignId;

  const AnalyticsScreen({
    Key? key,
    required this.campaignId,
  }) : super(key: key);

  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(organizerStatsServiceProvider);

    // State
    final campaign = useState<CampaignStats?>(null);
    final submissions = useState<List<SubmissionAnalytics>>([]);
    final userRankings = useState<List<UserRanking>>([]);
    final platformBreakdown = useState<Map<String, int>>({});
    final isLoading = useState(true);

    // Filters
    final viewsPlatform = useState('All');
    final rankingPlatform = useState('All');

    // Load campaign data
    Future<void> loadData() async {
      isLoading.value = true;
      final details = await service.getCampaignDetails(campaignId);
      campaign.value = details;

      final subs = await service.getCampaignSubmissions(
        campaignId: campaignId,
        platform: viewsPlatform.value,
      );
      submissions.value = subs;

      final breakdown = await service.getCampaignViewsByPlatform(campaignId);
      platformBreakdown.value = breakdown;

      final rankings = await service.getCampaignUserRanking(
        campaignId: campaignId,
        platform: rankingPlatform.value,
      );
      userRankings.value = rankings;

      isLoading.value = false;
    }

    useEffect(() {
      loadData();
      return null;
    }, []);

    // Reload views when platform filter changes
    Future<void> reloadViews() async {
      final subs = await service.getCampaignSubmissions(
        campaignId: campaignId,
        platform: viewsPlatform.value,
      );
      submissions.value = subs;
    }

    // Reload rankings when filter changes
    Future<void> reloadRankings() async {
      final rankings = await service.getCampaignUserRanking(
        campaignId: campaignId,
        platform: rankingPlatform.value,
      );
      userRankings.value = rankings;
    }

    final totalFilteredViews = submissions.value.fold<int>(
      0,
      (sum, s) => sum + s.viewCount,
    );

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: isLoading.value
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header with dashboard background
                SliverToBoxAdapter(
                  child: _AnalyticsHeader(
                    campaignName: campaign.value?.name ?? '',
                    totalViews: campaign.value?.totalViews ?? 0,
                    targetViews: campaign.value?.targetViews ?? 0,
                    progressPercentage: campaign.value?.progressPercentage ?? 0,
                    formatNumber: _formatNumber,
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(SpacePalette.base),
                    child: Column(
                      children: [
                        // Views Analysis Card
                        _ViewsAnalysisCard(
                          totalViews: totalFilteredViews,
                          platformBreakdown: platformBreakdown.value,
                          selectedPlatform: viewsPlatform.value,
                          onPlatformChanged: (p) {
                            viewsPlatform.value = p;
                            reloadViews();
                          },
                          formatNumber: _formatNumber,
                        ),

                        SizedBox(height: SpacePalette.base),

                        // User Ranking Card
                        _UserRankingCard(
                          rankings: userRankings.value,
                          selectedPlatform: rankingPlatform.value,
                          onPlatformChanged: (p) {
                            rankingPlatform.value = p;
                            reloadRankings();
                          },
                          formatNumber: _formatNumber,
                        ),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Header
class _AnalyticsHeader extends StatelessWidget {
  final String campaignName;
  final int totalViews;
  final int targetViews;
  final double progressPercentage;
  final String Function(int) formatNumber;

  const _AnalyticsHeader({
    required this.campaignName,
    required this.totalViews,
    required this.targetViews,
    required this.progressPercentage,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/dashboard_card.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ColorPalette.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Icon(Icons.arrow_back, color: ColorPalette.white, size: 20),
                ),
              ),
              SizedBox(height: SpacePalette.base),

              Text(
                campaignName,
                style: TextStylePalette.smallHeader.copyWith(
                  color: ColorPalette.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: SpacePalette.lg),

              Text(
                AppLocalizations.of(context)!.totalViews,
                style: TextStylePalette.normalText.copyWith(
                  color: ColorPalette.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: SpacePalette.xs),
              Text(
                formatNumber(totalViews),
                style: TextStylePalette.header.copyWith(
                  color: ColorPalette.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SpacePalette.base),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progressPercentage / 100).clamp(0.0, 1.0),
                        backgroundColor: ColorPalette.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercentage >= 100
                              ? ColorPalette.positive500
                              : ColorPalette.white,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Text(
                    '${progressPercentage.toStringAsFixed(0)}%',
                    style: TextStylePalette.smTitle.copyWith(
                      color: ColorPalette.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.xs),
              Text(
                'Target: ${formatNumber(targetViews)} views',
                style: TextStylePalette.smText.copyWith(
                  color: ColorPalette.white.withOpacity(0.7),
                ),
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }
}

// Views Analysis Card
class _ViewsAnalysisCard extends StatelessWidget {
  final int totalViews;
  final Map<String, int> platformBreakdown;
  final String selectedPlatform;
  final void Function(String) onPlatformChanged;
  final String Function(int) formatNumber;

  const _ViewsAnalysisCard({
    required this.totalViews,
    required this.platformBreakdown,
    required this.selectedPlatform,
    required this.onPlatformChanged,
    required this.formatNumber,
  });

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Colors.red;
      case 'tiktok':
        return ColorPalette.neutral800;
      case 'instagram':
        return Colors.purple;
      default:
        return ColorPalette.neutral400;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = platformBreakdown.values.fold<int>(0, (a, b) => a + b);

    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.lg),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.viewsAnalysis, style: TextStylePalette.title),
              _PlatformDropdown(
                value: selectedPlatform,
                onChanged: onPlatformChanged,
              ),
            ],
          ),

          SizedBox(height: SpacePalette.lg),

          // Total Views
          Text(
            'Filtered Views',
            style: TextStylePalette.smSubTitle.copyWith(color: ColorPalette.neutral500),
          ),
          SizedBox(height: SpacePalette.xs),
          Text(
            formatNumber(totalViews),
            style: TextStylePalette.header.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: SpacePalette.lg),

          // Platform breakdown bars
          if (platformBreakdown.isNotEmpty) ...[
            Text(
              'By Platform',
              style: TextStylePalette.smSubTitle.copyWith(color: ColorPalette.neutral500),
            ),
            SizedBox(height: SpacePalette.base),
            ...platformBreakdown.entries.map((entry) {
              final percentage = grandTotal > 0 ? entry.value / grandTotal : 0.0;
              return Padding(
                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          PlatformIcon.fromPlatform(entry.key, size: 16),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            _capitalize(entry.key),
                            style: TextStylePalette.smText,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: SpacePalette.sm),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: ColorPalette.neutral100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPlatformColor(entry.key),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: SpacePalette.sm),
                    SizedBox(
                      width: 70,
                      child: Text(
                        formatNumber(entry.value),
                        style: TextStylePalette.smTitle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else
            Padding(
              padding: EdgeInsets.symmetric(vertical: SpacePalette.lg),
              child: Center(
                child: Text(
                  'No approved submissions yet',
                  style: TextStylePalette.normalText.copyWith(
                    color: ColorPalette.neutral500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// User Ranking Card
class _UserRankingCard extends StatelessWidget {
  final List<UserRanking> rankings;
  final String selectedPlatform;
  final void Function(String) onPlatformChanged;
  final String Function(int) formatNumber;

  const _UserRankingCard({
    required this.rankings,
    required this.selectedPlatform,
    required this.onPlatformChanged,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.lg),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.userRanking, style: TextStylePalette.title),
              _PlatformDropdown(
                value: selectedPlatform,
                onChanged: onPlatformChanged,
              ),
            ],
          ),

          SizedBox(height: SpacePalette.base),

          // Table header
          Row(
            children: [
              SizedBox(width: 30),
                Expanded(
                child: Text(AppLocalizations.of(context)!.user, style: TextStylePalette.smSubTitle.copyWith(color: ColorPalette.neutral500)),
              ),
              Text(AppLocalizations.of(context)!.videos, style: TextStylePalette.smSubTitle.copyWith(color: ColorPalette.neutral500)),
              SizedBox(width: SpacePalette.base),
              SizedBox(
                width: 80,
                child: Text(
                  AppLocalizations.of(context)!.views,
                  style: TextStylePalette.smSubTitle.copyWith(color: ColorPalette.neutral500),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          SizedBox(height: SpacePalette.sm),
          Divider(color: ColorPalette.neutral200, height: 1),

          if (rankings.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: SpacePalette.lg),
              child: Center(
                child: Text(
                  'No participants yet',
                  style: TextStylePalette.normalText.copyWith(
                    color: ColorPalette.neutral500,
                  ),
                ),
              ),
            )
          else
            ...rankings.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final user = entry.value;
              return _UserRankingRow(
                rank: rank,
                displayName: user.displayName,
                avatarUrl: user.avatarUrl,
                submissionCount: user.submissionCount,
                totalViews: user.formattedViews,
              );
            }),
        ],
      ),
    );
  }
}

// User ranking row
class _UserRankingRow extends StatelessWidget {
  final int rank;
  final String displayName;
  final String? avatarUrl;
  final int submissionCount;
  final String totalViews;

  const _UserRankingRow({
    required this.rank,
    required this.displayName,
    this.avatarUrl,
    required this.submissionCount,
    required this.totalViews,
  });

  @override
  Widget build(BuildContext context) {
    Color? rankColor;
    if (rank == 1) rankColor = Color(0xFFFFD700);
    if (rank == 2) rankColor = Color(0xFFC0C0C0);
    if (rank == 3) rankColor = Color(0xFFCD7F32);

    return Container(
      padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: rank <= 3
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: rankColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.white,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '$rank',
                    style: TextStylePalette.smSubTitle,
                    textAlign: TextAlign.center,
                  ),
          ),
          SizedBox(width: SpacePalette.sm),

          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.neutral200,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 12, color: ColorPalette.neutral500),
                  )
                : null,
          ),
          SizedBox(width: SpacePalette.sm),

          // Name
          Expanded(
            child: Text(
              displayName,
              style: TextStylePalette.normalText,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Submission count
          Text(
            '$submissionCount',
            style: TextStylePalette.smText.copyWith(color: ColorPalette.neutral500),
          ),
          SizedBox(width: SpacePalette.base),

          // Views
          SizedBox(
            width: 80,
            child: Text(
              totalViews,
              style: TextStylePalette.smTitle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Shared platform dropdown
class _PlatformDropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _PlatformDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.neutral200),
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: SizedBox(),
        isDense: true,
        icon: Icon(Icons.keyboard_arrow_down, size: 16, color: ColorPalette.neutral800),
        style: TextStylePalette.smText,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: [
          DropdownMenuItem(value: 'All', child: Text(AppLocalizations.of(context)!.all)),
          DropdownMenuItem(
            value: 'YouTube',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlatformIcon.youtube(size: 14),
                SizedBox(width: 4),
                Text('YouTube'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'TikTok',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlatformIcon.tiktok(size: 14),
                SizedBox(width: 4),
                Text('TikTok'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Instagram',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlatformIcon.instagram(size: 14),
                SizedBox(width: 4),
                Text('Instagram'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
