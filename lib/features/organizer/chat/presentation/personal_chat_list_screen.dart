// lib/features/organizer/chat/presentation/personal_chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/common_search_bar.dart';
import '../../../../shared/data/models/chat_room.dart';
import '../../../../shared/data/models/chat_message.dart';
import '../../../../shared/data/services/chat_service.dart';
import '../../../../shared/presentation/providers/chat_service_provider.dart';
import 'personal_chat_screen.dart';

/// クリエイター情報を保持するクラス
class CreatorChatInfo {
  final ChatRoom room;
  final String creatorId;
  final String creatorName;
  final String avatarUrl;
  final ChatMessage? latestMessage;

  CreatorChatInfo({
    required this.room,
    required this.creatorId,
    required this.creatorName,
    required this.avatarUrl,
    this.latestMessage,
  });
}

class PersonalChatListScreen extends HookConsumerWidget {
  final String campaignId;
  final String projectName;

  const PersonalChatListScreen({
    Key? key,
    required this.campaignId,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final chatService = ref.watch(chatServiceProvider);
    final supabase = Supabase.instance.client;

    final creatorChats = useState<List<CreatorChatInfo>>([]);
    final isLoading = useState(true);
    final searchQuery = useState('');

    // クリエイター一覧を取得
    Future<void> loadCreatorChats() async {
      try {
        // 1. キャンペーンの1:1ルーム一覧を取得
        final rooms = await chatService.getPersonalRoomsForCampaign(campaignId);

        // 2. 各ルームのクリエイター情報を取得
        final List<CreatorChatInfo> infos = [];
        for (final room in rooms) {
          if (room.creatorId == null) continue;

          // プロファイル情報を取得
          final profileResponse = await supabase
              .from('profiles')
              .select('display_name, avatar_url')
              .eq('id', room.creatorId!)
              .maybeSingle();

          final displayName = profileResponse?['display_name'] ?? 'Unknown';
          final avatarUrl = profileResponse?['avatar_url'] ??
              'https://i.pravatar.cc/150?u=${room.creatorId}';

          // 最新メッセージを取得
          final latestMessage = await chatService.getLatestMessage(room.id);

          infos.add(CreatorChatInfo(
            room: room,
            creatorId: room.creatorId!,
            creatorName: displayName,
            avatarUrl: avatarUrl,
            latestMessage: latestMessage,
          ));
        }

        // 最新メッセージの日時でソート（新しい順）
        infos.sort((a, b) {
          if (a.latestMessage == null && b.latestMessage == null) return 0;
          if (a.latestMessage == null) return 1;
          if (b.latestMessage == null) return -1;
          return b.latestMessage!.createdAt.compareTo(a.latestMessage!.createdAt);
        });

        creatorChats.value = infos;
      } catch (e) {
        debugPrint('Failed to load creator chats: $e');
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadCreatorChats();
      return null;
    }, []);

    // 検索フィルター
    final filteredChats = creatorChats.value.where((c) {
      if (searchQuery.value.isEmpty) return true;
      return c.creatorName.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

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
            Text('Personal Chat', style: TextStylePalette.title),
            Text(projectName, style: TextStylePalette.listLeading),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SpacePalette.base),
            child: Center(
              child: Text(
                '${creatorChats.value.length} creators',
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
                    onChanged: (value) => searchQuery.value = value,
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
            child: isLoading.value
                ? Center(child: CircularProgressIndicator())
                : filteredChats.isEmpty
                    ? Center(
                        child: Text(
                          'No creators yet.\nWait for creators to join!',
                          style: TextStylePalette.listLeading,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final info = filteredChats[index];
                          return _PersonalChatItem(
                            name: info.creatorName,
                            message: info.latestMessage?.content ?? '',
                            time: info.latestMessage?.formattedTime ?? '',
                            avatarUrl: info.avatarUrl,
                            hasUnread: false, // TODO: 未読管理
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonalChatScreen(
                                    roomId: info.room.id,
                                    creatorName: info.creatorName,
                                    avatarUrl: info.avatarUrl,
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
                      Text(name, style: TextStylePalette.listTitle),
                      if (time.isNotEmpty)
                        Text(time, style: TextStylePalette.smSubText),
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