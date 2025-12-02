class Event {
  final String id;
  final String name;
  final DateTime date;
  final String venue;
  final int totalTickets;
  final int soldTickets;
  final String status; // '開催中' | '開催予定' | '終了'
  final String staffPasscode; // スタッフ認証用パスコード
  final SecuritySettings security;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.venue,
    required this.totalTickets,
    required this.soldTickets,
    required this.status,
    required this.staffPasscode,
    required this.security,
  });

  // 販売率を計算
  double get salesPercentage {
    if (totalTickets == 0) return 0.0;
    return (soldTickets / totalTickets) * 100;
  }

  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? venue,
    int? totalTickets,
    int? soldTickets,
    String? status,
    String? staffPasscode,
    SecuritySettings? security,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      totalTickets: totalTickets ?? this.totalTickets,
      soldTickets: soldTickets ?? this.soldTickets,
      status: status ?? this.status,
      staffPasscode: staffPasscode ?? this.staffPasscode,
      security: security ?? this.security,
    );
  }
}

class SecuritySettings {
  final bool ticketSignature; // チケット署名
  final bool bleEncryption; // BLE通信暗号化
  final bool publicKeyDistribution; // 公開鍵配布

  SecuritySettings({
    this.ticketSignature = true,
    this.bleEncryption = true,
    this.publicKeyDistribution = false,
  });

  SecuritySettings copyWith({
    bool? ticketSignature,
    bool? bleEncryption,
    bool? publicKeyDistribution,
  }) {
    return SecuritySettings(
      ticketSignature: ticketSignature ?? this.ticketSignature,
      bleEncryption: bleEncryption ?? this.bleEncryption,
      publicKeyDistribution: publicKeyDistribution ?? this.publicKeyDistribution,
    );
  }
}