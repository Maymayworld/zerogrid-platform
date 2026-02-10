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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
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
      videoUrl: map['video_url'] as String,
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
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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
      'video_url': videoUrl,
      'platform': platform,
      'video_title': videoTitle,
      'video_thumbnail_url': videoThumbnailUrl,
      'view_count': viewCount,
      'status': status.name,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      campaignName: campaignName ?? this.campaignName,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
    );
  }

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
}
