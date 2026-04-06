// lib/features/organizer/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/presentation/providers/notification_provider.dart';
import '../../../creator/find/presentation/widgets/notification_sheet.dart';
import 'analytics_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';
import '../../payment/presentation/providers/payment_provider.dart';
import 'providers/organizer_stats_provider.dart';

class HomeScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    // Load balance on mount
    useEffect(() {
      Future.microtask(() async {
        try {
          final paymentService = ref.read(paymentServiceProvider);
          final bal = await paymentService.getBalance();
          ref.read(walletBalanceProvider.notifier).state = bal;
        } catch (_) {}
      });
      return null;
    }, []);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ヘッダー（青いグラデーション）
            _DashboardHeader(
              statusBarHeight: statusBarHeight,
              balance: balance,
              unreadCount: unreadCount,
            ),

            // コンテンツエリア
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                children: [
                  // Cumulative Total Views カード
                  _ViewsCard(),

                  SizedBox(height: SpacePalette.base),

                  // Your Projects カード
                  _ProjectsCard(),

                  SizedBox(height: 100), // ナビゲーション分の余白
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ダッシュボードヘッダー
class _DashboardHeader extends StatelessWidget {
  final double statusBarHeight;
  final int balance;
  final int unreadCount;

  const _DashboardHeader({
    required this.statusBarHeight,
    required this.balance,
    this.unreadCount = 0,
  });

  String _formatCurrency(int amount) {
    return '¥${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

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
              SizedBox(height: SpacePalette.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dashboard,
                    style: TextStylePalette.header.copyWith(
                      color: ColorPalette.white,
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => NotificationSheet(),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColorPalette.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.bell,
                            color: ColorPalette.white,
                            size: 22,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: ColorPalette.critical500,
                                shape: BoxShape.circle,
                                border: Border.all(color: ColorPalette.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                  style: TextStyle(
                                    color: ColorPalette.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),

              // Balance セクション
              Text(
                AppLocalizations.of(context)!.balance,
                style: TextStylePalette.normalText.copyWith(
                  color: ColorPalette.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: SpacePalette.xs),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側: 残高
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrency(balance),
                        style: TextStylePalette.header.copyWith(
                          color: ColorPalette.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // 右側: Depositボタン
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SelectAmountScreen()),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ColorPalette.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.handTap,
                            color: ColorPalette.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: SpacePalette.xs),
                        Text(
                          AppLocalizations.of(context)!.deposit,
                          style: TextStylePalette.smText.copyWith(
                            color: ColorPalette.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }
}

// Cumulative Total Views カード
class _ViewsCard extends ConsumerWidget {
  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${num.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return num.toString();
  }

  /// Y軸ラベル用フォーマット（1K, 10K, 1.5M など）
  String _formatAxisLabel(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return m == m.roundToDouble() ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return k == k.roundToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  /// 最大値に応じた「きれいな」Y軸間隔を計算
  double _calcInterval(double maxVal) {
    if (maxVal <= 0) return 25;
    // 4〜5本のグリッド線になるように間隔を決定
    final raw = maxVal / 4;
    final magnitude = _pow10((raw.toInt().toString().length - 1).clamp(0, 20));
    final normalized = raw / magnitude;
    double nice;
    if (normalized <= 1) {
      nice = 1;
    } else if (normalized <= 2) {
      nice = 2;
    } else if (normalized <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }

  double _pow10(int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalViewsAsync = ref.watch(totalViewsProvider);
    final campaignStatsAsync = ref.watch(myCampaignStatsProvider);

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
          // ヘッダー
          Text(
            AppLocalizations.of(context)!.cumulativeTotalViews,
            style: TextStylePalette.title,
          ),

          SizedBox(height: SpacePalette.lg),

          // Total Views ラベル
          Text(
            AppLocalizations.of(context)!.totalViews,
            style: TextStylePalette.smSubTitle.copyWith(
              color: ColorPalette.neutral500,
            ),
          ),

          SizedBox(height: SpacePalette.xs),

          // 数値
          totalViewsAsync.when(
            data: (totalViews) => Text(
              _formatNumber(totalViews),
              style: TextStylePalette.header.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => Text(
              '---',
              style: TextStylePalette.header.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            error: (_, __) => Text(
              AppLocalizations.of(context)!.error,
              style: TextStylePalette.header.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.critical500,
              ),
            ),
          ),

          SizedBox(height: SpacePalette.lg),

          // グラフ — キャンペーン開始日順に累計再生回数を表示
          SizedBox(
            height: 150,
            child: campaignStatsAsync.when(
              data: (campaigns) {
                // 締め切り順にソート
                final sorted = List<CampaignStats>.from(campaigns)
                  ..sort((a, b) => a.deadline.compareTo(b.deadline));

                // 累計データポイントを作成
                final spots = <FlSpot>[FlSpot(0, 0)];
                final dateLabels = <int, String>{0: ''};
                int cumulative = 0;
                for (int i = 0; i < sorted.length; i++) {
                  cumulative += sorted[i].totalViews;
                  spots.add(FlSpot((i + 1).toDouble(), cumulative.toDouble()));
                  final d = sorted[i].deadline;
                  dateLabels[i + 1] = '${d.month}/${d.day}';
                }

                // データがない場合
                if (sorted.isEmpty) {
                  spots.clear();
                  spots.addAll([FlSpot(0, 0), FlSpot(1, 0)]);
                }

                final maxVal = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
                final interval = _calcInterval(maxVal);
                final maxY = maxVal <= 0 ? 100.0 : (((maxVal / interval).ceil()) * interval);
                final maxX = spots.last.x;

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: ColorPalette.neutral200,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max) return SizedBox.shrink();
                            return Text(
                              value == 0 ? '0' : _formatAxisLabel(value),
                              style: TextStylePalette.smSubText.copyWith(
                                fontSize: 10,
                                color: ColorPalette.neutral400,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: sorted.isNotEmpty,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx <= 0 || !dateLabels.containsKey(idx)) {
                              return SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                dateLabels[idx]!,
                                style: TextStylePalette.smSubText.copyWith(
                                  fontSize: 9,
                                  color: ColorPalette.neutral400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: ColorPalette.smashedPumpkin600,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: spots.length <= 6),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ColorPalette.smashedPumpkin500.withOpacity(0.3),
                              ColorPalette.smashedPumpkin500.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: maxY,
                    minX: 0,
                    maxX: maxX <= 0 ? 1 : maxX,
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: ColorPalette.neutral300, strokeWidth: 2),
              ),
              error: (_, __) => Center(
                child: Text(AppLocalizations.of(context)!.error, style: TextStylePalette.smSubText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Your Projects カード
class _ProjectsCard extends ConsumerWidget {
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ColorPalette.smashedPumpkin600;
      case 'completed':
        return ColorPalette.positive500;
      case 'draft':
        return ColorPalette.neutral500;
      default:
        return ColorPalette.neutral500;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ColorPalette.smashedPumpkin100;
      case 'completed':
        return ColorPalette.positive50;
      case 'draft':
        return ColorPalette.neutral200;
      default:
        return ColorPalette.neutral200;
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(myCampaignStatsProvider);

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
          Text(
            AppLocalizations.of(context)!.yourProjects,
            style: TextStylePalette.title,
          ),

          SizedBox(height: SpacePalette.base),

          // テーブルヘッダー
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.name,
                  style: TextStylePalette.smSubTitle.copyWith(
                    color: ColorPalette.neutral500,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.status,
                style: TextStylePalette.smSubTitle.copyWith(
                  color: ColorPalette.neutral500,
                ),
              ),
            ],
          ),

          SizedBox(height: SpacePalette.sm),
          Divider(color: ColorPalette.neutral200, height: 1),

          // プロジェクトリスト
          campaignsAsync.when(
            data: (campaigns) {
              if (campaigns.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: SpacePalette.lg),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          PhosphorIconsRegular.megaphone,
                          size: 48,
                          color: ColorPalette.neutral400,
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Text(
                          AppLocalizations.of(context)!.noCampaignsYet,
                          style: TextStylePalette.normalText.copyWith(
                            color: ColorPalette.neutral500,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.createFirstCampaign,
                          style: TextStylePalette.listLeading,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: campaigns.take(5).map((campaign) => _ProjectListItem(
                  campaignId: campaign.id,
                  imageUrl: campaign.thumbnailUrl,
                  projectName: campaign.name,
                  budget: campaign.formattedBudget,
                  totalViews: campaign.formattedViews,
                  progressPercentage: campaign.progressPercentage,
                  status: _capitalizeStatus(campaign.status),
                  statusColor: _getStatusColor(campaign.status),
                  statusBgColor: _getStatusBgColor(campaign.status),
                )).toList(),
              );
            },
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: SpacePalette.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: EdgeInsets.symmetric(vertical: SpacePalette.lg),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.failedToLoadCampaigns,
                  style: TextStylePalette.normalText.copyWith(
                    color: ColorPalette.critical500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectListItem extends StatelessWidget {
  final String campaignId;
  final String? imageUrl;
  final String projectName;
  final String budget;
  final String totalViews;
  final double progressPercentage;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  const _ProjectListItem({
    required this.campaignId,
    this.imageUrl,
    required this.projectName,
    required this.budget,
    required this.totalViews,
    required this.progressPercentage,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsScreen(
              campaignId: campaignId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // サムネイル
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(PhosphorIconsFill.megaphone, color: ColorPalette.neutral400);
                        },
                      )
                    : Icon(PhosphorIconsFill.megaphone, color: ColorPalette.neutral400),
              ),
            ),

            SizedBox(width: SpacePalette.inner),

            // 名前と統計
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: TextStylePalette.listTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Row(
                    children: [
                      Text(
                        'Budget: $budget',
                        style: TextStylePalette.listLeading.copyWith(
                          color: ColorPalette.neutral500,
                        ),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Icon(PhosphorIconsFill.eye, size: 12, color: ColorPalette.neutral400),
                      SizedBox(width: 2),
                      Text(
                        totalViews,
                        style: TextStylePalette.listLeading.copyWith(
                          color: ColorPalette.neutral500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.xs),
                  // 進捗バー
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: ColorPalette.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressPercentage >= 100 
                          ? ColorPalette.positive500 
                          : ColorPalette.smashedPumpkin500,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),

            SizedBox(width: SpacePalette.sm),

            // ステータスバッジ
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.inner,
                vertical: SpacePalette.xs,
              ),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: Text(
                status,
                style: TextStylePalette.miniTitle.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
