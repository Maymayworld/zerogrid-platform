// lib/features/creator/submission/data/services/submission_service.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';
import '../../../../../shared/data/services/notification_service.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Create a new submission request for a campaign (URL-based, legacy)
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

    // Organizerに提出通知を送る
    if (submissions.isNotEmpty) {
      await _sendSubmissionNotification(campaignId, organizerId);
    }

    return submissions;
  }

  /// Create a file-based submission (video upload)
  Future<Submission> createFileSubmission({
    required String campaignId,
    required String organizerId,
    required Uint8List videoBytes,
    required String fileName,
    required List<String> targetPlatforms,
    Uint8List? thumbnailBytes,
    String? caption,
    int? videoDuration,
    void Function(double progress)? onProgress,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName.split('.').last.toLowerCase();
    final videoPath = '$_userId/${timestamp}_video.$ext';

    // 1. Upload video to Supabase Storage
    onProgress?.call(0.1);

    await _supabase.storage.from('videos').uploadBinary(
      videoPath,
      videoBytes,
      fileOptions: FileOptions(
        contentType: _getVideoContentType(ext),
        upsert: true,
      ),
    );

    onProgress?.call(0.6);

    final videoUrl = _supabase.storage.from('videos').getPublicUrl(videoPath);

    // 2. Upload thumbnail if provided
    String? thumbnailUrl;
    if (thumbnailBytes != null) {
      final thumbPath = '$_userId/${timestamp}_thumb.jpg';
      await _supabase.storage.from('thumbnails').uploadBinary(
        thumbPath,
        thumbnailBytes,
        fileOptions: FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );
      thumbnailUrl = _supabase.storage.from('thumbnails').getPublicUrl(thumbPath);
    }

    onProgress?.call(0.8);

    // 3. Create submission record(s) for each target platform
    final primaryPlatform = targetPlatforms.isNotEmpty
        ? targetPlatforms.first.toLowerCase()
        : 'youtube';

    final response = await _supabase.from('submission_requests').insert({
      'campaign_id': campaignId,
      'creator_id': _userId,
      'organizer_id': organizerId,
      'platform': primaryPlatform,
      'video_title': caption ?? '',
      'video_thumbnail_url': thumbnailUrl,
      'local_video_url': videoUrl,
      'video_file_size': videoBytes.length,
      'video_duration': videoDuration,
      'upload_status': 'completed',
      'status': 'pending',
    }).select().single();

    onProgress?.call(1.0);

    // Organizerに通知
    await _sendSubmissionNotification(campaignId, organizerId);

    return Submission.fromMap(response);
  }

  String _getVideoContentType(String ext) {
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      default:
        return 'video/mp4';
    }
  }

  Future<void> _sendSubmissionNotification(String campaignId, String organizerId) async {
    try {
      final campaignResponse = await _supabase
          .from('campaigns')
          .select('name')
          .eq('id', campaignId)
          .limit(1);
      final campaignName = (campaignResponse as List).isNotEmpty
          ? campaignResponse[0]['name'] as String? ?? ''
          : '';

      final creatorProfile = await _supabase
          .from('profiles')
          .select('display_name')
          .eq('id', _userId!)
          .limit(1);
      final creatorName = (creatorProfile as List).isNotEmpty
          ? creatorProfile[0]['display_name'] as String? ?? 'A creator'
          : 'A creator';

      await NotificationService().createNotification(
        userId: organizerId,
        type: 'submission_created',
        title: 'New Submission',
        body: '$creatorName submitted content for "$campaignName"',
        data: {'campaign_id': campaignId, 'campaign_name': campaignName},
      );
    } catch (_) {}
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

  /// Get all submissions for a campaign (for organizer review)
  Future<List<Submission>> getCampaignSubmissions(String campaignId) async {
    final response = await _supabase
        .from('submission_requests')
        .select('''
          *,
          profiles:creator_id (display_name, avatar_url)
        ''')
        .eq('campaign_id', campaignId)
        .order('submitted_at', ascending: false);

    return (response as List).map((map) {
      return Submission.fromMap({
        ...map,
        'creator_name': map['profiles']?['display_name'],
        'creator_avatar_url': map['profiles']?['avatar_url'],
      });
    }).toList();
  }

  /// Update submission status (approve/reject)
  /// If approved and submission has a local video, triggers auto-posting to SNS
  Future<void> updateSubmissionStatus({
    required String submissionId,
    required String status,
    String? reviewNote,
  }) async {
    await _supabase.from('submission_requests').update({
      'status': status,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      if (reviewNote != null) 'review_note': reviewNote,
    }).eq('id', submissionId);

    // Auto-post to SNS when approved
    if (status == 'approved') {
      await _triggerAutoPost(submissionId);
    }
  }

  /// Trigger auto-posting to the target SNS platform
  Future<void> _triggerAutoPost(String submissionId) async {
    try {
      // Get the submission to check if it has a local video
      final response = await _supabase
          .from('submission_requests')
          .select('platform, local_video_url, upload_status')
          .eq('id', submissionId)
          .single();

      final localVideoUrl = response['local_video_url'] as String?;
      final platform = response['platform'] as String?;
      final uploadStatus = response['upload_status'] as String?;

      // Only auto-post if there's a local video and it hasn't been posted yet
      if (localVideoUrl == null || localVideoUrl.isEmpty) return;
      if (uploadStatus == 'posted' || uploadStatus == 'posting') return;

      // Determine which Edge Function to call
      String? functionName;
      switch (platform) {
        case 'youtube':
          functionName = 'youtube-upload';
          break;
        case 'tiktok':
          functionName = 'tiktok-upload';
          break;
        case 'instagram':
          functionName = 'instagram-upload';
          break;
      }

      if (functionName == null) return;

      // Mark as posting
      await _supabase.from('submission_requests').update({
        'upload_status': 'posting',
      }).eq('id', submissionId);

      // Trigger the upload Edge Function (fire-and-forget)
      _supabase.functions.invoke(
        functionName,
        body: {'submission_id': submissionId},
      ).then((_) {
        // Success - Edge Function updates the record itself
      }).catchError((e) {
        // Mark as failed if Edge Function call fails
        _supabase.from('submission_requests').update({
          'upload_status': 'failed',
        }).eq('id', submissionId);
      });
    } catch (e) {
      // Don't throw - auto-posting failure shouldn't block approval
      print('Auto-post trigger failed: $e');
    }
  }

  /// Update view count for a submission (called periodically)
  Future<void> updateViewCount(String submissionId, int viewCount) async {
    await _supabase.from('submission_requests').update({
      'view_count': viewCount,
    }).eq('id', submissionId);
  }
}
