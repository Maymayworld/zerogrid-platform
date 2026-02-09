// lib/features/auth/presentation/providers/oauth_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/oauth_service.dart';

final oAuthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService(Supabase.instance.client);
});

// Alias for backwards compatibility
final oauthServiceProvider = oAuthServiceProvider;

// Provider to track connected platforms (includes usernames)
final connectedPlatformsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final oauthService = ref.read(oAuthServiceProvider);
  return oauthService.getConnectedPlatforms();
});
