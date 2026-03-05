// lib/features/creator/feed/presentation/pages/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../campaign/presentation/pages/detail_screen.dart';
import '../../../../organizer/campaign/presentation/providers/campaign_service_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/creator_tab_index_provider.dart';

class FeedScreen extends HookConsumerWidget {
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
    final tabIndex = ref.watch(creatorTabIndexProvider);
    final isFeedVisible = tabIndex == 1;

    // VideoPlayer controllers
    final vpControllers = useState<Map<int, VideoPlayerController>>({});

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

    Future<VideoPlayerController> getOrCreateVpController(int index) async {
      if (vpControllers.value.containsKey(index)) {
        return vpControllers.value[index]!;
      }
      final submission = submissions.value[index];
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(submission.localVideoUrl!),
      );
      await controller.initialize();
      controller.setLooping(true);
      if (index == currentIndex.value && isFeedVisible) {
        controller.play();
      }
      vpControllers.value = {...vpControllers.value, index: controller};
      return controller;
    }

    // Pause & reset current video
    void pauseAndResetCurrent() {
      final controller = vpControllers.value[currentIndex.value];
      if (controller != null && controller.value.isInitialized) {
        controller.pause();
        controller.seekTo(Duration.zero);
      }
    }

    // Play current video from start
    void playCurrent() {
      final controller = vpControllers.value[currentIndex.value];
      if (controller != null && controller.value.isInitialized) {
        controller.seekTo(Duration.zero);
        controller.play();
      }
    }

    void onPageChanged(int index) {
      // Pause previous
      pauseAndResetCurrent();
      currentIndex.value = index;
      // Play new
      if (isFeedVisible) {
        getOrCreateVpController(index).then((c) {
          c.seekTo(Duration.zero);
          c.play();
        });
      }
    }

    // Pause/reset when tab changes away from Feed
    useEffect(() {
      if (!isFeedVisible) {
        pauseAndResetCurrent();
      } else {
        // Returned to Feed tab — play from start
        playCurrent();
      }
      return null;
    }, [isFeedVisible]);

    // Pause on app background
    final appLifecycleState = useAppLifecycleState();
    useEffect(() {
      if (appLifecycleState == AppLifecycleState.paused ||
          appLifecycleState == AppLifecycleState.inactive) {
        pauseAndResetCurrent();
      } else if (appLifecycleState == AppLifecycleState.resumed && isFeedVisible) {
        playCurrent();
      }
      return null;
    }, [appLifecycleState]);

    useEffect(() {
      Future.wait([loadFeed(), loadLikedIds()]);
      return () {
        for (final c in vpControllers.value.values) {
          c.dispose();
        }
      };
    }, []);

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
                      final isActive = currentIndex.value == index;
                      final isLiked = likedIds.contains(submission.id);

                      return _LocalVideoPage(
                        submission: submission,
                        isActive: isActive,
                        isLiked: isLiked,
                        getOrCreateController: () =>
                            getOrCreateVpController(index),
                        onLike: () => toggleLike(submission.id),
                        onJoin: () {
                          pauseAndResetCurrent();
                          _navigateToCampaign(
                              context, ref, submission.campaignId,
                              onReturn: playCurrent);
                        },
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
          Icon(Icons.play_circle_outline,
              size: 64, color: ColorPalette.neutral400),
          SizedBox(height: SpacePalette.base),
          Text(
            'No videos yet',
            style: TextStylePalette.header
                .copyWith(color: ColorPalette.neutral400),
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Approved videos will appear here',
            style: TextStylePalette.subText
                .copyWith(color: ColorPalette.neutral500),
          ),
        ],
      ),
    );
  }

  void _navigateToCampaign(
      BuildContext context, WidgetRef ref, String campaignId,
      {VoidCallback? onReturn}) async {
    try {
      final campaignService = ref.read(campaignServiceProvider);
      final campaign = await campaignService.getCampaign(campaignId);
      if (campaign != null && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(campaign: campaign),
          ),
        );
        // Returned from detail screen
        onReturn?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load campaign'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// ローカル動画ページ（video_player使用）
class _LocalVideoPage extends HookWidget {
  final Submission submission;
  final bool isActive;
  final bool isLiked;
  final Future<VideoPlayerController> Function() getOrCreateController;
  final VoidCallback onLike;
  final VoidCallback onJoin;

  const _LocalVideoPage({
    required this.submission,
    required this.isActive,
    required this.isLiked,
    required this.getOrCreateController,
    required this.onLike,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final controllerFuture = useMemoized(
      () => isActive ? getOrCreateController() : null,
      [isActive],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        if (submission.videoThumbnailUrl != null)
          Center(
            child: Image.network(
              submission.videoThumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),
        if (isActive && controllerFuture != null)
          FutureBuilder<VideoPlayerController>(
            future: controllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final controller = snapshot.data!;
                return GestureDetector(
                  onTap: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.white,
                  strokeWidth: 2,
                ),
              );
            },
          ),
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
            Positioned(
              left: SpacePalette.base,
              right: 80,
              bottom: bottomPadding + 148,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ColorPalette.neutral400,
                        backgroundImage: submission.creatorAvatarUrl != null
                            ? NetworkImage(submission.creatorAvatarUrl!)
                            : null,
                        child: submission.creatorAvatarUrl == null
                            ? Icon(Icons.person,
                                size: 16, color: ColorPalette.white)
                            : null,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Flexible(
                        child: Text(
                          submission.creatorName ?? 'Creator',
                          style: TextStylePalette.smTitle
                              .copyWith(color: ColorPalette.white),
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
                      style: TextStylePalette.smText
                          .copyWith(color: ColorPalette.white.withOpacity(0.8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (submission.videoTitle != null &&
                      submission.videoTitle!.isNotEmpty) ...[
                    SizedBox(height: SpacePalette.xs),
                    Text(
                      submission.videoTitle!,
                      style: TextStylePalette.smSubText.copyWith(
                          color: ColorPalette.white.withOpacity(0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              right: SpacePalette.base,
              bottom: bottomPadding + 148,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon:
                        isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? ColorPalette.critical500
                        : ColorPalette.white,
                    onTap: onLike,
                  ),
                  SizedBox(height: SpacePalette.lg),
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
