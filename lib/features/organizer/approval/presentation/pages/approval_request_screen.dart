// lib/features/organizer/approval/presentation/pages/approval_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../organizer/home/presentation/providers/organizer_tab_index_provider.dart';
import '../../data/models/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalRequestScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ApprovalRequestScreen> createState() => _ApprovalRequestScreenState();
}

class _ApprovalRequestScreenState extends ConsumerState<ApprovalRequestScreen> {
  bool _isProcessing = false;

  VideoPlayerController? _currentController;
  VideoPlayerController? _nextController;
  bool _isVideoReady = false;

  List<ApprovalRequest> _videoRequests = [];
  int _currentVideoIndex = 0;
  bool _videoInitDone = false;

  bool get _isVisible => ref.read(organizerTabIndexProvider) == 2;

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
          if (_isVisible) _currentController!.play();
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
      if (_isVisible) _currentController!.play();
    } else {
      setState(() => _isVideoReady = false);
      _currentController = VideoPlayerController.networkUrl(Uri.parse(request.localVideoUrl!));
      _currentController!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoReady = true);
          _currentController!.setLooping(true);
          if (_isVisible) _currentController!.play();
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

  // ── Video approval ──

  Future<void> _handleVideoAction(ApprovalRequest request, bool approve) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final notifier = ref.read(approvalNotifierProvider.notifier);
    if (approve) {
      await notifier.approve(request.id, request: request);
    } else {
      await notifier.reject(request.id, request: request);
    }

    _currentController?.pause();
    setState(() {
      _videoRequests.removeAt(_currentVideoIndex);
      _isVideoReady = false;
      if (_currentVideoIndex >= _videoRequests.length && _videoRequests.isNotEmpty) {
        _currentVideoIndex = _videoRequests.length - 1;
      }
    });

    if (_videoRequests.isNotEmpty) {
      _initVideoForIndex(_currentVideoIndex);
    } else {
      _currentController?.dispose();
      _currentController = null;
      _nextController?.dispose();
      _nextController = null;
      // 全件処理済み → 次回のリクエスト取得時にビデオリストを再初期化
      _videoInitDone = false;
      // Homeタブに切り替え
      ref.read(organizerTabIndexProvider.notifier).state = 0;
    }

    _isProcessing = false;
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    // タブ切り替え時に再生/停止を制御
    ref.listen<int>(organizerTabIndexProvider, (prev, next) {
      if (next == 2) {
        // Approvalタブに来た → 再生
        if (_isVideoReady && _currentController != null && _currentController!.value.isInitialized) {
          _currentController!.play();
        }
      } else {
        // 別タブに移動 → 停止
        _currentController?.pause();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: requestsAsync.when(
        data: (allRequests) {
          // Init video requests once
          if (!_videoInitDone && allRequests.isNotEmpty) {
            _videoRequests = List.from(allRequests.where((r) => r.hasLocalVideo));
            _videoInitDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstVideo());
          }

          return Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildVideoTab()),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: ColorPalette.smashedPumpkin500)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader() {
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.sm, SpacePalette.base, SpacePalette.sm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.approvalRequests,
              style: TextStylePalette.header.copyWith(color: ColorPalette.white),
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
            Text(AppLocalizations.of(context)!.noApprovalRequests, style: TextStylePalette.title.copyWith(color: ColorPalette.white)),
          ],
        ),
      );
    }

    final current = _videoRequests[_currentVideoIndex.clamp(0, _videoRequests.length - 1)];
    return Column(
      children: [
        // Video area
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_currentController != null && _currentController!.value.isInitialized) {
                _currentController!.value.isPlaying ? _currentController!.pause() : _currentController!.play();
                setState(() {});
              }
            },
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
                    padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.lg * 2, SpacePalette.base, SpacePalette.sm),
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
                      ],
                    ),
                  ),
                ),

                // Pause indicator
                if (_currentController != null && _currentController!.value.isInitialized && !_currentController!.value.isPlaying)
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
        ),
        // Reject / Approve buttons (outside video stack, above bottom nav)
        Container(
          color: Colors.black,
          padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.sm, SpacePalette.base, 132),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isProcessing ? null : () => _handleVideoAction(current, false),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorPalette.critical500),
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: ColorPalette.critical500, size: 20),
                        SizedBox(width: SpacePalette.xs),
                        Text(AppLocalizations.of(context)!.reject, style: TextStylePalette.smTitle.copyWith(color: ColorPalette.critical500)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: GestureDetector(
                  onTap: _isProcessing ? null : () => _handleVideoAction(current, true),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorPalette.positive500,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: ColorPalette.white, size: 20),
                        SizedBox(width: SpacePalette.xs),
                        Text(AppLocalizations.of(context)!.approve, style: TextStylePalette.smTitle.copyWith(color: ColorPalette.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ──

  String _getPlatformLabel(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube': return 'YouTube';
      case 'tiktok': return 'TikTok';
      case 'instagram': return 'Instagram';
      default: return platform;
    }
  }
}
