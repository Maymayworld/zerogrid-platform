// lib/features/creator/campaign/presentation/pages/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../data/models/campaign_review.dart';
import '../../data/services/review_service.dart';
import '../providers/participation_service_provider.dart';
import '../providers/review_provider.dart';
import 'success_screen.dart';

class ReviewScreen extends HookConsumerWidget {
  final Campaign? campaign;
  final bool showJoinButton;
  final bool showAddReview;

  const ReviewScreen({
    Key? key,
    this.campaign,
    this.showJoinButton = true,
    this.showAddReview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJoining = useState(false);
    final isAlreadyJoined = useState(false);
    final reviews = useState<List<CampaignReview>>([]);
    final isLoading = useState(true);
    final hasReviewed = useState(false);

    // データ取得
    Future<void> loadData() async {
      if (campaign == null) {
        isLoading.value = false;
        return;
      }
      try {
        final reviewService = ref.read(reviewServiceProvider);
        final participationService = ref.read(participationServiceProvider);

        final results = await Future.wait([
          reviewService.getReviews(campaign!.id),
          participationService.isParticipating(campaign!.id),
          reviewService.hasReviewed(campaign!.id),
        ]);

        reviews.value = results[0] as List<CampaignReview>;
        isAlreadyJoined.value = results[1] as bool;
        hasReviewed.value = results[2] as bool;
      } catch (e) {
        // ignore
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadData();
      return null;
    }, [campaign?.id]);

    // 参加処理
    Future<void> handleJoin() async {
      if (campaign == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProjectSuccessScreen()),
        );
        return;
      }

      isJoining.value = true;
      try {
        final participationService = ref.read(participationServiceProvider);
        await participationService.joinCampaign(campaign!.id);

        final currentIds = ref.read(participatingCampaignIdsProvider);
        ref.read(participatingCampaignIdsProvider.notifier).state = {
          ...currentIds,
          campaign!.id,
        };

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProjectSuccessScreen()),
          );
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

    // レビュー追加ダイアログ
    Future<void> showAddReviewDialog() async {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _AddReviewSheet(
          campaignId: campaign!.id,
          reviewService: ref.read(reviewServiceProvider),
        ),
      );
      if (result == true) {
        // リフレッシュ
        await loadData();
      }
    }

    final bool canAddReview = (showAddReview || isAlreadyJoined.value) && !hasReviewed.value;

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reviews', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (isLoading.value)
            Center(
              child: CircularProgressIndicator(color: ColorPalette.neutral800),
            )
          else if (reviews.value.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 48, color: ColorPalette.neutral300),
                  SizedBox(height: SpacePalette.base),
                  Text('No reviews yet', style: TextStylePalette.subText),
                  if (canAddReview) ...[
                    SizedBox(height: SpacePalette.sm),
                    Text('Be the first to leave a review!', style: TextStylePalette.smSubText),
                  ],
                ],
              ),
            )
          else
            ListView.separated(
              padding: EdgeInsets.fromLTRB(
                SpacePalette.base,
                SpacePalette.base,
                SpacePalette.base,
                100,
              ),
              itemCount: reviews.value.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: SpacePalette.lg),
              itemBuilder: (context, index) {
                final review = reviews.value[index];
                return _ReviewListItem(review: review);
              },
            ),

          // 下部固定ボタン
          if (showJoinButton || canAddReview)
            Positioned(
              left: SpacePalette.base,
              right: SpacePalette.base,
              bottom: SpacePalette.base + MediaQuery.of(context).padding.bottom,
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: canAddReview
                      ? showAddReviewDialog
                      : (showJoinButton && !isAlreadyJoined.value
                          ? (isJoining.value ? null : handleJoin)
                          : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.smashedPumpkin600,
                    disabledBackgroundColor: ColorPalette.neutral400,
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
                          canAddReview
                              ? 'Add Review'
                              : (isAlreadyJoined.value ? 'Already Joined' : 'Join'),
                          style: TextStylePalette.buttonTextWhite,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// レビュー一覧の各アイテム
class _ReviewListItem extends StatefulWidget {
  final CampaignReview review;

  const _ReviewListItem({required this.review});

  @override
  State<_ReviewListItem> createState() => _ReviewListItemState();
}

class _ReviewListItemState extends State<_ReviewListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final isLong = review.comment.length > 120;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: ColorPalette.neutral300,
          backgroundImage: review.reviewerAvatarUrl != null
              ? NetworkImage(review.reviewerAvatarUrl!)
              : null,
          child: review.reviewerAvatarUrl == null
              ? Icon(Icons.person, size: 18, color: ColorPalette.neutral500)
              : null,
        ),
        SizedBox(width: SpacePalette.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.reviewerName ?? 'Anonymous',
                    style: TextStylePalette.miniTitle,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  ...List.generate(review.rating, (_) =>
                    Icon(Icons.star, size: 12, color: Colors.amber)),
                  ...List.generate(5 - review.rating, (_) =>
                    Icon(Icons.star_border, size: 12, color: ColorPalette.neutral300)),
                ],
              ),
              SizedBox(height: SpacePalette.xs),
              if (isLong && !_expanded) ...[
                Text(
                  review.comment,
                  style: TextStylePalette.smText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SpacePalette.xs),
                GestureDetector(
                  onTap: () => setState(() => _expanded = true),
                  child: Text(
                    'View More',
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.smashedPumpkin600,
                    ),
                  ),
                ),
              ] else
                Text(
                  review.comment,
                  style: TextStylePalette.smText,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// レビュー追加ボトムシート
class _AddReviewSheet extends StatefulWidget {
  final String campaignId;
  final ReviewService reviewService;

  const _AddReviewSheet({
    required this.campaignId,
    required this.reviewService,
  });

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.reviewService.createReview(
        campaignId: widget.campaignId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted!'),
            backgroundColor: ColorPalette.positive500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: 80),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      child: Padding(
        padding: EdgeInsets.all(SpacePalette.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.lg),

            Text('Leave a Review', style: TextStylePalette.smallHeader),
            SizedBox(height: SpacePalette.lg),

            // Star rating
            Text('Rating', style: TextStylePalette.smTitle),
            SizedBox(height: SpacePalette.sm),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: EdgeInsets.only(right: SpacePalette.sm),
                    child: Icon(
                      starIndex <= _selectedRating ? Icons.star : Icons.star_border,
                      size: 36,
                      color: starIndex <= _selectedRating
                          ? Colors.amber
                          : ColorPalette.neutral300,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: SpacePalette.lg),

            // Comment
            Text('Comment', style: TextStylePalette.smTitle),
            SizedBox(height: SpacePalette.sm),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStylePalette.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  borderSide: BorderSide(color: ColorPalette.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  borderSide: BorderSide(color: ColorPalette.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  borderSide: BorderSide(color: ColorPalette.neutral800),
                ),
                contentPadding: EdgeInsets.all(SpacePalette.base),
              ),
            ),
            SizedBox(height: SpacePalette.lg),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: ButtonSizePalette.button,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.smashedPumpkin600,
                  disabledBackgroundColor: ColorPalette.neutral400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Submit Review', style: TextStylePalette.buttonTextWhite),
              ),
            ),
            SizedBox(height: SpacePalette.base),
          ],
        ),
      ),
    );
  }
}
