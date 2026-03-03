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
import '../../../../creator/submission/presentation/pages/connected_accounts_screen.dart';
import '../../../../auth/presentation/widgets/duolingo_form_components.dart';

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

          ref.read(connectedProvidersProvider.notifier).state = conns
              .map((c) => c.provider)
              .toSet();

          if (campaignId.isNotEmpty) {
            final subs = await submissionService.getMySubmissionsForCampaign(
              campaignId,
            );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a video file')));
        return;
      }

      // Size check (max 500MB)
      if (selectedVideoSize.value != null &&
          selectedVideoSize.value! > 500 * 1024 * 1024) {
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

    String providerToPlatform(String provider) {
      switch (provider.toLowerCase()) {
        case 'youtube':
          return 'YouTube';
        case 'instagram':
          return 'Instagram';
        case 'tiktok':
          return 'TikTok';
        default:
          return provider;
      }
    }

    final connectedAccounts = connections.value
        .where(
          (c) =>
              c.isConnected &&
              platforms.any((p) => p.toLowerCase() == c.provider.toLowerCase()),
        )
        .toList();
    final selectedPostType = useState('Reel');
    final selectedAccountId = useState<String?>(
      connectedAccounts.isNotEmpty ? connectedAccounts.first.id : null,
    );

    if (connectedAccounts.isNotEmpty &&
        !connectedAccounts.any((a) => a.id == selectedAccountId.value)) {
      selectedAccountId.value = connectedAccounts.first.id;
    }

    final selectedAccount = connectedAccounts
        .cast<SocialConnection?>()
        .firstWhere(
          (a) => a?.id == selectedAccountId.value,
          orElse: () => null,
        );

    if (selectedAccount != null) {
      selectedPlatforms.value = {providerToPlatform(selectedAccount.provider)};
    }

    Widget buildActionRow(IconData icon, String label) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label is coming soon'),
              backgroundColor: ColorPalette.neutral800,
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SpacePalette.base,
            vertical: SpacePalette.base,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: ColorPalette.neutral800),
              SizedBox(width: SpacePalette.base),
              Expanded(child: Text(label, style: TextStylePalette.bigText)),
              Icon(
                Icons.chevron_right,
                color: ColorPalette.neutral500,
                size: 22,
              ),
            ],
          ),
        ),
      );
    }

    Widget buildAccountChip(SocialConnection? account) {
      final provider = account?.provider ?? 'instagram';
      final accountLabel = account != null
          ? '@${(account.providerAccountName?.isNotEmpty ?? false) ? account.providerAccountName : account.provider}'
          : '@connect_account';
      return Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: ColorPalette.white,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: ColorPalette.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorPalette.white, width: 1),
                      ),
                      child: Center(
                        child: PlatformIcon.fromPlatform(provider, size: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: SpacePalette.xs),
            Text(
              accountLabel,
              style: TextStylePalette.smTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Post', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoadingData.value
            ? Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.neutral800,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(SpacePalette.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: connectedAccounts.length <= 1
                                    ? null
                                    : () {
                                        final currentIndex = connectedAccounts
                                            .indexWhere(
                                              (a) =>
                                                  a.id == selectedAccountId.value,
                                            );
                                        final nextIndex =
                                            (currentIndex + 1) %
                                            connectedAccounts.length;
                                        final next = connectedAccounts[nextIndex];
                                        selectedAccountId.value = next.id;
                                        selectedPlatforms.value = {
                                          providerToPlatform(next.provider),
                                        };
                                      },
                                child: buildAccountChip(selectedAccount),
                              ),
                              SizedBox(width: SpacePalette.sm),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ConnectedAccountsScreen(),
                                    ),
                                  );
                                  final socialService = ref.read(
                                    socialConnectionServiceProvider,
                                  );
                                  final conns = await socialService
                                      .getMyConnections();
                                  connections.value = conns;
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: ColorPalette.neutral200,
                                    borderRadius: BorderRadius.circular(
                                      RadiusPalette.base,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: ColorPalette.neutral500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SpacePalette.base),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(
                                RadiusPalette.base,
                              ),
                              border: Border.all(
                                color: ColorPalette.neutral200,
                              ),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: captionController,
                                  maxLines: 8,
                                  style: TextStylePalette.normalText,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Write something to go with your video',
                                    hintStyle: TextStylePalette.hintText,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(
                                      SpacePalette.base,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    SpacePalette.base,
                                    0,
                                    SpacePalette.base,
                                    SpacePalette.base,
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: isSubmitting.value
                                            ? null
                                            : pickVideo,
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: ColorPalette.neutral100,
                                            borderRadius: BorderRadius.circular(
                                              RadiusPalette.base,
                                            ),
                                            border: Border.all(
                                              color: ColorPalette.neutral300,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 20,
                                            color: ColorPalette.neutral700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: SpacePalette.sm),
                                      Expanded(
                                        child: selectedVideoName.value != null
                                            ? Text(
                                                '${selectedVideoName.value} • ${selectedVideoSize.value != null ? formatBytes(selectedVideoSize.value!) : ''}${videoDuration.value != null ? ' • ${formatDuration(videoDuration.value!)}' : ''}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStylePalette.smSubText,
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                      if (selectedVideoPath.value != null)
                                        GestureDetector(
                                          onTap: () {
                                            selectedVideoPath.value = null;
                                            selectedVideoName.value = null;
                                            selectedVideoSize.value = null;
                                            videoDuration.value = null;
                                            videoThumbnailBytes.value = null;
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: ColorPalette.neutral500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),
                          Container(
                            padding: EdgeInsets.all(SpacePalette.xs),
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(
                                RadiusPalette.base,
                              ),
                              border: Border.all(
                                color: ColorPalette.neutral200,
                              ),
                            ),
                            child: Row(
                              children: ['Reel', 'Post', 'Story'].map((type) {
                                final selected = selectedPostType.value == type;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => selectedPostType.value = type,
                                    child: Container(
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? ColorPalette.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          RadiusPalette.mini,
                                        ),
                                      ),
                                      child: Text(
                                        type,
                                        style: selected
                                            ? TextStylePalette.smTitle
                                            : TextStylePalette.normalText,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: SpacePalette.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(
                                RadiusPalette.base,
                              ),
                              border: Border.all(
                                color: ColorPalette.neutral200,
                              ),
                            ),
                            child: Column(
                              children: [
                                buildActionRow(
                                  Icons.music_note_outlined,
                                  'Music',
                                ),
                                Divider(
                                  height: 1,
                                  color: ColorPalette.neutral200,
                                ),
                                buildActionRow(
                                  Icons.location_on_outlined,
                                  'Location',
                                ),
                                Divider(
                                  height: 1,
                                  color: ColorPalette.neutral200,
                                ),
                                buildActionRow(Icons.tag, 'Hashtags'),
                              ],
                            ),
                          ),
                          if (isSubmitting.value) ...[
                            SizedBox(height: SpacePalette.base),
                            Text(
                              'Uploading... ${(uploadProgress.value * 100).toInt()}%',
                              style: TextStylePalette.smSubText,
                            ),
                            SizedBox(height: SpacePalette.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: uploadProgress.value,
                                backgroundColor: ColorPalette.neutral200,
                                color: ColorPalette.smashedPumpkin600,
                                minHeight: 6,
                              ),
                            ),
                          ],
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      SpacePalette.base,
                      SpacePalette.sm,
                      SpacePalette.base,
                      SpacePalette.base,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: IgnorePointer(
                        ignoring:
                            isSubmitting.value ||
                            selectedVideoPath.value == null ||
                            selectedAccount == null,
                        child: Opacity(
                          opacity:
                              isSubmitting.value ||
                                  selectedVideoPath.value == null ||
                                  selectedAccount == null
                              ? 0.5
                              : 1,
                          child: DuolingoButton(
                            onPressed: handleSubmit,
                            isEnabled: true,
                            isLoading: isSubmitting.value,
                            text: 'Schedule Post',
                          ),
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
