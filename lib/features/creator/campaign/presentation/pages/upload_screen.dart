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
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';

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
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final isSubmitting = useState(false);
    final uploadProgress = useState(0.0);
    final connections = useState<List<SocialConnection>>([]);
    final isLoadingData = useState(true);

    // Mode: 0 = file upload, 1 = URL
    final mode = useState(0);

    // Video file state
    final selectedVideoPath = useState<String?>(null);
    final selectedVideoName = useState<String?>(null);
    final selectedVideoSize = useState<int?>(null);
    final videoDuration = useState<int?>(null);
    final videoThumbnailBytes = useState<Uint8List?>(null);
    final selectedPlatforms = useState<Set<String>>({'YouTube'});

    // URL mode: selected platform
    final urlPlatform = useState<String>(
      platforms.isNotEmpty ? platforms.first.toLowerCase() : 'youtube',
    );

    useEffect(() {
      Future<void> loadData() async {
        try {
          final socialService = ref.read(socialConnectionServiceProvider);
          final conns = await socialService.getMyConnections();
          connections.value = conns;
          ref.read(connectedProvidersProvider.notifier).state = conns
              .map((c) => c.provider)
              .toSet();
        } catch (e) {
          // Silently handle
        } finally {
          isLoadingData.value = false;
        }
      }
      loadData();
      return null;
    }, [campaignId]);

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

        try {
          final thumbFile = await VideoCompress.getFileThumbnail(
            video.path,
            quality: 50,
            position: 1000,
          );
          videoThumbnailBytes.value = await thumbFile.readAsBytes();
        } catch (_) {}

        try {
          final info = await VideoCompress.getMediaInfo(video.path);
          if (info.duration != null) {
            videoDuration.value = (info.duration! / 1000).round();
          }
        } catch (_) {}
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick video: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    // File upload submission
    Future<void> handleFileSubmit() async {
      if (selectedVideoPath.value == null) return;
      if (selectedVideoSize.value != null && selectedVideoSize.value! > 500 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video must be under 500MB'), backgroundColor: Colors.red),
        );
        return;
      }

      isSubmitting.value = true;
      uploadProgress.value = 0.0;

      try {
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
            videoBytes = await XFile(selectedVideoPath.value!).readAsBytes();
          }
        } catch (_) {
          videoBytes = await XFile(selectedVideoPath.value!).readAsBytes();
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
          title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : null,
          videoDuration: videoDuration.value,
          onProgress: (p) {
            uploadProgress.value = 0.3 + (p * 0.7);
          },
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video uploaded successfully!'), backgroundColor: ColorPalette.positive500),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSubmitting.value = false;
        uploadProgress.value = 0.0;
      }
    }

    // URL submission
    Future<void> handleUrlSubmit() async {
      final url = urlController.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a video URL')),
        );
        return;
      }

      isSubmitting.value = true;

      try {
        final submissionService = ref.read(submissionServiceProvider);
        await submissionService.createUrlSubmission(
          campaignId: campaignId,
          organizerId: organizerId,
          videoUrl: url,
          platform: urlPlatform.value,
          title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : null,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL submitted successfully!'), backgroundColor: ColorPalette.positive500),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

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
        case 'youtube': return 'YouTube';
        case 'instagram': return 'Instagram';
        case 'tiktok': return 'TikTok';
        default: return provider;
      }
    }

    // Connected accounts (for file upload mode)
    final connectedAccounts = connections.value
        .where((c) => c.isConnected && platforms.any((p) => p.toLowerCase() == c.provider.toLowerCase()))
        .toList();
    final selectedAccountId = useState<String?>(
      connectedAccounts.isNotEmpty ? connectedAccounts.first.id : null,
    );
    if (connectedAccounts.isNotEmpty && !connectedAccounts.any((a) => a.id == selectedAccountId.value)) {
      selectedAccountId.value = connectedAccounts.first.id;
    }
    final selectedAccount = connectedAccounts.cast<SocialConnection?>().firstWhere(
      (a) => a?.id == selectedAccountId.value,
      orElse: () => null,
    );
    if (selectedAccount != null) {
      selectedPlatforms.value = {providerToPlatform(selectedAccount.provider)};
    }

    final isFileMode = mode.value == 0;
    final hasVideo = selectedVideoPath.value != null;
    final hasUrl = urlController.text.trim().isNotEmpty;
    final canSubmitFile = hasVideo && selectedAccount != null && !isSubmitting.value;
    final canSubmitUrl = hasUrl && !isSubmitting.value;
    final canSubmit = isFileMode ? canSubmitFile : canSubmitUrl;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: ColorPalette.neutral200, width: 1)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Submit', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoadingData.value
            ? Center(child: CircularProgressIndicator(color: ColorPalette.neutral800))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(SpacePalette.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campaign info
                          Container(
                            padding: EdgeInsets.all(SpacePalette.sm),
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                              border: Border.all(color: ColorPalette.neutral200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.campaign_outlined, size: 20, color: ColorPalette.neutral500),
                                SizedBox(width: SpacePalette.sm),
                                Expanded(
                                  child: Text(campaignName, style: TextStylePalette.smTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),

                          // Mode toggle
                          Container(
                            padding: EdgeInsets.all(SpacePalette.xs),
                            decoration: BoxDecoration(
                              color: ColorPalette.neutral200,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                            ),
                            child: Row(
                              children: [
                                _buildModeTab('Upload Video', 0, mode),
                                SizedBox(width: SpacePalette.xs),
                                _buildModeTab('Paste URL', 1, mode),
                              ],
                            ),
                          ),
                          SizedBox(height: SpacePalette.base + SpacePalette.sm),

                          if (isFileMode) ...[
                            // === FILE UPLOAD MODE ===
                            // Platform account selector
                            Text('Platform', style: TextStylePalette.smTitle),
                            SizedBox(height: SpacePalette.sm),
                            if (connectedAccounts.isEmpty)
                              _buildConnectAccountButton(context, ref, connections)
                            else
                              _buildAccountSelector(
                                context, ref, connections, connectedAccounts,
                                selectedAccountId, selectedAccount, selectedPlatforms, providerToPlatform,
                              ),
                            SizedBox(height: SpacePalette.base + SpacePalette.sm),

                            // Video picker
                            Text('Video', style: TextStylePalette.smTitle),
                            SizedBox(height: SpacePalette.sm),
                            _buildVideoPicker(
                              isSubmitting, pickVideo, hasVideo,
                              videoThumbnailBytes, selectedVideoName, selectedVideoSize,
                              videoDuration, selectedVideoPath, formatBytes, formatDuration,
                            ),
                            SizedBox(height: SpacePalette.base + SpacePalette.sm),
                          ] else ...[
                            // === URL MODE ===
                            // Platform selector
                            Text('Platform', style: TextStylePalette.smTitle),
                            SizedBox(height: SpacePalette.sm),
                            _buildUrlPlatformSelector(platforms, urlPlatform),
                            SizedBox(height: SpacePalette.base + SpacePalette.sm),

                            // URL input
                            Text('Video URL', style: TextStylePalette.smTitle),
                            SizedBox(height: SpacePalette.sm),
                            Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.white,
                                borderRadius: BorderRadius.circular(RadiusPalette.base),
                                border: Border.all(color: ColorPalette.neutral200),
                              ),
                              child: TextField(
                                controller: urlController,
                                maxLines: 1,
                                style: TextStylePalette.normalText,
                                decoration: InputDecoration(
                                  hintText: 'https://...',
                                  hintStyle: TextStylePalette.hintText,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: SpacePalette.sm,
                                    vertical: SpacePalette.sm,
                                  ),
                                  prefixIcon: Icon(Icons.link, color: ColorPalette.neutral400, size: 20),
                                ),
                                onChanged: (_) => (context as Element).markNeedsBuild(),
                              ),
                            ),
                            SizedBox(height: SpacePalette.base + SpacePalette.sm),
                          ],

                          // Title (shared)
                          Text('Title', style: TextStylePalette.smTitle),
                          SizedBox(height: SpacePalette.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.base),
                              border: Border.all(color: ColorPalette.neutral200),
                            ),
                            child: TextField(
                              controller: titleController,
                              maxLines: 1,
                              style: TextStylePalette.normalText,
                              decoration: InputDecoration(
                                hintText: 'Video title',
                                hintStyle: TextStylePalette.hintText,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: SpacePalette.sm,
                                  vertical: SpacePalette.sm,
                                ),
                              ),
                            ),
                          ),

                          // Upload progress (file mode only)
                          if (isFileMode && isSubmitting.value) ...[
                            SizedBox(height: SpacePalette.base),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: uploadProgress.value,
                                      backgroundColor: ColorPalette.neutral200,
                                      color: ColorPalette.smashedPumpkin600,
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                SizedBox(width: SpacePalette.sm),
                                Text('${(uploadProgress.value * 100).toInt()}%', style: TextStylePalette.smSubText),
                              ],
                            ),
                          ],
                          SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  // Submit button
                  Container(
                    padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.sm, SpacePalette.base, SpacePalette.base),
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral100,
                      border: Border(top: BorderSide(color: ColorPalette.neutral200, width: 1)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: IgnorePointer(
                        ignoring: !canSubmit,
                        child: Opacity(
                          opacity: canSubmit ? 1 : 0.5,
                          child: DuolingoButton(
                            onPressed: isFileMode ? handleFileSubmit : handleUrlSubmit,
                            isEnabled: true,
                            isLoading: isSubmitting.value,
                            text: isFileMode ? 'Upload' : 'Submit URL',
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

  Widget _buildModeTab(String label, int index, ValueNotifier<int> mode) {
    final selected = mode.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => mode.value = index,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? ColorPalette.white : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusPalette.mini + 2),
            boxShadow: selected
                ? [BoxShadow(color: ColorPalette.neutral800.withOpacity(0.06), blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            style: selected ? TextStylePalette.smTitle : TextStylePalette.normalText.copyWith(color: ColorPalette.neutral500),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectAccountButton(BuildContext context, WidgetRef ref, ValueNotifier<List<SocialConnection>> connections) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectedAccountsScreen()));
        final socialService = ref.read(socialConnectionServiceProvider);
        final conns = await socialService.getMyConnections();
        connections.value = conns;
      },
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(color: ColorPalette.neutral300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 20, color: ColorPalette.neutral500),
            SizedBox(width: SpacePalette.sm),
            Text('Connect an account', style: TextStylePalette.normalText.copyWith(color: ColorPalette.neutral500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<List<SocialConnection>> connections,
    List<SocialConnection> connectedAccounts,
    ValueNotifier<String?> selectedAccountId,
    SocialConnection? selectedAccount,
    ValueNotifier<Set<String>> selectedPlatforms,
    String Function(String) providerToPlatform,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.sm),
            decoration: BoxDecoration(
              color: ColorPalette.white,
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              border: Border.all(color: ColorPalette.neutral200),
            ),
            child: GestureDetector(
              onTap: connectedAccounts.length <= 1
                  ? null
                  : () {
                      final currentIndex = connectedAccounts.indexWhere((a) => a.id == selectedAccountId.value);
                      final nextIndex = (currentIndex + 1) % connectedAccounts.length;
                      final next = connectedAccounts[nextIndex];
                      selectedAccountId.value = next.id;
                      selectedPlatforms.value = {providerToPlatform(next.provider)};
                    },
              child: Row(
                children: [
                  SizedBox(width: 28, height: 28, child: PlatformIcon.fromPlatform(selectedAccount?.provider ?? 'youtube', size: 20)),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(providerToPlatform(selectedAccount?.provider ?? 'youtube'), style: TextStylePalette.smTitle),
                        if (selectedAccount?.providerAccountName != null && selectedAccount!.providerAccountName!.isNotEmpty)
                          Text('@${selectedAccount.providerAccountName}', style: TextStylePalette.smSubText),
                      ],
                    ),
                  ),
                  if (connectedAccounts.length > 1) Icon(Icons.swap_horiz, size: 20, color: ColorPalette.neutral400),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: SpacePalette.sm),
        GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectedAccountsScreen()));
            final socialService = ref.read(socialConnectionServiceProvider);
            final conns = await socialService.getMyConnections();
            connections.value = conns;
          },
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: ColorPalette.white,
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              border: Border.all(color: ColorPalette.neutral200),
            ),
            child: Icon(Icons.settings_outlined, color: ColorPalette.neutral500, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPicker(
    ValueNotifier<bool> isSubmitting,
    Future<void> Function() pickVideo,
    bool hasVideo,
    ValueNotifier<Uint8List?> videoThumbnailBytes,
    ValueNotifier<String?> selectedVideoName,
    ValueNotifier<int?> selectedVideoSize,
    ValueNotifier<int?> videoDuration,
    ValueNotifier<String?> selectedVideoPath,
    String Function(int) formatBytes,
    String Function(int) formatDuration,
  ) {
    return GestureDetector(
      onTap: isSubmitting.value ? null : pickVideo,
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(color: hasVideo ? ColorPalette.neutral200 : ColorPalette.neutral300),
        ),
        child: hasVideo
            ? Padding(
                padding: EdgeInsets.all(SpacePalette.sm),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(RadiusPalette.mini),
                      child: SizedBox(
                        width: 64, height: 64,
                        child: videoThumbnailBytes.value != null
                            ? Image.memory(videoThumbnailBytes.value!, fit: BoxFit.cover)
                            : Container(color: ColorPalette.neutral200, child: Icon(Icons.videocam, color: ColorPalette.neutral400)),
                      ),
                    ),
                    SizedBox(width: SpacePalette.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedVideoName.value ?? 'video', style: TextStylePalette.smTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2),
                          Text(
                            [
                              if (selectedVideoSize.value != null) formatBytes(selectedVideoSize.value!),
                              if (videoDuration.value != null) formatDuration(videoDuration.value!),
                            ].join(' · '),
                            style: TextStylePalette.smSubText,
                          ),
                        ],
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
                      child: Padding(
                        padding: EdgeInsets.all(SpacePalette.xs),
                        child: Icon(Icons.close, size: 20, color: ColorPalette.neutral400),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(vertical: SpacePalette.lg + SpacePalette.sm),
                child: Column(
                  children: [
                    Icon(Icons.video_library_outlined, size: 36, color: ColorPalette.neutral400),
                    SizedBox(height: SpacePalette.sm),
                    Text('Tap to select a video', style: TextStylePalette.normalText.copyWith(color: ColorPalette.neutral500)),
                    SizedBox(height: SpacePalette.xs),
                    Text('Max 500MB · Up to 10 minutes', style: TextStylePalette.smSubText),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUrlPlatformSelector(List<String> platforms, ValueNotifier<String> urlPlatform) {
    return Row(
      children: platforms.map((p) {
        final key = p.toLowerCase();
        final selected = urlPlatform.value == key;
        return Padding(
          padding: EdgeInsets.only(right: SpacePalette.sm),
          child: GestureDetector(
            onTap: () => urlPlatform.value = key,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.sm),
              decoration: BoxDecoration(
                color: selected ? ColorPalette.neutral800 : ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                border: Border.all(color: selected ? ColorPalette.neutral800 : ColorPalette.neutral200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlatformIcon.fromPlatform(key, size: 16),
                  SizedBox(width: SpacePalette.xs),
                  Text(
                    p,
                    style: TextStylePalette.smTitle.copyWith(
                      color: selected ? ColorPalette.white : ColorPalette.neutral800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
