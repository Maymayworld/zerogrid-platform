// lib/features/organizer/approval/data/models/approval_request.dart

enum ApprovalStatus {
  pending,
  approved,
  rejected,
  skipped,
}

class ApprovalRequest {
  final String id;
  final String campaignId;
  final String campaignName;
  final String creatorId;
  final String creatorName;
  final String creatorAvatarUrl;
  final String videoUrl;
  final String? localVideoUrl;
  final String platform; // youtube, tiktok, instagram
  final String videoTitle;
  final String? videoThumbnailUrl;
  final int viewCount;
  final DateTime submittedAt;
  final ApprovalStatus status;
  final DateTime? reviewedAt;

  ApprovalRequest({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.videoUrl,
    this.localVideoUrl,
    required this.platform,
    required this.videoTitle,
    this.videoThumbnailUrl,
    required this.viewCount,
    required this.submittedAt,
    required this.status,
    this.reviewedAt,
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] as String,
      campaignId: json['campaign_id'] as String,
      campaignName: json['campaign_name'] as String? ?? '',
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String? ?? 'Unknown',
      creatorAvatarUrl: json['creator_avatar_url'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      localVideoUrl: json['local_video_url'] as String?,
      platform: json['platform'] as String? ?? 'youtube',
      videoTitle: json['video_title'] as String? ?? '',
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      status: ApprovalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_avatar_url': creatorAvatarUrl,
      'video_url': videoUrl,
      'local_video_url': localVideoUrl,
      'platform': platform,
      'video_title': videoTitle,
      'video_thumbnail_url': videoThumbnailUrl,
      'view_count': viewCount,
      'submitted_at': submittedAt.toIso8601String(),
      'status': status.name,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  ApprovalRequest copyWith({
    String? id,
    String? campaignId,
    String? campaignName,
    String? creatorId,
    String? creatorName,
    String? creatorAvatarUrl,
    String? videoUrl,
    String? localVideoUrl,
    String? platform,
    String? videoTitle,
    String? videoThumbnailUrl,
    int? viewCount,
    DateTime? submittedAt,
    ApprovalStatus? status,
    DateTime? reviewedAt,
  }) {
    return ApprovalRequest(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      localVideoUrl: localVideoUrl ?? this.localVideoUrl,
      platform: platform ?? this.platform,
      videoTitle: videoTitle ?? this.videoTitle,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      viewCount: viewCount ?? this.viewCount,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  bool get hasLocalVideo => localVideoUrl != null && localVideoUrl!.isNotEmpty;
}
