// lib/features/organizer/campaign/presentation/widgets/campaign_card.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';

class OrganizerCampaignCard extends StatelessWidget {
  final double width;
  final double height;
  final String campaignName;
  final int budget;
  final String? imageUrl;
  final String status;
  final VoidCallback onEdit;

  const OrganizerCampaignCard({
    Key? key,
    required this.width,
    required this.height,
    required this.campaignName,
    required this.budget,
    this.imageUrl,
    required this.status,
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
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
                    child: Icon(PhosphorIconsFill.image, size: 50, color: ColorPalette.neutral400),
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
                      AppLocalizations.of(context)!.totalSpent(
                        '¥${budget.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}',
                      ),
                      style: TextStylePalette.miniTitle.copyWith(
                        color: ColorPalette.neutral100,
                        fontSize: FontSizePalette.size12,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                    if (status == 'completed')
                      // Completedラベル
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral400.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(RadiusPalette.full),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.completed,
                            style: TextStylePalette.buttonTextBlack.copyWith(
                              color: ColorPalette.white,
                            ),
                          ),
                        ),
                      )
                    else
                      // Editボタン（Duolingoスタイル・押下アニメーション付き）
                      SizedBox(
                        height: 44,
                        child: _CardDuolingoButton(
                          onPressed: onEdit,
                          child: Text(
                            AppLocalizations.of(context)!.edit,
                            style: TextStylePalette.buttonTextBlack,
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

/// Editボタン（角丸full、白Duolingoスタイル・押下アニメーション付き）
class _CardDuolingoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _CardDuolingoButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_CardDuolingoButton> createState() => _CardDuolingoButtonState();
}

class _CardDuolingoButtonState extends State<_CardDuolingoButton> {
  bool _isPressed = false;

  static const double shadowOffset = 4.0;
  static const double buttonHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: buttonHeight + shadowOffset,
        child: Stack(
          children: [
            // シャドウ
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                ),
              ),
            ),
            // サーフェス（押下時に下にずれて影が隠れる）
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              left: 0, right: 0,
              top: _isPressed ? shadowOffset : 0,
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  border: Border.all(color: ColorPalette.neutral200),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}