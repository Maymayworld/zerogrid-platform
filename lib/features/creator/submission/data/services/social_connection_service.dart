// lib/features/creator/submission/data/services/social_connection_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/social_connection.dart';

class SocialConnectionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all connected accounts for current user
  Future<List<SocialConnection>> getMyConnections() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('social_connections')
        .select()
        .eq('user_id', _userId!)
        .eq('status', 'connected')
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => SocialConnection.fromMap(map))
        .toList();
  }

  /// Get connection for a specific provider
  Future<SocialConnection?> getConnection(String provider) async {
    if (_userId == null) return null;

    final response = await _supabase
        .from('social_connections')
        .select()
        .eq('user_id', _userId!)
        .eq('provider', provider.toLowerCase())
        .eq('status', 'connected')
        .maybeSingle();

    if (response == null) return null;
    return SocialConnection.fromMap(response);
  }

  /// Save a new connection after OAuth flow completes
  Future<SocialConnection> saveConnection({
    required String provider,
    required String providerAccountId,
    String? providerAccountName,
    String? accessToken,
    DateTime? accessTokenExpiresAt,
    required String refreshToken,
    DateTime? refreshTokenExpiresAt,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    // Upsert: if connection already exists for this provider, update it
    final existing = await _supabase
        .from('social_connections')
        .select('id')
        .eq('user_id', _userId!)
        .eq('provider', provider.toLowerCase())
        .maybeSingle();

    Map<String, dynamic> data = {
      'user_id': _userId,
      'provider': provider.toLowerCase(),
      'provider_account_id': providerAccountId,
      'provider_account_name': providerAccountName,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'status': 'connected',
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (accessTokenExpiresAt != null) {
      data['access_token_expires_at'] = accessTokenExpiresAt.toIso8601String();
    }
    if (refreshTokenExpiresAt != null) {
      data['refresh_token_expires_at'] = refreshTokenExpiresAt.toIso8601String();
    }

    Map<String, dynamic> response;
    if (existing != null) {
      response = await _supabase
          .from('social_connections')
          .update(data)
          .eq('id', existing['id'])
          .select()
          .single();
    } else {
      response = await _supabase
          .from('social_connections')
          .insert(data)
          .select()
          .single();
    }

    return SocialConnection.fromMap(response);
  }

  /// Disconnect a provider (soft delete)
  Future<void> disconnectProvider(String connectionId) async {
    await _supabase
        .from('social_connections')
        .update({
          'status': 'disconnected',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', connectionId);
  }

  /// Validate that a submitted URL belongs to the connected account
  /// Returns true if the URL appears to match the connected account
  bool validateUrlOwnership({
    required String url,
    required String provider,
    required String providerAccountId,
    String? providerAccountName,
  }) {
    final lowerUrl = url.toLowerCase();
    final lowerProvider = provider.toLowerCase();

    switch (lowerProvider) {
      case 'youtube':
        // Check if URL contains the channel ID or custom URL
        if (lowerUrl.contains(providerAccountId.toLowerCase())) return true;
        if (providerAccountName != null &&
            lowerUrl.contains(providerAccountName.toLowerCase())) return true;
        // YouTube URLs like youtube.com/watch?v=xxx don't contain channel info
        // so we allow them if the account is connected (basic trust)
        if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
          return true;
        }
        return false;

      case 'instagram':
        if (providerAccountName != null &&
            lowerUrl.contains(providerAccountName.toLowerCase())) return true;
        // Instagram URLs like instagram.com/reel/xxx or instagram.com/p/xxx
        if (lowerUrl.contains('instagram.com')) return true;
        return false;

      case 'tiktok':
        if (providerAccountName != null &&
            lowerUrl.contains('@${providerAccountName.toLowerCase()}')) {
          return true;
        }
        // TikTok URLs like tiktok.com/@user/video/xxx
        if (lowerUrl.contains('tiktok.com')) return true;
        return false;

      default:
        return false;
    }
  }
}
