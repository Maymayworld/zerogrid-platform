// lib/screens/creator/likes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/common_search_bar.dart';
import '../project/presentation/widgets/project_card.dart';
import '../../../shared/widgets/filter_bottom_sheet.dart';
import '../find/widgets/notification_sheet.dart';
import '../project/presentation/pages/detail_screen.dart';

class LikesScreen extends HookWidget {
  const LikesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedCategory = useState<String>('All');
    final selectedPlatforms = useState<Set<String>>({});
    final minPay = useState<double>(0);
    final maxPay = useState<double>(500000);
    final searchController = useTextEditingController();

    final categories = [
      {'icon': Icons.grid_view, 'label': 'All'},
      {'icon': Icons.business_center_outlined, 'label': 'Business'},
      {'icon': Icons.music_note_outlined, 'label': 'Entertainment'},
      {'icon': Icons.music_note, 'label': 'Music'},
      {'icon': Icons.podcasts_outlined, 'label': 'Podcast'},
    ];

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
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // カテゴリーフィルター（横スクロール）
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(vertical: SpacePalette.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = selectedCategory.value == category['label'];
                    return Padding(
                      padding: EdgeInsets.only(right: SpacePalette.base),
                      child: _CategoryChip(
                        icon: category['icon'] as IconData,
                        label: category['label'] as String,
                        isSelected: isSelected,
                        onTap: () {
                          selectedCategory.value = category['label'] as String;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // 検索バー + フィルター + 通知
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
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
                ],
              ),
            ),
            SizedBox(height: SpacePalette.base),
            // タイトル
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Liked Projects',
                  style: TextStylePalette.header
                ),
              ),
            ),
            SizedBox(height: SpacePalette.base),
            // いいねした案件リスト
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
                            // 直接detail_screenに遷移（showAddReview=false）
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailScreen(
                                  projectName: 'Project Name ${index + 1}',
                                  pricePerView: 300,
                                  viewCount: 400 + (index * 100),
                                  currentAmount: 1000 + (index * 500),
                                  totalAmount: 4000,
                                  showAddReview: false, // LikesScreenからはJoinボタン
                                ),
                              ),
                            );
                          },
                          onLike: () {
                            print('Project $index unliked');
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

// カテゴリーフィルターチップ
class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
          ),
          SizedBox(height: SpacePalette.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: FontSizePalette.size12,
              color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: SpacePalette.xs),
          // アンダーライン
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: ColorPalette.neutral800,
            ),
        ],
      ),
    );
  }
}