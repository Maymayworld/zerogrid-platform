// lib/features/creator/campaign/presentation/providers/review_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/review_service.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});
