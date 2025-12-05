// lib/widgets/project/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProjectChatScreen extends HookWidget {
  final String projectName;
  final int memberCount;
  final int onlineCount;

  const ProjectChatScreen({
    Key? key,
    this.projectName = 'Project Name',
    this.memberCount = 16,
    this.onlineCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageController = useTextEditingController();

    return Scaffold(
      backgroundColor: ColorPalette().neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette().neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette().neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // クリエイターアバターグループ
            SizedBox(
              width: 60,
              height: 32,
              child: Stack(
                children: List.generate(3, (index) {
                  return Positioned(
                    left: index * 16.0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: ColorPalette().neutral300,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=${index + 1}',
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: SpacePalette.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.base,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette().neutral900,
                    ),
                  ),
                  Text(
                    '$memberCount members • $onlineCount online',
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.xs,
                      color: ColorPalette().neutral500,
                    ),
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
                      color: ColorPalette().neutral100,
                      borderRadius: BorderRadius.circular(RadiusPalette.sm),
                    ),
                    child: Text(
                      'Nov 12',
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.xs,
                        color: ColorPalette().neutral600,
                      ),
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
              color: ColorPalette().neutral0,
              border: Border(
                top: BorderSide(
                  color: ColorPalette().neutral200,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette().neutral100,
                        borderRadius: BorderRadius.circular(RadiusPalette.lg),
                      ),
                      child: TextField(
                        controller: messageController,
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.base,
                          color: ColorPalette().neutral900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: FontSizePalette.base,
                            color: ColorPalette().neutral400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.sm,
                          ),
                          suffixIcon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: ColorPalette().neutral400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Icon(
                    Icons.mic_outlined,
                    color: ColorPalette().neutral400,
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
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette().neutral900,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.base,
                      color: ColorPalette().neutral0,
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.xs,
                          color: ColorPalette().neutral400,
                        ),
                      ),
                      SizedBox(width: SpacePalette.xs),
                      Icon(
                        Icons.done_all,
                        size: 12,
                        color: ColorPalette().neutral400,
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
              backgroundColor: ColorPalette().neutral300,
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
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.xs,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette().neutral900,
                    ),
                  ),
                if (showAvatar && senderName != null) SizedBox(height: SpacePalette.xs),
                Container(
                  padding: EdgeInsets.all(SpacePalette.base),
                  decoration: BoxDecoration(
                    color: ColorPalette().neutral100,
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.base,
                      color: ColorPalette().neutral900,
                    ),
                  ),
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.xs,
                    color: ColorPalette().neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}