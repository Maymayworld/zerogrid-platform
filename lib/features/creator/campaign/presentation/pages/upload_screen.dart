// lib/features/creator/campaign/presentation/pages/upload_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../../creator/submission/data/models/social_connection.dart';
import '../../../../creator/submission/presentation/providers/submission_providers.dart';
import '../../../../auth/presentation/providers/oauth_provider.dart';

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
    final captionController = useTextEditingController();
    final isSubmitting = useState(false);
    final uploadProgress = useState(0.0);
    final connections = useState<List<SocialConnection>>([]);
    final previousSubmissions = useState<List<Submission>>([]);
    final isLoadingData = useState(true);

    // Video file state
    final selectedVideoPath = useState<String?>(null);
    final selectedVideoName = useState<String?>(null);
    final selectedVideoSize = useState<int?>(null);
    final videoDuration = useState<int?>(null);
    final videoThumbnailBytes = useState<Uint8List?>(null);
    final selectedPlatforms = useState<Set<String>>({'YouTube'});

    // Load connected accounts and previous submissions
    useEffect(() {
      Future<void> loadData() async {
        try {
          final socialService = ref.read(socialConnectionServiceProvider);
          final submissionService = ref.read(submissionServiceProvider);

          final conns = await socialService.getMyConnections();
          connections.value = conns;

          ref.read(connectedProvidersProvider.notifier).state =
              conns.map((c) => c.provider).toSet();

          if (campaignId.isNotEmpty) {
            final subs = await submissionService.getMySubmissionsForCampaign(campaignId);
            previousSubmissions.value = subs;
          }
        } catch (e) {
          // Silently handle
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

    // Handle OAuth connection
    Future<void> handleConnect(String platform) async {
      try {
        final oauthService = ref.read(oAuthServiceProvider);
        switch (platform.toLowerCase()) {
          case 'youtube':
            await oauthService.connectYouTube();
            break;
          case 'instagram':
            await oauthService.connectInstagram();
            break;
          case 'tiktok':
            await oauthService.connectTikTok();
            break;
        }
        // Reload connections
        final socialService = ref.read(socialConnectionServiceProvider);
        final conns = await socialService.getMyConnections();
        connections.value = conns;
        ref.read(connectedProvidersProvider.notifier).state =
            conns.map((c) => c.provider).toSet();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect $platform: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Pick video file
    Future<void> pickVideo() async {
      try {
        final picker = ImagePicker();
        final video = await picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 10),
        );

        if (video == null) return;

        selectedVideoPath.value = video.path;
        selectedVideoName.value = video.name;
        final bytes = await video.readAsBytes();
        selectedVideoSize.value = bytes.length;

        // Generate thumbnail
        try {
          final thumbFile = await VideoCompress.getFileThumbnail(
            video.path,
            quality: 50,
            position: 1000, // 1 second
          );
          videoThumbnailBytes.value = await thumbFile.readAsBytes();
        } catch (_) {
          // Thumbnail generation failed (may not be supported on this platform)
        }

        // Get duration
        try {
          final info = await VideoCompress.getMediaInfo(video.path);
          if (info.duration != null) {
            videoDuration.value = (info.duration! / 1000).round();
          }
        } catch (_) {
          // Duration extraction failed
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to pick video: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Handle submission
    Future<void> handleSubmit() async {
      if (selectedVideoPath.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a video file')),
        );
        return;
      }

      // Size check (max 500MB)
      if (selectedVideoSize.value != null && selectedVideoSize.value! > 500 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video must be under 500MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isSubmitting.value = true;
      uploadProgress.value = 0.0;

      try {
        // Compress video
        Uint8List videoBytes;
        uploadProgress.value = 0.05;

        try {
          final info = await VideoCompress.compressVideo(
            selectedVideoPath.value!,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
            includeAudio: true,
          );

          if (info?.file != null) {
            videoBytes = await info!.file!.readAsBytes();
          } else {
            // Compression failed, use original
            final file = XFile(selectedVideoPath.value!);
            videoBytes = await file.readAsBytes();
          }
        } catch (_) {
          // Compression not supported on this platform, use original
          final file = XFile(selectedVideoPath.value!);
          videoBytes = await file.readAsBytes();
        }

        uploadProgress.value = 0.3;

        final submissionService = ref.read(submissionServiceProvider);
        await submissionService.createFileSubmission(
          campaignId: campaignId,
          organizerId: organizerId,
          videoBytes: videoBytes,
          fileName: selectedVideoName.value ?? 'video.mp4',
          targetPlatforms: selectedPlatforms.value.toList(),
          thumbnailBytes: videoThumbnailBytes.value,
          caption: captionController.text.trim().isNotEmpty
              ? captionController.text.trim()
              : null,
          videoDuration: videoDuration.value,
          onProgress: (p) {
            uploadProgress.value = 0.3 + (p * 0.7);
          },
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: ColorPalette.positive500,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
        uploadProgress.value = 0.0;
      }
    }

    // Format bytes to readable size
    String formatBytes(int bytes) {
      final mb = bytes / (1024 * 1024);
      if (mb >= 1000) return '${(mb / 1024).toStringAsFixed(1)} GB';
      return '${mb.toStringAsFixed(1)} MB';
    }

    String formatDuration(int seconds) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
                                    'Upload your video file. It will be compressed and stored for feed display. Max 500MB, 10 min.',
                                    style: TextStylePalette.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Video Selection
                          Text('Video File', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          GestureDetector(
                            onTap: isSubmitting.value ? null : pickVideo,
                            child: Container(
                              width: double.infinity,
                              height: selectedVideoPath.value != null ? null : 180,
                              padding: EdgeInsets.all(SpacePalette.base),
                              decoration: BoxDecoration(
                                color: ColorPalette.white,
                                borderRadius: BorderRadius.circular(RadiusPalette.base),
                                border: Border.all(
                                  color: selectedVideoPath.value != null
                                      ? ColorPalette.positive500
                                      : ColorPalette.neutral200,
                                  width: selectedVideoPath.value != null ? 2 : 1,
                                ),
                              ),
                              child: selectedVideoPath.value == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: ColorPalette.neutral100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.video_library_outlined,
                                            size: 28,
                                            color: ColorPalette.neutral500,
                                          ),
                                        ),
                                        SizedBox(height: SpacePalette.sm),
                                        Text(
                                          'Tap to select video',
                                          style: TextStylePalette.listTitle,
                                        ),
                                        SizedBox(height: SpacePalette.xs),
                                        Text(
                                          'MP4, MOV, WebM supported',
                                          style: TextStylePalette.smSubText,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        // Thumbnail preview
                                        if (videoThumbnailBytes.value != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                                            child: Image.memory(
                                              videoThumbnailBytes.value!,
                                              width: double.infinity,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else
                                          Container(
                                            width: double.infinity,
                                            height: 180,
                                            decoration: BoxDecoration(
                                              color: ColorPalette.neutral200,
                                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.play_circle_outline,
                                                size: 48,
                                                color: ColorPalette.neutral400,
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: SpacePalette.sm),
                                        // File info
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 18, color: ColorPalette.positive500),
                                            SizedBox(width: SpacePalette.xs),
                                            Expanded(
                                              child: Text(
                                                selectedVideoName.value ?? 'Video selected',
                                                style: TextStylePalette.listTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                selectedVideoPath.value = null;
                                                selectedVideoName.value = null;
                                                selectedVideoSize.value = null;
                                                videoDuration.value = null;
                                                videoThumbnailBytes.value = null;
                                              },
                                              child: Icon(Icons.close,
                                                  size: 18, color: ColorPalette.neutral400),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: SpacePalette.xs),
                                        Row(
                                          children: [
                                            if (selectedVideoSize.value != null) ...[
                                              Icon(Icons.storage,
                                                  size: 14, color: ColorPalette.neutral400),
                                              SizedBox(width: 4),
                                              Text(
                                                formatBytes(selectedVideoSize.value!),
                                                style: TextStylePalette.smSubText,
                                              ),
                                              SizedBox(width: SpacePalette.base),
                                            ],
                                            if (videoDuration.value != null) ...[
                                              Icon(Icons.timer_outlined,
                                                  size: 14, color: ColorPalette.neutral400),
                                              SizedBox(width: 4),
                                              Text(
                                                formatDuration(videoDuration.value!),
                                                style: TextStylePalette.smSubText,
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: SpacePalette.sm),
                                        // Change video button
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: isSubmitting.value ? null : pickVideo,
                                            icon: Icon(Icons.refresh, size: 16),
                                            label: Text('Change Video'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: ColorPalette.neutral600,
                                              side: BorderSide(color: ColorPalette.neutral200),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(RadiusPalette.base),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Upload progress
                          if (isSubmitting.value) ...[
                            Container(
                              padding: EdgeInsets.all(SpacePalette.base),
                              decoration: BoxDecoration(
                                color: ColorPalette.white,
                                borderRadius: BorderRadius.circular(RadiusPalette.base),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Uploading...', style: TextStylePalette.listTitle),
                                      Text(
                                        '${(uploadProgress.value * 100).toInt()}%',
                                        style: TextStylePalette.smTitle,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: SpacePalette.sm),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: uploadProgress.value,
                                      backgroundColor: ColorPalette.neutral200,
                                      color: ColorPalette.smashedPumpkin600,
                                      minHeight: 6,
                                    ),
                                  ),
                                  SizedBox(height: SpacePalette.xs),
                                  Text(
                                    uploadProgress.value < 0.3
                                        ? 'Compressing video...'
                                        : uploadProgress.value < 0.8
                                            ? 'Uploading to server...'
                                            : 'Finalizing...',
                                    style: TextStylePalette.smSubText,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SpacePalette.lg),
                          ],

                          // Target Platforms
                          Text('Target Platform', style: TextStylePalette.miniTitle),
                          SizedBox(height: SpacePalette.sm),
                          Container(
                            padding: EdgeInsets.all(SpacePalette.base),
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: Column(
                              children: platforms.map((platform) {
                                final isSelected = selectedPlatforms.value.contains(platform);
                                final platformColors = {
                                  'YouTube': Colors.red,
                                  'Instagram': Colors.pink,
                                  'TikTok': Colors.black,
                                };

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: platform != platforms.last ? SpacePalette.sm : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Single selection (one platform per submission)
                                      selectedPlatforms.value = {platform};
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: SpacePalette.sm,
                                        vertical: SpacePalette.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? platformColors[platform]!.withOpacity(0.05)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                                        border: Border.all(
                                          color: isSelected
                                              ? platformColors[platform]!.withOpacity(0.3)
                                              : ColorPalette.neutral200,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          PlatformIcon.fromPlatform(
                                              platform.toLowerCase(),
                                              size: 18),
                                          SizedBox(width: SpacePalette.sm),
                                          Expanded(
                                            child: Text(platform,
                                                style: TextStylePalette.listTitle),
                                          ),
                                          Icon(
                                            isSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            size: 20,
                                            color: isSelected
                                                ? platformColors[platform]
                                                : ColorPalette.neutral300,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
                                final connected = isConnected(platform);
                                final conn = connections.value.cast<SocialConnection?>().firstWhere(
                                  (c) =>
                                      c != null &&
                                      c.provider == platform.toLowerCase() &&
                                      c.isConnected,
                                  orElse: () => null,
                                );

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        platform != platforms.last ? SpacePalette.sm : 0,
                                  ),
                                  child: Row(
                                    children: [
                                      PlatformIcon.fromPlatform(
                                          platform.toLowerCase(),
                                          size: 16),
                                      SizedBox(width: SpacePalette.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(platform,
                                                style: TextStylePalette.listTitle),
                                            if (connected &&
                                                conn?.providerAccountName != null)
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
                                            color: ColorPalette.positive500
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(RadiusPalette.mini),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 14,
                                                  color: ColorPalette.positive500),
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
                                              borderRadius:
                                                  BorderRadius.circular(RadiusPalette.mini),
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
                                hintText: 'Add a caption for your video...',
                                hintStyle: TextStylePalette.hintText,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(RadiusPalette.base),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(SpacePalette.base),
                              ),
                            ),
                          ),
                          SizedBox(height: SpacePalette.lg),

                          // Previous Submissions
                          if (previousSubmissions.value.isNotEmpty) ...[
                            Text('Previous Submissions',
                                style: TextStylePalette.miniTitle),
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
                  onPressed: isSubmitting.value || selectedVideoPath.value == null
                      ? null
                      : handleSubmit,
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
                              Icons.cloud_upload_outlined,
                              color: ColorPalette.neutral100,
                              size: 20,
                            ),
                            SizedBox(width: SpacePalette.sm),
                            Text(
                              'Upload & Submit',
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
          Row(
            children: [
              PlatformIcon.fromPlatform(submission.platform, size: 14),
              SizedBox(width: SpacePalette.xs),
              Expanded(
                child: Text(
                  submission.hasLocalVideo
                      ? 'Video uploaded'
                      : submission.videoUrl,
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
