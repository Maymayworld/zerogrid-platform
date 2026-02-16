class PaymentMethodModel {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    final card = map['card'] as Map<String, dynamic>?;
    return PaymentMethodModel(
      id: map['id'] as String,
      brand: card?['brand'] as String? ?? 'unknown',
      last4: card?['last4'] as String? ?? '****',
      expMonth: card?['exp_month'] as int? ?? 0,
      expYear: card?['exp_year'] as int? ?? 0,
      isDefault: map['is_default'] as bool? ?? false,
    );
  }

  String get displayBrand {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'AMEX';
      case 'jcb':
        return 'JCB';
      default:
        return brand.toUpperCase();
    }
  }

  String get displayName => '$displayBrand ****$last4';
  String get expiry => '${expMonth.toString().padLeft(2, '0')}/$expYear';
}
