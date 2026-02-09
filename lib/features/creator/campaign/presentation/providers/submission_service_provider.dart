// lib/features/creator/campaign/presentation/providers/submission_service_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/submission_service.dart';

final submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SubmissionService(Supabase.instance.client);
});
