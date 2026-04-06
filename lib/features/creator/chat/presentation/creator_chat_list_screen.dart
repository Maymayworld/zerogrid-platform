// lib/features/creator/chat/presentation/creator_chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/common_search_bar.dart';
import '../../../../shared/data/models/chat_room.dart';
import '../../../../shared/data/models/chat_message.dart';
import '../../../../shared/data/services/chat_service.dart';
import '../../../../shared/presentation/providers/chat_service_provider.dart';
import '../../../creator/campaign/presentation/providers/participation_service_provider.dart';
import '../../../../features/organizer/campaign/data/models/campaign.dart';
import 'chat_screen.dart';
import 'creator_personal_chat_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

/// DM情報を保持するクラス
class _DmChatInfo {
  final ChatRoom room;
  final Campaign campaign;
  final String otherUserName;
  final String avatarUrl;
  final ChatMessage? latestMessage;
  final bool isOnline;
  final int unreadCount;
  final String type; // 'creator' or 'campaign'

  _DmChatInfo({
    required this.room,
    required this.campaign,
    required this.otherUserName,
    required this.avatarUrl,
    this.latestMessage,
    this.isOnline = false,
    this.unreadCount = 0,
    required this.type,
  });
}

class CreatorChatListScreen extends HookConsumerWidget {
  const CreatorChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final chatService = ref.watch(chatServiceProvider);
    final supabase = Supabase.instance.client;
    final currentUserId = supabase.auth.currentUser?.id;

    final dmChats = useState<List<_DmChatInfo>>([]);
    final isLoading = useState(true);
    final searchQuery = useState('');
    final selectedTab = useState(0); // 0: All, 1: Creator, 2: Campaign

    final tabs = ['All', 'Creator', 'Campaign'];

    // 参加中のキャンペーンのDM一覧を取得
    Future<void> loadDmChats() async {
      if (currentUserId == null) return;
      isLoading.value = true;
      try {
        final participationService = ref.read(participationServiceProvider);
        final campaigns = await participationService.getParticipatingCampaigns();

        final List<_DmChatInfo> allChats = [];

        for (final campaign in campaigns) {
          // 1:1チャット（Organizerとの個人チャット）を取得
          final personalRoom = await chatService.getPersonalRoom(
            campaignId: campaign.id,
            creatorId: currentUserId,
          );

          if (personalRoom != null) {
            // Organizer情報を取得
            final profileResponse = await supabase
                .from('profiles')
                .select('display_name, avatar_url')
                .eq('id', campaign.organizerId)
                .maybeSingle();

            final displayName = profileResponse?['display_name'] ?? campaign.name;
            final avatarUrl = profileResponse?['avatar_url'] ??
                'https://i.pravatar.cc/150?u=${campaign.organizerId}';

            final latestMessage = await chatService.getLatestMessage(personalRoom.id);

            allChats.add(_DmChatInfo(
              room: personalRoom,
              campaign: campaign,
              otherUserName: displayName,
              avatarUrl: avatarUrl,
              latestMessage: latestMessage,
              isOnline: false,
              unreadCount: 0,
              type: 'creator',
            ));
          }

          // グループチャットも取得（Campaign タブ用）
          final groupRoom = await chatService.getGroupRoom(campaign.id);
          if (groupRoom != null) {
            final latestMessage = await chatService.getLatestMessage(groupRoom.id);
            final memberCount = await chatService.getRoomMemberCount(groupRoom.id);

            allChats.add(_DmChatInfo(
              room: groupRoom,
              campaign: campaign,
              otherUserName: campaign.name,
              avatarUrl: (campaign.thumbnailUrl != null && campaign.thumbnailUrl!.isNotEmpty)
                  ? campaign.thumbnailUrl!
                  : 'https://i.pravatar.cc/150?u=${campaign.id}',
              latestMessage: latestMessage,
              isOnline: false,
              unreadCount: 0,
              type: 'campaign',
            ));
          }
        }

        // 最新メッセージの日時でソート（新しい順）
        allChats.sort((a, b) {
          if (a.latestMessage == null && b.latestMessage == null) return 0;
          if (a.latestMessage == null) return 1;
          if (b.latestMessage == null) return -1;
          return b.latestMessage!.createdAt.compareTo(a.latestMessage!.createdAt);
        });

        dmChats.value = allChats;
      } catch (e) {
        debugPrint('Failed to load DM chats: $e');
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadDmChats();
      return null;
    }, []);

