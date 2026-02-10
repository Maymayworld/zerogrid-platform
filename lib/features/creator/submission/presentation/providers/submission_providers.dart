// lib/features/creator/submission/presentation/providers/submission_providers.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/submission_service.dart';
import '../../data/services/social_connection_service.dart';
import '../../data/models/social_connection.dart';

final submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SubmissionService();
});

final socialConnectionServiceProvider = Provider<SocialConnectionService>((ref) {
  return SocialConnectionService();
});

/// Cache of connected provider names for quick UI checks
final connectedProvidersProvider = StateProvider<Set<String>>((ref) => {});

/// Full connection objects for detailed display
final socialConnectionsProvider = StateProvider<List<SocialConnection>>((ref) => []);
