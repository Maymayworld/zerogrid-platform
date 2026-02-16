// lib/features/organizer/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import 'analytics_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';
import '../../payment/presentation/providers/payment_provider.dart';

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
class _ViewsCard extends StatelessWidget {
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
                    Text('Today', style: TextStylePalette.smText),
                    SizedBox(width: SpacePalette.xs),
                    Icon(
                      Icons.keyboard_arrow_down,
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

          // 数値とトレンド
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '912,400',
                style: TextStylePalette.header.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: SpacePalette.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SpacePalette.sm,
                  vertical: SpacePalette.xs,
                ),
                decoration: BoxDecoration(
                  color: ColorPalette.critical50,
                  borderRadius: BorderRadius.circular(RadiusPalette.mini),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_down,
                      size: 14,
                      color: ColorPalette.critical500,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '-21,9%',
                      style: TextStylePalette.smText.copyWith(
                        color: ColorPalette.critical500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SpacePalette.lg),

          // グラフ
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
                          text = '¥0';
                        } else {
                          text = '${(value / 1000).toInt()} K';
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const times = ['12:00 AM', '10:00 AM', '08:00 PM'];
                        if (value.toInt() >= 0 && value.toInt() < times.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: SpacePalette.sm),
                            child: Text(
                              times[value.toInt()],
                              style: TextStylePalette.smSubText.copyWith(
                                fontSize: 10,
                                color: ColorPalette.neutral400,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 80000),
                      FlSpot(0.5, 90000),
                      FlSpot(1, 70000),
                      FlSpot(1.3, 140000),
                      FlSpot(1.6, 110000),
                      FlSpot(2, 50000),
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
class _ProjectsCard extends StatelessWidget {
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
          _ProjectListItem(
            imageUrl: 'assets/project1.png',
            projectName: 'Project Armin',
            budget: '¥100 K',
            status: 'Active',
            statusColor: ColorPalette.smashedPumpkin600,
            statusBgColor: ColorPalette.smashedPumpkin100,
          ),
          _ProjectListItem(
            imageUrl: 'assets/project2.png',
            projectName: 'Project Mikasa',
            budget: '¥100 K',
            status: 'Completed',
            statusColor: ColorPalette.positive500,
            statusBgColor: ColorPalette.positive50,
          ),
          _ProjectListItem(
            imageUrl: 'assets/project3.png',
            projectName: 'Project Annie\nLeonhart',
            budget: '¥100 K',
            status: 'Active',
            statusColor: ColorPalette.smashedPumpkin600,
            statusBgColor: ColorPalette.smashedPumpkin100,
          ),
        ],
      ),
    );
  }
}

class _ProjectListItem extends StatelessWidget {
  final String imageUrl;
  final String projectName;
  final String budget;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  const _ProjectListItem({
    required this.imageUrl,
    required this.projectName,
    required this.budget,
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
                child: Image.network(
                  'https://picsum.photos/seed/${projectName.hashCode}/100',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, color: ColorPalette.neutral400);
                  },
                ),
              ),
            ),

            SizedBox(width: SpacePalette.inner),

            // 名前とバジェット
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: TextStylePalette.listTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    'Budget: $budget',
                    style: TextStylePalette.listLeading.copyWith(
                      color: ColorPalette.neutral500,
                    ),
                  ),
                ],
              ),
            ),

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
