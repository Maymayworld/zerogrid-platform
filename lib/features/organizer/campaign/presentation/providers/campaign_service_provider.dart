// lib/features/organizer/campaign/presentation/providers/campaign_service_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/campaign_service.dart';

final campaignServiceProvider = Provider<CampaignService>((ref) {
  return CampaignService();
});