// lib/features/creator/find/presentation/widgets/notification_sheet.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/presentation/providers/notification_provider.dart';
import 'notification_list_tile.dart';

class NotificationSheet extends HookConsumerWidget {
  const NotificationSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: ColorPalette.neutral100,
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
                        PhosphorIconsRegular.arrowLeft,
                        size: 24,
                        color: ColorPalette.neutral800,
                      ),
                    ),
                  ),
                  // タイトル（中央）
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.notifications,
                        style: TextStylePalette.title,
                      ),
                    ),
                  ),
                  // Mark all as read ボタン
                  GestureDetector(
                    onTap: () async {
                      final service = ref.read(notificationServiceProvider);
                      await service.markAllAsRead();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        PhosphorIconsRegular.checks,
                        size: 24,
                        color: ColorPalette.neutral800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 区切り線
            Divider(
              color: ColorPalette.neutral200,
              height: 1,
              thickness: 1,
            ),
            // 通知リスト
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.bell,
                            size: 64,
                            color: ColorPalette.neutral300,
                          ),
                          SizedBox(height: SpacePalette.base),
                          Text(
                            AppLocalizations.of(context)!.noNotificationsYet,
                            style: TextStylePalette.subText,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      color: ColorPalette.neutral200,
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationListTile(
                        notification: notification,
                        onTap: () async {
                          if (!notification.isRead) {
                            final service = ref.read(notificationServiceProvider);
                            await service.markAsRead(notification.id);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: ColorPalette.neutral800,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    AppLocalizations.of(context)!.failedToLoadNotifications,
                    style: TextStylePalette.subText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
