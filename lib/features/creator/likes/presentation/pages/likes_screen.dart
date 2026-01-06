// lib/features/creator/likes/presentation/pages/likes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/common_search_bar.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../campaign/presentation/widgets/project_card.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../find/presentation/widgets/notification_sheet.dart';
import '../providers/like_service_provider.dart';

class LikesScreen extends HookConsumerWidget {
  const LikesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = useState<List<Campaign>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final selectedCategory = useState<String>('All');
    final searchQuery = useState<String>('');
    final searchController = useTextEditingController();

    final likedIds = ref.watch(likedCampaignIdsProvider);

    final categories = [
      {'icon': Icons.grid_view, 'label': 'All'},
      {'icon': Icons.business_center_outlined, 'label': 'Business'},
      {'icon': Icons.music_note_outlined, 'label': 'Entertainment'},
      {'icon': Icons.music_note, 'label': 'Music'},
      {'icon': Icons.podcasts_outlined, 'label': 'Podcast'},
    ];

    Future<void> loadLikedCampaigns() async {
      isLoading.value = true;
      error.value = null;
      try {
        final likeService = ref.read(likeServiceProvider);
        List<Campaign> result;

        if (selectedCategory.value == 'All') {
          result = await likeService.getLikedCampaigns();
        } else {
          result = await likeService.getLikedCampaignsByCategory(selectedCategory.value);
        }

        campaigns.value = result;
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> unlikeCampaign(String campaignId) async {
      try {
        final likeService = ref.read(likeServiceProvider);
        await likeService.unlikeCampaign(campaignId);
        
        campaigns.value = campaigns.value
            .where((c) => c.id != campaignId)
            .toList();
        
        final currentIds = ref.read(likedCampaignIdsProvider);
        ref.read(likedCampaignIdsProvider.notifier).state = 
            {...currentIds}..remove(campaignId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from likes')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    useEffect(() {
      loadLikedCampaigns();
      return null;
    }, [likedIds.length]);

    useEffect(() {
      loadLikedCampaigns();
      return null;
    }, [selectedCategory.value]);

    final filteredCampaigns = campaigns.value.where((c) {
      if (searchQuery.value.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(vertical: SpacePalette.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = selectedCategory.value == category['label'];
                    return Padding(
                      padding: EdgeInsets.only(right: SpacePalette.base),
                      child: _CategoryChip(
                        icon: category['icon'] as IconData,
                        label: category['label'] as String,
                        isSelected: isSelected,
                        onTap: () {
                          selectedCategory.value = category['label'] as String;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: CommonSearchBar(
                controller: searchController,
                hintText: 'Search liked projects',
                onChanged: (value) => searchQuery.value = value,
              ),
            ),
            SizedBox(height: SpacePalette.base),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Liked Projects', style: TextStylePalette.header),
                  IconButton(
                    icon: Icon(Icons.refresh, color: ColorPalette.neutral800),
                    onPressed: loadLikedCampaigns,
                  ),
                ],
              ),
            ),
            SizedBox(height: SpacePalette.base),

            Expanded(
              child: _buildContent(
                context,
                isLoading: isLoading.value,
                error: error.value,
                campaigns: filteredCampaigns,
                onRefresh: loadLikedCampaigns,
                onUnlike: unlikeCampaign,
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required List<Campaign> campaigns,
    required VoidCallback onRefresh,
    required Future<void> Function(String) onUnlike,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorPalette.neutral800),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text('Failed to load', style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(onPressed: onRefresh, child: Text('Retry')),
          ],
        ),
      );
    }

    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text('No liked projects yet', style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.xs),
            Text('Find campaigns and tap ♥ to save them here', 
                style: TextStylePalette.smSubText),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (SpacePalette.base * 2);
    final cardHeight = cardWidth * 9 / 16;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];

          return Padding(
            padding: EdgeInsets.only(bottom: SpacePalette.base),
            child: ProjectCard(
              width: cardWidth,
              height: cardHeight,
              imageUrl: campaign.thumbnailUrl,
              platformIcon: _getPlatformIcon(campaign.platforms),
              currentAmount: campaign.budget.toDouble() * 0.25,
              totalAmount: campaign.budget.toDouble(),
              pricePerView: campaign.pricePerThousand,
              viewCount: 1000,
              participants: 3,
              isLiked: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailScreen(
                      campaign: campaign,  // ← campaignオブジェクトを渡す
                    ),
                  ),
                );
              },
              onLike: () => onUnlike(campaign.id),
            ),
          );
        },
      ),
    );
  }

  IconData _getPlatformIcon(List<String> platforms) {
    if (platforms.contains('YouTube')) return Icons.play_arrow;
    if (platforms.contains('Instagram')) return Icons.camera_alt;
    if (platforms.contains('TikTok')) return Icons.music_note;
    return Icons.video_library;
  }

  String _formatDeadline(DateTime deadline) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
          ),
          SizedBox(height: SpacePalette.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: FontSizePalette.size12,
              color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: SpacePalette.xs),
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: ColorPalette.neutral800,
            ),
        ],
      ),
    );
  }
}