// lib/features/creator/profile/presentation/pages/profile_detail_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/utils/youtube_utils.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../../creator/submission/data/models/submission.dart';
import '../../../../creator/feed/presentation/providers/feed_provider.dart';
import '../../../../creator/feed/presentation/pages/feed_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class ProfileDetailScreen extends HookConsumerWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;

    final myPosts = useState<List<Submission>>([]);
    final likedPosts = useState<List<Submission>>([]);
    final isLoadingPosts = useState(true);
    final isLoadingLiked = useState(true);

    Future<void> loadMyPosts() async {
      if (profile == null) {
        isLoadingPosts.value = false;
        return;
      }
      isLoadingPosts.value = true;
      try {
        final feedService = ref.read(feedServiceProvider);
        myPosts.value = await feedService.getUserYouTubeSubmissions(profile.id);
      } catch (e) {
        debugPrint('Failed to load my posts: $e');
      } finally {
        isLoadingPosts.value = false;
      }
    }

    Future<void> loadLikedPosts() async {
      isLoadingLiked.value = true;
      try {
        final feedService = ref.read(feedServiceProvider);
        likedPosts.value = await feedService.getLikedYouTubeSubmissions();
      } catch (e) {
        debugPrint('Failed to load liked posts: $e');
      } finally {
        isLoadingLiked.value = false;
      }
    }

    useEffect(() {
      loadMyPosts();
      loadLikedPosts();
      return null;
    }, [profile?.id]);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorPalette.neutral100,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          backgroundColor: ColorPalette.neutral100,
          actions: [
            IconButton(
              icon: Icon(PhosphorIconsRegular.pencilSimple, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const _ProfileEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // プロフィールヘッダー
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Column(
                children: [
                  SizedBox(height: SpacePalette.base),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: ColorPalette.neutral400,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            profile?.displayName
                                    .substring(0, 2)
                                    .toUpperCase() ??
                                'CR',
                            style: TextStylePalette.smallHeader.copyWith(
                              color: ColorPalette.white,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  Text(
                    profile?.displayName ?? '-',
                    style: TextStylePalette.smallHeader,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    '@${profile?.username ?? ''}',
                    style: TextStylePalette.subText,
                  ),
                  SizedBox(height: SpacePalette.base),
                ],
              ),
            ),
            // タブバー
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ColorPalette.neutral200, width: 1),
                ),
              ),
              child: TabBar(
                labelColor: ColorPalette.neutral800,
                unselectedLabelColor: ColorPalette.neutral400,
                indicatorColor: ColorPalette.neutral800,
                indicatorWeight: 2,
                labelStyle: TextStylePalette.smTitle,
                unselectedLabelStyle: TextStylePalette.smText,
                tabs: [
                  Tab(icon: Icon(PhosphorIconsRegular.gridFour, size: 20)),
                  Tab(icon: Icon(PhosphorIconsRegular.heart, size: 20)),
                ],
              ),
            ),
            // タブコンテンツ
            Expanded(
              child: TabBarView(
                children: [
                  // タブ1: 自分の投稿
                  _buildVideoGrid(
                    context,
                    submissions: myPosts.value,
                    isLoading: isLoadingPosts.value,
                    emptyIcon: PhosphorIconsRegular.videoCameraSlash,
                    emptyText: AppLocalizations.of(context)!.noSubmissionsYet,
                  ),
                  // タブ2: いいねした動画
                  _buildVideoGrid(
                    context,
                    submissions: likedPosts.value,
                    isLoading: isLoadingLiked.value,
                    emptyIcon: PhosphorIconsRegular.heart,
                    emptyText: AppLocalizations.of(context)!.noLikedProjectsYet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
    BuildContext context, {
    required List<Submission> submissions,
    required bool isLoading,
    required IconData emptyIcon,
    required String emptyText,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorPalette.neutral800),
      );
    }

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 48, color: ColorPalette.neutral300),
            SizedBox(height: SpacePalette.sm),
            Text(emptyText, style: TextStylePalette.subText),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        // local video has its own thumbnail, YouTube has generated thumbnail
        String? thumbnailUrl;
        if (submission.videoThumbnailUrl != null &&
            submission.videoThumbnailUrl!.isNotEmpty) {
          thumbnailUrl = submission.videoThumbnailUrl;
        } else {
          final videoId = extractYoutubeVideoId(submission.videoUrl);
          thumbnailUrl = videoId != null
              ? getYoutubeThumbnailUrl(videoId)
              : null;
        }

        return GestureDetector(
          onTap: () {
            // フィードをこの動画から開始
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedScreen(
                  initialSubmissions: submissions,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            color: ColorPalette.neutral200,
            child: thumbnailUrl != null
                ? Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbnailPlaceholder(),
                  )
                : _thumbnailPlaceholder(),
          ),
        );
      },
    );
  }

  Widget _thumbnailPlaceholder() {
    return Center(
      child: Icon(
        PhosphorIconsRegular.playCircle,
        color: ColorPalette.neutral400,
        size: 32,
      ),
    );
  }
}

