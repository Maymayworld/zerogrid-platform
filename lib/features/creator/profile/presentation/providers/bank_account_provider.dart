import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/bank_account.dart';
import '../../data/services/bank_account_service.dart';

final bankAccountServiceProvider = Provider<BankAccountService>((ref) {
  return BankAccountService();
});

final bankAccountProvider = StateProvider<BankAccount?>((ref) => null);

final bankAccountLoadingProvider = StateProvider<bool>((ref) => false);
