// lib/features/organizer/approval/data/services/approval_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/approval_request.dart';
import '../../../../../shared/data/services/notification_service.dart';

class ApprovalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 未処理のリクエストを取得
  Future<List<ApprovalRequest>> getPendingRequests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          campaigns:campaign_id (name),
          profiles:creator_id (display_name, avatar_url)
        ''')
        .eq('organizer_id', userId)
        .eq('status', 'pending')
        .order('submitted_at', ascending: false);

    return (response as List).map((json) {
      return ApprovalRequest.fromJson({
        ...json,
        'campaign_name': json['campaigns']?['name'] ?? '',
        'creator_name': json['profiles']?['display_name'] ?? 'Unknown',
        'creator_avatar_url': json['profiles']?['avatar_url'] ?? '',
      });
    }).toList();
  }

  // 未処理リクエスト数を取得
  Future<int> getPendingRequestCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('submission_requests')
        .select('id')
        .eq('organizer_id', userId)
        .eq('status', 'pending');

    return (response as List).length;
  }

  // 処理済みリクエストを取得（履歴用）
  Future<List<ApprovalRequest>> getReviewedRequests({int limit = 50}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          campaigns:campaign_id (name),
          profiles:creator_id (display_name, avatar_url)
        ''')
        .eq('organizer_id', userId)
        .neq('status', 'pending')
        .order('reviewed_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) {
      return ApprovalRequest.fromJson({
        ...json,
        'campaign_name': json['campaigns']?['name'] ?? '',
        'creator_name': json['profiles']?['display_name'] ?? 'Unknown',
        'creator_avatar_url': json['profiles']?['avatar_url'] ?? '',
      });
    }).toList();
  }

  // リクエストを承認
  Future<void> approveRequest(String requestId) async {
    await _supabase.from('submission_requests').update({
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  // リクエストを却下
  Future<void> rejectRequest(String requestId) async {
    await _supabase.from('submission_requests').update({
      'status': 'rejected',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  // リクエストをスキップ（後で確認）
  Future<void> skipRequest(String requestId) async {
    await _supabase.from('submission_requests').update({
      'status': 'skipped',
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  // リアルタイム購読（新しいリクエストの通知用）
  Stream<int> watchPendingRequestCount() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _supabase
        .from('submission_requests')
        .stream(primaryKey: ['id'])
        .eq('organizer_id', userId)
        .map((data) => data.where((r) => r['status'] == 'pending').length);
  }
}
