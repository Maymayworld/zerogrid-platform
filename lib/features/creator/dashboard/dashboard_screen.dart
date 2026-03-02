// lib/features/creator/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/platform_icon.dart';
import '../../../shared/presentation/providers/reward_provider.dart';
import '../../../shared/presentation/providers/view_count_provider.dart';
import '../../../shared/data/services/reward_service.dart';
import '../../../shared/data/services/view_count_service.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  String _formatCurrency(int amount) {
    return '¥${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalEarningsAsync = ref.watch(totalEarningsProvider);
    final estimatedAsync = ref.watch(estimatedPendingProvider);
    final submissionStatsAsync = ref.watch(mySubmissionStatsProvider);
    final campaignEarningsAsync = ref.watch(campaignEarningsProvider);

    // Calculate total views from submission stats
    final totalViews = submissionStatsAsync.whenOrNull(
      data: (stats) =>
          stats.fold<int>(0, (sum, s) => sum + s.viewCount),
    );

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: TextStylePalette.header),
              SizedBox(height: SpacePalette.lg),

              // Earnings section
              Text('Earnings', style: TextStylePalette.smallHeader),
              SizedBox(height: SpacePalette.base),

              // Total Views & Total Earnings
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Views',
                      value: submissionStatsAsync.when(
                        data: (_) => _formatNumber(totalViews ?? 0),
                        loading: () => '---',
                        error: (_, __) => '-',
                      ),
                      icon: Icons.visibility_outlined,
                      iconColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Total Earnings',
                      value: totalEarningsAsync.when(
                        data: (v) => _formatCurrency(v),
                        loading: () => '---',
                        error: (_, __) => '-',
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.sm),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Active Campaigns',
                      value: submissionStatsAsync.when(
                        data: (stats) {
                          final uniqueCampaigns =
                              stats.map((s) => s.campaignId).toSet();
                          return '${uniqueCampaigns.length}';
                        },
                        loading: () => '---',
                        error: (_, __) => '-',
                      ),
                      icon: Icons.campaign_outlined,
                      iconColor: Colors.orange,
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Estimated Pending',
                      value: estimatedAsync.when(
                        data: (v) => '~${_formatCurrency(v)}',
                        loading: () => '---',
                        error: (_, __) => '-',
                      ),
                      icon: Icons.hourglass_empty,
                      iconColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),

              // Earning History
              Text('Earning History', style: TextStylePalette.smallHeader),
              SizedBox(height: SpacePalette.base),

              // Header row
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_outline,
                              size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text('Video',
                              style: TextStylePalette.smSubTitle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text('Views',
                              style: TextStylePalette.smSubTitle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text('Earning',
                              style: TextStylePalette.smSubTitle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacePalette.sm),

              // Earning list - real data
              submissionStatsAsync.when(
                data: (stats) {
                  if (stats.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: SpacePalette.lg),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 48,
                              color: ColorPalette.neutral400,
                            ),
                            SizedBox(height: SpacePalette.base),
                            Text(
                              'No approved submissions yet',
                              style: TextStylePalette.normalText
                                  .copyWith(
                                      color: ColorPalette.neutral500),
                            ),
                            SizedBox(height: SpacePalette.xs),
                            Text(
                              'Submit videos to campaigns to start earning!',
                              style: TextStylePalette.smSubText,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: stats
                        .map((stat) => _EarningItem(stat: stat))
                        .toList(),
                  );
                },
                loading: () => Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: SpacePalette.lg),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorPalette.neutral800,
                    ),
                  ),
                ),
                error: (_, __) => Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: SpacePalette.lg),
                  child: Center(
                    child: Text(
                      'Failed to load data',
                      style: TextStylePalette.subText,
                    ),
                  ),
                ),
              ),

              // Past campaign earnings
              campaignEarningsAsync.when(
                data: (earnings) {
                  if (earnings.isEmpty) return SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: SpacePalette.lg),
                      Text('Past Earnings',
                          style: TextStylePalette.smallHeader),
                      SizedBox(height: SpacePalette.base),
                      ...earnings.map((e) => _PastEarningItem(
                            earning: e,
                            formatCurrency: _formatCurrency,
                          )),
                    ],
                  );
                },
                loading: () => SizedBox.shrink(),
                error: (_, __) => SizedBox.shrink(),
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              SizedBox(width: SpacePalette.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStylePalette.listLeading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            value,
            style: TextStylePalette.miniTitle.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EarningItem extends StatelessWidget {
  final SubmissionViewStats stat;

  const _EarningItem({required this.stat});

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '¥${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '¥${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '¥$amount';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.sm),
      padding: EdgeInsets.all(SpacePalette.sm),
      child: Row(
        children: [
          // Platform icon + campaign name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral100,
                    borderRadius:
                        BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Center(
                    child: PlatformIcon.fromPlatform(
                        stat.platform, size: 20),
                  ),
                ),
                SizedBox(width: SpacePalette.sm),
                Expanded(
                  child: Text(
                    stat.campaignName,
                    style: TextStylePalette.smText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Views
          Expanded(
            child: Text(
              _formatNumber(stat.viewCount),
              style: TextStylePalette.smText,
            ),
          ),
          // Earning
          Expanded(
            child: Text(
              _formatCurrency(stat.estimatedEarnings),
              style: TextStylePalette.smTitle.copyWith(
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastEarningItem extends StatelessWidget {
  final CampaignEarning earning;
  final String Function(int) formatCurrency;

  const _PastEarningItem({
    required this.earning,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.sm),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusPalette.mini),
            child: earning.thumbnailUrl != null
                ? Image.network(
                    earning.thumbnailUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: ColorPalette.neutral200,
                      child: Icon(Icons.campaign,
                          size: 20, color: ColorPalette.neutral400),
                    ),
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: ColorPalette.neutral200,
                    child: Icon(Icons.campaign,
                        size: 20, color: ColorPalette.neutral400),
                  ),
          ),
          SizedBox(width: SpacePalette.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning.campaignName,
                  style: TextStylePalette.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  '${earning.earnedAt.year}/${earning.earnedAt.month}/${earning.earnedAt.day}',
                  style: TextStylePalette.listLeading,
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(earning.amount),
            style: TextStylePalette.miniTitle.copyWith(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
