// lib/shared/presentation/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_notification.dart';
import '../../data/services/notification_service.dart';

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Realtime通知ストリーム
final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.watchNotifications();
});

// 未読数
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.whenOrNull(
        data: (list) => list.where((n) => !n.isRead).length,
      ) ??
      0;
});
