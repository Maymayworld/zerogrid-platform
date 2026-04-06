// lib/features/organizer/campaign/presentation/pages/submission_review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../../creator/submission/data/services/submission_service.dart';
import '../../../../organizer/approval/data/services/approval_service.dart';

final _submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SubmissionService();
});

final _approvalServiceProvider = Provider<ApprovalService>((ref) {
  return ApprovalService();
});

class SubmissionReviewScreen extends HookConsumerWidget {
  final String campaignId;
  final String? campaignName;

  const SubmissionReviewScreen({
    Key? key,
    required this.campaignId,
    this.campaignName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = useState<List<Submission>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final filterStatus = useState<String?>('all');

    Future<void> loadSubmissions() async {
      isLoading.value = true;
      error.value = null;
      try {
        final service = ref.read(_submissionServiceProvider);
        final result = await service.getCampaignSubmissions(campaignId);
        submissions.value = result;
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadSubmissions();
      return null;
    }, [campaignId]);

    // Filter submissions
    final filteredSubmissions = filterStatus.value == 'all'
        ? submissions.value
        : submissions.value
            .where((s) => s.status.name == filterStatus.value)
            .toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.submissions, style: TextStylePalette.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsRegular.arrowClockwise, color: ColorPalette.neutral800),
            onPressed: loadSubmissions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: ColorPalette.white,
            padding: EdgeInsets.symmetric(
              horizontal: SpacePalette.base,
              vertical: SpacePalette.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: AppLocalizations.of(context)!.all,
                    count: submissions.value.length,
                    isSelected: filterStatus.value == 'all',
                    onTap: () => filterStatus.value = 'all',
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: AppLocalizations.of(context)!.pending,
                    count: submissions.value
                        .where((s) => s.status == SubmissionStatus.pending)
                        .length,
                    isSelected: filterStatus.value == 'pending',
                    onTap: () => filterStatus.value = 'pending',
                    color: Colors.orange,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: AppLocalizations.of(context)!.approved,
                    count: submissions.value
                        .where((s) => s.status == SubmissionStatus.approved)
                        .length,
                    isSelected: filterStatus.value == 'approved',
                    onTap: () => filterStatus.value = 'approved',
                    color: ColorPalette.positive500,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: AppLocalizations.of(context)!.rejected,
                    count: submissions.value
                        .where((s) => s.status == SubmissionStatus.rejected)
                        .length,
                    isSelected: filterStatus.value == 'rejected',
                    onTap: () => filterStatus.value = 'rejected',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SpacePalette.sm),

          // Content
          Expanded(
            child: _buildContent(
              context,
              ref,
              isLoading: isLoading.value,
              error: error.value,
              submissions: filteredSubmissions,
              onRefresh: loadSubmissions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
    required String? error,
    required List<Submission> submissions,
    required Future<void> Function() onRefresh,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorPalette.neutral800),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.warningCircle, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.failedToLoad, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(
              onPressed: onRefresh,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.filmStrip, size: 48,
                color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text(AppLocalizations.of(context)!.noSubmissionsYet, style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.xs),
            Text(AppLocalizations.of(context)!.creatorsWillSubmitHere,
                style: TextStylePalette.smSubText),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: SpacePalette.base),
            child: _SubmissionCard(
              submission: submissions[index],
              onStatusChanged: onRefresh,
              ref: ref,
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? ColorPalette.neutral800)
              : ColorPalette.neutral100,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? ColorPalette.white : ColorPalette.neutral600,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? ColorPalette.white.withOpacity(0.8)
                    : ColorPalette.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final Submission submission;
  final Future<void> Function() onStatusChanged;
  final WidgetRef ref;

  const _SubmissionCard({
    required this.submission,
    required this.onStatusChanged,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator info + status
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ColorPalette.neutral300,
                backgroundImage: submission.creatorAvatarUrl != null
                    ? NetworkImage(submission.creatorAvatarUrl!)
                    : null,
                child: submission.creatorAvatarUrl == null
                    ? Icon(PhosphorIconsFill.user, size: 20, color: ColorPalette.neutral500)
                    : null,
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.creatorName ?? AppLocalizations.of(context)!.creator,
                      style: TextStylePalette.listTitle,
                    ),
                    Text(
                      _formatDate(submission.createdAt),
                      style: TextStylePalette.smSubText,
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: submission.status.name),
            ],
          ),
          SizedBox(height: SpacePalette.base),

          // Video URL
          GestureDetector(
            onTap: () async {
              final url = submission.platformPostUrl ?? submission.playableUrl;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(SpacePalette.sm),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Row(
                children: [
                  PlatformIcon.fromPlatform(submission.platform, size: 18),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.uploadedVideo,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorPalette.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 16,
                    color: ColorPalette.neutral400,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SpacePalette.sm),

          // Upload / posting status
          if (submission.hasLocalVideo &&
              submission.uploadStatus != null &&
              submission.uploadStatus != 'completed') ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.sm,
                vertical: SpacePalette.xs,
              ),
              decoration: BoxDecoration(
                color: submission.uploadStatus == 'posted'
                    ? ColorPalette.positive500.withValues(alpha: 0.1)
                    : submission.uploadStatus == 'failed'
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    submission.uploadStatus == 'posted'
                        ? PhosphorIconsFill.checkCircle
                        : submission.uploadStatus == 'failed'
                            ? PhosphorIconsFill.warningCircle
                            : PhosphorIconsRegular.uploadSimple,
                    size: 14,
                    color: submission.uploadStatus == 'posted'
                        ? ColorPalette.positive500
                        : submission.uploadStatus == 'failed'
                            ? Colors.red
                            : Colors.blue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    submission.uploadStatus == 'posted'
                        ? AppLocalizations.of(context)!.postedToPlatform(submission.platformDisplayName)
                        : submission.uploadStatus == 'failed'
                            ? AppLocalizations.of(context)!.snsPostingFailed
                            : AppLocalizations.of(context)!.postingToPlatform(submission.platformDisplayName),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: submission.uploadStatus == 'posted'
                          ? ColorPalette.positive500
                          : submission.uploadStatus == 'failed'
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SpacePalette.sm),
          ],

          // Platform post URL (if posted)
          if (submission.platformPostUrl != null &&
              submission.platformPostUrl!.isNotEmpty) ...[
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(submission.platformPostUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: EdgeInsets.all(SpacePalette.xs),
                decoration: BoxDecoration(
                  color: ColorPalette.positive500.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(RadiusPalette.mini),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.link, size: 14, color: ColorPalette.positive500),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        submission.platformPostUrl!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: SpacePalette.sm),
          ],

          // Video title
          if (submission.videoTitle != null &&
              submission.videoTitle!.isNotEmpty) ...[
            Text(
              submission.videoTitle!,
              style: TextStylePalette.subText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: SpacePalette.sm),
          ],

          // Review note (if already reviewed)
          if (submission.reviewNote != null &&
              submission.reviewNote!.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(SpacePalette.sm),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(PhosphorIconsRegular.chatText, size: 14, color: ColorPalette.neutral500),
                  SizedBox(width: SpacePalette.xs),
                  Expanded(
                    child: Text(
                      submission.reviewNote!,
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorPalette.neutral600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SpacePalette.sm),
          ],

          // Action buttons (only for pending status)
          if (submission.isPending)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReview(
                        context,
                        submission.id,
                        'rejected',
                      ),
                      icon: Icon(PhosphorIconsRegular.x, size: 16),
                      label: Text(AppLocalizations.of(context)!.reject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SpacePalette.base),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleReview(
                        context,
                        submission.id,
                        'approved',
                      ),
                      icon: Icon(PhosphorIconsRegular.check, size: 16),
                      label: Text(AppLocalizations.of(context)!.approve),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.positive500,
                        foregroundColor: ColorPalette.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleReview(
    BuildContext context,
    String submissionId,
    String status,
  ) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'approved' ? AppLocalizations.of(context)!.approveSubmission : AppLocalizations.of(context)!.rejectSubmission,
          style: TextStylePalette.miniTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status == 'approved'
                  ? AppLocalizations.of(context)!.approveConfirm
                  : AppLocalizations.of(context)!.rejectConfirm,
              style: TextStylePalette.normalText,
            ),
            SizedBox(height: SpacePalette.base),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addNoteOptional,
                hintStyle: TextStylePalette.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                contentPadding: EdgeInsets.all(SpacePalette.base),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved'
                  ? ColorPalette.positive500
                  : Colors.red,
              foregroundColor: ColorPalette.white,
            ),
            child: Text(status == 'approved' ? AppLocalizations.of(context)!.approve : AppLocalizations.of(context)!.reject),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final approvalService = ref.read(_approvalServiceProvider);
        final reviewNote = noteController.text.trim().isNotEmpty
            ? noteController.text.trim()
            : null;
        if (status == 'approved') {
          await approvalService.approveRequest(submissionId, reviewNote: reviewNote);
        } else {
          await approvalService.rejectRequest(submissionId, reviewNote: reviewNote);
        }
        await onStatusChanged();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'approved'
                    ? AppLocalizations.of(context)!.submissionApprovedAutoPosting
                    : AppLocalizations.of(context)!.submissionRejected,
              ),
              backgroundColor: status == 'approved'
                  ? ColorPalette.positive500
                  : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    noteController.dispose();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'approved':
        bgColor = ColorPalette.positive500.withOpacity(0.1);
        textColor = ColorPalette.positive500;
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      default:
        bgColor = ColorPalette.neutral200;
        textColor = ColorPalette.neutral500;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacePalette.sm,
        vertical: SpacePalette.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RadiusPalette.mini),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
