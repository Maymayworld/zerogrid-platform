// lib/features/auth/data/services/oauth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthService {
  final SupabaseClient _client;

  OAuthService(this._client);

  // Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // Check if a platform is connected (returns both status and usernames)
  Future<Map<String, dynamic>> getConnectedPlatforms() async {
    final userId = currentUserId;
    if (userId == null) return {};

    try {
      final response = await _client
          .from('social_connections')
          .select('platform, platform_username')
          .eq('user_id', userId);

      final connected = <String, dynamic>{
        'youtube': false,
        'instagram': false,
        'tiktok': false,
        'google_calendar': false,
      };

      for (final row in response as List) {
        final platform = row['platform'] as String?;
        final username = row['platform_username'] as String?;
        if (platform != null) {
          connected[platform] = true;
          if (username != null) {
            connected['${platform}_username'] = username;
            // For Google Calendar, use email key
            if (platform == 'google_calendar') {
              connected['google_calendar_email'] = username;
            }
          }
        }
      }

      return connected;
    } catch (e) {
      print('Error checking connected platforms: $e');
      return {
        'youtube': false,
        'instagram': false,
        'tiktok': false,
        'google_calendar': false,
      };
    }
  }

  // Connect YouTube via Google OAuth (Edge Function)
  Future<void> connectYouTube() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.functions.invoke(
      'youtube-oauth-url',
      body: {'user_id': userId},
    );

    if (response.status != 200) {
      throw Exception('Failed to get YouTube OAuth URL');
    }

    final url = response.data['url'] as String?;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // Connect Google Calendar
  Future<void> connectGoogleCalendar() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        scopes: 'https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events',
        redirectTo: 'io.zerogrid.app://oauth-callback',
      );
    } catch (e) {
      throw Exception('Failed to connect Google Calendar: $e');
    }
  }

  // Connect Instagram via Facebook OAuth
  Future<void> connectInstagram() async {
    // Instagram requires going through Facebook OAuth
    // This will be handled via Supabase Edge Function
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Get the OAuth URL from Edge Function
    final response = await _client.functions.invoke(
      'instagram-oauth-url',
      body: {'user_id': userId},
    );

    if (response.status != 200) {
      throw Exception('Failed to get Instagram OAuth URL');
    }

    final url = response.data['url'] as String?;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // Connect TikTok
  Future<void> connectTikTok() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Get the OAuth URL from Edge Function
    final response = await _client.functions.invoke(
      'tiktok-oauth-url',
      body: {'user_id': userId},
    );

    if (response.status != 200) {
      throw Exception('Failed to get TikTok OAuth URL');
    }

    final url = response.data['url'] as String?;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // Disconnect a platform
  Future<void> disconnectPlatform(String platform) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _client
        .from('social_connections')
        .delete()
        .eq('user_id', userId)
        .eq('platform', platform);
  }

  // Get platform stats (views, etc.)
  Future<Map<String, dynamic>?> getPlatformStats(String platform) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('social_connections')
          .select('access_token, platform_user_id, platform_username')
          .eq('user_id', userId)
          .eq('platform', platform)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }
}
