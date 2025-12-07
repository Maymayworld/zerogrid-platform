// lib/screens/find/find_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/project_card.dart';
import '../../../widgets/common_search_bar.dart';
import 'widgets/notification_sheet.dart';
import '../../../widgets/project/detail_screen.dart';

class FindScreen extends HookWidget {
  const FindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedFilterIndex = useState<int>(0); // デフォルトでAll(0)を選択
    final bannerIndex = useState(0);
    final scrollController = FixedExtentScrollController();

    // 自動バナースライド
    useEffect(() {
      final timer = Future.delayed(Duration(seconds: 3), () {
        if (bannerIndex.value < 2) {
          bannerIndex.value++;
        } else {
          bannerIndex.value = 0;
        }
      });
      return null;
    }, [bannerIndex.value]);

    // 画面構成
    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  // ロゴ（仮アイコン）
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'ZG',
                        style: TextStyle(
                          color: backgroundColor,
                          fontSize: FontSizePalette.md,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  // 検索バー（共通Widget使用）
                  Expanded(
                    child: CommonSearchBar(),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  // 通知ボタン（ボーダーなし）
                  GestureDetector(
                    onTap: () {
                      // 通知シートが開く
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => NotificationSheet(),
                      );
                    },
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color: ColorPalette.neutral800,
                    ),
                  ),
                ],
              ),
            ),
            // 広告バナー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Container(
                height: 144,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral100,
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Ad Banner ${bannerIndex.value + 1}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: FontSizePalette.md,
                        ),
                      ),
                    ),
                    // ページインジケーター
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bannerIndex.value == index
                                  ? ColorPalette.neutral800
                                  : ColorPalette.neutral400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: SpacePalette.base),
            // フィルターチップ（左揃え）
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        icon: Icons.all_inclusive,
                        label: 'All',
                        isSelected: selectedFilterIndex.value == 0,
                        onTap: () => selectedFilterIndex.value = 0,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _FilterChip(
                        icon: Icons.video_library,
                        label: 'Video',
                        isSelected: selectedFilterIndex.value == 1,
                        onTap: () => selectedFilterIndex.value = 1,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _FilterChip(
                        icon: Icons.image,
                        label: 'Photo',
                        isSelected: selectedFilterIndex.value == 2,
                        onTap: () => selectedFilterIndex.value = 2,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _FilterChip(
                        icon: Icons.music_note,
                        label: 'Music',
                        isSelected: selectedFilterIndex.value == 3,
                        onTap: () => selectedFilterIndex.value = 3,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _FilterChip(
                        icon: Icons.lightbulb_outline,
                        label: 'Creative',
                        isSelected: selectedFilterIndex.value == 4,
                        onTap: () => selectedFilterIndex.value = 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.base),
            // 案件リスト（ドラムロール風に回転半径を大きく）
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cardWidth = screenWidth - 32; // 左右16pxずつのpadding
                  final cardHeight = cardWidth * 9 / 16;
                  
                  return ListWheelScrollView.useDelegate(
                    controller: scrollController,
                    itemExtent: cardHeight + 8, // カードの高さ + 間隔
                    diameterRatio: 2, // 回転半径を大きく（デフォルト2.0から1.0に）
                    perspective: 0.002, // 遠近感を調整
                    physics: FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: 0,
                          ),
                          child: ProjectCard(
                            width: cardWidth,
                            height: cardHeight,
                            // imageUrlを省略 → ランダム画像
                            platformIcon: Icons.music_note,
                            currentAmount: 1000,
                            totalAmount: 4000,
                            pricePerView: 1,
                            viewCount: 400,
                            participants: 3,
                            onTap: () {
                              // 直接detail_screenに遷移（showAddReview=false）
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(
                                    projectName: 'Project Name ${index + 1}',
                                    pricePerView: 300,
                                    viewCount: 400,
                                    currentAmount: 1000,
                                    totalAmount: 4000,
                                    showAddReview: false, // FindScreenからはJoinボタン
                                  ),
                                ),
                              );
                            },
                            onLike: () {
                              print('Project $index liked');
                            },
                          ),
                        );
                      },
                      childCount: 10,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 80), // フッター分の余白
          ],
        ),
      ),
    );
  }
}

// あとでWidgetsに分離
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 36, // 高さを固定
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 10,
          vertical: 0, // 縦方向のpaddingは0に（高さで調整）
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral100,
          borderRadius: BorderRadius.circular(RadiusPalette.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? ColorPalette.neutral100 : ColorPalette.neutral800,
            ),
            if (isSelected) ...[
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorPalette.neutral0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}