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
        .inFilter('status', ['connected', 'expired'])
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => SocialConnection.fromMap(map))
        .toList();
  }

  /// Get connection for a specific provider (first one found)
  Future<SocialConnection?> getConnection(String provider) async {
    if (_userId == null) return null;

    final response = await _supabase
        .from('social_connections')
        .select()
        .eq('user_id', _userId!)
        .eq('provider', provider.toLowerCase())
        .inFilter('status', ['connected', 'expired'])
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SocialConnection.fromMap(response);
  }

  /// Get all connections for a specific provider (multi-account)
  Future<List<SocialConnection>> getConnectionsForProvider(String provider) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('social_connections')
        .select()
        .eq('user_id', _userId!)
        .eq('provider', provider.toLowerCase())
        .inFilter('status', ['connected', 'expired'])
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => SocialConnection.fromMap(map))
        .toList();
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

    // Upsert: if same account already exists, update tokens; otherwise insert new
    final existing = await _supabase
        .from('social_connections')
        .select('id')
        .eq('user_id', _userId!)
        .eq('provider', provider.toLowerCase())
        .eq('provider_account_id', providerAccountId)
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

}
