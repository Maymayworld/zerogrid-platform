class Ticket {
  final String id;
  final String eventName;
  final String eventImage; // 画像URL or アセットパス
  final DateTime eventDate;
  final String venue;
  final String seatType;
  final String ticketNumber;
  final bool isUsed;

  Ticket({
    required this.id,
    required this.eventName,
    required this.eventImage,
    required this.eventDate,
    required this.venue,
    required this.seatType,
    required this.ticketNumber,
    this.isUsed = false,
  });

  Ticket copyWith({
    String? id,
    String? eventName,
    String? eventImage,
    DateTime? eventDate,
    String? venue,
    String? seatType,
    String? ticketNumber,
    bool? isUsed,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      eventImage: eventImage ?? this.eventImage,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      seatType: seatType ?? this.seatType,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  // QRコード用のデータ生成
  String toQrData() {
    return '$id|$ticketNumber|${eventDate.millisecondsSinceEpoch}';
  }
}