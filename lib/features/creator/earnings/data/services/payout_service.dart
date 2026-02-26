// lib/features/creator/earnings/data/services/payout_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectStatus {
  final bool hasConnect;
  final bool payoutsEnabled;
  final bool detailsSubmitted;

  const ConnectStatus({
    this.hasConnect = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
  });

  factory ConnectStatus.fromJson(Map<String, dynamic> json) {
    return ConnectStatus(
      hasConnect: json['has_connect'] as bool? ?? false,
      payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
      detailsSubmitted: json['details_submitted'] as bool? ?? false,
    );
  }
}

class PayoutService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Stripe Connect オンボーディングURLを取得
  Future<String> getOnboardingUrl({String? returnUrl}) async {
    final response = await _supabase.functions.invoke(
      'stripe-connect-onboarding',
      body: {'return_url': returnUrl},
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Failed to start onboarding';
      throw Exception(error);
    }

    return response.data['onboarding_url'] as String;
  }

  /// Connect アカウントの状態を取得
  Future<ConnectStatus> getConnectStatus() async {
    final response = await _supabase.functions.invoke(
      'stripe-connect-status',
      body: {},
    );

    if (response.status != 200) {
      return const ConnectStatus();
    }

    return ConnectStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// 出金を実行
  Future<int> withdraw(int amount) async {
    final response = await _supabase.functions.invoke(
      'stripe-withdrawal',
      body: {'amount': amount},
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Withdrawal failed';
      throw Exception(error);
    }

    return response.data['new_balance'] as int;
  }
}
