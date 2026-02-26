// lib/features/creator/feed/data/services/feed_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../creator/submission/data/models/submission.dart';

class FeedService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 承認済みYouTube動画を全件取得（フィード用）
  Future<List<Submission>> getFeedSubmissions() async {
    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          profiles:creator_id (display_name, avatar_url),
          campaigns:campaign_id (name)
        ''')
        .eq('platform', 'youtube')
        .eq('status', 'approved')
        .order('submitted_at', ascending: false);

    return (response as List).map((map) {
      return Submission.fromMap({
        ...map,
        'creator_name': map['profiles']?['display_name'],
        'creator_avatar_url': map['profiles']?['avatar_url'],
        'campaign_name': map['campaigns']?['name'],
      });
    }).toList();
  }

  /// いいね済みの提出IDリストを取得
  Future<Set<String>> getLikedSubmissionIds() async {
    if (_userId == null) return {};

    final response = await _supabase
        .from('feed_likes')
        .select('submission_id')
        .eq('user_id', _userId!);

    return (response as List)
        .map((row) => row['submission_id'] as String)
        .toSet();
  }

  /// いいねトグル
  Future<bool> toggleLike(String submissionId) async {
    if (_userId == null) throw Exception('User not logged in');

    // 既にいいねしてるか確認
    final existing = await _supabase
        .from('feed_likes')
        .select('id')
        .eq('user_id', _userId!)
        .eq('submission_id', submissionId)
        .limit(1);

    if ((existing as List).isNotEmpty) {
      // いいね解除
      await _supabase
          .from('feed_likes')
          .delete()
          .eq('user_id', _userId!)
          .eq('submission_id', submissionId);
      return false;
    } else {
      // いいね
      await _supabase.from('feed_likes').insert({
        'user_id': _userId!,
        'submission_id': submissionId,
      });
      return true;
    }
  }

  /// 特定ユーザーのYouTube投稿一覧（プロフィール用）
  Future<List<Submission>> getUserYouTubeSubmissions(String userId) async {
    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          campaigns:campaign_id (name)
        ''')
        .eq('creator_id', userId)
        .eq('platform', 'youtube')
        .eq('status', 'approved')
        .order('submitted_at', ascending: false);

    return (response as List).map((map) {
      return Submission.fromMap({
        ...map,
        'campaign_name': map['campaigns']?['name'],
      });
    }).toList();
  }

  /// いいねしたYouTube動画一覧（プロフィール用）
  Future<List<Submission>> getLikedYouTubeSubmissions() async {
    if (_userId == null) return [];

    final likeResponse = await _supabase
        .from('feed_likes')
        .select('submission_id')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    final likedIds = (likeResponse as List)
        .map((row) => row['submission_id'] as String)
        .toList();

    if (likedIds.isEmpty) return [];

    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          profiles:creator_id (display_name, avatar_url),
          campaigns:campaign_id (name)
        ''')
        .inFilter('id', likedIds)
        .eq('platform', 'youtube')
        .eq('status', 'approved');

    return (response as List).map((map) {
      return Submission.fromMap({
        ...map,
        'creator_name': map['profiles']?['display_name'],
        'creator_avatar_url': map['profiles']?['avatar_url'],
        'campaign_name': map['campaigns']?['name'],
      });
    }).toList();
  }
}
