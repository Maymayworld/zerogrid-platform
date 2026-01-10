// lib/features/organizer/chat/presentation/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/common_search_bar.dart';
import '../../../../shared/data/models/chat_room.dart';
import '../../../../shared/data/services/chat_service.dart';
import '../../../../shared/presentation/providers/chat_service_provider.dart';
import '../../../organizer/campaign/data/models/campaign.dart';
import '../../../organizer/campaign/data/services/campaign_service.dart';
import '../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import 'personal_chat_list_screen.dart';
import 'group_chat_screen.dart';

class ChatListScreen extends HookConsumerWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final chatService = ref.watch(chatServiceProvider);
    final campaignService = ref.watch(campaignServiceProvider);

    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);
    final searchQuery = useState('');

    // 自分の案件一覧を取得
    Future<void> loadCampaigns() async {
      try {
        final result = await campaignService.getMyCampaigns();
        campaigns.value = result;
      } catch (e) {
        debugPrint('Failed to load campaigns: $e');
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadCampaigns();
      return null;
    }, []);

    // 検索フィルター
    final filteredCampaigns = campaigns.value.where((c) {
      if (searchQuery.value.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    // 色のリスト
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.black,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
    ];

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        title: Text('Chat', style: TextStylePalette.header),
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
          SizedBox(height: SpacePalette.base),

          // キャンペーンチャットリスト
          Expanded(
            child: isLoading.value
                ? Center(child: CircularProgressIndicator())
                : filteredCampaigns.isEmpty
                    ? Center(
                        child: Text(
                          'No campaigns yet.\nCreate a campaign to start chatting!',
                          style: TextStylePalette.listLeading,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredCampaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = filteredCampaigns[index];
                          final color = colors[index % colors.length];

                          return _ProjectChatItem(
                            campaign: campaign,
                            projectColor: color,
                            chatService: chatService,
                            onGroupTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupChatScreen(
                                    campaignId: campaign.id,
                                    projectName: campaign.name,
                                    memberCount: 0, // 後でロード
                                    onlineCount: 0,
                                    projectColor: color,
                                  ),
                                ),
                              );
                            },
                            onPersonalTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonalChatListScreen(
                                    campaignId: campaign.id,
                                    projectName: campaign.name,
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

class _ProjectChatItem extends HookWidget {
  final Campaign campaign;
  final Color projectColor;
  final ChatService chatService;
  final VoidCallback onGroupTap;
  final VoidCallback onPersonalTap;

  const _ProjectChatItem({
    required this.campaign,
    required this.projectColor,
    required this.chatService,
    required this.onGroupTap,
    required this.onPersonalTap,
  });

  @override
  Widget build(BuildContext context) {
    final creatorCount = useState(0);

    // 参加者数を取得
    useEffect(() {
      chatService.getGroupRoom(campaign.id).then((room) {
        if (room != null) {
          chatService.getRoomMemberCount(room.id).then((count) {
            creatorCount.value = count - 1; // Organizer自身を除く
          });
        }
      });
      return null;
    }, []);

    // プロジェクトの頭文字を取得
    String getProjectInitials() {
      if (campaign.name.startsWith('Project ') && campaign.name.length > 8) {
        return campaign.name.substring(8, 10).toUpperCase();
      }
      return campaign.name.substring(0, 2).toUpperCase();
    }

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
              getProjectInitials(),
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
                Text(campaign.name, style: TextStylePalette.listTitle),
                SizedBox(height: SpacePalette.xs),
                Text(
                  '${creatorCount.value} creators',
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