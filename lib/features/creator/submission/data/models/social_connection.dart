// lib/features/creator/submission/data/models/social_connection.dart

class SocialConnection {
  final String id;
  final String userId;
  final String provider; // youtube, instagram, tiktok
  final String providerAccountId;
  final String? providerAccountName;
  final String? accessToken;
  final DateTime? accessTokenExpiresAt;
  final String refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final int tokenVersion;
  final String status; // connected, disconnected, expired
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialConnection({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerAccountId,
    this.providerAccountName,
    this.accessToken,
    this.accessTokenExpiresAt,
    required this.refreshToken,
    this.refreshTokenExpiresAt,
    this.tokenVersion = 1,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialConnection.fromMap(Map<String, dynamic> map) {
    return SocialConnection(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      provider: map['provider'] as String,
      providerAccountId: map['provider_account_id'] as String,
      providerAccountName: map['provider_account_name'] as String?,
      accessToken: map['access_token'] as String?,
      accessTokenExpiresAt: map['access_token_expires_at'] != null
          ? DateTime.parse(map['access_token_expires_at'] as String)
          : null,
      refreshToken: map['refresh_token'] as String,
      refreshTokenExpiresAt: map['refresh_token_expires_at'] != null
          ? DateTime.parse(map['refresh_token_expires_at'] as String)
          : null,
      tokenVersion: map['token_version'] as int? ?? 1,
      status: map['status'] as String? ?? 'connected',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  bool get isConnected => status == 'connected';

  bool get isExpired => status == 'expired';

  bool get isTokenExpired {
    if (accessTokenExpiresAt == null) return false;
    return DateTime.now().isAfter(accessTokenExpiresAt!);
  }

  /// Token expires within 7 days
  bool get isExpiringSoon {
    if (accessTokenExpiresAt == null) return false;
    final daysLeft = accessTokenExpiresAt!.difference(DateTime.now()).inDays;
    return daysLeft > 0 && daysLeft <= 7;
  }

  /// Needs reconnection (server marked expired or token actually expired)
  bool get needsReconnect => isExpired || isTokenExpired;
}
