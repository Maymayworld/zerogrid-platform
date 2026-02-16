import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/payment_service.dart';
import '../../data/models/payment_method.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final walletBalanceProvider = StateProvider<int>((ref) => 0);

final paymentMethodsProvider = StateProvider<List<PaymentMethodModel>>((ref) => []);

final paymentLoadingProvider = StateProvider<bool>((ref) => false);
