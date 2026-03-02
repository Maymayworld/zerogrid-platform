import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Ensure a Stripe Customer exists for this user
  Future<String> ensureStripeCustomer() async {
    final response = await _supabase.functions.invoke(
      'stripe-customer',
      body: {},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to create Stripe customer: $error');
    }
    return response.data['customer_id'] as String;
  }

  /// Create a Stripe Checkout Session for deposit
  Future<Map<String, String>> createCheckoutSession({
    required int amount,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final response = await _supabase.functions.invoke(
      'stripe-checkout-session',
      body: {
        'mode': 'payment',
        'amount': amount,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      },
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to create checkout session: $error');
    }
    return {
      'checkout_url': response.data['checkout_url'] as String,
      'session_id': response.data['session_id'] as String,
    };
  }

  /// Create a Stripe Checkout Session for saving a card (setup mode)
  Future<String> createSetupCheckoutSession({
    required String successUrl,
    required String cancelUrl,
  }) async {
    final response = await _supabase.functions.invoke(
      'stripe-checkout-session',
      body: {
        'mode': 'setup',
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      },
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to create setup session: $error');
    }
    return response.data['checkout_url'] as String;
  }

  /// List saved payment methods
  Future<List<PaymentMethodModel>> listPaymentMethods() async {
    final response = await _supabase.functions.invoke(
      'stripe-payment-methods',
      body: {'action': 'list'},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to list payment methods: $error');
    }
    final methods = response.data['payment_methods'] as List;
    return methods
        .map((m) => PaymentMethodModel.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Remove a payment method
  Future<void> detachPaymentMethod(String paymentMethodId) async {
    final response = await _supabase.functions.invoke(
      'stripe-payment-methods',
      body: {'action': 'detach', 'payment_method_id': paymentMethodId},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to remove payment method: $error');
    }
  }

  /// Set a payment method as default
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    final response = await _supabase.functions.invoke(
      'stripe-payment-methods',
      body: {'action': 'set_default', 'payment_method_id': paymentMethodId},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to set default payment method: $error');
    }
  }

  /// Confirm deposit server-side (supports both payment_intent_id and checkout_session_id)
  Future<int> confirmDeposit(String paymentIntentId) async {
    final response = await _supabase.functions.invoke(
      'stripe-confirm-deposit',
      body: {'payment_intent_id': paymentIntentId},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to confirm deposit: $error');
    }
    return (response.data['new_balance'] as num).toInt();
  }

  /// Confirm deposit via Checkout Session ID (after redirect back)
  Future<int> confirmCheckoutDeposit(String checkoutSessionId) async {
    final response = await _supabase.functions.invoke(
      'stripe-confirm-deposit',
      body: {'checkout_session_id': checkoutSessionId},
    );
    if (response.status != 200) {
      final error = response.data is Map ? response.data['error'] : 'Unknown error';
      throw Exception('Failed to confirm deposit: $error');
    }
    return (response.data['new_balance'] as num).toInt();
  }

  /// Get current balance from profiles
  Future<int> getBalance() async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('profiles')
        .select('balance')
        .eq('id', _userId!)
        .single();

    return (response['balance'] as num?)?.toInt() ?? 0;
  }

  /// Get transaction history
  Future<List<WalletTransaction>> getTransactions({int limit = 50}) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((t) => WalletTransaction.fromMap(Map<String, dynamic>.from(t)))
        .toList();
  }
}
