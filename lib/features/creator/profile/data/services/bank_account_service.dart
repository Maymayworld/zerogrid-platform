import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_account.dart';

class BankAccountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<BankAccount?> getBankAccount() async {
    if (_userId == null) return null;

    final response = await _supabase
        .from('bank_accounts')
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();

    if (response == null) return null;
    return BankAccount.fromMap(response);
  }

  Future<BankAccount> saveBankAccount({
    required String bankName,
    required String branchName,
    required String accountType,
    required String accountNumber,
    required String accountHolder,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final data = {
      'user_id': _userId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_type': accountType,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('bank_accounts')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();

    return BankAccount.fromMap(response);
  }

  Future<void> deleteBankAccount() async {
    if (_userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('bank_accounts')
        .delete()
        .eq('user_id', _userId!);
  }
}
