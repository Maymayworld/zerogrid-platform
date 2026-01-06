// lib/features/creator/campaign/presentation/pages/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../providers/participation_service_provider.dart';
import '../../../likes/presentation/providers/like_service_provider.dart';
import '../widgets/share_sheet.dart';
import 'success_screen.dart';

class ProjectDetailScreen extends HookConsumerWidget {
  final Campaign? campaign;  // Campaignオブジェクトを受け取る
  // 後方互換のための個別パラメータ
  final String? imageUrl;
  final String projectName;
  final double pricePerView;
  final int viewCount;
  final double currentAmount;
  final double totalAmount;
  final String campaignPeriod;
  final String companyName;
  final double rating;
  final int reviewCount;
  final bool showAddReview;

  const ProjectDetailScreen({
    Key? key,
    this.campaign,
    this.imageUrl,
    this.projectName = 'Project Name',
    this.pricePerView = 300,
    this.viewCount = 1000,
    this.currentAmount = 1000,
    this.totalAmount = 4000,
    this.campaignPeriod = 'November 1-30, 2025',
    this.companyName = 'Company Name',
    this.rating = 4.9,
    this.reviewCount = 141,
    this.showAddReview = false,
  }) : super(key: key);

  // 実際に使う値を取得（campaignがあればそちらを優先）
  String get _projectName => campaign?.name ?? projectName;
  String? get _imageUrl => campaign?.thumbnailUrl ?? imageUrl;
  double get _pricePerView => campaign?.pricePerThousand ?? pricePerView;
  double get _totalAmount => campaign?.budget.toDouble() ?? totalAmount;
  double get _currentAmount => _totalAmount * 0.25; // TODO: 実際の消費額
  List<String> get _platforms => campaign?.platforms ?? ['YouTube', 'Instagram', 'TikTok'];
  String get _description => campaign?.description ?? '';
  DateTime? get _deadline => campaign?.deadline;

