// lib/features/organizer/approval/presentation/providers/approval_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/approval_request.dart';
import '../../data/services/approval_service.dart';
import '../../../../../shared/data/services/notification_service.dart';

// Service provider
final approvalServiceProvider = Provider<ApprovalService>((ref) {
  return ApprovalService();
});

// 未処理リクエスト数
final pendingRequestCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(approvalServiceProvider);
  return service.watchPendingRequestCount();
});

// 未処理リクエストがあるかどうか
final hasPendingRequestsProvider = Provider<bool>((ref) {
  final countAsync = ref.watch(pendingRequestCountProvider);
  return countAsync.whenOrNull(data: (count) => count > 0) ?? false;
});

// 未処理リクエスト一覧
final pendingRequestsProvider = FutureProvider<List<ApprovalRequest>>((ref) async {
  final service = ref.watch(approvalServiceProvider);
  return service.getPendingRequests();
});

// 処理済みリクエスト一覧（履歴）
final reviewedRequestsProvider = FutureProvider<List<ApprovalRequest>>((ref) async {
  final service = ref.watch(approvalServiceProvider);
  return service.getReviewedRequests();
});

// 現在のリクエストインデックス（スワイプ用）
final currentRequestIndexProvider = StateProvider<int>((ref) => 0);

// リクエスト処理アクション
class ApprovalNotifier extends StateNotifier<AsyncValue<void>> {
  final ApprovalService _service;
  final Ref _ref;

  ApprovalNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> approve(String requestId, {ApprovalRequest? request}) async {
    state = const AsyncValue.loading();
    try {
      await _service.approveRequest(requestId);
      if (request != null) {
        await NotificationService().createNotification(
          userId: request.creatorId,
          type: 'submission_approved',
          title: 'Submission Approved',
          body: 'Your submission for "${request.campaignName}" was approved!',
          data: {'campaign_id': request.campaignId, 'campaign_name': request.campaignName},
        );
      }
      _ref.invalidate(pendingRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reject(String requestId, {ApprovalRequest? request}) async {
    state = const AsyncValue.loading();
    try {
      await _service.rejectRequest(requestId);
      if (request != null) {
        await NotificationService().createNotification(
          userId: request.creatorId,
          type: 'submission_rejected',
          title: 'Submission Rejected',
          body: 'Your submission for "${request.campaignName}" was rejected.',
          data: {'campaign_id': request.campaignId, 'campaign_name': request.campaignName},
        );
      }
      _ref.invalidate(pendingRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> skip(String requestId) async {
    state = const AsyncValue.loading();
    try {
      await _service.skipRequest(requestId);
      _ref.invalidate(pendingRequestsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final approvalNotifierProvider =
    StateNotifierProvider<ApprovalNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(approvalServiceProvider);
  return ApprovalNotifier(service, ref);
});
