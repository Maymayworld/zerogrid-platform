// lib/shared/presentation/providers/chat_service_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});