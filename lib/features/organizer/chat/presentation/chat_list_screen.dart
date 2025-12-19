// lib/features/organizer/chat/presentation/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/common_search_bar.dart';
import 'personal_chat_list_screen.dart';
import 'group_chat_screen.dart';

class ChatListScreen extends HookWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        title: Text(
          'Chat',
          style: TextStylePalette.header,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
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
          SizedBox(height: SpacePalette.base),
          
          // プロジェクトチャットリスト
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _ProjectChatItem(
                  projectName: 'Project Mikasa',
                  creatorCount: 16,
                  projectColor: Colors.red,
                  groupUnreadCount: 8,
                  personalUnreadCount: 0,
                  onGroupTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          projectName: 'Project Mikasa',
                          memberCount: 16,
                          onlineCount: 5,
                        ),
                      ),
                    );
                  },
                  onPersonalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatListScreen(
                          projectName: 'Project Mikasa',
                          creatorCount: 16,
                        ),
                      ),
                    );
                  },
                ),
                _ProjectChatItem(
                  projectName: 'Project Armin',
                  creatorCount: 9,
                  projectColor: Colors.blue,
                  groupUnreadCount: 2,
                  personalUnreadCount: 0,
                  onGroupTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          projectName: 'Project Armin',
                          memberCount: 9,
                          onlineCount: 3,
                        ),
                      ),
                    );
                  },
                  onPersonalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatListScreen(
                          projectName: 'Project Armin',
                          creatorCount: 9,
                        ),
                      ),
                    );
                  },
                ),
                _ProjectChatItem(
                  projectName: 'Project Annie Leonhart',
                  creatorCount: 27,
                  projectColor: Colors.black,
                  groupUnreadCount: 2,
                  personalUnreadCount: 0,
                  onGroupTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          projectName: 'Project Annie Leonhart',
                          memberCount: 27,
                          onlineCount: 8,
                        ),
                      ),
                    );
                  },
                  onPersonalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatListScreen(
                          projectName: 'Project Annie Leonhart',
                          creatorCount: 27,
                        ),
                      ),
                    );
                  },
                ),
                _ProjectChatItem(
                  projectName: 'Project Sakamoto',
                  creatorCount: 15,
                  projectColor: Colors.purple,
                  groupUnreadCount: 2,
                  personalUnreadCount: 0,
                  onGroupTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          projectName: 'Project Sakamoto',
                          memberCount: 15,
                          onlineCount: 6,
                        ),
                      ),
                    );
                  },
                  onPersonalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatListScreen(
                          projectName: 'Project Sakamoto',
                          creatorCount: 15,
                        ),
                      ),
                    );
                  },
                ),
                _ProjectChatItem(
                  projectName: 'Project Squarepants',
                  creatorCount: 6,
                  projectColor: Colors.black87,
                  groupUnreadCount: 2,
                  personalUnreadCount: 0,
                  onGroupTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          projectName: 'Project Squarepants',
                          memberCount: 6,
                          onlineCount: 2,
                        ),
                      ),
                    );
                  },
                  onPersonalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChatListScreen(
                          projectName: 'Project Squarepants',
                          creatorCount: 6,
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

class _ProjectChatItem extends StatelessWidget {
  final String projectName;
  final int creatorCount;
  final Color projectColor;
  final int groupUnreadCount;
  final int personalUnreadCount;
  final VoidCallback onGroupTap;
  final VoidCallback onPersonalTap;

  const _ProjectChatItem({
    required this.projectName,
    required this.creatorCount,
    required this.projectColor,
    required this.groupUnreadCount,
    required this.personalUnreadCount,
    required this.onGroupTap,
    required this.onPersonalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // プロジェクトアイコン
          CircleAvatar(
            radius: 24,
            backgroundColor: projectColor,
            child: Text(
              projectName.substring(8, 10).toUpperCase(),
              style: TextStylePalette.smTitle.copyWith(
                color: ColorPalette.neutral0,
              ),
            ),
          ),
          SizedBox(width: SpacePalette.inner),
          
          // プロジェクト情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: TextStylePalette.listTitle,
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  '$creatorCount creators',
                  style: TextStylePalette.listLeading,
                ),
              ],
            ),
          ),
          
          // GroupとPersonalボタン
          Row(
            children: [
              GestureDetector(
                onTap: onGroupTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.sm,
                    vertical: SpacePalette.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral100,
                    borderRadius: BorderRadius.circular(RadiusPalette.mini),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 16,
                        color: ColorPalette.neutral800,
                      ),
                      if (groupUnreadCount > 0) ...[
                        SizedBox(width: SpacePalette.xs),
                        Container(
                          constraints: BoxConstraints(minWidth: 18),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral800,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            groupUnreadCount.toString(),
                            style: TextStylePalette.miniTitle.copyWith(
                              color: ColorPalette.neutral0,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: SpacePalette.xs),
              GestureDetector(
                onTap: onPersonalTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.sm,
                    vertical: SpacePalette.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral100,
                    borderRadius: BorderRadius.circular(RadiusPalette.mini),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: ColorPalette.neutral800,
                      ),
                      if (personalUnreadCount > 0) ...[
                        SizedBox(width: SpacePalette.xs),
                        Container(
                          constraints: BoxConstraints(minWidth: 18),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral800,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            personalUnreadCount.toString(),
                            style: TextStylePalette.miniTitle.copyWith(
                              color: ColorPalette.neutral0,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}