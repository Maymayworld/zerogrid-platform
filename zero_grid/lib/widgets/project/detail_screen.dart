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

    return Scaffold(
      backgroundColor: ColorPalette().neutral0,
      body: Stack(
        children: [
          // メインコンテンツ
          CustomScrollView(
            slivers: [
              // ヘッダー（画像）
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: ColorPalette().neutral0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.all(SpacePalette.sm),
                    decoration: BoxDecoration(
                      color: ColorPalette().neutral800.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorPalette().neutral0,
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      _showShareSheet(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(SpacePalette.sm),
                      padding: EdgeInsets.all(SpacePalette.sm),
                      decoration: BoxDecoration(
                        color: ColorPalette().neutral800.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        color: ColorPalette().neutral0,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Details',
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.md,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette().neutral900,
                    ),
                  ),
                  centerTitle: true,
                  background: Image.network(
                    _getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: ColorPalette().neutral300,
                        child: Center(
                          child: Icon(Icons.image, size: 50, color: ColorPalette().neutral400),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // コンテンツ
              SliverToBoxAdapter(
                child: Padding(
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
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.lg,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette().neutral900,
                        ),
                      ),
                      SizedBox(height: SpacePalette.sm),
                      
                      // Price per view
                      Text(
                        '¥${pricePerView.toInt()} / ${viewCount.toString()} Views',
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.md,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette().neutral900,
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // 金額とプログレスバー
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${currentAmount.toInt()} / ¥${totalAmount.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: FontSizePalette.base,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette().neutral900,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: GoogleFonts.inter(
                              fontSize: FontSizePalette.base,
                              color: ColorPalette().neutral500,
                            ),
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
                              color: ColorPalette().neutral200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorPalette().systemGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),
                      
                      // Campaign period
                      Text(
                        'Campaign period: $campaignPeriod',
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.sm,
                          color: ColorPalette().neutral500,
                        ),
                      ),
                      SizedBox(height: SpacePalette.lg),
                      
                      // Company
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: ColorPalette().neutral900,
                            child: Text(
                              'C',
                              style: GoogleFonts.inter(
                                fontSize: FontSizePalette.md,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette().neutral0,
                              ),
                            ),
                          ),
                          SizedBox(width: SpacePalette.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyName,
                                style: GoogleFonts.inter(
                                  fontSize: FontSizePalette.md,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette().neutral900,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: SpacePalette.xs),
                                  Text(
                                    '$rating ($reviewCount reviews)',
                                    style: GoogleFonts.inter(
                                      fontSize: FontSizePalette.sm,
                                      color: ColorPalette().neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.lg),
                      
                      // Reviews
                      Text(
                        'Reviews (10)',
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.md,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette().neutral900,
                        ),
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
                      
                      SizedBox(height: 100), // ボタン分の余白
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 下部固定ボタン（JoinまたはAdd Review）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette().neutral0,
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette().neutral800.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: ButtonSizePalette.heightMd,
                  child: ElevatedButton(
                    onPressed: () {
                      if (showAddReview) {
                        _showAddReviewDialog(context);
                      } else {
                        _showSuccessScreen(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette().neutral900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.sm),
                      ),
                    ),
                    child: Text(
                      showAddReview ? 'Add Review' : 'Join',
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.md,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette().neutral0,
                      ),
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
        border: Border.all(color: ColorPalette().neutral300),
        borderRadius: BorderRadius.circular(RadiusPalette.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorPalette().neutral800),
          SizedBox(width: SpacePalette.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: FontSizePalette.xs,
              color: ColorPalette().neutral800,
            ),
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
            backgroundColor: ColorPalette().neutral300,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${hashCode % 70}'),
          ),
          SizedBox(width: SpacePalette.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorName,
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.sm,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette().neutral900,
                  ),
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  comment,
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.sm,
                    color: ColorPalette().neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}