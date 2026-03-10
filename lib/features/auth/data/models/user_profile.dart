// lib/features/auth/data/models/user_profile.dart

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final String? stripeCustomerId;
  final int organizerBalance;
  final int creatorBalance;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.stripeCustomerId,
    this.organizerBalance = 0,
    this.creatorBalance = 0,
  });

  // Supabaseのレスポンスから変換（nullセーフ）
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString(),
      role: map['role']?.toString() ?? 'creator',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      stripeCustomerId: map['stripe_customer_id']?.toString(),
      organizerBalance: (map['organizer_balance'] as num?)?.toInt() ?? 0,
      creatorBalance: (map['creator_balance'] as num?)?.toInt() ?? 0,
    );
  }
}