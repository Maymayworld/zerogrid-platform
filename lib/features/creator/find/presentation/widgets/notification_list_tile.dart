// lib/features/creator/find/presentation/widgets/notification_list_tile.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/data/models/app_notification.dart';

class NotificationListTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationListTile({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.inner,
        ),
        color: notification.isRead ? null : ColorPalette.smashedPumpkin600.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カテゴリーアイコン
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(notification.type),
                size: 20,
                color: _getIconColor(notification.type),
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
                          notification.title,
                          style: TextStylePalette.listTitle,
                        ),
                      ),
                      // 未読インジケーター
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(left: SpacePalette.sm),
                          decoration: BoxDecoration(
                            color: ColorPalette.smashedPumpkin600,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    notification.body,
                    style: TextStylePalette.listLeading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: SpacePalette.sm),
            // 相対時間
            Text(
              _formatRelativeTime(notification.createdAt),
              style: TextStylePalette.smSubText,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'campaign_joined':
        return PhosphorIconsRegular.userPlus;
      case 'submission_created':
        return PhosphorIconsRegular.uploadSimple;
      case 'submission_approved':
        return PhosphorIconsRegular.checkCircle;
      case 'submission_rejected':
        return PhosphorIconsRegular.xCircle;
      case 'new_message':
        return PhosphorIconsRegular.chatCircle;
      case 'news':
        return PhosphorIconsRegular.megaphone;
      case 'reward_received':
        return PhosphorIconsRegular.money;
      case 'new_participation':
        return PhosphorIconsRegular.userPlus;
      case 'new_submission':
        return PhosphorIconsRegular.filmStrip;
      case 'campaign_completed':
        return PhosphorIconsRegular.flag;
      default:
        return PhosphorIconsRegular.bell;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'campaign_joined':
        return ColorPalette.smashedPumpkin600;
      case 'submission_created':
        return ColorPalette.neutral800;
      case 'submission_approved':
        return ColorPalette.positive500;
      case 'submission_rejected':
        return ColorPalette.critical500;
      case 'new_message':
        return ColorPalette.neutral800;
      case 'news':
        return ColorPalette.smashedPumpkin600;
      case 'reward_received':
        return ColorPalette.positive500;
      case 'new_participation':
        return ColorPalette.smashedPumpkin600;
      case 'new_submission':
        return ColorPalette.neutral800;
      case 'campaign_completed':
        return ColorPalette.positive500;
      default:
        return ColorPalette.neutral500;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
