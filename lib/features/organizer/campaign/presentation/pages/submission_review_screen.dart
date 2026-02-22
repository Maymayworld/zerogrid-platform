// lib/features/organizer/campaign/presentation/pages/submission_review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../../creator/submission/data/services/submission_service.dart';

final _submissionServiceProvider = Provider<SubmissionService>((ref) {
  return SubmissionService();
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
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Submissions', style: TextStylePalette.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ColorPalette.neutral800),
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
                    label: 'All',
                    count: submissions.value.length,
                    isSelected: filterStatus.value == 'all',
                    onTap: () => filterStatus.value = 'all',
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: 'Pending',
                    count: submissions.value
                        .where((s) => s.status == SubmissionStatus.pending)
                        .length,
                    isSelected: filterStatus.value == 'pending',
                    onTap: () => filterStatus.value = 'pending',
                    color: Colors.orange,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: 'Approved',
                    count: submissions.value
                        .where((s) => s.status == SubmissionStatus.approved)
                        .length,
                    isSelected: filterStatus.value == 'approved',
                    onTap: () => filterStatus.value = 'approved',
                    color: ColorPalette.positive500,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  _FilterChip(
                    label: 'Rejected',
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
            Icon(Icons.error_outline, size: 48, color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text('Failed to load submissions', style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.base),
            ElevatedButton(
              onPressed: onRefresh,
              child: Text('Retry'),
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
            Icon(Icons.video_library_outlined, size: 48,
                color: ColorPalette.neutral400),
            SizedBox(height: SpacePalette.base),
            Text('No submissions yet', style: TextStylePalette.subText),
            SizedBox(height: SpacePalette.xs),
            Text('Creators will submit videos here',
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
                    ? Icon(Icons.person, size: 20, color: ColorPalette.neutral500)
                    : null,
              ),
              SizedBox(width: SpacePalette.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.creatorName ?? 'Creator',
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL: ${submission.videoUrl}')),
              );
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
                      submission.videoUrl,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: ColorPalette.neutral400,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SpacePalette.sm),

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
                  Icon(Icons.comment, size: 14, color: ColorPalette.neutral500),
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
                      icon: Icon(Icons.close, size: 16),
                      label: Text('Reject'),
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
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Approve'),
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
          status == 'approved' ? 'Approve Submission' : 'Reject Submission',
          style: TextStylePalette.miniTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status == 'approved'
                  ? 'Are you sure you want to approve this submission?'
                  : 'Are you sure you want to reject this submission?',
              style: TextStylePalette.normalText,
            ),
            SizedBox(height: SpacePalette.base),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)...',
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
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved'
                  ? ColorPalette.positive500
                  : Colors.red,
              foregroundColor: ColorPalette.white,
            ),
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(_submissionServiceProvider);
        await service.updateSubmissionStatus(
          submissionId: submissionId,
          status: status,
          reviewNote: noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : null,
        );
        await onStatusChanged();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'approved'
                    ? 'Submission approved!'
                    : 'Submission rejected',
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
              content: Text('Failed to update: $e'),
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

  Widget _getPlatformIconWidget(String platform, {double size = 18}) {
    return PlatformIcon.fromPlatform(platform, size: size);
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Colors.red;
      case 'instagram':
        return Colors.pink;
      case 'tiktok':
        return Colors.black;
      default:
        return ColorPalette.neutral500;
    }
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
