// lib/features/organizer/chat/presentation/personal_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';

class PersonalChatScreen extends HookWidget {
  final String creatorName;
  final String avatarUrl;

  const PersonalChatScreen({
    Key? key,
    required this.creatorName,
    required this.avatarUrl,
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
            // クリエイターアバター
            CircleAvatar(
              radius: 16,
              backgroundColor: ColorPalette.neutral400,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(width: SpacePalette.sm),
            Expanded(
              child: Text(
                creatorName,
                style: TextStylePalette.listTitle
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
                      'Today',
                      style: TextStylePalette.smSubTitle
                    ),
                  ),
                ),
                // メッセージ（左寄せ - クリエイター）
                _MessageBubble(
                  message: 'Hi! How are you?',
                  time: '10:30 AM',
                  isMe: false,
                  avatarUrl: avatarUrl,
                ),
                SizedBox(height: SpacePalette.base),
                // メッセージ（右寄せ - 自分）
                _MessageBubble(
                  message: 'I\'m good! How about you?',
                  time: '10:32 AM',
                  isMe: true,
                ),
                SizedBox(height: SpacePalette.base),
                _MessageBubble(
                  message: 'Pretty good! Thanks for asking.',
                  time: '10:33 AM',
                  isMe: false,
                  avatarUrl: avatarUrl,
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
          // アバター
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.neutral400,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          ),
          SizedBox(width: SpacePalette.sm),
          // メッセージ
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