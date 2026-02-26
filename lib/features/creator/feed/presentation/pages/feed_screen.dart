// lib/features/creator/feed/presentation/pages/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/utils/youtube_utils.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import '../providers/feed_provider.dart';

class FeedScreen extends HookConsumerWidget {
  /// プロフィールグリッドから開く場合に使用
  final List<Submission>? initialSubmissions;
  final int initialIndex;

  const FeedScreen({
    Key? key,
    this.initialSubmissions,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = useState<List<Submission>>(initialSubmissions ?? []);
    final isLoading = useState(initialSubmissions == null);
    final currentIndex = useState(initialIndex);
    final likedIds = ref.watch(feedLikedIdsProvider);
    final pageController = usePageController(initialPage: initialIndex);

    // YouTube コントローラーの管理
    final controllers = useState<Map<int, YoutubePlayerController>>({});

    Future<void> loadFeed() async {
      if (initialSubmissions != null) return;
      isLoading.value = true;
      try {
        final feedService = ref.read(feedServiceProvider);
        final results = await feedService.getFeedSubmissions();
        submissions.value = results;
      } catch (e) {
        debugPrint('Failed to load feed: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> loadLikedIds() async {
      try {
        final feedService = ref.read(feedServiceProvider);
        final ids = await feedService.getLikedSubmissionIds();
        ref.read(feedLikedIdsProvider.notifier).state = ids;
      } catch (e) {
        debugPrint('Failed to load liked IDs: $e');
      }
    }

    Future<void> toggleLike(String submissionId) async {
      final feedService = ref.read(feedServiceProvider);
      final current = ref.read(feedLikedIdsProvider);
      try {
        final isNowLiked = await feedService.toggleLike(submissionId);
        if (isNowLiked) {
          ref.read(feedLikedIdsProvider.notifier).state = {...current, submissionId};
        } else {
          ref.read(feedLikedIdsProvider.notifier).state = {...current}..remove(submissionId);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    YoutubePlayerController getOrCreateController(int index) {
      if (controllers.value.containsKey(index)) {
        return controllers.value[index]!;
      }
      final submission = submissions.value[index];
      final videoId = extractYoutubeVideoId(submission.videoUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: ${submission.videoUrl}');
      }
      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: index == currentIndex.value,
        params: const YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          enableCaption: false,
          playsInline: true,
        ),
      );
      controllers.value = {...controllers.value, index: controller};
      return controller;
    }

    void onPageChanged(int index) {
      // 前のページを一時停止
      controllers.value[currentIndex.value]?.pauseVideo();
      currentIndex.value = index;
      // 新しいページを再生
      try {
        final controller = getOrCreateController(index);
        controller.playVideo();
      } catch (_) {}
    }

    useEffect(() {
      loadFeed();
      loadLikedIds();
      return () {
        // 全コントローラーをdispose
        for (final c in controllers.value.values) {
          c.close();
        }
      };
    }, []);

    // ステータスバーを暗くする
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.white,
                ),
              )
            : submissions.value.isEmpty
                ? _buildEmptyState()
                : PageView.builder(
                    controller: pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: onPageChanged,
                    itemCount: submissions.value.length,
                    itemBuilder: (context, index) {
                      final submission = submissions.value[index];
                      final videoId = extractYoutubeVideoId(submission.videoUrl);
                      final isActive = currentIndex.value == index;
                      final isLiked = likedIds.contains(submission.id);

                      return _FeedVideoPage(
                        submission: submission,
                        videoId: videoId,
                        isActive: isActive,
                        isLiked: isLiked,
                        getOrCreateController: () => getOrCreateController(index),
                        onLike: () => toggleLike(submission.id),
                        onJoin: () => _navigateToCampaign(context, ref, submission.campaignId),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline, size: 64, color: ColorPalette.neutral400),
          SizedBox(height: SpacePalette.base),
          Text(
            'No videos yet',
            style: TextStylePalette.header.copyWith(color: ColorPalette.neutral400),
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Approved videos will appear here',
            style: TextStylePalette.subText.copyWith(color: ColorPalette.neutral500),
          ),
        ],
      ),
    );
  }

  void _navigateToCampaign(BuildContext context, WidgetRef ref, String campaignId) async {
    try {
      final campaignService = ref.read(campaignServiceProvider);
      final campaign = await campaignService.getCampaign(campaignId);
      if (campaign != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(campaign: campaign),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load campaign'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// フィードの1ページ分（動画 + オーバーレイUI）
class _FeedVideoPage extends StatelessWidget {
  final Submission submission;
  final String? videoId;
  final bool isActive;
  final bool isLiked;
  final YoutubePlayerController Function() getOrCreateController;
  final VoidCallback onLike;
  final VoidCallback onJoin;

  const _FeedVideoPage({
    required this.submission,
    required this.videoId,
    required this.isActive,
    required this.isLiked,
    required this.getOrCreateController,
    required this.onLike,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = videoId != null
        ? getYoutubeThumbnailUrl(videoId!)
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 黒背景
        Container(color: Colors.black),
        // サムネイル（常に表示、プレイヤーの下に）
        if (thumbnailUrl != null)
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),
          ),
        // YouTube プレイヤー（アクティブ時のみ）
        if (isActive && videoId != null)
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: getOrCreateController(),
              ),
            ),
          ),
        // オーバーレイUI
        _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned.fill(
      child: SafeArea(
        child: Stack(
          children: [
            // 左下: クリエイター情報 + キャンペーン名
            Positioned(
              left: SpacePalette.base,
              right: 80,
              bottom: bottomPadding + 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // クリエイター
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ColorPalette.neutral400,
                        backgroundImage: submission.creatorAvatarUrl != null
                            ? NetworkImage(submission.creatorAvatarUrl!)
                            : null,
                        child: submission.creatorAvatarUrl == null
                            ? Icon(Icons.person, size: 16, color: ColorPalette.white)
                            : null,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Flexible(
                        child: Text(
                          submission.creatorName ?? 'Creator',
                          style: TextStylePalette.smTitle.copyWith(
                            color: ColorPalette.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (submission.campaignName != null) ...[
                    SizedBox(height: SpacePalette.sm),
                    Text(
                      submission.campaignName!,
                      style: TextStylePalette.smText.copyWith(
                        color: ColorPalette.white.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (submission.videoTitle != null && submission.videoTitle!.isNotEmpty) ...[
                    SizedBox(height: SpacePalette.xs),
                    Text(
                      submission.videoTitle!,
                      style: TextStylePalette.smSubText.copyWith(
                        color: ColorPalette.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // 右下: いいね + JOINボタン
            Positioned(
              right: SpacePalette.base,
              bottom: bottomPadding + 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // いいねボタン
                  _ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? ColorPalette.critical500 : ColorPalette.white,
                    onTap: onLike,
                  ),
                  SizedBox(height: SpacePalette.lg),
                  // JOINボタン
                  _ActionButton(
                    icon: Icons.arrow_forward_ios,
                    label: 'JOIN',
                    color: ColorPalette.white,
                    onTap: onJoin,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorPalette.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (label != null) ...[
            SizedBox(height: SpacePalette.xs),
            Text(
              label!,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
