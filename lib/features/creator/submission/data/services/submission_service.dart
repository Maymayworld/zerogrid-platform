// lib/features/creator/submission/data/services/submission_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Create a new submission request for a campaign
  /// Each platform URL creates a separate submission request
  Future<List<Submission>> createSubmission({
    required String campaignId,
    required String organizerId,
    required Map<String, String> videoUrls,
    Map<String, String>? videoTitles,
    Map<String, String>? videoThumbnails,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final submissions = <Submission>[];

    for (final entry in videoUrls.entries) {
      if (entry.value.isEmpty) continue;

      final platform = entry.key.toLowerCase();
      final response = await _supabase.from('submission_requests').insert({
        'campaign_id': campaignId,
        'creator_id': _userId,
        'organizer_id': organizerId,
        'video_url': entry.value,
        'platform': platform,
        'video_title': videoTitles?[entry.key] ?? '',
        'video_thumbnail_url': videoThumbnails?[entry.key],
        'status': 'pending',
      }).select().single();

      submissions.add(Submission.fromMap(response));
    }

    return submissions;
  }

  /// Get the current user's submissions for a specific campaign
  Future<List<Submission>> getMySubmissionsForCampaign(String campaignId) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('submission_requests')
        .select()
        .eq('creator_id', _userId!)
        .eq('campaign_id', campaignId)
        .order('submitted_at', ascending: false);

    return (response as List)
        .map((map) => Submission.fromMap(map))
        .toList();
  }

  /// Get all submissions by the current user
  Future<List<Submission>> getMySubmissions() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          campaigns:campaign_id (name)
        ''')
        .eq('creator_id', _userId!)
        .order('submitted_at', ascending: false);

    return (response as List).map((map) {
      return Submission.fromMap({
        ...map,
        'campaign_name': map['campaigns']?['name'] ?? '',
      });
    }).toList();
  }

  /// Get submission count for a campaign (for menu screen display)
  Future<int> getSubmissionCountForCampaign(String campaignId) async {
    if (_userId == null) return 0;

    final response = await _supabase
        .from('submission_requests')
        .select('id')
        .eq('creator_id', _userId!)
        .eq('campaign_id', campaignId);

    return (response as List).length;
  }

  /// Check if user has pending submission for a campaign
  Future<bool> hasPendingSubmission(String campaignId) async {
    if (_userId == null) return false;

    final response = await _supabase
        .from('submission_requests')
        .select('id')
        .eq('creator_id', _userId!)
        .eq('campaign_id', campaignId)
        .eq('status', 'pending')
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Get approved submissions for view count tracking
  Future<List<Submission>> getApprovedSubmissions() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('submission_requests')
        .select()
        .eq('creator_id', _userId!)
        .eq('status', 'approved')
        .order('reviewed_at', ascending: false);

    return (response as List)
        .map((map) => Submission.fromMap(map))
        .toList();
  }

  /// Update view count for a submission (called periodically)
  Future<void> updateViewCount(String submissionId, int viewCount) async {
    await _supabase.from('submission_requests').update({
      'view_count': viewCount,
    }).eq('id', submissionId);
  }
}