    // フィルター
    final filteredChats = dmChats.value.where((chat) {
      // タブフィルター
      if (selectedTab.value == 1 && chat.type != 'creator') return false;
      if (selectedTab.value == 2 && chat.type != 'campaign') return false;

      // 検索フィルター
      if (searchQuery.value.isNotEmpty) {
        return chat.otherUserName.toLowerCase().contains(searchQuery.value.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.base, SpacePalette.base, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.chat, style: TextStylePalette.header),
              ),
            ),
            SizedBox(height: SpacePalette.sm),

            // 検索バー
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: CommonSearchBar(
                controller: searchController,
                hintText: AppLocalizations.of(context)!.search,
                onChanged: (value) => searchQuery.value = value,
              ),
            ),
            SizedBox(height: SpacePalette.base),

            // タブバー
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedTab.value == index;
                  return Padding(
                    padding: EdgeInsets.only(right: SpacePalette.sm),
                    child: GestureDetector(
                      onTap: () => selectedTab.value = index,
                      child: Container(
                        height: ButtonSizePalette.filter,
                        padding: EdgeInsets.symmetric(
                          horizontal: SpacePalette.base,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorPalette.smashedPumpkin600
                              : ColorPalette.white,
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                          border: Border.all(
                            color: isSelected
                                ? ColorPalette.smashedPumpkin600
                                : ColorPalette.neutral200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? ColorPalette.smashedPumpkin700
                                  : ColorPalette.neutral200,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: FontSizePalette.size14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? ColorPalette.white
                                : ColorPalette.neutral800,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: SpacePalette.sm),

            // チャットリスト
            Expanded(
              child: isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        color: ColorPalette.neutral800,
                      ),
                    )
                  : filteredChats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsRegular.chatCircle,
                                size: 48,
                                color: ColorPalette.neutral400,
                              ),
                              SizedBox(height: SpacePalette.base),
                              Text(
                                AppLocalizations.of(context)!.noMessagesYetStart,
                                style: TextStylePalette.subText,
                              ),
                              SizedBox(height: SpacePalette.xs),
                              Text(
                                AppLocalizations.of(context)!.joinCampaignsFromFind,
                                style: TextStylePalette.smSubText,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => loadDmChats(),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredChats.length,
                            itemBuilder: (context, index) {
                              final chat = filteredChats[index];
                              return _ChatListItem(
                                name: chat.otherUserName,
                                message: chat.latestMessage?.content ?? '',
                                time: chat.latestMessage != null
                                    ? _formatTime(chat.latestMessage!.createdAt)
                                    : '',
                                avatarUrl: chat.avatarUrl,
                                isOnline: chat.isOnline,
                                unreadCount: chat.unreadCount,
                                isGroupChat: chat.type == 'campaign',
                                onTap: () {
                                  if (chat.type == 'campaign') {
                                    // グループチャットへ
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProjectChatScreen(
                                          campaignId: chat.campaign.id,
                                          projectName: chat.campaign.name,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 1:1チャットへ
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreatorPersonalChatScreen(
                                          campaignId: chat.campaign.id,
                                          organizerId: chat.campaign.organizerId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Yesterday';
      return '${dateTime.month}/${dateTime.day}';
    }

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;
  final bool isGroupChat;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.isOnline,
    required this.unreadCount,
    required this.isGroupChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        child: Row(
          children: [
            // アバター + オンラインインジケーター
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ColorPalette.neutral200,
                  backgroundImage: NetworkImage(avatarUrl),
                  child: isGroupChat
                      ? Icon(PhosphorIconsRegular.usersThree, color: ColorPalette.neutral400)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: ColorPalette.positive500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorPalette.neutral100,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: SpacePalette.sm),

            // メッセージ情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStylePalette.listTitle.copyWith(
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: TextStylePalette.smSubText.copyWith(
                            color: unreadCount > 0
                                ? ColorPalette.neutral800
                                : ColorPalette.neutral400,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.isNotEmpty ? message : 'No messages yet',
                          style: TextStylePalette.listLeading.copyWith(
                            color: message.isNotEmpty
                                ? ColorPalette.neutral500
                                : ColorPalette.neutral400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        SizedBox(width: SpacePalette.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          constraints: BoxConstraints(minWidth: 22),
                          decoration: BoxDecoration(
                            color: ColorPalette.smashedPumpkin600,
                            borderRadius: BorderRadius.circular(RadiusPalette.full),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: ColorPalette.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
