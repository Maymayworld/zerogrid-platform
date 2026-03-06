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
import 'package:zero_grid/l10n/app_localizations.dart';

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
    final organizerName = useState(AppLocalizations.of(context)!.organizer);
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
          organizerName.value = response['display_name'] ?? AppLocalizations.of(context)!.organizer;
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
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString()))),
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
                  Text(AppLocalizations.of(context)!.organizer, style: TextStylePalette.listLeading),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // メッセージリスト
          isLoading.value
              ? Center(child: CircularProgressIndicator())
              : room.value == null
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.failedToLoad,
                        style: TextStylePalette.listLeading,
                      ),
                    )
                  : messages.value.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noMessagesYetCreator,
                            style: TextStylePalette.listLeading,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: SpacePalette.base,
                            right: SpacePalette.base,
                            top: SpacePalette.base,
                            bottom: 100,
                          ),
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
          // 入力フィールド（Stack下部に配置）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  SpacePalette.base,
                  SpacePalette.sm,
                  SpacePalette.base,
                  SpacePalette.base,
                ),
                child: Row(
                  children: [
                    // テキストフィールド
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStylePalette.normalText,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.messageHint,
                          hintStyle: TextStylePalette.hintText,
                          filled: true,
                          fillColor: ColorPalette.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(RadiusPalette.full),
                            borderSide: BorderSide(color: ColorPalette.neutral200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(RadiusPalette.full),
                            borderSide: BorderSide(color: ColorPalette.neutral200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(RadiusPalette.full),
                            borderSide: BorderSide(color: ColorPalette.neutral400),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.sm,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SpacePalette.sm),
                    // 送信ボタン
                    GestureDetector(
                      onTap: isSending.value ? null : sendMessage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSending.value
                              ? ColorPalette.neutral400
                              : ColorPalette.smashedPumpkin600,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: ColorPalette.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: SpacePalette.base,
              vertical: SpacePalette.inner,
            ),
            decoration: BoxDecoration(
              color: ColorPalette.smashedPumpkin600,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(RadiusPalette.xl),
                topRight: Radius.circular(RadiusPalette.xl),
                bottomLeft: Radius.circular(RadiusPalette.xl),
                bottomRight: Radius.circular(RadiusPalette.mini),
              ),
            ),
            child: Text(
              message,
              style: TextStylePalette.normalText.copyWith(
                color: ColorPalette.white,
              ),
            ),
          ),
          SizedBox(height: SpacePalette.xs),
          Padding(
            padding: EdgeInsets.only(right: SpacePalette.xs),
            child: Text(
              AppLocalizations.of(context)!.delivered,
              style: TextStylePalette.subGuide.copyWith(
                color: ColorPalette.neutral400,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.base,
                    vertical: SpacePalette.inner,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(RadiusPalette.xl),
                      topRight: Radius.circular(RadiusPalette.xl),
                      bottomLeft: Radius.circular(RadiusPalette.mini),
                      bottomRight: Radius.circular(RadiusPalette.xl),
                    ),
                  ),
                  child: Text(message, style: TextStylePalette.normalText),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}