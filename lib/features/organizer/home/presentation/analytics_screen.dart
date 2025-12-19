// lib/screens/organizer/home/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';

class AnalyticsScreen extends HookWidget {
  final String projectName;
  final String budget;

  const AnalyticsScreen({
    Key? key,
    required this.projectName,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = useState('Today');
    final selectedPlatform = useState('YouTube');
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          projectName,
          style: TextStylePalette.title,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Spent Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SpacePalette.base),
              color: ColorPalette.neutral800,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SpacePalette.base),
                    Text(
                      'Total Spent',
                      style: TextStylePalette.normalText.copyWith(
                        color: ColorPalette.neutral100
                      )
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Text(
                      '¥40,000',
                      style: TextStylePalette.header.copyWith(color: ColorPalette.neutral100),
                    ),
                    SizedBox(height: SpacePalette.base),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: SpacePalette.base),
            
            // Views Analysis Section
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Views Analysis',
                        style: TextStylePalette.title,
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
                  
                  Text(
                    'Total Views',
                    style: TextStylePalette.smSubTitle,
                  ),
                  
                  SizedBox(height: SpacePalette.sm),
                  
                  Row(
                    children: [
                      Text(
                        '96,513',
                        style: TextStylePalette.title,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Text(
                        '+18%',
                        style: TextStylePalette.guide.copyWith(
                          color: ColorPalette.systemGreen,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // グラフ
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
                              FlSpot(0, 30000),
                              FlSpot(0.5, 50000),
                              FlSpot(1, 35000),
                              FlSpot(1.5, 75000),
                              FlSpot(2, 85000),
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
                        maxY: 100000,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: SpacePalette.lg),
                  
                  Divider(color: ColorPalette.neutral200, height: 1),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // View Ranking Section
                  Text(
                    'View Ranking',
                    style: TextStylePalette.title,
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPeriod.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Today',
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: 'Yesterday',
                                child: Text('Yesterday'),
                              ),
                              DropdownMenuItem(
                                value: 'This Week',
                                child: Text('This Week'),
                              ),
                              DropdownMenuItem(
                                value: 'This Month',
                                child: Text('This Month'),
                              ),
                              DropdownMenuItem(
                                value: 'This Year',
                                child: Text('This Year'),
                              ),
                              DropdownMenuItem(
                                value: 'All Time',
                                child: Text('All Time'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPlatform.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPlatform.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'YouTube',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: SpacePalette.xs),
                                    Text('YouTube'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'TikTok',
                                child: Text('TikTok'),
                              ),
                              DropdownMenuItem(
                                value: 'Instagram',
                                child: Text('Instagram'),
                              ),
                              DropdownMenuItem(
                                value: 'Facebook',
                                child: Text('Facebook'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // Ranking Header
                  Row(
                    children: [
                      SizedBox(width: 30),
                      Text(
                        'User',
                        style: TextStylePalette.smSubTitle,
                      ),
                      Spacer(),
                      Text(
                        'Views',
                        style: TextStylePalette.smSubTitle,
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // Ranking List
                  _RankingItem(
                    rank: 1,
                    username: 'youtube.com/zenitsu',
                    views: '10,230,781',
                  ),
                  _RankingItem(
                    rank: 2,
                    username: 'youtube.com/nagumoyoichi',
                    views: '741,995',
                  ),
                  _RankingItem(
                    rank: 3,
                    username: 'youtube.com/turbogramy',
                    views: '230,781',
                  ),
                  
                  SizedBox(height: SpacePalette.lg),
                  
                  Divider(color: ColorPalette.neutral200, height: 1),
                  
                  SizedBox(height: SpacePalette.lg),
                  
                  // User Ranking Section
                  Text(
                    'User Ranking',
                    style: TextStylePalette.title,
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPeriod.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Today',
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: 'Yesterday',
                                child: Text('Yesterday'),
                              ),
                              DropdownMenuItem(
                                value: 'This Week',
                                child: Text('This Week'),
                              ),
                              DropdownMenuItem(
                                value: 'This Month',
                                child: Text('This Month'),
                              ),
                              DropdownMenuItem(
                                value: 'This Year',
                                child: Text('This Year'),
                              ),
                              DropdownMenuItem(
                                value: 'All Time',
                                child: Text('All Time'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPlatform.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPlatform.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'YouTube',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: SpacePalette.xs),
                                    Text('YouTube'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'TikTok',
                                child: Text('TikTok'),
                              ),
                              DropdownMenuItem(
                                value: 'Instagram',
                                child: Text('Instagram'),
                              ),
                              DropdownMenuItem(
                                value: 'Facebook',
                                child: Text('Facebook'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // User Ranking Header
                  Row(
                    children: [
                      SizedBox(width: 30),
                      Text(
                        'User',
                        style: TextStylePalette.smSubTitle,
                      ),
                      Spacer(),
                      Text(
                        'Views',
                        style: TextStylePalette.smSubTitle,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // User Ranking List
                  _UserRankingItem(
                    rank: 1,
                    username: '@Qmxnzkqxmqx',
                    views: '10,230,781',
                  ),
                  _UserRankingItem(
                    rank: 2,
                    username: '@Lkwqnzkxqmx',
                    views: '9,741,995',
                  ),
                  _UserRankingItem(
                    rank: 3,
                    username: '@Bmxznkxqxmx',
                    views: '8,230,781',
                  ),
                  
                  SizedBox(height: SpacePalette.lg),
                  
                  Divider(color: ColorPalette.neutral200, height: 1),
                  
                  SizedBox(height: SpacePalette.lg),
                  
                  // Most Viral Video Section
                  Text(
                    'Most Viral Video',
                    style: TextStylePalette.title,
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPeriod.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'Today',
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: 'Yesterday',
                                child: Text('Yesterday'),
                              ),
                              DropdownMenuItem(
                                value: 'This Week',
                                child: Text('This Week'),
                              ),
                              DropdownMenuItem(
                                value: 'This Month',
                                child: Text('This Month'),
                              ),
                              DropdownMenuItem(
                                value: 'This Year',
                                child: Text('This Year'),
                              ),
                              DropdownMenuItem(
                                value: 'All Time',
                                child: Text('All Time'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Expanded(
                        child: Container(
                          height: ButtonSizePalette.filter,
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPlatform.value,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ColorPalette.neutral800,
                            ),
                            style: TextStylePalette.smText,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPlatform.value = value;
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'YouTube',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: SpacePalette.xs),
                                    Text('YouTube'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'TikTok',
                                child: Text('TikTok'),
                              ),
                              DropdownMenuItem(
                                value: 'Instagram',
                                child: Text('Instagram'),
                              ),
                              DropdownMenuItem(
                                value: 'Facebook',
                                child: Text('Facebook'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: SpacePalette.base),
                  
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Views',
                              style: TextStylePalette.smSubTitle,
                            ),
                            SizedBox(height: SpacePalette.sm),
                            Row(
                              children: [
                                Text(
                                  '64,912',
                                  style: TextStylePalette.title,
                                ),
                                SizedBox(width: SpacePalette.sm),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 12,
                                      color: ColorPalette.systemGreen,
                                    ),
                                    Text(
                                      '+21.9%',
                                      style: TextStylePalette.guide.copyWith(
                                        color: ColorPalette.systemGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: SpacePalette.base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Earnings',
                              style: TextStylePalette.smSubTitle,
                            ),
                            SizedBox(height: SpacePalette.sm),
                            Text(
                              '¥300,000',
                              style: TextStylePalette.title,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPeriodMenu(BuildContext context, ValueNotifier<String> selectedPeriod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorPalette.neutral0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(SpacePalette.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PeriodMenuItem(
              label: 'Daily',
              isSelected: selectedPeriod.value == 'Daily',
              onTap: () {
                selectedPeriod.value = 'Daily';
                Navigator.pop(context);
              },
            ),
            _PeriodMenuItem(
              label: 'Weekly',
              isSelected: selectedPeriod.value == 'Weekly',
              onTap: () {
                selectedPeriod.value = 'Weekly';
                Navigator.pop(context);
              },
            ),
            _PeriodMenuItem(
              label: 'Monthly',
              isSelected: selectedPeriod.value == 'Monthly',
              onTap: () {
                selectedPeriod.value = 'Monthly';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final String username;
  final String views;

  const _RankingItem({
    required this.rank,
    required this.username,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ColorPalette.neutral200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStylePalette.miniTitle.copyWith(
                  color: ColorPalette.neutral800,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: SpacePalette.sm),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorPalette.neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: ColorPalette.neutral400, size: 20),
          ),
          SizedBox(width: SpacePalette.inner),
          Expanded(
            child: Text(
              username,
              style: TextStylePalette.normalText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: SpacePalette.sm),
          Text(
            views,
            style: TextStylePalette.smTitle,
          ),
        ],
      ),
    );
  }
}

class _UserRankingItem extends StatelessWidget {
  final int rank;
  final String username;
  final String views;

  const _UserRankingItem({
    required this.rank,
    required this.username,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStylePalette.smSubTitle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: SpacePalette.sm),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorPalette.neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: ColorPalette.neutral400, size: 20),
          ),
          SizedBox(width: SpacePalette.inner),
          Expanded(
            child: Text(
              username,
              style: TextStylePalette.normalText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: SpacePalette.sm),
          Text(
            views,
            style: TextStylePalette.smTitle,
          ),
        ],
      ),
    );
  }
}

class _PeriodMenuItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodMenuItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
        child: Row(
          children: [
            Text(
              label,
              style: TextStylePalette.listTitle.copyWith(
                color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral500,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(Icons.check, color: ColorPalette.neutral800, size: 20),
          ],
        ),
      ),
    );
  }
}