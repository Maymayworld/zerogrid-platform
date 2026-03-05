// lib/features/organizer/approval/presentation/pages/approval_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../data/models/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalRequestScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ApprovalRequestScreen> createState() => _ApprovalRequestScreenState();
}

class _ApprovalRequestScreenState extends ConsumerState<ApprovalRequestScreen> {
  // Tab: 0 = Videos, 1 = Links
  int _tabIndex = 0;

  // Video swipe state
  Offset _dragOffset = Offset.zero;
  _SwipeDirection? _swipeDirection;
  bool _isProcessing = false;

  VideoPlayerController? _currentController;
  VideoPlayerController? _nextController;
  bool _isVideoReady = false;

  List<ApprovalRequest> _videoRequests = [];
  final int _currentVideoIndex = 0;
  bool _videoInitDone = false;

  @override
  void dispose() {
    _currentController?.dispose();
    _nextController?.dispose();
    super.dispose();
  }

  // ── Video player lifecycle ──

  void _loadFirstVideo() {
    if (_videoRequests.isNotEmpty && _videoRequests[0].hasLocalVideo) {
      _currentController?.dispose();
      _currentController = VideoPlayerController.networkUrl(Uri.parse(_videoRequests[0].localVideoUrl!));
      _currentController!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoReady = true);
          _currentController!.setLooping(true);
          if (_tabIndex == 0) _currentController!.play();
          _preloadNext(1);
        }
      });
    }
  }

  void _initVideoForIndex(int index) {
    if (index >= _videoRequests.length) return;
    final request = _videoRequests[index];
    if (!request.hasLocalVideo) return;

    _currentController?.dispose();
    _currentController = _nextController;
    _nextController = null;

    if (_currentController != null && _currentController!.value.isInitialized) {
      setState(() => _isVideoReady = true);
      if (_tabIndex == 0) _currentController!.play();
    } else {
      setState(() => _isVideoReady = false);
      _currentController = VideoPlayerController.networkUrl(Uri.parse(request.localVideoUrl!));
      _currentController!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoReady = true);
          _currentController!.setLooping(true);
          if (_tabIndex == 0) _currentController!.play();
        }
      });
    }
    _preloadNext(index + 1);
  }

  void _preloadNext(int index) {
    if (index >= _videoRequests.length) return;
    final request = _videoRequests[index];
    if (!request.hasLocalVideo) return;

    _nextController?.dispose();
    _nextController = VideoPlayerController.networkUrl(Uri.parse(request.localVideoUrl!));
    _nextController!.initialize().then((_) {
      _nextController?.setLooping(true);
    });
  }

  // ── Swipe handling ──

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isProcessing) return;
    setState(() {
      _dragOffset += details.delta;
      if (_dragOffset.dx > 50) {
        _swipeDirection = _SwipeDirection.right;
      } else if (_dragOffset.dx < -50) {
        _swipeDirection = _SwipeDirection.left;
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isProcessing || _currentVideoIndex >= _videoRequests.length) return;
    final velocity = details.velocity.pixelsPerSecond;
    final shouldSwipe = _dragOffset.dx.abs() > 100 || velocity.dx.abs() > 500;
    if (shouldSwipe && _swipeDirection != null) {
      _handleVideoSwipe(_videoRequests[_currentVideoIndex], _swipeDirection!);
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

  Future<void> _handleVideoSwipe(ApprovalRequest request, _SwipeDirection direction) async {
    _isProcessing = true;
    setState(() {
      _dragOffset = direction == _SwipeDirection.right ? Offset(500, 0) : Offset(-500, 0);
    });
    await Future.delayed(const Duration(milliseconds: 200));

    final notifier = ref.read(approvalNotifierProvider.notifier);
    if (direction == _SwipeDirection.right) {
      await notifier.approve(request.id, request: request);
    } else {
      await notifier.reject(request.id, request: request);
    }

    _currentController?.pause();
    setState(() {
      _videoRequests.removeAt(_currentVideoIndex);
      _dragOffset = Offset.zero;
      _swipeDirection = null;
      _isVideoReady = false;
    });

    if (_videoRequests.isNotEmpty) {
      _initVideoForIndex(_currentVideoIndex.clamp(0, _videoRequests.length - 1));
    } else {
      _currentController?.dispose();
      _currentController = null;
      _nextController?.dispose();
      _nextController = null;
    }

    _isProcessing = false;
  }

  // ── Link approval ──

  Future<void> _approveLink(ApprovalRequest request) async {
    final notifier = ref.read(approvalNotifierProvider.notifier);
    await notifier.approve(request.id, request: request);
  }

  Future<void> _rejectLink(ApprovalRequest request) async {
    final notifier = ref.read(approvalNotifierProvider.notifier);
    await notifier.reject(request.id, request: request);
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      backgroundColor: _tabIndex == 0 ? Colors.black : ColorPalette.neutral100,
      body: requestsAsync.when(
        data: (allRequests) {
          final videoList = allRequests.where((r) => r.hasLocalVideo).toList();
          final linkList = allRequests.where((r) => !r.hasLocalVideo).toList();

          // Init video requests once
          if (!_videoInitDone && videoList.isNotEmpty) {
            _videoRequests = List.from(videoList);
            _videoInitDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstVideo());
          }

          return Column(
            children: [
              // Header with tabs
              _buildTabbedHeader(videoList.length, linkList.length),
              // Content
              Expanded(
                child: _tabIndex == 0
                    ? _buildVideoTab()
                    : _buildLinksTab(linkList),
              ),
              SizedBox(height: 80),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: ColorPalette.smashedPumpkin500)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTabbedHeader(int videoCount, int linkCount) {
    final isVideoTab = _tabIndex == 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorPalette.smashedPumpkin500, ColorPalette.smashedPumpkin700],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.sm, SpacePalette.base, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Approval Requests',
                  style: TextStylePalette.header.copyWith(color: ColorPalette.white),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.sm),
            // Tab bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Row(
                  children: [
                    _buildTab('Videos', videoCount, 0, isVideoTab),
                    SizedBox(width: 4),
                    _buildTab('Links', linkCount, 1, !isVideoTab),
                  ],
                ),
              ),
            ),
            SizedBox(height: SpacePalette.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, int index, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tabIndex = index);
          // Pause/play video based on tab
          if (index == 0) {
            _currentController?.play();
          } else {
            _currentController?.pause();
          }
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusPalette.mini + 2),
          ),
          child: Text(
            '$label${count > 0 ? ' ($count)' : ''}',
            style: TextStylePalette.smTitle.copyWith(
              color: selected ? ColorPalette.white : ColorPalette.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  // ── Videos tab ──

  Widget _buildVideoTab() {
    if (_videoRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: ColorPalette.positive500),
            SizedBox(height: SpacePalette.base),
            Text('No pending videos', style: TextStylePalette.title.copyWith(color: ColorPalette.white)),
          ],
        ),
      );
    }

    final current = _videoRequests[_currentVideoIndex.clamp(0, _videoRequests.length - 1)];
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        if (_currentController != null && _currentController!.value.isInitialized) {
          _currentController!.value.isPlaying ? _currentController!.pause() : _currentController!.play();
          setState(() {});
        }
      },
      child: AnimatedContainer(
        duration: _isProcessing ? Duration(milliseconds: 200) : Duration.zero,
        transform: Matrix4.translationValues(_dragOffset.dx, 0, 0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
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
                color: _swipeDirection == _SwipeDirection.right
                    ? ColorPalette.positive500.withOpacity(0.3)
                    : ColorPalette.critical500.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.lg, vertical: SpacePalette.base),
                    decoration: BoxDecoration(
                      color: _swipeDirection == _SwipeDirection.right ? ColorPalette.positive500 : ColorPalette.critical500,
                      borderRadius: BorderRadius.circular(RadiusPalette.lg),
                    ),
                    child: Text(
                      _swipeDirection == _SwipeDirection.right ? 'APPROVE' : 'REJECT',
                      style: TextStylePalette.header.copyWith(color: ColorPalette.white),
                    ),
                  ),
                ),
              ),

            // Counter
            Positioned(
              top: SpacePalette.sm,
              right: SpacePalette.sm,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.xs),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                ),
                child: Text(
                  '${_currentVideoIndex + 1} / ${_videoRequests.length}',
                  style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white),
                ),
              ),
            ),

            // Bottom info
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
                padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.lg * 2, SpacePalette.base, SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: current.creatorAvatarUrl.isNotEmpty ? NetworkImage(current.creatorAvatarUrl) : null,
                          child: current.creatorAvatarUrl.isEmpty ? Icon(Icons.person, size: 18, color: ColorPalette.neutral400) : null,
                        ),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          child: Text(current.creatorName, style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(RadiusPalette.full)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PlatformIcon.fromPlatform(current.platform, size: 14),
                              SizedBox(width: 4),
                              Text(_getPlatformLabel(current.platform), style: TextStylePalette.smText.copyWith(color: ColorPalette.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (current.videoTitle.isNotEmpty) ...[
                      SizedBox(height: SpacePalette.sm),
                      Text(current.videoTitle, style: TextStylePalette.normalText.copyWith(color: ColorPalette.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    SizedBox(height: SpacePalette.xs),
                    Text(current.campaignName, style: TextStylePalette.smText.copyWith(color: ColorPalette.smashedPumpkin300), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: SpacePalette.base),
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

            // Pause indicator
            if (_currentController != null && _currentController!.value.isInitialized && !_currentController!.value.isPlaying && _swipeDirection == null)
              Center(
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow, color: ColorPalette.white, size: 36),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Links tab ──

  Widget _buildLinksTab(List<ApprovalRequest> linkRequests) {
    if (linkRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: ColorPalette.positive500),
            SizedBox(height: SpacePalette.base),
            Text('No pending links', style: TextStylePalette.title),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(SpacePalette.base),
      itemCount: linkRequests.length,
      separatorBuilder: (_, __) => SizedBox(height: SpacePalette.sm),
      itemBuilder: (context, index) {
        final request = linkRequests[index];
        return _buildLinkCard(request);
      },
    );
  }

  Widget _buildLinkCard(ApprovalRequest request) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        border: Border.all(color: ColorPalette.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator + platform
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: request.creatorAvatarUrl.isNotEmpty ? NetworkImage(request.creatorAvatarUrl) : null,
                child: request.creatorAvatarUrl.isEmpty ? Icon(Icons.person, size: 16, color: ColorPalette.neutral400) : null,
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.creatorName, style: TextStylePalette.smTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(request.campaignName, style: TextStylePalette.smSubText, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorPalette.neutral100,
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlatformIcon.fromPlatform(request.platform, size: 14),
                    SizedBox(width: 4),
                    Text(_getPlatformLabel(request.platform), style: TextStylePalette.smText),
                  ],
                ),
              ),
            ],
          ),

          if (request.videoTitle.isNotEmpty) ...[
            SizedBox(height: SpacePalette.sm),
            Text(request.videoTitle, style: TextStylePalette.normalText, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],

          // URL link
          if (request.videoUrl.isNotEmpty) ...[
            SizedBox(height: SpacePalette.sm),
            GestureDetector(
              onTap: () {
                final uri = Uri.tryParse(request.videoUrl);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 16, color: ColorPalette.smashedPumpkin600),
                  SizedBox(width: SpacePalette.xs),
                  Expanded(
                    child: Text(
                      request.videoUrl,
                      style: TextStylePalette.smText.copyWith(color: ColorPalette.smashedPumpkin600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: SpacePalette.base),
          // Approve / Reject buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _rejectLink(request),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorPalette.critical500),
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Text('Reject', style: TextStylePalette.smTitle.copyWith(color: ColorPalette.critical500)),
                  ),
                ),
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => _approveLink(request),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorPalette.positive500,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Text('Approve', style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

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

enum _SwipeDirection { left, right }
