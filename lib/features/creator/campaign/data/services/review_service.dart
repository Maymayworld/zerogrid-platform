// lib/features/creator/campaign/data/services/review_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campaign_review.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  /// キャンペーンのレビュー一覧を取得（profilesをjoin）
  Future<List<CampaignReview>> getReviews(String campaignId) async {
    final response = await _supabase
        .from('campaign_reviews')
        .select('*, profiles!campaign_reviews_user_id_profiles_fkey(display_name, avatar_url)')
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => CampaignReview.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// キャンペーンの平均評価と件数を取得
  Future<({double average, int count})> getRatingSummary(String campaignId) async {
    final response = await _supabase
        .from('campaign_reviews')
        .select('rating')
        .eq('campaign_id', campaignId);

    final ratings = (response as List).map((e) => (e['rating'] as num).toInt()).toList();
    if (ratings.isEmpty) return (average: 0.0, count: 0);

    final sum = ratings.reduce((a, b) => a + b);
    return (average: sum / ratings.length, count: ratings.length);
  }

  /// organizerの全キャンペーンの平均評価と件数を取得
  Future<({double average, int count})> getOrganizerRatingSummary(String organizerId) async {
    final response = await _supabase
        .from('campaign_reviews')
        .select('rating, campaigns!inner(organizer_id)')
        .eq('campaigns.organizer_id', organizerId);

    final ratings = (response as List).map((e) => (e['rating'] as num).toInt()).toList();
    if (ratings.isEmpty) return (average: 0.0, count: 0);

    final sum = ratings.reduce((a, b) => a + b);
    return (average: sum / ratings.length, count: ratings.length);
  }

  /// レビューを投稿
  Future<void> createReview({
    required String campaignId,
    required int rating,
    required String comment,
  }) async {
    await _supabase.from('campaign_reviews').insert({
      'campaign_id': campaignId,
      'user_id': _userId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// 自分がすでにレビュー済みかチェック
  Future<bool> hasReviewed(String campaignId) async {
    final response = await _supabase
        .from('campaign_reviews')
        .select('id')
        .eq('campaign_id', campaignId)
        .eq('user_id', _userId)
        .maybeSingle();
    return response != null;
  }
}
