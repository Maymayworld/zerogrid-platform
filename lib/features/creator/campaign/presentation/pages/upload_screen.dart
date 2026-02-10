// lib/features/creator/campaign/presentation/pages/upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../../creator/submission/data/models/social_connection.dart';
import '../../../../creator/submission/presentation/providers/submission_providers.dart';

class ProjectUploadScreen extends HookConsumerWidget {
  final String campaignId;
  final String campaignName;
  final String organizerId;
  final List<String> platforms;

  const ProjectUploadScreen({
    Key? key,
    required this.campaignId,
    required this.campaignName,
    required this.organizerId,
    this.platforms = const ['YouTube', 'Instagram', 'TikTok'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeController = useTextEditingController();
    final instagramController = useTextEditingController();
    final tiktokController = useTextEditingController();
    final captionController = useTextEditingController();
    final isSubmitting = useState(false);
    final scheduledDate = useState<DateTime?>(null);
    final connections = useState<List<SocialConnection>>([]);
    final previousSubmissions = useState<List<Submission>>([]);
    final isLoadingData = useState(true);

    // Platform config
    final platformConfig = {
      'YouTube': _PlatformInfo(Icons.play_arrow, Colors.red, youtubeController),
      'Instagram': _PlatformInfo(Icons.camera_alt, Colors.pink, instagramController),
      'TikTok': _PlatformInfo(Icons.music_note, Colors.black, tiktokController),
    };

    // Load connected accounts and previous submissions
    useEffect(() {
      Future<void> loadData() async {
        try {
          final socialService = ref.read(socialConnectionServiceProvider);
          final submissionService = ref.read(submissionServiceProvider);

          final conns = await socialService.getMyConnections();
          connections.value = conns;

          // Update global connected providers state
          ref.read(connectedProvidersProvider.notifier).state =
              conns.map((c) => c.provider).toSet();

          if (campaignId.isNotEmpty) {
            final subs = await submissionService.getMySubmissionsForCampaign(campaignId);
            previousSubmissions.value = subs;
          }
        } catch (e) {
          // Silently handle - connections may not be set up yet
        } finally {
          isLoadingData.value = false;
        }
      }

      loadData();
      return null;
    }, [campaignId]);

    // Check if a platform is connected
    bool isConnected(String platform) {
      return connections.value.any(
        (c) => c.provider == platform.toLowerCase() && c.isConnected,
      );
    }

    // Get connection for a platform
    SocialConnection? getConnectionFor(String platform) {
      try {
        return connections.value.firstWhere(
          (c) => c.provider == platform.toLowerCase() && c.isConnected,
        );
      } catch (_) {
        return null;
      }
    }

    // Handle OAuth connection
    Future<void> handleConnect(String platform) async {
      // TODO: Implement OAuth flow with flutter_web_auth_2
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform OAuth connection coming soon. You can still submit URLs.'),
          backgroundColor: ColorPalette.neutral800,
        ),
      );
    }

    // Handle submission
    Future<void> handleSubmit() async {
      final videoUrls = <String, String>{};

      for (final platform in platforms) {
        final info = platformConfig[platform];
        if (info != null && info.controller.text.trim().isNotEmpty) {
          videoUrls[platform.toLowerCase()] = info.controller.text.trim();
        }
      }

      if (videoUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please paste at least one video link')),
        );
        return;
      }

      // Validate URLs belong to connected accounts
      final socialService = ref.read(socialConnectionServiceProvider);
      for (final entry in videoUrls.entries) {
        final conn = getConnectionFor(entry.key);
        if (conn != null) {
          final isValid = socialService.validateUrlOwnership(
            url: entry.value,
            provider: entry.key,
            providerAccountId: conn.providerAccountId,
            providerAccountName: conn.providerAccountName,
          );
          if (!isValid) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('The ${entry.key} URL doesn\'t match your connected account'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }

      isSubmitting.value = true;

      try {
        final submissionService = ref.read(submissionServiceProvider);
        await submissionService.createSubmission(
          campaignId: campaignId,
          organizerId: organizerId,
          videoUrls: videoUrls,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video submitted successfully!'),
              backgroundColor: ColorPalette.positive500,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    // Pick schedule date
    Future<void> pickScheduleDate() async {
      final date = await showDatePicker(
        context: context,
        initialDate: scheduledDate.value ?? DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
      );

      if (date != null && context.mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 12, minute: 0),
        );

        if (time != null) {
          scheduledDate.value = DateTime(
            date.year, date.month, date.day, time.hour, time.minute,
          );
        } else {
          scheduledDate.value = date;
        }
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Submit Video', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoadingData.value
                  ? Center(
                      child: CircularProgressIndicator(
                        color: ColorPalette.neutral800,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(SpacePalette.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info banner
                          Container(
                            padding: EdgeInsets.all(SpacePalette.base),
                            decoration: BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Color(0xFFF59E0B),
                                ),
                                SizedBox(width: SpacePalette.sm),
                                Expanded(
                                  child: Text(
                                    'Connect your accounts and submit your video links. Connected accounts help verify video ownership.',
                                    style: TextStylePalette.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Connected Accounts Section
                          Text('Connected Accounts', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          Container(
                            padding: EdgeInsets.all(SpacePalette.base),
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: Column(
                              children: platforms.map((platform) {
                                final info = platformConfig[platform]!;
                                final connected = isConnected(platform);
                                final conn = getConnectionFor(platform);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: platform != platforms.last
                                        ? SpacePalette.sm
                                        : 0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: info.color.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          info.icon,
                                          size: 18,
                                          color: info.color,
                                        ),
                                      ),
                                      SizedBox(width: SpacePalette.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(platform, style: TextStylePalette.listTitle),
                                            if (connected && conn?.providerAccountName != null)
                                              Text(
                                                '@${conn!.providerAccountName}',
                                                style: TextStylePalette.smSubText,
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (connected)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: SpacePalette.sm,
                                            vertical: SpacePalette.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorPalette.positive500.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: ColorPalette.positive500,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Connected',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ColorPalette.positive500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        GestureDetector(
                                          onTap: () => handleConnect(platform),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: SpacePalette.base,
                                              vertical: SpacePalette.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorPalette.neutral800,
                                              borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                            ),
                                            child: Text(
                                              'Connect',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: ColorPalette.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Video Links Section
                          Text('Video Links', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          ...platforms.map((platform) {
                            final info = platformConfig[platform]!;
                            return Padding(
                              padding: EdgeInsets.only(bottom: SpacePalette.base),
                              child: _PlatformLinkField(
                                icon: info.icon,
                                platformName: platform,
                                iconColor: info.color,
                                controller: info.controller,
                                hintText: 'Paste your $platform video link...',
                                isConnected: isConnected(platform),
                              ),
                            );
                          }),

                          // Caption (optional)
                          Text('Caption (optional)', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: TextField(
                              controller: captionController,
                              maxLines: 3,
                              style: TextStylePalette.normalText,
                              decoration: InputDecoration(
                                hintText: 'Add a note about your submission...',
                                hintStyle: TextStylePalette.hintText,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(SpacePalette.base),
                              ),
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),

                          // Schedule Date
                          Text('Schedule Date (optional)', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          GestureDetector(
                            onTap: pickScheduleDate,
                            child: Container(
                              padding: EdgeInsets.all(SpacePalette.base),
                              decoration: BoxDecoration(
                                color: ColorPalette.white,
                                borderRadius: BorderRadius.circular(RadiusPalette.base),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: ColorPalette.neutral500,
                                  ),
                                  SizedBox(width: SpacePalette.sm),
                                  Expanded(
                                    child: Text(
                                      scheduledDate.value != null
                                          ? _formatDateTime(scheduledDate.value!)
                                          : 'Select posting date & time',
                                      style: scheduledDate.value != null
                                          ? TextStylePalette.normalText
                                          : TextStylePalette.hintText,
                                    ),
                                  ),
                                  if (scheduledDate.value != null)
                                    GestureDetector(
                                      onTap: () => scheduledDate.value = null,
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: ColorPalette.neutral400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Previous Submissions
                          if (previousSubmissions.value.isNotEmpty) ...[
                            Text('Previous Submissions', style: TextStylePalette.miniTitle),
                            SizedBox(height: SpacePalette.sm),
                            ...previousSubmissions.value.map((sub) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                                child: _SubmissionStatusCard(submission: sub),
                              );
                            }),
                          ],
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
            ),

            // Submit button
            Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                border: Border(
                  top: BorderSide(
                    color: ColorPalette.neutral200,
                    width: 1.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: isSubmitting.value ? null : handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    disabledBackgroundColor: ColorPalette.neutral400,
                  ),
                  child: isSubmitting.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: ColorPalette.neutral100,
                              size: 20,
                            ),
                            SizedBox(width: SpacePalette.sm),
                            Text(
                              'Submit',
                              style: TextStylePalette.buttonTextWhite,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute';
  }
}

class _PlatformInfo {
  final IconData icon;
  final Color color;
  final TextEditingController controller;

  _PlatformInfo(this.icon, this.color, this.controller);
}

// Platform link field with connection status
class _PlatformLinkField extends StatelessWidget {
  final IconData icon;
  final String platformName;
  final Color iconColor;
  final TextEditingController controller;
  final String hintText;
  final bool isConnected;

  const _PlatformLinkField({
    required this.icon,
    required this.platformName,
    required this.iconColor,
    required this.controller,
    required this.hintText,
    this.isConnected = false,
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              SizedBox(width: SpacePalette.sm),
              Text(platformName, style: TextStylePalette.smTitle),
              Spacer(),
              if (isConnected)
                Icon(
                  Icons.verified,
                  size: 16,
                  color: ColorPalette.positive500,
                ),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          Container(
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              border: Border.all(
                color: ColorPalette.neutral200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: SpacePalette.sm),
                  child: Icon(
                    Icons.link,
                    size: 16,
                    color: ColorPalette.neutral400,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStylePalette.normalText,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStylePalette.hintText,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: SpacePalette.sm,
                        vertical: SpacePalette.base,
                      ),
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
}

// Submission status card for previous submissions
class _SubmissionStatusCard extends StatelessWidget {
  final Submission submission;

  const _SubmissionStatusCard({required this.submission});

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
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(submission.createdAt),
                  style: TextStylePalette.subText,
                ),
              ),
              _StatusBadge(status: submission.status.name),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          // Show platform and URL
          Row(
            children: [
              Icon(
                _getPlatformIcon(submission.platform),
                size: 14,
                color: ColorPalette.neutral500,
              ),
              SizedBox(width: SpacePalette.xs),
              Expanded(
                child: Text(
                  submission.videoUrl,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorPalette.neutral500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (submission.viewCount > 0) ...[
            SizedBox(height: SpacePalette.xs),
            Row(
              children: [
                Icon(Icons.visibility, size: 12, color: ColorPalette.neutral400),
                SizedBox(width: 4),
                Text(
                  submission.formattedViewCount,
                  style: TextStyle(
                    fontSize: 11,
                    color: ColorPalette.neutral400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_arrow;
      case 'instagram':
        return Icons.camera_alt;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.link;
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
        bgColor = ColorPalette.positive500.withValues(alpha: 0.1);
        textColor = ColorPalette.positive500;
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case 'skipped':
        bgColor = ColorPalette.neutral300;
        textColor = ColorPalette.neutral600;
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
