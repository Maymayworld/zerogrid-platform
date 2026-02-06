// lib/features/creator/submission/data/models/submission.dart

class Submission {
  final String id;
  final String userId;
  final String? campaignId;
  final String caption;
  final Map<String, dynamic> mediaAssets;
  final DateTime? scheduleAt;
  final String status; // draft, submitted, approved, rejected
  final String? storageProvider;
  final String? r2Key;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined profile data (for organizer review)
  final String? creatorUsername;
  final String? creatorDisplayName;
  final String? creatorAvatarUrl;

  Submission({
    required this.id,
    required this.userId,
    this.campaignId,
    required this.caption,
    required this.mediaAssets,
    this.scheduleAt,
    required this.status,
    this.storageProvider,
    this.r2Key,
    this.reviewNote,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.creatorUsername,
    this.creatorDisplayName,
    this.creatorAvatarUrl,
  });

  factory Submission.fromMap(Map<String, dynamic> map) {
    // Handle joined profile data
    final profiles = map['profiles'] as Map<String, dynamic>?;

    return Submission(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      campaignId: map['campaign_id'] as String?,
      caption: map['caption'] as String? ?? '',
      mediaAssets: map['media_assets'] is Map
          ? Map<String, dynamic>.from(map['media_assets'] as Map)
          : {},
      scheduleAt: map['schedule_at'] != null
          ? DateTime.parse(map['schedule_at'] as String)
          : null,
      status: map['status'] as String? ?? 'draft',
      storageProvider: map['storage_provider'] as String?,
      r2Key: map['r2_key'] as String?,
      reviewNote: map['review_note'] as String?,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      creatorUsername: profiles?['username'] as String?,
      creatorDisplayName: profiles?['display_name'] as String?,
      creatorAvatarUrl: profiles?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'campaign_id': campaignId,
      'caption': caption,
      'media_assets': mediaAssets,
      if (scheduleAt != null) 'schedule_at': scheduleAt!.toIso8601String(),
      'status': status,
    };
  }

  /// Get video URL for a specific platform
  String? getUrlForPlatform(String platform) {
    return mediaAssets[platform.toLowerCase()] as String?;
  }

  /// Get all platform URLs as a Map<platform, url>
  Map<String, String> get platformUrls {
    final urls = <String, String>{};
    for (final entry in mediaAssets.entries) {
      if (entry.value is String && (entry.value as String).isNotEmpty) {
        urls[entry.key] = entry.value as String;
      }
    }
    return urls;
  }
}
