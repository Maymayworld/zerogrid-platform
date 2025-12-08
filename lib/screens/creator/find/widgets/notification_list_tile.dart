// lib/screens/creator/find/widgets/notification_list_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';

class NotificationListTile extends StatelessWidget {
  final IconData categoryIcon;
  final String title;
  final String description;
  final String dateTime;
  final bool isUnread;

  const NotificationListTile({
    Key? key,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isUnread = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.base,
        vertical: SpacePalette.inner,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーアイコン
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              size: 20,
              color: ColorPalette.neutral800,
            ),
          ),
          SizedBox(width: SpacePalette.base),
          // タイトルと説明
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStylePalette.listTitle
                      ),
                    ),
                    // 未読インジケーター
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(left: SpacePalette.sm),
                        decoration: BoxDecoration(
                          color: ColorPalette.systemGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  description,
                  style: TextStylePalette.listLeading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: SpacePalette.sm),
          // 日時
          Text(
            dateTime,
            style: TextStylePalette.subMiniText
          ),
        ],
      ),
    );
  }
}