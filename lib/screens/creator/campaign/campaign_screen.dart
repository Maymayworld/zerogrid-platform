// lib/screens/creator/campaign_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_search_bar.dart';
import '../../../widgets/project_card.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../find/widgets/notification_sheet.dart';
import '../../../widgets/project/menu_screen.dart';

class CampaignScreen extends HookWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final selectedPlatforms = useState<Set<String>>({});
    final minPay = useState<double>(0);
    final maxPay = useState<double>(500000);

    void _showFilterModal() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FilterBottomSheet(
          selectedPlatforms: selectedPlatforms.value,
          minPay: minPay.value,
          maxPay: maxPay.value,
          onApply: (platforms, min, max) {
            selectedPlatforms.value = platforms;
            minPay.value = min;
            maxPay.value = max;
          },
        ),
      );
    }

    void _showNotificationSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => NotificationSheet(),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー（検索バー + フィルター + 通知）
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  // 検索バー
                  Expanded(
                    child: CommonSearchBar(
                      controller: searchController,
                      hintText: 'Search',
                    ),
                  ),
                  SizedBox(width: SpacePalette.base),
                  // フィルターボタン（ボーダーなし）
                  GestureDetector(
                    onTap: _showFilterModal,
                    child: Icon(
                      Icons.tune,
                      size: 24,
                      color: ColorPalette.neutral800,
                    ),
                  ),
                  SizedBox(width: SpacePalette.base),
                  // 通知ボタン（ボーダーなし）
                  GestureDetector(
                    onTap: _showNotificationSheet,
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color: ColorPalette.neutral800,
                    ),
                  ),
                ],
              ),
            ),
            // 参加中のキャンペーンリスト
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cardWidth = screenWidth - (SpacePalette.base * 2);
                  final cardHeight = cardWidth * 9 / 16;

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                    itemCount: 10, // モックデータ
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: SpacePalette.base),
                        child: ProjectCard(
                          width: cardWidth,
                          height: cardHeight,
                          // imageUrlを省略 → ランダム画像
                          platformIcon: _getPlatformIcon(index),
                          currentAmount: 1000 + (index * 500),
                          totalAmount: 4000,
                          pricePerView: 1,
                          viewCount: 400 + (index * 100),
                          participants: 3,
                          onTap: () {
                            // ProjectMenuScreenに遷移
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectMenuScreen(
                                  projectName: 'Project Name ${index + 1}',
                                  creatorCount: 16 + index,
                                  currentAmount: 1000 + (index * 500),
                                  totalAmount: 4000,
                                  pricePerView: 1,
                                  viewCount: 400 + (index * 100),
                                ),
                              ),
                            );
                          },
                          onLike: () {
                            print('Campaign $index liked');
                          },
                        ),
                      );
                    },
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

  // プラットフォームアイコンをランダムに返す
  IconData _getPlatformIcon(int index) {
    final icons = [
      Icons.music_note, // TikTok
      Icons.camera_alt, // Instagram
      Icons.play_arrow, // YouTube
      Icons.image, // Photo
    ];
    return icons[index % icons.length];
  }
}