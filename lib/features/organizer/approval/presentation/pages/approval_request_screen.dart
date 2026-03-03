// lib/features/organizer/approval/presentation/pages/approval_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../data/models/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalRequestScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ApprovalRequestScreen> createState() => _ApprovalRequestScreenState();
}

class _ApprovalRequestScreenState extends ConsumerState<ApprovalRequestScreen> {
  Offset _dragOffset = Offset.zero;
  SwipeDirection? _swipeDirection;
  bool _isProcessing = false;

  VideoPlayerController? _currentController;
  VideoPlayerController? _nextController;
  bool _isVideoReady = false;

  List<ApprovalRequest> _requests = [];
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentController?.dispose();
    _nextController?.dispose();
    super.dispose();
  }

  void _initVideoForIndex(int index) {
    if (index >= _requests.length) return;
    final request = _requests[index];
    if (!request.hasLocalVideo) return;

    _currentController?.dispose();
    _currentController = _nextController;
    _nextController = null;

    if (_currentController != null && _currentController!.value.isInitialized) {
      setState(() => _isVideoReady = true);
      _currentController!.play();
    } else {
      setState(() => _isVideoReady = false);
      _currentController = VideoPlayerController.networkUrl(Uri.parse(request.localVideoUrl!));
      _currentController!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoReady = true);
          _currentController!.setLooping(true);
          _currentController!.play();
        }
      });
    }

    // Preload next
    _preloadNext(index + 1);
  }

  void _preloadNext(int index) {
    if (index >= _requests.length) return;
    final request = _requests[index];
    if (!request.hasLocalVideo) return;

    _nextController?.dispose();
    _nextController = VideoPlayerController.networkUrl(Uri.parse(request.localVideoUrl!));
    _nextController!.initialize().then((_) {
      _nextController?.setLooping(true);
    });
  }

  void _loadFirstVideo() {
    if (_requests.isNotEmpty && _requests[0].hasLocalVideo) {
      _currentController?.dispose();
      _currentController = VideoPlayerController.networkUrl(Uri.parse(_requests[0].localVideoUrl!));
      _currentController!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoReady = true);
          _currentController!.setLooping(true);
          _currentController!.play();
          _preloadNext(1);
        }
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isProcessing) return;
    setState(() {
      _dragOffset += details.delta;
      if (_dragOffset.dx > 50) {
        _swipeDirection = SwipeDirection.right;
      } else if (_dragOffset.dx < -50) {
        _swipeDirection = SwipeDirection.left;
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isProcessing) return;
    if (_currentIndex >= _requests.length) return;

    final velocity = details.velocity.pixelsPerSecond;
    final shouldSwipe = _dragOffset.dx.abs() > 100 || velocity.dx.abs() > 500;

    if (shouldSwipe && _swipeDirection != null) {
      _handleSwipe(_requests[_currentIndex], _swipeDirection!);
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() {
    setState(() {
      _dragOffset = Offset.zero;
      _swipeDirection = null;
    });
  }

  Future<void> _handleSwipe(ApprovalRequest request, SwipeDirection direction) async {
    _isProcessing = true;

    setState(() {
      _dragOffset = direction == SwipeDirection.right ? Offset(500, 0) : Offset(-500, 0);
    });

    await Future.delayed(const Duration(milliseconds: 200));

    final notifier = ref.read(approvalNotifierProvider.notifier);
    switch (direction) {
      case SwipeDirection.right:
        await notifier.approve(request.id, request: request);
        break;
      case SwipeDirection.left:
        await notifier.reject(request.id, request: request);
        break;
    }

    _currentController?.pause();

    setState(() {
      _requests.removeAt(_currentIndex);
      _dragOffset = Offset.zero;
      _swipeDirection = null;
      _isVideoReady = false;
    });

    if (_requests.isNotEmpty) {
      _initVideoForIndex(_currentIndex.clamp(0, _requests.length - 1));
    } else {
      _currentController?.dispose();
      _currentController = null;
      _nextController?.dispose();
      _nextController = null;
    }

    _isProcessing = false;
    ref.invalidate(pendingRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: requestsAsync.when(
        data: (requests) {
          // Filter to only those with local video
          final videoRequests = requests.where((r) => r.hasLocalVideo).toList();

          if (_requests.isEmpty && videoRequests.isNotEmpty) {
            _requests = List.from(videoRequests);
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstVideo());
          }

          if (_requests.isEmpty) {
            return _buildEmptyState();
          }

          final current = _requests[_currentIndex.clamp(0, _requests.length - 1)];
          return _buildVideoView(current);
        },
        loading: () => Center(child: CircularProgressIndicator(color: ColorPalette.white)),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: ColorPalette.white))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: ColorPalette.positive500),
            SizedBox(height: SpacePalette.base),
            Text('All caught up!', style: TextStylePalette.title.copyWith(color: ColorPalette.white)),
            SizedBox(height: SpacePalette.sm),
            Text('No pending video reviews', style: TextStylePalette.normalText.copyWith(color: ColorPalette.neutral400)),
            SizedBox(height: SpacePalette.lg),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.lg, vertical: SpacePalette.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorPalette.neutral500),
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Text('Go back', style: TextStylePalette.normalText.copyWith(color: ColorPalette.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView(ApprovalRequest request) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        if (_currentController != null && _currentController!.value.isInitialized) {
          if (_currentController!.value.isPlaying) {
            _currentController!.pause();
          } else {
            _currentController!.play();
          }
          setState(() {});
        }
      },
      child: AnimatedContainer(
        duration: _isProcessing ? Duration(milliseconds: 200) : Duration.zero,
        transform: Matrix4.translationValues(_dragOffset.dx, 0, 0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isVideoReady && _currentController != null && _currentController!.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _currentController!.value.aspectRatio,
                  child: VideoPlayer(_currentController!),
                ),
              )
            else
              Center(child: CircularProgressIndicator(color: ColorPalette.white)),

            // Swipe overlay
            if (_swipeDirection != null)
              Container(
                color: _swipeDirection == SwipeDirection.right
                    ? ColorPalette.positive500.withOpacity(0.3)
                    : ColorPalette.critical500.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.lg, vertical: SpacePalette.base),
                    decoration: BoxDecoration(
                      color: _swipeDirection == SwipeDirection.right
                          ? ColorPalette.positive500
                          : ColorPalette.critical500,
                      borderRadius: BorderRadius.circular(RadiusPalette.lg),
                    ),
                    child: Text(
                      _swipeDirection == SwipeDirection.right ? 'APPROVE' : 'REJECT',
                      style: TextStylePalette.header.copyWith(color: ColorPalette.white),
                    ),
                  ),
                ),
              ),

            // Top bar (back + counter)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.sm),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, color: ColorPalette.white, size: 20),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.xs),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(RadiusPalette.full),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_requests.length}',
                          style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.lg * 2, SpacePalette.base, SpacePalette.base + 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Creator info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: request.creatorAvatarUrl.isNotEmpty
                                  ? NetworkImage(request.creatorAvatarUrl)
                                  : null,
                              child: request.creatorAvatarUrl.isEmpty
                                  ? Icon(Icons.person, size: 18, color: ColorPalette.neutral400)
                                  : null,
                            ),
                            SizedBox(width: SpacePalette.sm),
                            Expanded(
                              child: Text(
                                request.creatorName,
                                style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(RadiusPalette.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PlatformIcon.fromPlatform(request.platform, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    _getPlatformLabel(request.platform),
                                    style: TextStylePalette.smText.copyWith(color: ColorPalette.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (request.videoTitle.isNotEmpty) ...[
                          SizedBox(height: SpacePalette.sm),
                          Text(
                            request.videoTitle,
                            style: TextStylePalette.normalText.copyWith(color: ColorPalette.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: SpacePalette.xs),
                        Text(
                          request.campaignName,
                          style: TextStylePalette.smText.copyWith(color: ColorPalette.smashedPumpkin300),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: SpacePalette.base),
                        // Swipe guide
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGuideChip(Icons.close, 'Reject', ColorPalette.critical500, '←'),
                            SizedBox(width: SpacePalette.lg),
                            _buildGuideChip(Icons.check, 'Approve', ColorPalette.positive500, '→'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pause indicator
            if (_currentController != null &&
                _currentController!.value.isInitialized &&
                !_currentController!.value.isPlaying &&
                _swipeDirection == null)
              Center(
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: ColorPalette.white, size: 36),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideChip(IconData icon, String label, Color color, String direction) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(RadiusPalette.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(direction, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Icon(icon, color: color, size: 16),
          SizedBox(width: 4),
          Text(label, style: TextStylePalette.smText.copyWith(color: color)),
        ],
      ),
    );
  }

  String _getPlatformLabel(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube': return 'YouTube';
      case 'tiktok': return 'TikTok';
      case 'instagram': return 'Instagram';
      default: return platform;
    }
  }
}

enum SwipeDirection { left, right }
