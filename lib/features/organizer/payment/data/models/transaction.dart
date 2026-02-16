class WalletTransaction {
  final String id;
  final String userId;
  final String type;
  final int amount;
  final int balanceAfter;
  final String? stripePaymentIntentId;
  final String? campaignId;
  final String? description;
  final String status;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.stripePaymentIntentId,
    this.campaignId,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toInt(),
      balanceAfter: (map['balance_after'] as num).toInt(),
      stripePaymentIntentId: map['stripe_payment_intent_id'] as String?,
      campaignId: map['campaign_id'] as String?,
      description: map['description'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isCredit => amount > 0;

  String get typeLabel {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'campaign_charge':
        return 'Campaign Payment';
      case 'payout':
        return 'Payout';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }
}
