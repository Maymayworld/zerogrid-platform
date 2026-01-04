// lib/features/creator/project/presentation/widgets/project_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl; // オプショナルに変更
  final IconData platformIcon;
  final double currentAmount;
  final double totalAmount;
  final double pricePerView;
  final int viewCount;
  final int participants;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const ProjectCard({
    Key? key,
    required this.width,
    required this.height,
    this.imageUrl, // オプショナル
    required this.platformIcon,
    required this.currentAmount,
    required this.totalAmount,
    required this.pricePerView,
    required this.viewCount,
    required this.participants,
    required this.onTap,
    required this.onLike,
  }) : super(key: key);

  // 画像URLを決定（Unsplashランダム画像対応）
  String _getImageUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'placeholder') {
      return imageUrl!;
    }
    // Unsplashランダム画像（Lorem Picsum使用）
    // ※ Unsplash Source (source.unsplash.com) は2024年に廃止されたため
    // Lorem Picsumを使用。実際のUnsplashを使う場合はAPI keyが必要です。
    // カードごとに異なるが安定した画像を表示するためhashCodeを使用
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  @override
  Widget build(BuildContext context) {
    final progress = currentAmount / totalAmount;
    final percentage = (progress * 100).toInt();
    final displayImageUrl = _getImageUrl();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景画像（16:9）
            Image.network(
              displayImageUrl,
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
            // グラデーションオーバーレイ（下部50%のみ、中央から下部へ）
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center, // 中央から開始
                  end: Alignment.bottomCenter, // 下部で終了
                  colors: [
                    Colors.transparent, // 中央は透明
                    ColorPalette.neutral800, // 下部はneutral800
                  ],
                ),
              ),
            ),
            // プラットフォームアイコン（左上）
            Positioned(
              top: SpacePalette.sm,
              left: SpacePalette.sm,
              child: Container(
                padding: EdgeInsets.all(SpacePalette.sm),
                decoration: BoxDecoration(
                  color: ColorPalette.neutral800.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  platformIcon,
                  color: ColorPalette.neutral100,
                  size: 12,
                ),
              ),
            ),
            // 下部情報
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(SpacePalette.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 金額と参加者（プログレスバーの上）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 金額
                        Text(
                          '\$${currentAmount.toInt()} / \$${totalAmount.toInt()} ($percentage%)',
                          style: TextStylePalette.miniTitle.copyWith(
                            color: ColorPalette.neutral100
                          )
                        ),
                        // 参加者アイコン（Stackで重ねる）
                        SizedBox(
                          width: participants.clamp(0, 3) * 14.0 + 6,
                          height: 20,
                          child: Stack(
                            children: List.generate(
                              participants.clamp(0, 3),
                              (index) => Positioned(
                                left: index * 14.0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.neutral400,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ColorPalette.neutral100,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 10,
                                    color: ColorPalette.neutral100,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    // プログレスバー
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: ColorPalette.systemGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.sm),
                    // ボタン
                    Row(
                      children: [
                        // 案件詳細ボタン
                        Expanded(
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: ColorPalette.neutral100,
                                borderRadius: BorderRadius.circular(RadiusPalette.base),
                              ),
                              child: Center(
                                child: Text(
                                  '\$$pricePerView / 1000 views',
                                  style: TextStylePalette.buttonTextBlack
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SpacePalette.sm),
                        // いいねボタン
                        GestureDetector(
                          onTap: onLike,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: ColorPalette.neutral100, width: 2),
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: ColorPalette.neutral100,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}