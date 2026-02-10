// lib/features/creator/campaign/presentation/pages/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../providers/participation_service_provider.dart';
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

  // デモ用レビューデータ
  static final List<_ReviewData> _demoReviews = [
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"Happy to work with you!"',
      avatarIndex: 1,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC}"',
      avatarIndex: 2,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"ez 5 stars!!"',
      avatarIndex: 3,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC} This is a fun project \u{1F3AC}"',
      avatarIndex: 4,
      isLong: true,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"ez 5 stars!!"',
      avatarIndex: 5,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"ez 5 stars!!"',
      avatarIndex: 6,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"ez 5 stars!!"',
      avatarIndex: 7,
    ),
    _ReviewData(
      creatorName: 'Creator Name',
      comment: '"ez 5 stars!!"',
      avatarIndex: 8,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isJoining = useState(false);
    final isAlreadyJoined = useState(false);

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

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.fromLTRB(
              SpacePalette.base,
              SpacePalette.base,
              SpacePalette.base,
              100,
            ),
            itemCount: _demoReviews.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: SpacePalette.lg),
            itemBuilder: (context, index) {
              final review = _demoReviews[index];
              return _ReviewListItem(review: review);
            },
          ),

          // 下部固定Joinボタン
          if (showJoinButton)
            Positioned(
              left: SpacePalette.base,
              right: SpacePalette.base,
              bottom: SpacePalette.base + MediaQuery.of(context).padding.bottom,
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: isJoining.value || isAlreadyJoined.value
                      ? null
                      : handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAlreadyJoined.value
                        ? ColorPalette.neutral400
                        : ColorPalette.smashedPumpkin600,
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
                          isAlreadyJoined.value ? 'Already Joined' : 'Join',
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

/// レビューデータモデル（デモ用）
class _ReviewData {
  final String creatorName;
  final String comment;
  final int avatarIndex;
  final bool isLong;

  const _ReviewData({
    required this.creatorName,
    required this.comment,
    required this.avatarIndex,
    this.isLong = false,
  });
}

/// レビュー一覧の各アイテム
class _ReviewListItem extends StatefulWidget {
  final _ReviewData review;

  const _ReviewListItem({required this.review});

  @override
  State<_ReviewListItem> createState() => _ReviewListItemState();
}

class _ReviewListItemState extends State<_ReviewListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: ColorPalette.neutral300,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?img=${review.avatarIndex}',
          ),
        ),
        SizedBox(width: SpacePalette.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.creatorName, style: TextStylePalette.miniTitle),
              SizedBox(height: SpacePalette.xs),
              if (review.isLong && !_expanded) ...[
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
