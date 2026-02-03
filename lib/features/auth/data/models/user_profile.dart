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
    );
  }
}