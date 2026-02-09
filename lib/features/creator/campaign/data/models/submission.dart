// lib/features/creator/campaign/data/models/submission.dart

class Submission {
  final String id;
  final String campaignId;
  final String creatorId;
  final String? youtubeUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final DateTime? scheduledPostDate;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewComment;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional: creator profile data (joined)
  final String? creatorName;
  final String? creatorAvatarUrl;

  const Submission({
    required this.id,
    required this.campaignId,
    required this.creatorId,
    this.youtubeUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.scheduledPostDate,
    required this.status,
    this.reviewComment,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.creatorName,
    this.creatorAvatarUrl,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  int get platformCount {
    int count = 0;
    if (youtubeUrl != null && youtubeUrl!.isNotEmpty) count++;
    if (instagramUrl != null && instagramUrl!.isNotEmpty) count++;
    if (tiktokUrl != null && tiktokUrl!.isNotEmpty) count++;
    return count;
  }

  List<String> get platforms {
    final list = <String>[];
    if (youtubeUrl != null && youtubeUrl!.isNotEmpty) list.add('YouTube');
    if (instagramUrl != null && instagramUrl!.isNotEmpty) list.add('Instagram');
    if (tiktokUrl != null && tiktokUrl!.isNotEmpty) list.add('TikTok');
    return list;
  }

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'] as String,
      campaignId: map['campaign_id'] as String,
      creatorId: map['creator_id'] as String,
      youtubeUrl: map['youtube_url'] as String?,
      instagramUrl: map['instagram_url'] as String?,
      tiktokUrl: map['tiktok_url'] as String?,
      scheduledPostDate: map['scheduled_post_date'] != null
          ? DateTime.parse(map['scheduled_post_date'] as String)
          : null,
      status: map['status'] as String? ?? 'pending',
      reviewComment: map['review_comment'] as String?,
      reviewedBy: map['reviewed_by'] as String?,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      // Joined profile data
      creatorName: map['profiles']?['name'] as String?,
      creatorAvatarUrl: map['profiles']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'campaign_id': campaignId,
      'creator_id': creatorId,
      'youtube_url': youtubeUrl,
      'instagram_url': instagramUrl,
      'tiktok_url': tiktokUrl,
      'scheduled_post_date': scheduledPostDate?.toIso8601String(),
      'status': status,
    };
  }

  Submission copyWith({
    String? id,
    String? campaignId,
    String? creatorId,
    String? youtubeUrl,
    String? instagramUrl,
    String? tiktokUrl,
    DateTime? scheduledPostDate,
    String? status,
    String? reviewComment,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorName,
    String? creatorAvatarUrl,
  }) {
    return Submission(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      creatorId: creatorId ?? this.creatorId,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      scheduledPostDate: scheduledPostDate ?? this.scheduledPostDate,
      status: status ?? this.status,
      reviewComment: reviewComment ?? this.reviewComment,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
    );
  }
}
