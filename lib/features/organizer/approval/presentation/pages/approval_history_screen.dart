// lib/features/organizer/approval/presentation/pages/approval_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../data/models/approval_request.dart';
import '../providers/approval_provider.dart';

class ApprovalHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(reviewedRequestsProvider);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.approvalHistory,
          style: TextStylePalette.title.copyWith(
            color: ColorPalette.neutral800,
          ),
        ),
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildHistoryList(history);
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsBold.clockCounterClockwise,
            size: 80,
            color: ColorPalette.neutral300,
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            AppLocalizations.of(context)!.approvalHistory,
            style: TextStylePalette.title.copyWith(
              color: ColorPalette.neutral500,
            ),
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            AppLocalizations.of(context)!.noApprovalRequests,
            style: TextStylePalette.normalText.copyWith(
              color: ColorPalette.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<ApprovalRequest> history) {
    return ListView.builder(
      padding: EdgeInsets.all(SpacePalette.base),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final request = history[index];
        return _HistoryItem(request: request);
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ApprovalRequest request;

  const _HistoryItem({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.inner),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.lg),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(SpacePalette.inner),
        child: Row(
          children: [
            // サムネイル
            ClipRRect(
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              child: Container(
                width: 80,
                height: 80,
                color: ColorPalette.neutral200,
                child: request.videoThumbnailUrl != null
                    ? Image.network(
                        request.videoThumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          PhosphorIconsBold.playCircle,
                          color: ColorPalette.neutral400,
                        ),
                      )
                    : Icon(
                        PhosphorIconsBold.playCircle,
                        color: ColorPalette.neutral400,
                      ),
              ),
            ),
            
            SizedBox(width: SpacePalette.inner),
            
            // 情報
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
                  SizedBox(height: 4),
                  Text(
                    request.videoTitle,
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.neutral600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    request.campaignName,
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.smashedPumpkin600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            SizedBox(width: SpacePalette.inner),
            
            // ステータス
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(context, request.status),
                SizedBox(height: 8),
                if (request.reviewedAt != null)
                  Text(
                    _formatDate(request.reviewedAt!),
                    style: TextStylePalette.smSubText.copyWith(
                      color: ColorPalette.neutral400,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ApprovalStatus status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case ApprovalStatus.approved:
        bgColor = ColorPalette.positive50;
        textColor = ColorPalette.positive500;
        label = AppLocalizations.of(context)!.approved;
        icon = PhosphorIconsBold.check;
        break;
      case ApprovalStatus.rejected:
        bgColor = ColorPalette.critical50;
        textColor = ColorPalette.critical500;
        label = AppLocalizations.of(context)!.rejected;
        icon = PhosphorIconsBold.x;
        break;
      case ApprovalStatus.skipped:
        bgColor = ColorPalette.neutral200;
        textColor = ColorPalette.neutral600;
        label = 'Skipped';
        icon = PhosphorIconsBold.skipForward;
        break;
      default:
        bgColor = ColorPalette.neutral200;
        textColor = ColorPalette.neutral600;
        label = AppLocalizations.of(context)!.pending;
        icon = PhosphorIconsBold.hourglass;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.inner,
        vertical: SpacePalette.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStylePalette.miniTitle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
