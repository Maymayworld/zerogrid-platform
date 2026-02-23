// lib/features/creator/campaign/data/models/campaign_review.dart

class CampaignReview {
  final String id;
  final String campaignId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  // profiles join data
  final String? reviewerName;
  final String? reviewerAvatarUrl;

  const CampaignReview({
    required this.id,
    required this.campaignId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
  });

  factory CampaignReview.fromMap(Map<String, dynamic> map) {
    // profiles join がある場合
    final profile = map['profiles'] as Map<String, dynamic>?;

    return CampaignReview(
      id: map['id'] as String,
      campaignId: map['campaign_id'] as String,
      userId: map['user_id'] as String,
      rating: (map['rating'] as num).toInt(),
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      reviewerName: profile?['display_name'] as String?,
      reviewerAvatarUrl: profile?['avatar_url'] as String?,
    );
  }
}
