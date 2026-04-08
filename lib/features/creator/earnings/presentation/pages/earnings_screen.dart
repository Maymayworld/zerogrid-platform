// lib/features/creator/earnings/presentation/pages/earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../../shared/presentation/providers/reward_provider.dart';
import '../../../../../shared/presentation/providers/view_count_provider.dart';
import '../../../../../shared/data/services/reward_service.dart';
import '../../../../../shared/data/services/view_count_service.dart';
import 'withdrawal_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class EarningsScreen extends HookConsumerWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  String _formatCurrency(int amount) {
    return '¥${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(creatorBalanceProvider);
    final totalEarningsAsync = ref.watch(totalEarningsProvider);
    final estimatedAsync = ref.watch(estimatedPendingProvider);
    final campaignEarningsAsync = ref.watch(campaignEarningsProvider);
    final submissionStatsAsync = ref.watch(mySubmissionStatsProvider);

    final selectedTab = useState(0);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: CustomScrollView(
        slivers: [
          // ヘッダー
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Icon(PhosphorIconsBold.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: ColorPalette.neutral800,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ColorPalette.neutral800, ColorPalette.neutral900],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(SpacePalette.base),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.earnings,
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.white,
                          ),
                        ),
                        SizedBox(height: SpacePalette.base),
                        // 残高
                        balanceAsync.when(
                          data: (balance) => Text(
                            _formatCurrency(balance),
                            style: TextStylePalette.header.copyWith(
                              color: ColorPalette.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => Text(
                            '---',
                            style: TextStylePalette.header.copyWith(
                              color: ColorPalette.white,
                              fontSize: 36,
                            ),
                          ),
                          error: (_, __) => Text(
                            'Error',
                            style: TextStylePalette.header.copyWith(
                              color: ColorPalette.white,
                            ),
                          ),
                        ),
                        SizedBox(height: SpacePalette.xs),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.balance,
                              style: TextStylePalette.normalText.copyWith(
                                color: ColorPalette.neutral400,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                final balance =
                                    balanceAsync.whenOrNull(data: (b) => b) ??
                                    0;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WithdrawalScreen(
                                      currentBalance: balance,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SpacePalette.base,
                                  vertical: SpacePalette.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPalette.white,
                                  borderRadius: BorderRadius.circular(
                                    RadiusPalette.full,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.withdraw,
                                  style: TextStylePalette.smTitle.copyWith(
                                    color: ColorPalette.neutral800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 統計カード
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: AppLocalizations.of(context)!.earnings,
                      valueAsync: totalEarningsAsync,
                      formatValue: _formatCurrency,
                      icon: PhosphorIconsBold.wallet,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: _StatCard(
                      title: AppLocalizations.of(context)!.pending,
                      valueAsync: estimatedAsync,
                      formatValue: (v) => '~${_formatCurrency(v)}',
                      icon: PhosphorIconsBold.hourglass,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // タブ
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Row(
                children: [
                  _TabButton(
                    title: 'Performance',
                    isSelected: selectedTab.value == 0,
                    onTap: () => selectedTab.value = 0,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _TabButton(
                    title: 'History',
                    isSelected: selectedTab.value == 1,
                    onTap: () => selectedTab.value = 1,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: SpacePalette.base)),

          // コンテンツ
          if (selectedTab.value == 0)
            // Performance Tab - 提出物別の視聴回数と収益
            submissionStatsAsync.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(SpacePalette.lg),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIconsBold.filmStrip,
                              size: 48,
                              color: ColorPalette.neutral400,
                            ),
                            SizedBox(height: SpacePalette.base),
                            Text(
                              AppLocalizations.of(context)!.noApprovedSubmissionsYet,
                              style: TextStylePalette.normalText.copyWith(
                                color: ColorPalette.neutral500,
                              ),
                            ),
                            SizedBox(height: SpacePalette.xs),
                            Text(
                              AppLocalizations.of(context)!.submitVideosToEarn,
                              style: TextStylePalette.listLeading,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PerformanceCard(stat: stats[index]),
                    childCount: stats.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Center(child: Text(AppLocalizations.of(context)!.failedToLoad)),
              ),
            )
          else
            // History Tab - 収益履歴
            campaignEarningsAsync.when(
              data: (earnings) {
                if (earnings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(SpacePalette.lg),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.earningHistory,
                          style: TextStylePalette.normalText.copyWith(
                            color: ColorPalette.neutral500,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _EarningHistoryCard(earning: earnings[index]),
                    childCount: earnings.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Center(child: Text(AppLocalizations.of(context)!.failedToLoad)),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// 統計カード
class _StatCard extends StatelessWidget {
  final String title;
  final AsyncValue<int> valueAsync;
  final String Function(int) formatValue;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.valueAsync,
    required this.formatValue,
    required this.icon,
    required this.color,
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
              Icon(icon, size: 16, color: color),
              SizedBox(width: SpacePalette.xs),
              Text(title, style: TextStylePalette.listLeading),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          valueAsync.when(
            data: (value) => Text(
              formatValue(value),
              style: TextStylePalette.miniTitle.copyWith(fontSize: 18),
            ),
            loading: () => Text('---', style: TextStylePalette.miniTitle),
            error: (_, __) => Text('-', style: TextStylePalette.miniTitle),
          ),
        ],
      ),
    );
  }
}

// タブボタン
class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.neutral800 : ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Text(
          title,
          style: TextStylePalette.miniTitle.copyWith(
            color: isSelected ? ColorPalette.white : ColorPalette.neutral600,
          ),
        ),
      ),
    );
  }
}

// パフォーマンスカード
class _PerformanceCard extends StatelessWidget {
  final SubmissionViewStats stat;

  const _PerformanceCard({required this.stat});

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  Widget _getPlatformIconWidget() {
    return PlatformIcon.fromPlatform(stat.platform, size: 20);
  }

  Color _getPlatformColor() {
    switch (stat.platform.toLowerCase()) {
      case 'youtube':
        return Colors.red;
      case 'tiktok':
        return Colors.black;
      case 'instagram':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SpacePalette.base,
        vertical: SpacePalette.xs,
      ),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Row(
        children: [
          // プラットフォームアイコン
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPlatformColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(RadiusPalette.mini),
            ),
            child: Center(child: _getPlatformIconWidget()),
          ),
          SizedBox(width: SpacePalette.base),
          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.campaignName,
                  style: TextStylePalette.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SpacePalette.xs),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.eye,
                      size: 14,
                      color: ColorPalette.neutral500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${_formatNumber(stat.viewCount)} views',
                      style: TextStylePalette.listLeading,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 収益
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${stat.estimatedEarnings}',
                style: TextStylePalette.miniTitle.copyWith(color: Colors.green),
              ),
              Text(AppLocalizations.of(context)!.estimated, style: TextStylePalette.subGuide),
            ],
          ),
        ],
      ),
    );
  }
}

// 収益履歴カード
class _EarningHistoryCard extends StatelessWidget {
  final CampaignEarning earning;

  const _EarningHistoryCard({required this.earning});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: SpacePalette.base,
        vertical: SpacePalette.xs,
      ),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Row(
        children: [
          // サムネイル
          ClipRRect(
            borderRadius: BorderRadius.circular(RadiusPalette.mini),
            child: earning.thumbnailUrl != null
                ? Image.network(
                    earning.thumbnailUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: ColorPalette.neutral200,
                      child: Icon(PhosphorIconsBold.image, color: ColorPalette.neutral400),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: ColorPalette.neutral200,
                    child: Icon(PhosphorIconsBold.megaphone, color: ColorPalette.neutral400),
                  ),
          ),
          SizedBox(width: SpacePalette.base),
          // 情報
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
          // 金額
          Text(
            earning.formattedAmount,
            style: TextStylePalette.miniTitle.copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