/// プロフィール編集画面
class _ProfileEditScreen extends HookConsumerWidget {
  const _ProfileEditScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;

    final nameController = useTextEditingController(
      text: profile?.displayName ?? '',
    );
    final isSaving = useState(false);
    final selectedImageBytes = useState<Uint8List?>(null);
    final selectedImageName = useState<String?>(null);

    final picker = ImagePicker();

    Future<void> pickImage(ImageSource source) async {
      Navigator.pop(context);
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          selectedImageBytes.value = bytes;
          selectedImageName.value = pickedFile.name;
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

    void showImagePicker() {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusPalette.lg),
          ),
        ),
        builder: (ctx) => Container(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              ListTile(
                leading: Icon(
                  PhosphorIconsRegular.image,
                  color: ColorPalette.neutral800,
                ),
                title: Text(
                  AppLocalizations.of(context)!.chooseFromLibrary,
                  style: TextStylePalette.normalText,
                ),
                onTap: () => pickImage(ImageSource.gallery),
              ),
              Divider(color: ColorPalette.neutral200),
              ListTile(
                leading: Icon(
                  PhosphorIconsRegular.camera,
                  color: ColorPalette.neutral800,
                ),
                title: Text(AppLocalizations.of(context)!.takePhoto, style: TextStylePalette.normalText),
                onTap: () => pickImage(ImageSource.camera),
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      );
    }

    Future<void> handleSave() async {
      final newName = nameController.text.trim();
      if (newName.isEmpty) return;

      isSaving.value = true;
      try {
        String? newAvatarUrl;

        if (selectedImageBytes.value != null &&
            selectedImageName.value != null) {
          final authService = ref.read(authServiceProvider);
          newAvatarUrl = await authService.uploadAvatarBytes(
            selectedImageBytes.value!,
            selectedImageName.value!,
          );
        }

        await ref
            .read(userProfileProvider.notifier)
            .updateProfile(displayName: newName, avatarUrl: newAvatarUrl);

        if (context.mounted) {
          Navigator.pop(context);
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
      } finally {
        isSaving.value = false;
      }
    }

    final hasNewImage = selectedImageBytes.value != null;
    final hasExistingImage = profile?.avatarUrl != null;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
        backgroundColor: ColorPalette.neutral100,
        actions: [
          TextButton(
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.smashedPumpkin600,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStylePalette.smTitle.copyWith(
                      color: ColorPalette.smashedPumpkin600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SpacePalette.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SpacePalette.lg),
            Center(
              child: GestureDetector(
                onTap: showImagePicker,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorPalette.neutral400,
                      backgroundImage: hasNewImage
                          ? MemoryImage(selectedImageBytes.value!)
                          : (hasExistingImage
                                ? NetworkImage(profile!.avatarUrl!)
                                : null),
                      child: (!hasNewImage && !hasExistingImage)
                          ? Text(
                              profile?.displayName
                                      .substring(0, 2)
                                      .toUpperCase() ??
                                  'CR',
                              style: TextStylePalette.header.copyWith(
                                color: ColorPalette.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.neutral200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.camera,
                          size: 16,
                          color: ColorPalette.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.displayName, style: TextStylePalette.smTitle),
            SizedBox(height: SpacePalette.sm),
            TextField(
              controller: nameController,
              style: TextStylePalette.normalText,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.pleaseEnterDisplayName),
            ),
            SizedBox(height: SpacePalette.lg),
          ],
        ),
      ),
    );
  }
}
