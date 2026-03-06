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
import 'package:zero_grid/l10n/app_localizations.dart';

class FeedScreen extends HookConsumerWidget {
  final List<Submission>? initialSubmissions;
  final int initialIndex;

  const FeedScreen({Key? key, this.initialSubmissions, this.initialIndex = 0})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = useState<List<Submission>>(initialSubmissions ?? []);
    final isLoading = useState(initialSubmissions == null);
    final currentIndex = useState(initialIndex);
    final likedIds = ref.watch(feedLikedIdsProvider);
    final pageController = usePageController(initialPage: initialIndex);
    final isStandalone = initialSubmissions != null;
    final tabIndex = ref.watch(creatorTabIndexProvider);
    final isFeedVisible = isStandalone || tabIndex == 1;

    // Video controllers managed centrally — child widgets receive them directly
    final vpControllers = useState<Map<int, VideoPlayerController>>({});
    // Guard against concurrent creation for the same index
    final creatingGuard = useRef(<int>{});

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
          ref.read(feedLikedIdsProvider.notifier).state = {
            ...current,
            submissionId,
          };
        } else {
          ref.read(feedLikedIdsProvider.notifier).state = {...current}
            ..remove(submissionId);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.errorMessage(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    /// Initialize a controller without auto-play. Race-guarded.
    Future<void> ensureControllerReady(int index) async {
      if (index < 0 || index >= submissions.value.length) return;
      if (vpControllers.value.containsKey(index)) return;
      if (creatingGuard.value.contains(index)) return;

      creatingGuard.value.add(index);
      try {
        final submission = submissions.value[index];
        if (submission.localVideoUrl == null) return;
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(submission.localVideoUrl!),
        );
        await controller.initialize();
        controller.setLooping(true);
        // Add to map — triggers FeedScreen rebuild, passing controller to child
        vpControllers.value = {...vpControllers.value, index: controller};
      } catch (e) {
        debugPrint('Failed to init video $index: $e');
      } finally {
        creatingGuard.value.remove(index);
      }
    }

    /// Pause and reset ALL controllers
    void pauseAll() {
      for (final c in vpControllers.value.values) {
        if (c.value.isInitialized) {
          c.pause();
          c.seekTo(Duration.zero);
        }
      }
    }

    /// Play the current video (only if Feed is visible)
    void playCurrentIfVisible() {
      final visible = isStandalone || ref.read(creatorTabIndexProvider) == 1;
      if (!visible) return;
      final controller = vpControllers.value[currentIndex.value];
      if (controller != null && controller.value.isInitialized) {
        controller.seekTo(Duration.zero);
        controller.play();
      }
    }

    void onPageChanged(int index) {
      // Pause previous video
      final prevController = vpControllers.value[currentIndex.value];
      if (prevController != null && prevController.value.isInitialized) {
        prevController.pause();
        prevController.seekTo(Duration.zero);
      }
      currentIndex.value = index;
      // Create (if needed) and play new video
      ensureControllerReady(index).then((_) {
        // Verify still on this page and feed is visible
        if (currentIndex.value == index) {
          playCurrentIfVisible();
        }
      });
    }

    // Handle tab visibility changes
    useEffect(() {
      if (!isFeedVisible) {
        pauseAll();
      } else if (submissions.value.isNotEmpty) {
        ensureControllerReady(currentIndex.value).then((_) {
          playCurrentIfVisible();
        });
      }
      return null;
    }, [isFeedVisible]);

    // Handle app lifecycle
    final appLifecycleState = useAppLifecycleState();
    useEffect(() {
      if (appLifecycleState == AppLifecycleState.paused ||
          appLifecycleState == AppLifecycleState.inactive) {
        pauseAll();
      } else if (appLifecycleState == AppLifecycleState.resumed) {
        playCurrentIfVisible();
      }
      return null;
    }, [appLifecycleState]);

    // Initial load
    useEffect(() {
      Future.wait([loadFeed(), loadLikedIds()]).then((_) {
        if (submissions.value.isNotEmpty) {
          ensureControllerReady(currentIndex.value).then((_) {
            playCurrentIfVisible();
          });
        }
      });
      return () {
        for (final c in vpControllers.value.values) {
          c.dispose();
        }
      };
    }, []);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorPalette.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: ColorPalette.white),
                  )
                : submissions.value.isEmpty
                ? _buildEmptyState(context)
                : PageView.builder(
                    controller: pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: onPageChanged,
                    itemCount: submissions.value.length,
                    itemBuilder: (context, index) {
                      final submission = submissions.value[index];
                      final controller = vpControllers.value[index];
                      final isLiked = likedIds.contains(submission.id);

                      return _LocalVideoPage(
                        submission: submission,
                        controller: controller,
                        isLiked: isLiked,
                        onLike: () => toggleLike(submission.id),
                        onJoin: () {
                          pauseAll();
                          _navigateToCampaign(
                            context,
                            ref,
                            submission.campaignId,
                            onReturn: playCurrentIfVisible,
                          );
                        },
                      );
                    },
                  ),
            // 戻るボタン（スタンドアロン時のみ）
            if (isStandalone)
              Positioned(
                top: MediaQuery.of(context).padding.top + SpacePalette.sm,
                left: SpacePalette.sm,
                child: GestureDetector(
                  onTap: () {
                    pauseAll();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ColorPalette.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorPalette.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: ColorPalette.neutral400,
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            AppLocalizations.of(context)!.noSubmissionsYet,
            style: TextStylePalette.header.copyWith(
              color: ColorPalette.neutral400,
            ),
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            AppLocalizations.of(context)!.creatorsWillSubmitHere,
            style: TextStylePalette.subText.copyWith(
              color: ColorPalette.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCampaign(
    BuildContext context,
    WidgetRef ref,
    String campaignId, {
    VoidCallback? onReturn,
  }) async {
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
        onReturn?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToLoadCampaigns),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Video page — receives controller directly from parent (no async creation)
class _LocalVideoPage extends StatelessWidget {
  final Submission submission;
  final VideoPlayerController? controller;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onJoin;

  const _LocalVideoPage({
    required this.submission,
    this.controller,
    required this.isLiked,
    required this.onLike,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final hasVideo = controller != null && controller!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        // Thumbnail as background (visible while loading)
        if (submission.videoThumbnailUrl != null)
          Center(
            child: Image.network(
              submission.videoThumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),
        // Video player layered on top
        if (hasVideo)
          GestureDetector(
            onTap: () {
              if (controller!.value.isPlaying) {
                controller!.pause();
              } else {
                controller!.play();
              }
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
            ),
          )
        else
          Center(
            child: CircularProgressIndicator(
              color: ColorPalette.white,
              strokeWidth: 2,
            ),
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
              bottom: bottomPadding + 60,
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
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: ColorPalette.white,
                              )
                            : null,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Flexible(
                        child: Text(
                          submission.creatorName ??
                              AppLocalizations.of(context)!.creator,
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
                  if (submission.videoTitle != null &&
                      submission.videoTitle!.isNotEmpty) ...[
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
            Positioned(
              right: SpacePalette.base,
              bottom: bottomPadding + 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? ColorPalette.critical500
                        : ColorPalette.white,
                    onTap: onLike,
                  ),
                  SizedBox(height: SpacePalette.base),
                  _ActionButton(
                    icon: Icons.arrow_forward_ios,
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
