// lib/features/organizer/campaign/presentation/pages/submissions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../creator/campaign/data/models/submission.dart';
import '../../../../creator/campaign/presentation/providers/submission_service_provider.dart';

class SubmissionsScreen extends HookConsumerWidget {
  final String campaignId;
  final String campaignName;

  const SubmissionsScreen({
    Key? key,
    required this.campaignId,
    required this.campaignName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = useState<List<Submission>>([]);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final selectedFilter = useState<String>('all'); // all, pending, approved, rejected

    // Load submissions
    Future<void> loadSubmissions() async {
      try {
        isLoading.value = true;
        error.value = null;
        final service = ref.read(submissionServiceProvider);
        submissions.value = await service.getSubmissionsForCampaign(campaignId);
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
    List<Submission> filteredSubmissions() {
      if (selectedFilter.value == 'all') return submissions.value;
      return submissions.value
          .where((s) => s.status == selectedFilter.value)
          .toList();
    }

    // Count by status
    int countByStatus(String status) {
      if (status == 'all') return submissions.value.length;
      return submissions.value.where((s) => s.status == status).length;
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Submissions', style: TextStylePalette.title),
            Text(
              campaignName,
              style: TextStylePalette.subText.copyWith(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: ColorPalette.white,
            padding: EdgeInsets.all(SpacePalette.base),
            child: Row(
              children: [
                _FilterTab(
                  label: 'All',
                  count: countByStatus('all'),
                  isSelected: selectedFilter.value == 'all',
                  onTap: () => selectedFilter.value = 'all',
                ),
                SizedBox(width: SpacePalette.sm),
                _FilterTab(
                  label: 'Pending',
                  count: countByStatus('pending'),
                  isSelected: selectedFilter.value == 'pending',
                  color: Colors.orange,
                  onTap: () => selectedFilter.value = 'pending',
                ),
                SizedBox(width: SpacePalette.sm),
                _FilterTab(
                  label: 'Approved',
                  count: countByStatus('approved'),
                  isSelected: selectedFilter.value == 'approved',
                  color: ColorPalette.positive500,
                  onTap: () => selectedFilter.value = 'approved',
                ),
                SizedBox(width: SpacePalette.sm),
                _FilterTab(
                  label: 'Rejected',
                  count: countByStatus('rejected'),
                  isSelected: selectedFilter.value == 'rejected',
                  color: ColorPalette.critical500,
                  onTap: () => selectedFilter.value = 'rejected',
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: ColorPalette.neutral800,
                    ),
                  )
                : error.value != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: ColorPalette.critical500),
                            SizedBox(height: SpacePalette.base),
                            Text('Error: ${error.value}'),
                            SizedBox(height: SpacePalette.base),
                            ElevatedButton(
                              onPressed: loadSubmissions,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredSubmissions().isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: ColorPalette.neutral300,
                                ),
                                SizedBox(height: SpacePalette.base),
                                Text(
                                  'No submissions yet',
                                  style: TextStylePalette.subText,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadSubmissions,
                            child: ListView.builder(
                              padding: EdgeInsets.all(SpacePalette.base),
                              itemCount: filteredSubmissions().length,
                              itemBuilder: (context, index) {
                                final submission = filteredSubmissions()[index];
                                return _SubmissionCard(
                                  submission: submission,
                                  onReview: (status, comment) async {
                                    try {
                                      final service =
                                          ref.read(submissionServiceProvider);
                                      final updated =
                                          await service.reviewSubmission(
                                        submissionId: submission.id,
                                        status: status,
                                        comment: comment,
                                      );
                                      // Update local state
                                      final list = [...submissions.value];
                                      final idx =
                                          list.indexWhere((s) => s.id == updated.id);
                                      if (idx >= 0) {
                                        list[idx] = updated;
                                        submissions.value = list;
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: ColorPalette.critical500,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: SpacePalette.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? ColorPalette.neutral800)
                : ColorPalette.neutral100,
            borderRadius: BorderRadius.circular(RadiusPalette.mini),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : ColorPalette.neutral800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : ColorPalette.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final Submission submission;
  final Future<void> Function(String status, String? comment) onReview;

  const _SubmissionCard({
    required this.submission,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.base),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ColorPalette.neutral200,
                backgroundImage: submission.creatorAvatarUrl != null
                    ? NetworkImage(submission.creatorAvatarUrl!)
                    : null,
                child: submission.creatorAvatarUrl == null
                    ? Icon(Icons.person, color: ColorPalette.neutral400)
                    : null,
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.creatorName ?? 'Creator',
                      style: TextStylePalette.smTitle,
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • HH:mm')
                          .format(submission.createdAt),
                      style: TextStylePalette.subText.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: submission.status),
            ],
          ),
          SizedBox(height: SpacePalette.base),

          // Scheduled date
          if (submission.scheduledPostDate != null)
            Container(
              margin: EdgeInsets.only(bottom: SpacePalette.sm),
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.sm,
                vertical: SpacePalette.xs,
              ),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: ColorPalette.neutral600),
                  SizedBox(width: 4),
                  Text(
                    'Scheduled: ${DateFormat('MMM d, yyyy • HH:mm').format(submission.scheduledPostDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorPalette.neutral600,
                    ),
                  ),
                ],
              ),
            ),

          // Links
          if (submission.youtubeUrl != null && submission.youtubeUrl!.isNotEmpty)
            _LinkRow(
              platform: 'YouTube',
              url: submission.youtubeUrl!,
              color: Colors.red,
              iconWidget: PlatformIcon.youtube(size: 16),
            ),
          if (submission.instagramUrl != null && submission.instagramUrl!.isNotEmpty)
            _LinkRow(
              platform: 'Instagram',
              url: submission.instagramUrl!,
              color: Color(0xFFE1306C),
              iconWidget: PlatformIcon.instagram(size: 16),
            ),
          if (submission.tiktokUrl != null && submission.tiktokUrl!.isNotEmpty)
            _LinkRow(
              platform: 'TikTok',
              url: submission.tiktokUrl!,
              color: Colors.black,
              iconWidget: PlatformIcon.tiktok(size: 16),
            ),

          // Review comment
          if (submission.reviewComment != null &&
              submission.reviewComment!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: SpacePalette.sm),
              padding: EdgeInsets.all(SpacePalette.sm),
              decoration: BoxDecoration(
                color: submission.isApproved
                    ? ColorPalette.positive100
                    : ColorPalette.critical100,
                borderRadius: BorderRadius.circular(RadiusPalette.mini),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: submission.isApproved
                        ? ColorPalette.positive500
                        : ColorPalette.critical500,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: Text(
                      submission.reviewComment!,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons (only for pending)
          if (submission.isPending)
            Padding(
              padding: EdgeInsets.only(top: SpacePalette.base),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReviewDialog(context, 'rejected'),
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorPalette.critical500,
                        side: BorderSide(color: ColorPalette.critical500),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReviewDialog(context, 'approved'),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.positive500,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String status) {
    final commentController = TextEditingController();
    final isApprove = status == 'approved';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Submission' : 'Reject Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApprove
                  ? 'Add a comment for the creator (optional)'
                  : 'Please provide feedback for the creator',
            ),
            SizedBox(height: SpacePalette.base),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Great work! (optional)'
                    : 'Please explain why...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onReview(
                status,
                commentController.text.isNotEmpty ? commentController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isApprove ? ColorPalette.positive500 : ColorPalette.critical500,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        bgColor = ColorPalette.positive100;
        textColor = ColorPalette.positive500;
        label = 'Approved';
        break;
      case 'rejected':
        bgColor = ColorPalette.critical100;
        textColor = ColorPalette.critical500;
        label = 'Rejected';
        break;
      default:
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFFF59E0B);
        label = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String platform;
  final String url;
  final Color color;
  final Widget iconWidget;

  const _LinkRow({
    required this.platform,
    required this.url,
    required this.color,
    required this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SpacePalette.xs),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: SpacePalette.sm,
            vertical: SpacePalette.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              iconWidget,
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: Text(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.open_in_new, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
