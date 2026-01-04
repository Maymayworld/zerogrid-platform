// lib/screens/find/find_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/theme/app_theme.dart';
import '../project/presentation/widgets/project_card.dart';
import '../../../shared/widgets/common_search_bar.dart';
import 'widgets/notification_sheet.dart';
import '../project/presentation/pages/detail_screen.dart';
import 'widgets/filter_chip_widget.dart';

class FindScreen extends HookWidget {
  const FindScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedFilterIndex = useState<int>(0); // デフォルトでAll(0)を選択
    final bannerPageController = usePageController();
    final currentPage = useState(0);
    final scrollController = FixedExtentScrollController();

    // 画面構成
    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
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
                        style: TextStylePalette.title.copyWith(color: ColorPalette.neutral0),
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
                        isScrollControlled: true, // 画面最大まで開く
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
            // 広告バナー（手動スワイプ）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: SizedBox(
                height: 144,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: bannerPageController,
                      onPageChanged: (index) {
                        currentPage.value = index;
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral0,
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Center(
                            child: Text(
                              'Ad Banner ${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: FontSizePalette.size16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // ページインジケーター
                    Positioned(
                      bottom: 24,
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
                              color: currentPage.value == index
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
                      FilterButton(
                        icon: Icons.all_inclusive,
                        label: 'All',
                        isSelected: selectedFilterIndex.value == 0,
                        onTap: () => selectedFilterIndex.value = 0,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      FilterButton(
                        icon: Icons.video_library,
                        label: 'Video',
                        isSelected: selectedFilterIndex.value == 1,
                        onTap: () => selectedFilterIndex.value = 1,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      FilterButton(
                        icon: Icons.image,
                        label: 'Photo',
                        isSelected: selectedFilterIndex.value == 2,
                        onTap: () => selectedFilterIndex.value = 2,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      FilterButton(
                        icon: Icons.music_note,
                        label: 'Music',
                        isSelected: selectedFilterIndex.value == 3,
                        onTap: () => selectedFilterIndex.value = 3,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      FilterButton(
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
                            imageUrl: 'https://picsum.photos/seed/find-$index/400/225', // indexベースで固定
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