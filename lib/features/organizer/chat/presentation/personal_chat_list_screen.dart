// lib/features/organizer/chat/presentation/personal_chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/common_search_bar.dart';
import 'personal_chat_screen.dart';

class PersonalChatListScreen extends HookWidget {
  final String projectName;
  final int creatorCount;

  const PersonalChatListScreen({
    Key? key,
    required this.projectName,
    required this.creatorCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Chat',
              style: TextStylePalette.title,
            ),
            Text(
              projectName,
              style: TextStylePalette.listLeading,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SpacePalette.base),
            child: Center(
              child: Text(
                '$creatorCount creators',
                style: TextStylePalette.smSubTitle,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: EdgeInsets.all(SpacePalette.base),
            child: Row(
              children: [
                Expanded(
                  child: CommonSearchBar(
                    controller: searchController,
                    hintText: 'Search',
                  ),
                ),
                SizedBox(width: SpacePalette.base),
                Icon(
                  Icons.filter_list,
                  color: ColorPalette.neutral800,
                  size: 24,
                ),
              ],
            ),
          ),
          
          // チャットリスト
          Expanded(
            child: ListView(
              children: [
                _PersonalChatItem(
                  name: 'Kathryn Murphy',
                  message: 'Can\'t wait to see you! <',
                  time: '9:30 PM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=10',
                  hasUnread: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Kathryn Murphy',
                          avatarUrl: 'https://i.pravatar.cc/150?img=10',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Kristin Watson',
                  message: 'Scale of this world is mind-blowing. Can\'t get enou...',
                  time: '4:41 PM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=11',
                  hasUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Kristin Watson',
                          avatarUrl: 'https://i.pravatar.cc/150?img=11',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Wade Warren',
                  message: 'Why not add a little thrill? How about sneaking...',
                  time: '2:19 PM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=12',
                  hasUnread: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Wade Warren',
                          avatarUrl: 'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Darlene Robertson',
                  message: 'okayy <<<',
                  time: '2:07 PM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=13',
                  hasUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Darlene Robertson',
                          avatarUrl: 'https://i.pravatar.cc/150?img=13',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Jenny Wilson',
                  message: 'that sounds cool!',
                  time: '12:33 PM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=14',
                  hasUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Jenny Wilson',
                          avatarUrl: 'https://i.pravatar.cc/150?img=14',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Cody Fisher',
                  message: 'I need more details about the features of yo...',
                  time: '11:50 AM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=15',
                  hasUnread: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Cody Fisher',
                          avatarUrl: 'https://i.pravatar.cc/150?img=15',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Eleanor Pena',
                  message: 'when will it be ready?',
                  time: '10:45 AM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=16',
                  hasUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Eleanor Pena',
                          avatarUrl: 'https://i.pravatar.cc/150?img=16',
                        ),
                      ),
                    );
                  },
                ),
                _PersonalChatItem(
                  name: 'Brooklyn Simmons',
                  message: '',
                  time: '09:41 AM',
                  avatarUrl: 'https://i.pravatar.cc/150?img=17',
                  hasUnread: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatScreen(
                          creatorName: 'Brooklyn Simmons',
                          avatarUrl: 'https://i.pravatar.cc/150?img=17',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final bool hasUnread;
  final VoidCallback onTap;

  const _PersonalChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.inner,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorPalette.neutral200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // アバター
            CircleAvatar(
              radius: 24,
              backgroundColor: ColorPalette.neutral400,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(width: SpacePalette.inner),
            
            // メッセージ情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStylePalette.listTitle,
                      ),
                      Text(
                        time,
                        style: TextStylePalette.smSubText,
                      ),
                    ],
                  ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: SpacePalette.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            style: TextStylePalette.listLeading,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          SizedBox(width: SpacePalette.sm),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorPalette.neutral800,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStylePalette.miniTitle.copyWith(
                                  color: ColorPalette.neutral0,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}