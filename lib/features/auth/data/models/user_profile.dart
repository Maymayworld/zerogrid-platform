// lib/features/auth/data/models/user_profile.dart

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  // Supabaseのレスポンスから変換
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['display_name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}