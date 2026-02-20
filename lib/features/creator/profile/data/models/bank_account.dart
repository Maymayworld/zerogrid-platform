import 'dart:math';

class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String branchName;
  final String accountType;
  final String accountNumber;
  final String accountHolder;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.branchName,
    required this.accountType,
    required this.accountNumber,
    required this.accountHolder,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bankName: map['bank_name'] as String,
      branchName: map['branch_name'] as String,
      accountType: map['account_type'] as String,
      accountNumber: map['account_number'] as String,
      accountHolder: map['account_holder'] as String,
      isVerified: map['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_type': accountType,
      'account_number': accountNumber,
      'account_holder': accountHolder,
    };
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final last4 = accountNumber.substring(max(0, accountNumber.length - 4));
    return '****$last4';
  }

  String get displayAccountType {
    switch (accountType) {
      case 'ordinary':
        return 'Ordinary';
      case 'checking':
        return 'Checking';
      case 'savings':
        return 'Savings';
      default:
        return accountType;
    }
  }
}
