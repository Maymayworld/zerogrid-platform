// lib/widgets/project/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'share_sheet.dart';
import 'success_screen.dart';

class ProjectDetailScreen extends HookWidget {
  final String? imageUrl;
  final String projectName;
  final double pricePerView;
  final int viewCount;
  final double currentAmount;
  final double totalAmount;
  final String campaignPeriod;
  final String companyName;
  final double rating;
  final int reviewCount;
  final bool showAddReview; // menu_screenから来た場合はtrue

  const ProjectDetailScreen({
    Key? key,
    this.imageUrl,
    this.projectName = 'Project Name',
    this.pricePerView = 300,
    this.viewCount = 1000,
    this.currentAmount = 1000,
    this.totalAmount = 4000,
    this.campaignPeriod = 'November 1-30, 2025',
    this.companyName = 'Company Name',
    this.rating = 4.9,
    this.reviewCount = 141,
    this.showAddReview = false, // デフォルトはfalse（Joinボタン）
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
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 9 / 16;

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Details',
          style: TextStylePalette.title
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: ColorPalette.neutral800),
            onPressed: () {
              _showShareSheet(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // メインコンテンツ
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー画像（16:9）
                SizedBox(
                  width: screenWidth,
                  height: imageHeight,
                  child: Image.network(
                    _getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: ColorPalette.neutral400,
                        child: Center(
                          child: Icon(Icons.image, size: 50, color: ColorPalette.neutral400),
                        ),
                      );
                    },
                  ),
                ),
                
                // コンテンツ
                Padding(
                  padding: EdgeInsets.all(SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // プラットフォームアイコン
                      Row(
                        children: [
                          _PlatformBadge(icon: Icons.music_note, label: 'TikTok'),
                          SizedBox(width: SpacePalette.sm),
                          _PlatformBadge(icon: Icons.camera_alt, label: 'Instagram'),
                          SizedBox(width: SpacePalette.sm),
                          _PlatformBadge(icon: Icons.play_arrow, label: 'YouTube'),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Project Name
                      Text(
                        projectName,
                        style: TextStylePalette.smallHeader
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Price per view
                      Text(
                        '¥${pricePerView.toInt()} / ${viewCount.toString()} Views',
                        style: TextStylePalette.header
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // 金額とプログレスバー
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${currentAmount.toInt()} / ¥${totalAmount.toInt()}',
                            style: TextStylePalette.bigText
                          ),
                          Text(
                            '$percentage%',
                            style: TextStylePalette.bigSubText
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
                      SizedBox(height: SpacePalette.sm),
                      
                      // Campaign period
                      Text(
                        'Campaign period: $campaignPeriod',
                        style: TextStylePalette.subMiniText
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Divider
                      Divider(
                        color: ColorPalette.neutral200,
                        height: 1,
                      ),

                      SizedBox(height: SpacePalette.base),
                      
                      // Company
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: ColorPalette.neutral800,
                            child: Text(
                              'C',
                              style: TextStylePalette.miniTitle
                            ),
                          ),
                          SizedBox(width: SpacePalette.sm),
                          Divider(
                            color: ColorPalette.neutral200,
                            height: 1,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyName,
                                style: TextStylePalette.listTitle
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: SpacePalette.xs),
                                  Text(
                                    '$rating ($reviewCount reviews)',
                                    style: TextStylePalette.listLeading
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),
                      Divider(
                        color: ColorPalette.neutral200,
                        height: 1,
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Reviews
                      Text(
                        'Reviews (10)',
                        style: TextStylePalette.title
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // レビューリスト
                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"Happy to work with you!"',
                        rating: 5,
                      ),
                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"This is a fun project 🎬 This is a fun project 🎬 This is a fun project 🎬 This is a fun project 🎬 This is a fun proj..."',
                        rating: 5,
                      ),
                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"⭐ 5 stars!!!"',
                        rating: 5,
                      ),
                      
                      SizedBox(height: 60), // ボタン分の余白
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 下部固定ボタン（JoinまたはAdd Review）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(SpacePalette.base),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: ButtonSizePalette.button,
                  child: ElevatedButton(
                    onPressed: () {
                      if (showAddReview) {
                        _showAddReviewDialog(context);
                      } else {
                        _showSuccessScreen(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.neutral800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                      ),
                    ),
                    child: Text(
                      showAddReview ? 'Add Review' : 'Join',
                      style: TextStylePalette.buttonTextWhite
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectShareSheet(
        projectName: projectName,
        imageUrl: _getImageUrl(),
        pricePerView: pricePerView,
        viewCount: viewCount,
      ),
    );
  }

  void _showSuccessScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectSuccessScreen(),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add Review feature coming soon...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// プラットフォームバッジ
class _PlatformBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlatformBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.sm,
        vertical: SpacePalette.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.neutral200),
        borderRadius: BorderRadius.circular(RadiusPalette.mini),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorPalette.neutral800),
          SizedBox(width: SpacePalette.xs),
          Text(
            label,
            style: TextStylePalette.miniText
          ),
        ],
      ),
    );
  }
}

// レビューアイテム
class _ReviewItem extends StatelessWidget {
  final String creatorName;
  final String comment;
  final int rating;

  const _ReviewItem({
    required this.creatorName,
    required this.comment,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.neutral400,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${hashCode % 70}'),
          ),
          SizedBox(width: SpacePalette.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorName,
                  style: TextStylePalette.tagText
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  comment,
                  style: TextStylePalette.miniText
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}