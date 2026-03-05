// lib/features/creator/campaign/presentation/pages/upload_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../creator/submission/data/models/social_connection.dart';
import '../../../../creator/submission/data/services/submission_service.dart';
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
    final isSubmitting = useState(false);
    final uploadProgress = useState(0.0);
    final connections = useState<List<SocialConnection>>([]);
    final isLoadingData = useState(true);

    // Video file state
    final selectedVideoPath = useState<String?>(null);
    final selectedVideoName = useState<String?>(null);
    final selectedVideoSize = useState<int?>(null);
    final videoDuration = useState<int?>(null);
    final videoThumbnailBytes = useState<Uint8List?>(null);

    // Selected targets (platform + connectionId)
    final selectedTargets = useState<List<PlatformAccountTarget>>([]);

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

    String providerToPlatform(String provider) {
      switch (provider.toLowerCase()) {
        case 'youtube': return 'YouTube';
        case 'instagram': return 'Instagram';
        case 'tiktok': return 'TikTok';
        default: return provider;
      }
    }

    // Get connected accounts grouped by platform
    List<SocialConnection> connectionsForPlatform(String platformKey) {
      return connections.value
          .where((c) => c.isConnected && c.provider.toLowerCase() == platformKey.toLowerCase())
          .toList();
    }

    // Check if a platform is selected in targets
    bool isPlatformSelected(String platformKey) {
      return selectedTargets.value.any((t) => t.platform.toLowerCase() == platformKey.toLowerCase());
    }

    // Get selected connection for a platform
    PlatformAccountTarget? getTargetForPlatform(String platformKey) {
      try {
        return selectedTargets.value.firstWhere((t) => t.platform.toLowerCase() == platformKey.toLowerCase());
      } catch (_) {
        return null;
      }
    }

    // Toggle platform selection
    void togglePlatform(String platformKey) {
      final key = platformKey.toLowerCase();
      final current = List<PlatformAccountTarget>.from(selectedTargets.value);

      if (isPlatformSelected(key)) {
        current.removeWhere((t) => t.platform.toLowerCase() == key);
      } else {
        // Auto-select account if only one exists
        final accts = connectionsForPlatform(key);
        if (accts.isNotEmpty) {
          current.add(PlatformAccountTarget(
            platform: key,
            connectionId: accts.first.id,
          ));
        }
      }
      selectedTargets.value = current;
    }

    // Change account for a platform
    void selectAccountForPlatform(String platformKey, String connectionId) {
      final key = platformKey.toLowerCase();
      final current = List<PlatformAccountTarget>.from(selectedTargets.value);
      current.removeWhere((t) => t.platform.toLowerCase() == key);
      current.add(PlatformAccountTarget(platform: key, connectionId: connectionId));
      selectedTargets.value = current;
    }

    // File upload submission
    Future<void> handleFileSubmit() async {
      if (selectedVideoPath.value == null) return;
      if (selectedTargets.value.isEmpty) return;
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
        await submissionService.createFileSubmissions(
          campaignId: campaignId,
          organizerId: organizerId,
          videoBytes: videoBytes,
          fileName: selectedVideoName.value ?? 'video.mp4',
          targets: selectedTargets.value,
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

    final hasVideo = selectedVideoPath.value != null;
    final canSubmit = hasVideo && selectedTargets.value.isNotEmpty && !isSubmitting.value;

    // Check if any platform has connected accounts
    final hasAnyConnection = connections.value.any((c) => c.isConnected);

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
                          SizedBox(height: SpacePalette.base + SpacePalette.sm),

                          // Platform + Account selector
                            Row(
                              children: [
                                Expanded(child: Text('Platforms', style: TextStylePalette.smTitle)),
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectedAccountsScreen()));
                                    final socialService = ref.read(socialConnectionServiceProvider);
                                    final conns = await socialService.getMyConnections();
                                    connections.value = conns;
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.settings_outlined, size: 16, color: ColorPalette.neutral500),
                                      SizedBox(width: 4),
                                      Text('Manage', style: TextStylePalette.smSubText),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SpacePalette.sm),

                            if (!hasAnyConnection)
                              _buildConnectAccountButton(context, ref, connections)
                            else
                              _buildMultiPlatformSelector(
                                context,
                                platforms,
                                connections.value,
                                selectedTargets,
                                connectionsForPlatform,
                                isPlatformSelected,
                                getTargetForPlatform,
                                togglePlatform,
                                selectAccountForPlatform,
                                providerToPlatform,
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

                            // Title (file mode only)
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

                          // Upload progress
                          if (isSubmitting.value) ...[
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
                            onPressed: handleFileSubmit,
                            isEnabled: true,
                            isLoading: isSubmitting.value,
                            text: 'Upload',
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

  Widget _buildMultiPlatformSelector(
    BuildContext context,
    List<String> platforms,
    List<SocialConnection> allConnections,
    ValueNotifier<List<PlatformAccountTarget>> selectedTargets,
    List<SocialConnection> Function(String) connectionsForPlatform,
    bool Function(String) isPlatformSelected,
    PlatformAccountTarget? Function(String) getTargetForPlatform,
    void Function(String) togglePlatform,
    void Function(String, String) selectAccountForPlatform,
    String Function(String) providerToPlatform,
  ) {
    return Column(
      children: platforms.map((p) {
        final key = p.toLowerCase();
        final accts = connectionsForPlatform(key);
        final selected = isPlatformSelected(key);
        final target = getTargetForPlatform(key);
        final hasAccounts = accts.isNotEmpty;

        // Find the selected account name
        String? selectedAccountName;
        if (target != null) {
          try {
            final conn = accts.firstWhere((a) => a.id == target.connectionId);
            selectedAccountName = conn.providerAccountName;
          } catch (_) {}
        }

        return Padding(
          padding: EdgeInsets.only(bottom: SpacePalette.sm),
          child: GestureDetector(
            onTap: hasAccounts ? () => togglePlatform(key) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: SpacePalette.sm),
              decoration: BoxDecoration(
                color: selected ? ColorPalette.neutral800 : ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                border: Border.all(
                  color: selected
                      ? ColorPalette.neutral800
                      : hasAccounts
                          ? ColorPalette.neutral200
                          : ColorPalette.neutral200,
                ),
              ),
              child: Row(
                children: [
                  PlatformIcon.fromPlatform(key, size: 18),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p,
                          style: TextStylePalette.smTitle.copyWith(
                            color: selected ? ColorPalette.white : (hasAccounts ? ColorPalette.neutral800 : ColorPalette.neutral400),
                          ),
                        ),
                        if (selected && selectedAccountName != null)
                          Text(
                            '@$selectedAccountName',
                            style: TextStylePalette.smSubText.copyWith(
                              color: ColorPalette.neutral400,
                            ),
                          ),
                        if (!hasAccounts)
                          Text(
                            'No account connected',
                            style: TextStylePalette.smSubText.copyWith(color: ColorPalette.neutral400),
                          ),
                      ],
                    ),
                  ),
                  // Account picker (if multiple accounts for this platform and selected)
                  if (selected && accts.length > 1)
                    GestureDetector(
                      onTap: () {
                        _showAccountPicker(context, accts, target?.connectionId, (id) {
                          selectAccountForPlatform(key, id);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(RadiusPalette.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz, size: 14, color: ColorPalette.white),
                            SizedBox(width: 2),
                            Text('Switch', style: TextStylePalette.smSubText.copyWith(color: ColorPalette.white)),
                          ],
                        ),
                      ),
                    ),
                  if (selected)
                    Padding(
                      padding: EdgeInsets.only(left: SpacePalette.sm),
                      child: Icon(Icons.check_circle, size: 20, color: ColorPalette.positive400),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAccountPicker(
    BuildContext context,
    List<SocialConnection> accounts,
    String? currentConnectionId,
    void Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(SpacePalette.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Account', style: TextStylePalette.miniTitle),
                SizedBox(height: SpacePalette.sm),
                ...accounts.map((a) {
                  final isSelected = a.id == currentConnectionId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? ColorPalette.neutral800 : ColorPalette.neutral400,
                    ),
                    title: Text(
                      '@${a.providerAccountName ?? a.providerAccountId}',
                      style: TextStylePalette.normalText,
                    ),
                    onTap: () {
                      onSelect(a.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
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

}
