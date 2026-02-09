// lib/features/creator/campaign/data/services/submission_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SubmissionService {
  final SupabaseClient _client;

  SubmissionService(this._client);

  // Create a new submission
  Future<Submission> createSubmission({
    required String campaignId,
    String? youtubeUrl,
    String? instagramUrl,
    String? tiktokUrl,
    DateTime? scheduledPostDate,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final data = {
      'campaign_id': campaignId,
      'creator_id': userId,
      'youtube_url': youtubeUrl,
      'instagram_url': instagramUrl,
      'tiktok_url': tiktokUrl,
      'scheduled_post_date': scheduledPostDate?.toIso8601String(),
      'status': 'pending',
    };

    final response = await _client
        .from('submissions')
        .insert(data)
        .select()
        .single();

    return Submission.fromMap(response);
  }

  // Get submissions for a campaign (for organizer)
  Future<List<Submission>> getSubmissionsForCampaign(String campaignId) async {
    final response = await _client
        .from('submissions')
        .select('''
          *,
          profiles:creator_id (
            name,
            avatar_url
          )
        ''')
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Submission.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Get my submissions for a campaign (for creator)
  Future<List<Submission>> getMySubmissions(String campaignId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('submissions')
        .select()
        .eq('campaign_id', campaignId)
        .eq('creator_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Submission.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Update submission (for creator - edit their own)
  Future<Submission> updateSubmission({
    required String submissionId,
    String? youtubeUrl,
    String? instagramUrl,
    String? tiktokUrl,
    DateTime? scheduledPostDate,
  }) async {
    final response = await _client
        .from('submissions')
        .update({
          'youtube_url': youtubeUrl,
          'instagram_url': instagramUrl,
          'tiktok_url': tiktokUrl,
          'scheduled_post_date': scheduledPostDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', submissionId)
        .select()
        .single();

    return Submission.fromMap(response);
  }

  // Review submission (for organizer - approve/reject)
  Future<Submission> reviewSubmission({
    required String submissionId,
    required String status, // 'approved' or 'rejected'
    String? comment,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('submissions')
        .update({
          'status': status,
          'review_comment': comment,
          'reviewed_by': userId,
          'reviewed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', submissionId)
        .select('''
          *,
          profiles:creator_id (
            name,
            avatar_url
          )
        ''')
        .single();

    return Submission.fromMap(response);
  }

  // Delete submission
  Future<void> deleteSubmission(String submissionId) async {
    await _client
        .from('submissions')
        .delete()
        .eq('id', submissionId);
  }

  // Get submission counts for a campaign
  Future<Map<String, int>> getSubmissionCounts(String campaignId) async {
    final response = await _client
        .from('submissions')
        .select('status')
        .eq('campaign_id', campaignId);

    final list = response as List;
    int pending = 0;
    int approved = 0;
    int rejected = 0;

    for (final item in list) {
      switch (item['status']) {
        case 'pending':
          pending++;
          break;
        case 'approved':
          approved++;
          break;
        case 'rejected':
          rejected++;
          break;
      }
    }

    return {
      'total': list.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
