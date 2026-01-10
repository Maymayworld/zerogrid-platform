// lib/features/creator/chat/presentation/creator_personal_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/data/models/chat_room.dart';
import '../../../../shared/data/models/chat_message.dart';
import '../../../../shared/data/services/chat_service.dart';
import '../../../../shared/presentation/providers/chat_service_provider.dart';

/// Creator側からOrganizerとの1:1チャットを行う画面
class CreatorPersonalChatScreen extends HookConsumerWidget {
  final String campaignId;
  final String organizerId;

  const CreatorPersonalChatScreen({
    Key? key,
    required this.campaignId,
    required this.organizerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final chatService = ref.watch(chatServiceProvider);
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;

    final room = useState<ChatRoom?>(null);
    final messages = useState<List<ChatMessage>>([]);
    final isLoading = useState(true);
    final isSending = useState(false);
    final scrollController = useScrollController();
    final channel = useState<RealtimeChannel?>(null);
    final organizerName = useState('Organizer');
    final organizerAvatarUrl = useState('https://i.pravatar.cc/150?u=$organizerId');

    // Organizer情報を取得
    Future<void> loadOrganizerInfo() async {
      try {
        final response = await supabase
            .from('profiles')
            .select('display_name, avatar_url')
            .eq('id', organizerId)
            .maybeSingle();

        if (response != null) {
          organizerName.value = response['display_name'] ?? 'Organizer';
          if (response['avatar_url'] != null) {
            organizerAvatarUrl.value = response['avatar_url'];
          }
        }
      } catch (e) {
        debugPrint('Failed to load organizer info: $e');
      }
    }

    // ルーム取得
    Future<void> loadRoom() async {
      try {
        // 現在のユーザー（Creator）のIDで1:1ルームを取得
        room.value = await chatService.getPersonalRoom(
          campaignId: campaignId,
          creatorId: currentUserId!,
        );
      } catch (e) {
        debugPrint('Failed to load room: $e');
      }
    }

    // メッセージ取得
    Future<void> loadMessages() async {
      if (room.value == null) {
        isLoading.value = false;
        return;
      }
      try {
        final result = await chatService.getMessages(room.value!.id);
        messages.value = result;
      } catch (e) {
        debugPrint('Failed to load messages: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // リアルタイム購読
    void subscribeMessages() {
      if (room.value == null) return;
      channel.value = chatService.subscribeToMessages(
        room.value!.id,
        (newMessage) {
          messages.value = [...messages.value, newMessage];
          Future.delayed(Duration(milliseconds: 100), () {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        },
      );
    }

    // メッセージ送信
    Future<void> sendMessage() async {
      final content = messageController.text.trim();
      if (content.isEmpty || room.value == null || isSending.value) return;

      isSending.value = true;
      try {
        await chatService.sendMessage(
          roomId: room.value!.id,
          content: content,
        );
        messageController.clear();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send: $e')),
          );
        }
      } finally {
        isSending.value = false;
      }
    }

    // 初期化
    useEffect(() {
      loadOrganizerInfo();
      loadRoom().then((_) {
        loadMessages();
        subscribeMessages();
      });
      return () {
        if (channel.value != null) {
          chatService.unsubscribe(channel.value!);
        }
      };
    }, []);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Organizerアバター
            CircleAvatar(
              radius: 16,
              backgroundColor: ColorPalette.neutral400,
              backgroundImage: NetworkImage(organizerAvatarUrl.value),
            ),
            SizedBox(width: SpacePalette.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(organizerName.value, style: TextStylePalette.listTitle),
                  Text('Organizer', style: TextStylePalette.listLeading),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // メッセージリスト
          Expanded(
            child: isLoading.value
                ? Center(child: CircularProgressIndicator())
                : room.value == null
                    ? Center(
                        child: Text(
                          'Chat room not available',
                          style: TextStylePalette.listLeading,
                        ),
                      )
                    : messages.value.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet.\nSay hi to the organizer!',
                              style: TextStylePalette.listLeading,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.all(SpacePalette.base),
                            itemCount: messages.value.length,
                            itemBuilder: (context, index) {
                              final message = messages.value[index];
                              final isMe = message.senderId == currentUserId;

                              return Padding(
                                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                                child: _MessageBubble(
                                  message: message.content,
                                  time: message.formattedTime,
                                  isMe: isMe,
                                  avatarUrl: isMe ? null : organizerAvatarUrl.value,
                                ),
                              );
                            },
                          ),
          ),
          // 入力フィールド
          Container(
            padding: EdgeInsets.all(SpacePalette.base),
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              border: Border(
                top: BorderSide(
                  color: ColorPalette.neutral200,
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.neutral0,
                        borderRadius: BorderRadius.circular(RadiusPalette.lg),
                      ),
                      child: TextField(
                        controller: messageController,
                        style: TextStylePalette.normalText,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStylePalette.hintText,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.sm,
                          ),
                          suffixIcon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: ColorPalette.neutral400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  GestureDetector(
                    onTap: isSending.value ? null : sendMessage,
                    child: Icon(
                      isSending.value ? Icons.hourglass_empty : Icons.send,
                      color: isSending.value
                          ? ColorPalette.neutral400
                          : ColorPalette.neutral800,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// メッセージバブル
class _MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final String? avatarUrl;

  const _MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(SpacePalette.inner),
              decoration: BoxDecoration(
                color: ColorPalette.neutral800,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: TextStylePalette.normalText.copyWith(
                      color: ColorPalette.neutral0,
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStylePalette.subGuide.copyWith(
                          color: ColorPalette.neutral400,
                        ),
                      ),
                      SizedBox(width: SpacePalette.xs),
                      Icon(
                        Icons.done_all,
                        size: 12,
                        color: ColorPalette.neutral400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.neutral400,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          ),
          SizedBox(width: SpacePalette.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(SpacePalette.inner),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral0,
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Text(message, style: TextStylePalette.normalText),
                ),
                SizedBox(height: SpacePalette.xs),
                Text(time, style: TextStylePalette.subGuide),
              ],
            ),
          ),
        ],
      );
    }
  }
}