// lib/features/organizer/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import 'analytics_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';
import '../../payment/presentation/providers/payment_provider.dart';
import 'providers/organizer_stats_provider.dart';

class HomeScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);

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
            _DashboardHeader(statusBarHeight: statusBarHeight, balance: balance),

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

  const _DashboardHeader({required this.statusBarHeight, required this.balance});

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.smashedPumpkin500,
            ColorPalette.smashedPumpkin700,
          ],
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
              Text(
                'Dashboard',
                style: TextStylePalette.header.copyWith(
                  color: ColorPalette.white,
                ),
              ),
              SizedBox(height: SpacePalette.lg),

              // Balance セクション
              Text(
                'Balance',
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
                            Icons.touch_app_outlined,
                            color: ColorPalette.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: SpacePalette.xs),
                        Text(
                          'Deposit',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalViewsAsync = ref.watch(totalViewsProvider);

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
          // ヘッダー行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cumulative Total Views',
                style: TextStylePalette.title,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SpacePalette.inner,
                  vertical: SpacePalette.xs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorPalette.neutral200),
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Row(
                  children: [
                    Text('All Time', style: TextStylePalette.smText),
                    SizedBox(width: SpacePalette.xs),
                    Icon(
                      Icons.insights,
                      size: 16,
                      color: ColorPalette.neutral600,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SpacePalette.lg),

          // Total Views ラベル
          Text(
            'Total Views',
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
              'Error',
              style: TextStylePalette.header.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.critical500,
              ),
            ),
          ),

          SizedBox(height: SpacePalette.lg),

          // グラフ（プレースホルダー）
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50000,
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
                      reservedSize: 35,
                      interval: 50000,
                      getTitlesWidget: (value, meta) {
                        String text;
                        if (value == 0) {
                          text = '0';
                        } else {
                          text = '${(value / 1000).toInt()}K';
                        }
                        return Text(
                          text,
                          style: TextStylePalette.smSubText.copyWith(
                            fontSize: 10,
                            color: ColorPalette.neutral400,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 0),
                      FlSpot(1, 0),
                      FlSpot(2, 0),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: ColorPalette.smashedPumpkin600,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
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
                maxY: 150000,
                minX: 0,
                maxX: 2,
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
            'Your Projects',
            style: TextStylePalette.title,
          ),

          SizedBox(height: SpacePalette.base),

          // テーブルヘッダー
          Row(
            children: [
              Expanded(
                child: Text(
                  'Name',
                  style: TextStylePalette.smSubTitle.copyWith(
                    color: ColorPalette.neutral500,
                  ),
                ),
              ),
              Text(
                'Status',
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
                          Icons.campaign_outlined,
                          size: 48,
                          color: ColorPalette.neutral400,
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Text(
                          'No campaigns yet',
                          style: TextStylePalette.normalText.copyWith(
                            color: ColorPalette.neutral500,
                          ),
                        ),
                        Text(
                          'Create your first campaign to get started',
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
                  'Failed to load campaigns',
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
              projectName: projectName.replaceAll('\n', ' '),
              budget: budget,
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
                          return Icon(Icons.campaign, color: ColorPalette.neutral400);
                        },
                      )
                    : Icon(Icons.campaign, color: ColorPalette.neutral400),
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
                      Icon(Icons.visibility, size: 12, color: ColorPalette.neutral400),
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
