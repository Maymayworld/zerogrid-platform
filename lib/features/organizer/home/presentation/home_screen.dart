// lib/screens/organizer/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/theme/app_theme.dart';
import 'analytics_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 170,
              color: ColorPalette.neutral800,
              child: Padding(
                padding: EdgeInsets.all(SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SpacePalette.base),
                    Text(
                      'Dashboard', 
                      style: TextStylePalette.smallHeader.copyWith(
                        color: ColorPalette.neutral0
                      )
                    ),
                    SizedBox(height: SpacePalette.lg),
                    Text(
                      'Total Spent',
                      style: TextStylePalette.normalText.copyWith(
                        color: ColorPalette.neutral0
                      )
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '¥400,500',
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.neutral0
                          )
                        ),
                        Container(
                          padding: EdgeInsets.all(SpacePalette.xs),
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral0.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SelectAmountScreen()),
                                  );
                                },
                                child: Text(
                                  'Deposit',
                                  style: TextStylePalette.smText.copyWith(
                                    color: ColorPalette.neutral0,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                children: [
                  SizedBox(height: SpacePalette.base),
                  Row(
                    children: [
                      Text(
                        'Cumulative Total Views',
                        style: TextStylePalette.title
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.xs),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorPalette.neutral200),
                          borderRadius: BorderRadius.circular(RadiusPalette.mini),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Today',
                              style: TextStylePalette.smText,
                            ),
                            SizedBox(width: SpacePalette.xs),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: ColorPalette.neutral800),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total Views',
                       style: TextStylePalette.smSubTitle
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  Row(
                    children: [
                      Text(
                        '912,400',
                        style: TextStylePalette.title
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Text(
                        '-21.9%',
                        style: TextStylePalette.guide.copyWith(
                          color: ColorPalette.systemRed
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.base),
                  // グラフ表示
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${(value / 1000).toInt()}k',
                                  style: TextStylePalette.smSubText.copyWith(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const times = ['12:00 AM', '10:00 AM', '08:00 PM'];
                                if (value.toInt() >= 0 && value.toInt() < times.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: SpacePalette.xs),
                                    child: Text(
                                      times[value.toInt()],
                                      style: TextStylePalette.smSubText.copyWith(fontSize: 10),
                                    ),
                                  );
                                }
                                return Text('');
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
                              FlSpot(0, 50000),
                              FlSpot(0.5, 70000),
                              FlSpot(1, 45000),
                              FlSpot(1.5, 95000),
                              FlSpot(2, 120000),
                            ],
                            isCurved: true,
                            color: ColorPalette.systemGreen,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: ColorPalette.systemGreen.withOpacity(0.3),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 150000,
                      ),
                    ),
                  ),
                  SizedBox(height: SpacePalette.lg),
                  Divider(
                    color: ColorPalette.neutral200,
                    height: 1,
                  ),
                  SizedBox(height: SpacePalette.base),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Projects',
                      style: TextStylePalette.title
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  Row(
                    children: [
                      Text(
                        'Name',
                        style: TextStylePalette.smSubTitle
                      ),
                      Spacer(),
                      Text(
                        'Status',
                        style: TextStylePalette.smSubTitle
                      ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.base),
                  Divider(
                    color: ColorPalette.neutral200,
                    height: 1,
                  ),
                  // プロジェクトリスト
                  _ProjectListItem(
                    imageUrl: 'assets/project1.png',
                    projectName: 'Project Armin',
                    budget: '¥100 K',
                    status: 'Active',
                    isActive: true,
                  ),
                  _ProjectListItem(
                    imageUrl: 'assets/project2.png',
                    projectName: 'Project Mikasa',
                    budget: '¥100 K',
                    status: 'Completed',
                    isActive: false,
                  ),
                  _ProjectListItem(
                    imageUrl: 'assets/project3.png',
                    projectName: 'Project Annie Leonhart',
                    budget: '¥100 K',
                    status: 'Active',
                    isActive: true,
                  ),
                  SizedBox(height: 80), // フッター分の余白
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectListItem extends StatelessWidget {
  final String imageUrl;
  final String projectName;
  final String budget;
  final String status;
  final bool isActive;

  const _ProjectListItem({
    required this.imageUrl,
    required this.projectName,
    required this.budget,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsScreen(
              projectName: projectName,
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Icon(Icons.image, color: ColorPalette.neutral400),
            ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: TextStylePalette.listTitle,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    'Budget: $budget',
                    style: TextStylePalette.listLeading,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.sm,
                vertical: SpacePalette.xs,
              ),
              decoration: BoxDecoration(
                color: isActive 
                  ? ColorPalette.systemGreen.withOpacity(0.1)
                  : ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Text(
                status,
                style: TextStylePalette.miniTitle.copyWith(
                  color: isActive 
                    ? ColorPalette.systemGreen
                    : ColorPalette.neutral500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}