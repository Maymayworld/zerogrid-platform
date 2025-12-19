// lib/widgets/project/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import 'detail_screen.dart';
import '../chat/presentation/chat_screen.dart';
import 'download_screen.dart';
import 'upload_screen.dart';

class ProjectMenuScreen extends HookWidget {
  final String? imageUrl;
  final String projectName;
  final int creatorCount;
  final double currentAmount;
  final double totalAmount;
  final double pricePerView;
  final int viewCount;

  const ProjectMenuScreen({
    Key? key,
    this.imageUrl,
    this.projectName = 'Project Name',
    this.creatorCount = 16,
    this.currentAmount = 1000,
    this.totalAmount = 4000,
    this.pricePerView = 1,
    this.viewCount = 400,
  }) : super(key: key);

  String _getImageUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'placeholder') {
      return imageUrl!;
    }
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  @override
  Widget build(BuildContext context) {
    final progress = currentAmount / totalAmount;
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorPalette.neutral800,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: SpacePalette.base),
                  Text(
                    'Back',
                    style: TextStylePalette.normalText
                  ),
                ],
              ),
            ),
            // メインコンテンツ
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name & Creators
                      Row(
                        children: [
                          // クリエイターアバターグループ
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: Stack(
                              children: List.generate(3, (index) {
                                return Positioned(
                                  left: index * 20.0,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: ColorPalette.neutral400,
                                    backgroundImage: NetworkImage(
                                      'https://i.pravatar.cc/150?img=${index + 1}',
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(width: SpacePalette.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projectName,
                                  style: TextStylePalette.lgListTitle
                                ),
                                Text(
                                  '$creatorCount creators',
                                  style: TextStylePalette.lgListLeading
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // 画像（タップ可能）
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailScreen(
                                imageUrl: _getImageUrl(),
                                projectName: projectName,
                                pricePerView: pricePerView,
                                viewCount: viewCount,
                                currentAmount: currentAmount,
                                totalAmount: totalAmount,
                                showAddReview: true, // menu_screenから遷移した場合
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              _getImageUrl(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: ColorPalette.neutral0,
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: ColorPalette.neutral400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // 金額とプログレスバー
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${currentAmount.toInt()} / \$${totalAmount.toInt()}',
                            style: TextStylePalette.miniTitle
                          ),
                          Text(
                            '$percentage%',
                            style: TextStylePalette.normalText
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.sm),
                      // プログレスバー
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: ColorPalette.neutral200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorPalette.systemGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.lg),
                      
                      // チャットボックス（横並び）
                      Row(
                        children: [
                          Expanded(
                            child: _ChatBox(
                              icon: Icons.group,
                              label: 'Group Chat',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectChatScreen(
                                      projectName: projectName,
                                      memberCount: creatorCount,
                                      onlineCount: 5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: SpacePalette.base),
                          Expanded(
                            child: _ChatBox(
                              icon: Icons.person,
                              label: '1-on-1 Chat',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectChatScreen(
                                      projectName: projectName,
                                      memberCount: 2, // 1-on-1なので2人
                                      onlineCount: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Download Project Files
                      _ActionSection(
                        icon: Icons.download,
                        title: 'Download Project Files',
                        subtitle: '6 items',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDownloadScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Submit Your Video
                      _ActionSection(
                        icon: Icons.upload,
                        title: 'Submit Your Video',
                        subtitle: '1 video uploaded',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectUploadScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 100), // フッター分の余白
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// チャットボックス（正方形）
class _ChatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChatBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // 正方形
        child: Container(
          decoration: BoxDecoration(
            color: ColorPalette.neutral0,
            borderRadius: BorderRadius.circular(RadiusPalette.base),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: ColorPalette.neutral800,
              ),
              SizedBox(height: SpacePalette.sm),
              Text(
                label,
                style: TextStylePalette.listTitle
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// アクションセクション
class _ActionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.neutral0,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: ColorPalette.neutral800,
            ),
            SizedBox(width: SpacePalette.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStylePalette.listTitle
                  ),
                  Text(
                    subtitle,
                    style: TextStylePalette.listLeading
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: ColorPalette.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}