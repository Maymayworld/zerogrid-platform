// lib/features/organizer/approval/presentation/pages/approval_request_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../data/models/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalRequestScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ApprovalRequestScreen> createState() => _ApprovalRequestScreenState();
}

class _ApprovalRequestScreenState extends ConsumerState<ApprovalRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.001;
      
      // スワイプ方向の判定
      if (_dragOffset.dx > 50) {
        _swipeDirection = SwipeDirection.right;
      } else if (_dragOffset.dx < -50) {
        _swipeDirection = SwipeDirection.left;
      } else if (_dragOffset.dy < -50) {
        _swipeDirection = SwipeDirection.up;
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details, ApprovalRequest request) {
    final velocity = details.velocity.pixelsPerSecond;
    final shouldSwipe = _dragOffset.dx.abs() > 100 || 
                        _dragOffset.dy < -100 ||
                        velocity.dx.abs() > 500 ||
                        velocity.dy < -500;

    if (shouldSwipe && _swipeDirection != null) {
      _handleSwipe(request, _swipeDirection!);
    } else {
      _resetCard();
    }
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
      _dragAngle = 0;
      _swipeDirection = null;
    });
  }

  Future<void> _handleSwipe(ApprovalRequest request, SwipeDirection direction) async {
    final notifier = ref.read(approvalNotifierProvider.notifier);
    
    setState(() {
      // アニメーションで画面外へ
      switch (direction) {
        case SwipeDirection.right:
          _dragOffset = Offset(500, 0);
          break;
        case SwipeDirection.left:
          _dragOffset = Offset(-500, 0);
          break;
        case SwipeDirection.up:
          _dragOffset = Offset(0, -500);
          break;
      }
    });

    await Future.delayed(const Duration(milliseconds: 200));

    switch (direction) {
      case SwipeDirection.right:
        await notifier.approve(request.id, request: request);
        break;
      case SwipeDirection.left:
        await notifier.reject(request.id, request: request);
        break;
      case SwipeDirection.up:
        await notifier.skip(request.id);
        break;
    }

    _resetCard();
    ref.invalidate(pendingRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(pendingRequestsProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: Column(
        children: [
          // ヘッダー
          _buildHeader(statusBarHeight),
          
          // カードエリア
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildCardStack(requests);
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.smashedPumpkin500,
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e'),
              ),
            ),
          ),
          
          // スワイプガイド
          _buildSwipeGuide(),
          
          SizedBox(height: 100), // ナビゲーション分
        ],
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.smashedPumpkin500,
            ColorPalette.smashedPumpkin700,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SpacePalette.sm),
              Text(
                'Approval Requests',
                style: TextStylePalette.header.copyWith(
                  color: ColorPalette.white,
                ),
              ),
              SizedBox(height: SpacePalette.xs),
              Consumer(
                builder: (context, ref, _) {
                  final countAsync = ref.watch(pendingRequestCountProvider);
                  return countAsync.when(
                    data: (count) => Text(
                      '$count pending requests',
                      style: TextStylePalette.normalText.copyWith(
                        color: ColorPalette.white.withOpacity(0.8),
                      ),
                    ),
                    loading: () => SizedBox.shrink(),
                    error: (_, __) => SizedBox.shrink(),
                  );
                },
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: ColorPalette.positive500,
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            'All caught up!',
            style: TextStylePalette.title,
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'No pending requests',
            style: TextStylePalette.normalText.copyWith(
              color: ColorPalette.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(List<ApprovalRequest> requests) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 後ろのカード（プレビュー）
        if (requests.length > 1)
          Positioned(
            child: Transform.scale(
              scale: 0.95,
              child: Opacity(
                opacity: 0.5,
                child: _buildCard(requests[1], isDraggable: false),
              ),
            ),
          ),
        
        // 前面のカード
        if (requests.isNotEmpty)
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: (details) => _onPanEnd(details, requests.first),
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(
                angle: _dragAngle,
                child: _buildCard(requests.first, isDraggable: true),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(ApprovalRequest request, {required bool isDraggable}) {
    return Container(
      width: MediaQuery.of(context).size.width - 48,
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.xl),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // コンテンツ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // サムネイル / 動画プレビュー
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(RadiusPalette.xl),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: ColorPalette.neutral200,
                    child: request.videoThumbnailUrl != null
                        ? Image.network(
                            request.videoThumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
              ),
              
              // 情報
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // クリエイター情報
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: request.creatorAvatarUrl.isNotEmpty
                                ? NetworkImage(request.creatorAvatarUrl)
                                : null,
                            child: request.creatorAvatarUrl.isEmpty
                                ? Icon(Icons.person, color: ColorPalette.neutral400)
                                : null,
                          ),
                          SizedBox(width: SpacePalette.inner),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.creatorName,
                                  style: TextStylePalette.listTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _getPlatformLabel(request.platform),
                                  style: TextStylePalette.smText.copyWith(
                                    color: ColorPalette.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildPlatformIcon(request.platform),
                        ],
                      ),
                      
                      SizedBox(height: SpacePalette.inner),
                      
                      // 動画タイトル
                      Text(
                        request.videoTitle,
                        style: TextStylePalette.normalText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      Spacer(),
                      
                      // キャンペーン名と視聴数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              request.campaignName,
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.smashedPumpkin600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 16,
                                color: ColorPalette.neutral500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatViewCount(request.viewCount),
                                style: TextStylePalette.smText.copyWith(
                                  color: ColorPalette.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // スワイプインジケーター
          if (isDraggable && _swipeDirection != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusPalette.xl),
                  color: _getSwipeColor().withOpacity(0.3),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SpacePalette.lg,
                      vertical: SpacePalette.inner,
                    ),
                    decoration: BoxDecoration(
                      color: _getSwipeColor(),
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Text(
                      _getSwipeLabel(),
                      style: TextStylePalette.title.copyWith(
                        color: ColorPalette.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.play_circle_outline,
        size: 64,
        color: ColorPalette.neutral400,
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    IconData icon;
    Color color;
    
    switch (platform.toLowerCase()) {
      case 'youtube':
        icon = Icons.play_circle_filled;
        color = Colors.red;
        break;
      case 'tiktok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      case 'instagram':
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      default:
        icon = Icons.video_library;
        color = ColorPalette.neutral500;
    }
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getPlatformLabel(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'instagram':
        return 'Instagram';
      default:
        return platform;
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Color _getSwipeColor() {
    switch (_swipeDirection) {
      case SwipeDirection.right:
        return ColorPalette.positive500;
      case SwipeDirection.left:
        return ColorPalette.critical500;
      case SwipeDirection.up:
        return ColorPalette.neutral500;
      default:
        return Colors.transparent;
    }
  }

  String _getSwipeLabel() {
    switch (_swipeDirection) {
      case SwipeDirection.right:
        return 'APPROVE';
      case SwipeDirection.left:
        return 'REJECT';
      case SwipeDirection.up:
        return 'SKIP';
      default:
        return '';
    }
  }

  Widget _buildSwipeGuide() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.lg,
        vertical: SpacePalette.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildGuideItem(
            icon: Icons.close,
            label: 'Reject',
            color: ColorPalette.critical500,
            direction: '←',
          ),
          _buildGuideItem(
            icon: Icons.arrow_upward,
            label: 'Skip',
            color: ColorPalette.neutral500,
            direction: '↑',
          ),
          _buildGuideItem(
            icon: Icons.check,
            label: 'Approve',
            color: ColorPalette.positive500,
            direction: '→',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String label,
    required Color color,
    required String direction,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: SpacePalette.xs),
        Text(
          '$direction $label',
          style: TextStylePalette.smText.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

enum SwipeDirection { left, right, up }
