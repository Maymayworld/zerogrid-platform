// lib/features/organizer/chat/presentation/group_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';

class GroupChatScreen extends HookWidget {
  final String projectName;
  final int memberCount;
  final int onlineCount;

  const GroupChatScreen({
    Key? key,
    required this.projectName,
    required this.memberCount,
    required this.onlineCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageController = useTextEditingController();

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
            // プロジェクトアイコン
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red,
              child: Text(
                projectName.substring(8, 10).toUpperCase(),
                style: TextStylePalette.miniTitle.copyWith(
                  color: ColorPalette.neutral0,
                  fontSize: 10,
                ),
              ),
            ),
            SizedBox(width: SpacePalette.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: TextStylePalette.listTitle
                  ),
                  Text(
                    '$memberCount members • $onlineCount online',
                    style: TextStylePalette.listLeading
                  ),
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
            child: ListView(
              padding: EdgeInsets.all(SpacePalette.base),
              children: [
                // 日付区切り
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SpacePalette.base,
                      vertical: SpacePalette.xs,
                    ),
                    margin: EdgeInsets.symmetric(vertical: SpacePalette.base),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorPalette.neutral200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(RadiusPalette.mini),
                    ),
                    child: Text(
                      'Nov 12',
                      style: TextStylePalette.smSubTitle
                    ),
                  ),
                ),
                // メッセージ（右寄せ - 自分）
                _MessageBubble(
                  message: 'Morning coffee tmr at Flash Coffee, who\'s in?',
                  time: '08:49 PM',
                  isMe: true,
                ),
                SizedBox(height: SpacePalette.base),
                // メッセージ（左寄せ - 他人）
                _MessageBubble(
                  message: 'Im in!',
                  time: '08:49 PM',
                  isMe: false,
                  senderName: 'Sender Name',
                  avatarUrl: 'https://i.pravatar.cc/150?img=4',
                ),
                SizedBox(height: SpacePalette.base),
                _MessageBubble(
                  message: 'can\'t say no',
                  time: '08:50 PM',
                  isMe: false,
                  senderName: 'Sender Name',
                  avatarUrl: 'https://i.pravatar.cc/150?img=5',
                ),
                SizedBox(height: SpacePalette.xs),
                _MessageBubble(
                  message: 'what time?',
                  time: '08:50 PM',
                  isMe: false,
                  senderName: 'Sender Name',
                  avatarUrl: 'https://i.pravatar.cc/150?img=5',
                  showAvatar: false,
                ),
              ],
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
                  Icon(
                    Icons.mic_outlined,
                    color: ColorPalette.neutral400,
                    size: 24,
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
  final String? senderName;
  final String? avatarUrl;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
    this.senderName,
    this.avatarUrl,
    this.showAvatar = true,
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
          // アバター
          if (showAvatar)
            CircleAvatar(
              radius: 16,
              backgroundColor: ColorPalette.neutral400,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            )
          else
            SizedBox(width: 32),
          SizedBox(width: SpacePalette.sm),
          // メッセージ
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAvatar && senderName != null)
                  Text(
                    senderName!,
                    style: TextStylePalette.miniTitle
                  ),
                if (showAvatar && senderName != null) SizedBox(height: SpacePalette.xs),
                Container(
                  padding: EdgeInsets.all(SpacePalette.inner),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral0,
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Text(
                    message,
                    style: TextStylePalette.normalText
                  ),
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  time,
                  style: TextStylePalette.subGuide
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}