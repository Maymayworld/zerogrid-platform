// lib/features/organizer/campaign/presentation/widgets/campaign_card.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';

class OrganizerCampaignCard extends StatelessWidget {
  final double width;
  final double height;
  final String campaignName;
  final int budget;
  final String? imageUrl;
  final VoidCallback onEdit;

  const OrganizerCampaignCard({
    Key? key,
    required this.width,
    required this.height,
    required this.campaignName,
    required this.budget,
    this.imageUrl,
    required this.onEdit,
  }) : super(key: key);

  // 画像URLを決定
  String _getImageUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'placeholder') {
      return imageUrl!;
    }
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  @override
  Widget build(BuildContext context) {
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
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ColorPalette.neutral800,
                  ],
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
                    // プロジェクト名
                    Text(
                      campaignName,
                      style: TextStylePalette.miniTitle.copyWith(
                        color: ColorPalette.neutral100,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: SpacePalette.xs),
                    // 予算
                    Text(
                      '¥${budget.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} total spent',
                      style: TextStylePalette.miniTitle.copyWith(
                        color: ColorPalette.neutral100,
                        fontSize: FontSizePalette.size12,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                    // Editボタン（フル幅）
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral800,
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                        child: Center(
                          child: Text(
                            'Edit',
                            style: TextStylePalette.buttonTextWhite,
                          ),
                        ),
                      ),
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