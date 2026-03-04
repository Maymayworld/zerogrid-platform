// lib/features/creator/campaign/presentation/widgets/project_card.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';

class ProjectCard extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final List<String> platforms;
  final int currentViews;
  final int targetViews;
  final double pricePerView;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const ProjectCard({
    Key? key,
    required this.width,
    required this.height,
    this.imageUrl,
    required this.platforms,
    required this.currentViews,
    required this.targetViews,
    required this.pricePerView,
    this.isLiked = false,
    required this.onTap,
    required this.onLike,
  }) : super(key: key);

  String _getImageUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'placeholder') {
      return imageUrl!;
    }
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  @override
  Widget build(BuildContext context) {
    final progress = targetViews > 0 ? currentViews / targetViews : 0.0;
    final percentage = (progress * 100).toInt();
    final displayImageUrl = _getImageUrl();

    String formatNumber(int n) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

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
            // 背景画像
            Image.network(
              displayImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: ColorPalette.neutral400,
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
            // グラデーションオーバーレイ
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, ColorPalette.neutral800],
                ),
              ),
            ),
            // プラットフォームアイコン（左上）
            Positioned(
              top: SpacePalette.sm,
              left: SpacePalette.sm,
              child: _buildPlatformIcons(),
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
                    // 視聴回数
                    Text(
                      '${formatNumber(currentViews)} / ${formatNumber(targetViews)} views ($percentage%)',
                      style: TextStylePalette.miniTitle.copyWith(
                        color: ColorPalette.neutral100,
                      ),
                    ),
                    SizedBox(height: 6),
                    // プログレスバー（パンプキンオレンジ）
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
                              color: ColorPalette.smashedPumpkin600,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.sm),
                    // ボタン（Duolingoスタイル・押下アニメーション付き）
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Expanded(
                            child: _CardDuolingoButton(
                              onPressed: onTap,
                              child: Text(
                                '¥${pricePerView.toStringAsFixed(1)} / 1000 views',
                                style: TextStylePalette.buttonTextBlack,
                              ),
                            ),
                          ),
                          SizedBox(width: SpacePalette.sm),
                          _CardDuolingoCircleButton(
                            onPressed: onLike,
                            icon: isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            iconColor: isLiked
                                ? ColorPalette.critical500
                                : ColorPalette.neutral800,
                          ),
                        ],
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

  /// プラットフォームアイコンを放射状グラデーション背景で表示
  /// 複数プラットフォームの場合は重なって表示（左が上）
  Widget _buildPlatformIcons() {
    if (platforms.isEmpty) {
      return _buildSinglePlatformIcon(
        Icon(Icons.video_library, size: 14, color: ColorPalette.neutral800),
      );
    }

    if (platforms.length == 1) {
      return _buildSinglePlatformIcon(
        PlatformIcon.fromPlatform(platforms[0], size: 14),
      );
    }

    // 複数プラットフォーム：16px間隔で重なって表示
    final iconSize = 24.0;
    final spacing = 16.0;
    final totalWidth = iconSize + (platforms.length - 1) * spacing;

    return SizedBox(
      width: totalWidth,
      height: iconSize,
      child: Stack(
        children: [
          // 右から左の順に描画（左のアイコンが上に来る）
          for (int i = platforms.length - 1; i >= 0; i--)
            Positioned(
              left: i * spacing,
              child: _buildSinglePlatformIcon(
                PlatformIcon.fromPlatform(platforms[i], size: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSinglePlatformIcon(Widget icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFD4D4D4)],
          stops: [0.5, 1.0],
        ),
      ),
      child: Center(child: icon),
    );
  }
}

/// viewsボタン（角丸full、白Duolingoスタイル・押下アニメーション付き）
class _CardDuolingoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _CardDuolingoButton({required this.onPressed, required this.child});

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
              left: 0,
              right: 0,
              bottom: 0,
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
              left: 0,
              right: 0,
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

/// いいねボタン（円形Duolingoスタイル・押下アニメーション付き）
class _CardDuolingoCircleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;

  const _CardDuolingoCircleButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_CardDuolingoCircleButton> createState() =>
      _CardDuolingoCircleButtonState();
}

class _CardDuolingoCircleButtonState extends State<_CardDuolingoCircleButton> {
  bool _isPressed = false;

  static const double shadowOffset = 4.0;
  static const double buttonSize = 40.0;

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
        width: buttonSize,
        height: buttonSize + shadowOffset,
        child: Stack(
          children: [
            // シャドウ
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // サーフェス（押下時に下にずれて影が隠れる）
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              left: 0,
              right: 0,
              top: _isPressed ? shadowOffset : 0,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorPalette.neutral200),
                ),
                child: Center(
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
