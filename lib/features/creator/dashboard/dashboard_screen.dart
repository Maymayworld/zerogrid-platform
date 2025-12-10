// lib/screens/creator/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';

class DashboardScreen extends HookWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedProject = useState<String>('Project Name');
    final selectedPeriod = useState<String>('Monthly');
    final selectedDays = useState<String>('7 days');

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                'Analytics',
                style: TextStylePalette.header
              ),
              SizedBox(height: SpacePalette.base),
              
              // プロジェクト選択とフィルター
              Row(
                children: [
                  // プロジェクト選択
                  Expanded(
                    child: _DropdownButton(
                      icon: Icons.error_outline,
                      value: selectedProject.value,
                      onTap: () {
                        // プロジェクト選択モーダル（後で実装）
                      },
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  // 期間選択
                  _DropdownButton(
                    value: selectedPeriod.value,
                    onTap: () {
                      // 期間選択モーダル（後で実装）
                    },
                  ),
                  SizedBox(width: SpacePalette.sm),
                  // 日数選択
                  _DropdownButton(
                    value: selectedDays.value,
                    onTap: () {
                      // 日数選択モーダル（後で実装）
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Earnings
              Text(
                'Earnings',
                style: TextStylePalette.smallHeader
              ),
              SizedBox(height: SpacePalette.base),
              
              // Total Views & Total Earnings
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Views',
                          style: TextStylePalette.listLeading
                        ),
                        SizedBox(height: SpacePalette.xs),
                        Row(
                          children: [
                            Text(
                              '912,400',
                              style: TextStylePalette.listTitle
                            ),
                            SizedBox(width: SpacePalette.sm),
                            Text(
                              '+31.8%',
                              style: TextStyle(
                                fontSize: FontSizePalette.size12,
                                color: ColorPalette.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStylePalette.listLeading
                        ),
                        SizedBox(height: SpacePalette.xs),
                        Text(
                          '¥300,000',
                          style: TextStylePalette.listTitle
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),
              
              // グラフ（プレースホルダー）
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral100,
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Center(
                  child: Text(
                    'Chart (Coming Soon)',
                    style: TextStylePalette.subText
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Earning History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Earning History',
                    style: TextStylePalette.smallHeader
                  ),
                  Text(
                    '45% left to be top 4%',
                    style: TextStylePalette.smSubTitle
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.sm),
              
              // プログレスバー
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.55,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.systemGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.base),
              
              // ヘッダー行
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_outline, size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            'Video',
                            style: TextStylePalette.smSubTitle
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            'Views',
                            style: TextStylePalette.smSubTitle
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.attach_money, size: 16, color: ColorPalette.neutral500),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            'Earning',
                            style: TextStylePalette.smSubTitle
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              
              // Earning List
              _EarningItem(
                imageUrl: 'https://picsum.photos/seed/1/80/80',
                views: '230 K',
                earning: '¥100 K',
              ),
              _EarningItem(
                imageUrl: 'https://picsum.photos/seed/2/80/80',
                views: '87 K',
                earning: '¥25 K',
              ),
              _EarningItem(
                imageUrl: 'https://picsum.photos/seed/3/80/80',
                views: '87 K',
                earning: '¥25 K',
              ),
              
              SizedBox(height: 80), // フッター分の余白
            ],
          ),
        ),
      ),
    );
  }
}

// ドロップダウンボタン
class _DropdownButton extends StatelessWidget {
  final IconData? icon;
  final String value;
  final VoidCallback onTap;

  const _DropdownButton({
    this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.sm,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: ColorPalette.neutral200),
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.red),
              SizedBox(width: SpacePalette.xs),
            ],
            Flexible(
              child: Text(
                value,
                style: TextStylePalette.normalText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: SpacePalette.xs),
            Icon(Icons.keyboard_arrow_down, size: 16, color: ColorPalette.neutral500),
          ],
        ),
      ),
    );
  }
}

// Earning履歴アイテム
class _EarningItem extends StatelessWidget {
  final String imageUrl;
  final String views;
  final String earning;

  const _EarningItem({
    required this.imageUrl,
    required this.views,
    required this.earning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.sm),
      padding: EdgeInsets.all(SpacePalette.sm),
      child: Row(
        children: [
          // サムネイル
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // Views
          Expanded(
            child: Text(
              views,
              style: TextStylePalette.smText
            ),
          ),
          // Earning
          Expanded(
            child: Text(
              earning,
              style: TextStylePalette.smTitle
            ),
          ),
        ],
      ),
    );
  }
}