  String _getImageUrl() {
    if (_imageUrl != null && _imageUrl!.isNotEmpty && _imageUrl != 'placeholder') {
      return _imageUrl!;
    }
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return campaignPeriod;
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = _currentAmount / _totalAmount;
    final percentage = (progress * 100).toInt();
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 9 / 16;

    final isJoining = useState(false);
    final isAlreadyJoined = useState(false);

    // いいね状態
    final likedIds = ref.watch(likedCampaignIdsProvider);
    final isLiked = campaign != null ? likedIds.contains(campaign!.id) : false;

    // 参加状態を確認
    useEffect(() {
      if (campaign != null) {
        Future.microtask(() async {
          final participationService = ref.read(participationServiceProvider);
          final joined = await participationService.isParticipating(campaign!.id);
          isAlreadyJoined.value = joined;
        });
      }
      return null;
    }, [campaign?.id]);

    // 参加処理
    Future<void> handleJoin() async {
      if (campaign == null) {
        _showSuccessScreen(context);
        return;
      }

      isJoining.value = true;
      try {
        final participationService = ref.read(participationServiceProvider);
        await participationService.joinCampaign(campaign!.id);

        // グローバル状態を更新
        final currentIds = ref.read(participatingCampaignIdsProvider);
        ref.read(participatingCampaignIdsProvider.notifier).state = {
          ...currentIds,
          campaign!.id
        };

        if (context.mounted) {
          _showSuccessScreen(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isJoining.value = false;
      }
    }

    // いいねトグル
    Future<void> toggleLike() async {
      if (campaign == null) return;

      final likeService = ref.read(likeServiceProvider);
      final currentLiked = ref.read(likedCampaignIdsProvider);

      try {
        if (currentLiked.contains(campaign!.id)) {
          await likeService.unlikeCampaign(campaign!.id);
          ref.read(likedCampaignIdsProvider.notifier).state =
              {...currentLiked}..remove(campaign!.id);
        } else {
          await likeService.likeCampaign(campaign!.id);
          ref.read(likedCampaignIdsProvider.notifier).state = {
            ...currentLiked,
            campaign!.id
          };
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Details', style: TextStylePalette.title),
        centerTitle: true,
        actions: [
          // いいねボタン
          if (campaign != null)
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? ColorPalette.systemRed : ColorPalette.neutral800,
              ),
              onPressed: toggleLike,
            ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: ColorPalette.neutral800),
            onPressed: () => _showShareSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー画像
                SizedBox(
                  width: screenWidth,
                  height: imageHeight,
                  child: Image.network(
                    _getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: ColorPalette.neutral200,
                        child: Center(
                          child: Icon(Icons.image, size: 50, color: ColorPalette.neutral400),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // プラットフォームバッジ
                      Wrap(
                        spacing: SpacePalette.sm,
                        runSpacing: SpacePalette.sm,
                        children: _platforms.map((platform) {
                          return _PlatformBadge(
                            icon: _getPlatformIcon(platform),
                            label: platform,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Project Name
                      Text(_projectName, style: TextStylePalette.smallHeader),
                      SizedBox(height: SpacePalette.base),

                      // Price per view
                      Text(
                        '¥${_pricePerView.toStringAsFixed(1)} / 1000 Views',
                        style: TextStylePalette.header,
                      ),
                      SizedBox(height: SpacePalette.base),

                      // 金額とプログレスバー
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${_currentAmount.toInt()} / ¥${_totalAmount.toInt()}',
                            style: TextStylePalette.bigText,
                          ),
                          Text('$percentage%', style: TextStylePalette.bigSubText),
                        ],
                      ),
                      SizedBox(height: SpacePalette.sm),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: ColorPalette.neutral200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorPalette.systemGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.sm),

                      // Campaign period
                      Text(
                        'Deadline: ${_formatDeadline(_deadline)}',
                        style: TextStylePalette.smSubText,
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Description
                      if (_description.isNotEmpty) ...[
                        Divider(color: ColorPalette.neutral200, height: 1),
                        SizedBox(height: SpacePalette.base),
                        Text('About this campaign', style: TextStylePalette.title),
                        SizedBox(height: SpacePalette.sm),
                        Text(_description, style: TextStylePalette.normalText),
                        SizedBox(height: SpacePalette.base),
                      ],

                      Divider(color: ColorPalette.neutral200, height: 1),
                      SizedBox(height: SpacePalette.base),

                      // Company
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: ColorPalette.neutral800,
                            child: Text('C', style: TextStylePalette.smTitle.copyWith(color: ColorPalette.neutral0)),
                          ),
                          SizedBox(width: SpacePalette.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(companyName, style: TextStylePalette.listTitle),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: SpacePalette.xs),
                                  Text(
                                    '$rating ($reviewCount reviews)',
                                    style: TextStylePalette.listLeading,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),

                      Divider(color: ColorPalette.neutral200, height: 1),
                      SizedBox(height: SpacePalette.base),

                      // Reviews
                      Text('Reviews (10)', style: TextStylePalette.title),
                      SizedBox(height: SpacePalette.base),

                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"Happy to work with you!"',
                        rating: 5,
                      ),
                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"This is a fun project 🎬"',
                        rating: 5,
                      ),
                      _ReviewItem(
                        creatorName: 'Creator Name',
                        comment: '"⭐ 5 stars!!!"',
                        rating: 5,
                      ),

                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 下部固定ボタン
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                border: Border(
                  top: BorderSide(color: ColorPalette.neutral200, width: 1),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: ButtonSizePalette.button,
                  child: ElevatedButton(
                    onPressed: isJoining.value || isAlreadyJoined.value || showAddReview
                        ? (showAddReview ? () => _showAddReviewDialog(context) : null)
                        : handleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyJoined.value
                          ? ColorPalette.neutral400
                          : ColorPalette.neutral800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                      ),
                    ),
                    child: isJoining.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            showAddReview
                                ? 'Add Review'
                                : (isAlreadyJoined.value ? 'Already Joined' : 'Join'),
                            style: TextStylePalette.buttonTextWhite,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'YouTube':
        return Icons.play_arrow;
      case 'Instagram':
        return Icons.camera_alt;
      case 'TikTok':
        return Icons.music_note;
      default:
        return Icons.video_library;
    }
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectShareSheet(
        projectName: _projectName,
        imageUrl: _getImageUrl(),
        pricePerView: _pricePerView,
        viewCount: viewCount,
      ),
    );
  }

  void _showSuccessScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectSuccessScreen()),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add Review feature coming soon...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlatformBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.sm,
        vertical: SpacePalette.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.neutral200),
        borderRadius: BorderRadius.circular(RadiusPalette.mini),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorPalette.neutral800),
          SizedBox(width: SpacePalette.xs),
          Text(label, style: TextStylePalette.smText),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String creatorName;
  final String comment;
  final int rating;

  const _ReviewItem({
    required this.creatorName,
    required this.comment,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.neutral400,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${hashCode % 70}'),
          ),
          SizedBox(width: SpacePalette.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(creatorName, style: TextStylePalette.miniTitle),
                SizedBox(height: SpacePalette.xs),
                Text(comment, style: TextStylePalette.smText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}