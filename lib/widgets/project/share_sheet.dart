// lib/widgets/project/share_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProjectShareSheet extends StatelessWidget {
  final String projectName;
  final String imageUrl;
  final double pricePerView;
  final int viewCount;

  const ProjectShareSheet({
    Key? key,
    required this.projectName,
    required this.imageUrl,
    required this.pricePerView,
    required this.viewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.neutral0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      padding: EdgeInsets.all(SpacePalette.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // プロジェクト情報
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: SpacePalette.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectName,
                        style: TextStylePalette.bigListTitle
                      ),
                      SizedBox(height: SpacePalette.xs),
                      Text(
                        'You can earn ¥${pricePerView.toInt()} per $viewCount views...',
                        style: TextStylePalette.bigListSubTitle
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24, color: ColorPalette.neutral800),
                ),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            
            // 参加者アバター
            Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(right: SpacePalette.sm),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: ColorPalette.neutral400,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 10}'),
                          ),
                          // オンラインインジケーター（3人目のみ）
                          if (index == 2)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: ColorPalette.systemGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorPalette.neutral0,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.xs),
                      Text(
                        ['Richard\nAntezana', 'Suga\nRangel', 'Marcos and 6\n2 People', 'Jenny\nCount'][index],
                        textAlign: TextAlign.center,
                        style: TextStylePalette.tagText
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.lg),
            
            // 共有オプション
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(icon: Icons.share, label: 'Share', color: Colors.blue),
                _ShareOption(icon: Icons.message, label: 'Messages', color: Colors.green),
                _ShareOption(icon: Icons.mail, label: 'Mail', color: Colors.blue),
                _ShareOption(icon: Icons.note, label: 'Notes', color: Colors.yellow[700]!),
              ],
            ),
            SizedBox(height: SpacePalette.lg),
            
            // 下部アクション
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(icon: Icons.file_download_outlined, label: ''),
                _ActionButton(icon: Icons.favorite_border, label: ''),
                _ActionButton(icon: Icons.remove_red_eye_outlined, label: ''),
                _ActionButton(icon: Icons.menu_book, label: ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 共有オプション
class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(RadiusPalette.base),
          ),
          child: Icon(icon, color: ColorPalette.neutral0, size: 28),
        ),
        SizedBox(height: SpacePalette.xs),
        Text(
          label,
          style: TextStylePalette.tagText
        ),
      ],
    );
  }
}

// アクションボタン
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ColorPalette.neutral100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ColorPalette.neutral800, size: 24),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: SpacePalette.xs),
          Text(
            label,
            style: TextStylePalette.tagText
          ),
        ],
      ],
    );
  }
}