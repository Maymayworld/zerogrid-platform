// lib/screens/creator/find/widgets/notification_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import 'notification_list_tile.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: ColorPalette().neutral0,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AppBar風ヘッダー
            Container(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Row(
                children: [
                  // 戻るボタン
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: ColorPalette().neutral900,
                      ),
                    ),
                  ),
                  // タイトル（中央）
                  Expanded(
                    child: Center(
                      child: Text(
                        'Notification',
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.md,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette().neutral900,
                        ),
                      ),
                    ),
                  ),
                  // 右側のスペース（戻るボタンと対称にするため）
                  SizedBox(width: 40),
                ],
              ),
            ),
            // 区切り線
            Divider(
              color: ColorPalette().neutral200,
              height: 1,
              thickness: 1,
            ),
            // 通知リスト
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _mockNotifications.length,
                separatorBuilder: (context, index) => Divider(
                  color: ColorPalette().neutral200,
                  height: 1,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                itemBuilder: (context, index) {
                  final notification = _mockNotifications[index];
                  return NotificationListTile(
                    categoryIcon: notification['icon'] as IconData,
                    title: notification['title'] as String,
                    description: notification['description'] as String,
                    dateTime: notification['dateTime'] as String,
                    isUnread: notification['isUnread'] as bool,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// モックデータ
final List<Map<String, dynamic>> _mockNotifications = [
  {
    'icon': Icons.grid_view_outlined,
    'title': 'Category',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': true,
  },
  {
    'icon': Icons.grid_view_outlined,
    'title': 'Category',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': true,
  },
  {
    'icon': Icons.grid_view_outlined,
    'title': 'Category',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': true,
  },
  {
    'icon': Icons.error_outline,
    'title': 'Project Name',
    'description': 'Your project has reached 75% of the target\nYou have a remaining budget of ¥1,000 to use.',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': false,
  },
  {
    'icon': Icons.grid_view_outlined,
    'title': 'Category',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': false,
  },
  {
    'icon': Icons.notifications_outlined,
    'title': 'Project Name',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': false,
  },
  {
    'icon': Icons.grid_view_outlined,
    'title': 'Category',
    'description': 'Title\nDescription',
    'dateTime': 'Nov 28, 2025 09:41 PM',
    'isUnread': false,
  },
];