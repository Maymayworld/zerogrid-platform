// lib/features/creator/submission/data/models/submission.dart

enum SubmissionStatus {
  pending,
  approved,
  rejected,
  skipped,
}

class Submission {
  final String id;
  final String campaignId;
  final String creatorId;
  final String organizerId;
  final String videoUrl;
  final String platform;
  final String? videoTitle;
  final String? videoThumbnailUrl;
  final int viewCount;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Video upload fields
  final String? localVideoUrl;
  final int? videoFileSize;
  final int? videoDuration;
  final String? uploadStatus;
  final String? platformPostId;
  final String? platformPostUrl;

  // Joined data
  final String? campaignName;
  final String? creatorName;
  final String? creatorAvatarUrl;

  Submission({
    required this.id,
    required this.campaignId,
    required this.creatorId,
    required this.organizerId,
    required this.videoUrl,
    required this.platform,
    this.videoTitle,
    this.videoThumbnailUrl,
    required this.viewCount,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNote,
    required this.createdAt,
    required this.updatedAt,
    this.localVideoUrl,
    this.videoFileSize,
    this.videoDuration,
    this.uploadStatus,
    this.platformPostId,
    this.platformPostUrl,
    this.campaignName,
    this.creatorName,
    this.creatorAvatarUrl,
  });

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'] as String,
      campaignId: map['campaign_id'] as String,
      creatorId: map['creator_id'] as String,
      organizerId: map['organizer_id'] as String,
      videoUrl: map['video_url'] as String? ?? '',
      platform: map['platform'] as String? ?? 'youtube',
      videoTitle: map['video_title'] as String?,
      videoThumbnailUrl: map['video_thumbnail_url'] as String?,
      viewCount: map['view_count'] as int? ?? 0,
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      submittedAt: DateTime.parse(map['submitted_at'] as String),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      reviewNote: map['review_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      localVideoUrl: map['local_video_url'] as String?,
      videoFileSize: (map['video_file_size'] as num?)?.toInt(),
      videoDuration: (map['video_duration'] as num?)?.toInt(),
      uploadStatus: map['upload_status'] as String?,
      platformPostId: map['platform_post_id'] as String?,
      platformPostUrl: map['platform_post_url'] as String?,
      campaignName: map['campaign_name'] as String?,
      creatorName: map['creator_name'] as String?,
      creatorAvatarUrl: map['creator_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'creator_id': creatorId,
      'organizer_id': organizerId,
      'video_url': videoUrl.isEmpty ? null : videoUrl,
      'platform': platform,
      'video_title': videoTitle,
      'video_thumbnail_url': videoThumbnailUrl,
      'view_count': viewCount,
      'status': status.name,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_note': reviewNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'local_video_url': localVideoUrl,
      'video_file_size': videoFileSize,
      'video_duration': videoDuration,
      'upload_status': uploadStatus,
      'platform_post_id': platformPostId,
      'platform_post_url': platformPostUrl,
    };
  }

  Submission copyWith({
    String? id,
    String? campaignId,
    String? creatorId,
    String? organizerId,
    String? videoUrl,
    String? platform,
    String? videoTitle,
    String? videoThumbnailUrl,
    int? viewCount,
    SubmissionStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? localVideoUrl,
    int? videoFileSize,
    int? videoDuration,
    String? uploadStatus,
    String? platformPostId,
    String? platformPostUrl,
    String? campaignName,
    String? creatorName,
    String? creatorAvatarUrl,
  }) {
    return Submission(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      creatorId: creatorId ?? this.creatorId,
      organizerId: organizerId ?? this.organizerId,
      videoUrl: videoUrl ?? this.videoUrl,
      platform: platform ?? this.platform,
      videoTitle: videoTitle ?? this.videoTitle,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      viewCount: viewCount ?? this.viewCount,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localVideoUrl: localVideoUrl ?? this.localVideoUrl,
      videoFileSize: videoFileSize ?? this.videoFileSize,
      videoDuration: videoDuration ?? this.videoDuration,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      platformPostId: platformPostId ?? this.platformPostId,
      platformPostUrl: platformPostUrl ?? this.platformPostUrl,
      campaignName: campaignName ?? this.campaignName,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
    );
  }

  /// The best available video URL for playback
  String? get playableUrl => localVideoUrl ?? platformPostUrl ?? (videoUrl.isNotEmpty ? videoUrl : null);

  /// Whether this submission has a locally uploaded video
  bool get hasLocalVideo => localVideoUrl != null && localVideoUrl!.isNotEmpty;

  /// Whether this is a YouTube URL submission
  bool get isYouTubeUrl => platform == 'youtube' && videoUrl.isNotEmpty && !hasLocalVideo;

  /// Get platform display name
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'instagram':
        return 'Instagram';
      default:
        return platform;
    }
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case SubmissionStatus.pending:
        return 'Pending Review';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.skipped:
        return 'Skipped';
    }
  }

  /// Check if submission is still pending
  bool get isPending => status == SubmissionStatus.pending;

  /// Check if submission was approved
  bool get isApproved => status == SubmissionStatus.approved;

  /// Format view count for display
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  /// Format file size for display
  String get formattedFileSize {
    if (videoFileSize == null) return '';
    final mb = videoFileSize! / (1024 * 1024);
    if (mb >= 1000) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Format duration for display
  String get formattedDuration {
    if (videoDuration == null) return '';
    final minutes = videoDuration! ~/ 60;
    final seconds = videoDuration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
