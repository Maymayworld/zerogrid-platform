// lib/features/creator/campaign/presentation/pages/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../data/models/campaign_review.dart';
import '../providers/participation_service_provider.dart';
import '../providers/review_provider.dart';
import '../../../likes/presentation/providers/like_service_provider.dart';
import 'success_screen.dart';
import 'review_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class ProjectDetailScreen extends HookConsumerWidget {
  final Campaign? campaign;  // Campaignオブジェクトを受け取る
  // 後方互換のための個別パラメータ
  final String? imageUrl;
  final String projectName;
  final double pricePerView;
  final int currentViews;
  final int targetViews;
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
    this.currentViews = 0,
    this.targetViews = 0,
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
  int get _targetViews => campaign?.targetViews ?? targetViews;
  int get _currentViews => campaign?.totalViews ?? currentViews;
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

  int _daysLeft(DateTime? deadline) {
    if (deadline == null) return 0;
    return deadline.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = _targetViews > 0 ? _currentViews / _targetViews : 0.0;
    final percentage = (progress * 100).toInt();

    String formatNumber(int n) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 9 / 16;
    final daysLeft = _daysLeft(_deadline);

    final isJoining = useState(false);
    final isAlreadyJoined = useState(false);

    // Organizer profile state
    final organizerName = useState<String?>(null);
    final organizerAvatarUrl = useState<String?>(null);

    // Reviews state
    final reviews = useState<List<CampaignReview>>([]);
    final avgRating = useState(0.0);
    final reviewCountState = useState(0);

    // いいね状態
    final likedIds = ref.watch(likedCampaignIdsProvider);
    final isLiked = campaign != null ? likedIds.contains(campaign!.id) : false;

    // 参加状態・organizer情報・レビュー情報を取得
    useEffect(() {
      if (campaign != null) {
        Future.microtask(() async {
          final participationService = ref.read(participationServiceProvider);
          final reviewService = ref.read(reviewServiceProvider);

          // 並列で取得
          final joinedFuture = participationService.isParticipating(campaign!.id);
          final profileFuture = Supabase.instance.client
              .from('profiles')
              .select('display_name, avatar_url')
              .eq('id', campaign!.organizerId)
              .maybeSingle();
          final reviewsFuture = reviewService.getReviews(campaign!.id);
          final summaryFuture = reviewService.getOrganizerRatingSummary(campaign!.organizerId);

          isAlreadyJoined.value = await joinedFuture;

          final profile = await profileFuture;
          if (profile != null) {
            organizerName.value = profile['display_name'] as String?;
            organizerAvatarUrl.value = profile['avatar_url'] as String?;
          }

          reviews.value = await reviewsFuture;

          final summary = await summaryFuture;
          avgRating.value = summary.average;
          reviewCountState.value = summary.count;
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
              content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
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
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ヘッダー画像 + AppBar
              SliverAppBar(
                expandedHeight: imageHeight,
                pinned: true,
                backgroundColor: ColorPalette.white,
                elevation: 0,
                leading: _CircleIconButton(
                  icon: PhosphorIconsRegular.arrowLeft,
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    _getImageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: ColorPalette.neutral200,
                        child: Center(
                          child: Icon(PhosphorIconsFill.image, size: 50, color: ColorPalette.neutral400),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: SpacePalette.base),

                    // プラットフォーム + 基本情報カード
                    _CardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // プラットフォームバッジ（CategoryChip使用）
                          Wrap(
                            spacing: SpacePalette.sm,
                            runSpacing: SpacePalette.sm,
                            children: _platforms.map((platform) {
                              return CategoryChip(
                                iconWidget: PlatformIcon.fromPlatform(platform, size: CategoryChipSize.iconSize),
                                label: platform,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: SpacePalette.base),

                          // Project Name
                          Text(_projectName, style: TextStylePalette.smallHeader),
                          SizedBox(height: SpacePalette.sm),

                          // Price per view + days left
                          Row(
                            children: [
                              Text(
                                '¥${_pricePerView.toStringAsFixed(0)} / 1,000 Views',
                                style: TextStylePalette.header,
                              ),
                              SizedBox(width: SpacePalette.sm),
                              if (daysLeft > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: SpacePalette.sm,
                                    vertical: SpacePalette.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.positive50,
                                    borderRadius: BorderRadius.circular(RadiusPalette.full),
                                  ),
                                  child: Text(
                                    '$daysLeft days left!',
                                    style: TextStyle(
                                      color: ColorPalette.positive600,
                                      fontSize: FontSizePalette.size12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: SpacePalette.base),

                          // 視聴回数とプログレスバー
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatNumber(_currentViews)} / ${formatNumber(_targetViews)} views',
                                style: TextStylePalette.bigText,
                              ),
                              Text('$percentage%', style: TextStylePalette.bigSubText),
                            ],
                          ),
                          SizedBox(height: SpacePalette.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: ColorPalette.neutral200,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.positive500),
                            ),
                          ),
                          SizedBox(height: SpacePalette.sm),

                          // Campaign period
                          Text(
                            'Campaign period: ${_formatDeadline(_deadline)}',
                            style: TextStylePalette.smSubText,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: CardSectionSize.spacing),

                    // Company カード（実データ）
                    _CardSection(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: ColorPalette.neutral200,
                            backgroundImage: organizerAvatarUrl.value != null
                                ? NetworkImage(organizerAvatarUrl.value!)
                                : null,
                            child: organizerAvatarUrl.value == null
                                ? Icon(PhosphorIconsRegular.buildings, size: 20, color: ColorPalette.neutral600)
                                : null,
                          ),
                          SizedBox(width: SpacePalette.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  organizerName.value ?? companyName,
                                  style: TextStylePalette.listTitle,
                                ),
                                SizedBox(height: SpacePalette.xs),
                                Row(
                                  children: [
                                    Icon(PhosphorIconsFill.star, size: 14, color: Colors.amber),
                                    SizedBox(width: SpacePalette.xs),
                                    Text(
                                      reviewCountState.value > 0
                                          ? '${avgRating.value.toStringAsFixed(1)} (${reviewCountState.value})'
                                          : AppLocalizations.of(context)!.noReviewsYet,
                                      style: TextStylePalette.listLeading,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: CardSectionSize.spacing),

                    // Description カード
                    if (_description.isNotEmpty)
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.description, style: TextStylePalette.title),
                            SizedBox(height: SpacePalette.sm),
                            Text(_description, style: TextStylePalette.normalText),
                          ],
                        ),
                      ),

                    if (_description.isNotEmpty) SizedBox(height: CardSectionSize.spacing),

                    // Reviews カード（タップでレビュー一覧へ遷移）
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewScreen(
                              campaign: campaign,
                              showJoinButton: !isAlreadyJoined.value && !showAddReview,
                              showAddReview: showAddReview || isAlreadyJoined.value,
                            ),
                          ),
                        );
                        // レビュー画面から戻った時にデータをリフレッシュ
                        if (campaign != null) {
                          final reviewService = ref.read(reviewServiceProvider);
                          reviews.value = await reviewService.getReviews(campaign!.id);
                          final summary = await reviewService.getOrganizerRatingSummary(campaign!.organizerId);
                          avgRating.value = summary.average;
                          reviewCountState.value = summary.count;
                        }
                      },
                      child: _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reviews header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.reviews, style: TextStylePalette.title),
                                Row(
                                  children: [
                                    if (reviewCountState.value > 0) ...[
                                      Icon(PhosphorIconsFill.star, size: 16, color: Colors.amber),
                                      SizedBox(width: SpacePalette.xs),
                                      Text(avgRating.value.toStringAsFixed(1), style: TextStylePalette.listTitle),
                                      SizedBox(width: SpacePalette.xs),
                                      Text('(${reviewCountState.value})', style: TextStylePalette.listLeading),
                                      SizedBox(width: SpacePalette.xs),
                                    ],
                                    Icon(PhosphorIconsRegular.caretRight, size: 18, color: ColorPalette.neutral400),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: SpacePalette.base),

                            if (reviews.value.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                                child: Text(AppLocalizations.of(context)!.noReviewsYet, style: TextStylePalette.smSubText),
                              )
                            else
                              ...reviews.value.take(3).map((review) => _ReviewItem(
                                creatorName: review.reviewerName ?? 'Anonymous',
                                comment: review.comment,
                                rating: review.rating,
                                avatarUrl: review.reviewerAvatarUrl,
                              )),
                          ],
                        ),
                      ),
                    ),

                    // 下部ボタンのスペース確保
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // 下部固定ボタン（背景ボックスなし、下部から16px離す）
          Positioned(
            left: SpacePalette.base,
            right: SpacePalette.base,
            bottom: SpacePalette.base + MediaQuery.of(context).padding.bottom,
            child: SizedBox(
              width: double.infinity,
              height: ButtonSizePalette.button,
              child: ElevatedButton(
                onPressed: isJoining.value
                    ? null
                    : (isAlreadyJoined.value || showAddReview)
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  campaign: campaign,
                                  showJoinButton: false,
                                  showAddReview: true,
                                ),
                              ),
                            );
                            // リフレッシュ
                            if (campaign != null) {
                              final reviewService = ref.read(reviewServiceProvider);
                              reviews.value = await reviewService.getReviews(campaign!.id);
                              final summary = await reviewService.getOrganizerRatingSummary(campaign!.organizerId);
                              avgRating.value = summary.average;
                              reviewCountState.value = summary.count;
                            }
                          }
                        : handleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.smashedPumpkin600,
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
                        (isAlreadyJoined.value || showAddReview)
                            ? AppLocalizations.of(context)!.leaveAReview
                            : AppLocalizations.of(context)!.joinCampaign,
                        style: TextStylePalette.buttonTextWhite,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _showSuccessScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectSuccessScreen()),
    );
  }

}

/// 丸い半透明背景のアイコンボタン（AppBar上で画像の上に表示）
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SpacePalette.sm),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: ColorPalette.neutral800, size: 20),
          onPressed: onPressed,
          constraints: BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// 白背景カードセクション（CardSectionSizeの定数を参照）
class _CardSection extends StatelessWidget {
  final Widget child;

  const _CardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: CardSectionSize.horizontalMargin),
      padding: EdgeInsets.all(CardSectionSize.padding),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(CardSectionSize.radius),
      ),
      child: child,
    );
  }
}


class _ReviewItem extends StatelessWidget {
  final String creatorName;
  final String comment;
  final int rating;
  final String? avatarUrl;

  const _ReviewItem({
    required this.creatorName,
    required this.comment,
    required this.rating,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: ColorPalette.neutral300,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(PhosphorIconsFill.user, size: 18, color: ColorPalette.neutral500)
                : null,
          ),
          SizedBox(width: SpacePalette.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(creatorName, style: TextStylePalette.miniTitle),
                    SizedBox(width: SpacePalette.sm),
                    ...List.generate(rating, (_) =>
                      Icon(PhosphorIconsFill.star, size: 12, color: Colors.amber)),
                  ],
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  comment,
                  style: TextStylePalette.smText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
