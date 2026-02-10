// lib/features/creator/submission/data/services/submission_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Create a new submission for a campaign
  Future<Submission> createSubmission({
    required String campaignId,
    required Map<String, String> videoUrls,
    String caption = '',
    DateTime? scheduleAt,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    // Insert into posts table
    final response = await _supabase.from('posts').insert({
      'user_id': _userId,
      'campaign_id': campaignId,
      'caption': caption,
      'media_assets': videoUrls,
      if (scheduleAt != null) 'schedule_at': scheduleAt.toIso8601String(),
      'status': 'submitted',
    }).select().single();

    final submission = Submission.fromMap(response);

    // Create post_targets for each platform
    for (final entry in videoUrls.entries) {
      if (entry.value.isNotEmpty) {
        await _supabase.from('post_targets').insert({
          'post_id': submission.id,
          'provider': entry.key,
          'options': {'url': entry.value},
          'status': 'submitted',
        });
      }
    }

    return submission;
  }

  /// Get the current user's submissions for a specific campaign
  Future<List<Submission>> getMySubmissionsForCampaign(String campaignId) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('posts')
        .select()
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Submission.fromMap(map))
        .toList();
  }

  /// Get all submissions for a campaign (organizer view, with creator profiles)
  Future<List<Submission>> getCampaignSubmissions(String campaignId) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles!posts_user_id_fkey (
            username, display_name, avatar_url
          )
        ''')
        .eq('campaign_id', campaignId)
        .neq('status', 'draft')
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Submission.fromMap(map))
        .toList();
  }

  /// Update submission status (organizer: approve/reject)
  Future<Submission> updateSubmissionStatus({
    required String submissionId,
    required String status,
    String? reviewNote,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'reviewed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (reviewNote != null) {
      updates['review_note'] = reviewNote;
    }

    final response = await _supabase
        .from('posts')
        .update(updates)
        .eq('id', submissionId)
        .select()
        .single();

    return Submission.fromMap(response);
  }

  /// Get submission count for a campaign (for menu screen display)
  Future<int> getSubmissionCountForCampaign(String campaignId) async {
    if (_userId == null) return 0;

    final response = await _supabase
        .from('posts')
        .select('id')
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId);

    return (response as List).length;
  }
}
