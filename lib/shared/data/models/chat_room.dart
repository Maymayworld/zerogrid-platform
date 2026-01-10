// lib/shared/data/models/chat_room.dart

class ChatRoom {
  final String id;
  final String campaignId;
  final String type; // 'group' or 'personal'
  final String? creatorId; // personalの場合のみ
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.campaignId,
    required this.type,
    this.creatorId,
    required this.createdAt,
  });

  bool get isGroup => type == 'group';
  bool get isPersonal => type == 'personal';

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String,
      campaignId: map['campaign_id'] as String,
      type: map['type'] as String,
      creatorId: map['creator_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'type': type,
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}