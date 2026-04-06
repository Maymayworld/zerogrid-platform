// lib/features/organizer/campaign/presentation/pages/create/preview_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zero_grid/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/campaign_service_provider.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/shared/widgets/platform_icon.dart';
import 'package:zero_grid/shared/theme/main_layout.dart';
import 'package:zero_grid/features/auth/data/models/user_role.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class PreviewPage extends HookConsumerWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final width = MediaQuery.of(context).size.width;

    final isLoading = useState(false);
    final selectedImageBytes = useState<Uint8List?>(null);
    final selectedImageName = useState<String?>(null);

    final picker = ImagePicker();

    // サムネイル選択
    Future<void> pickThumbnail() async {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 720,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          selectedImageBytes.value = bytes;
          selectedImageName.value = pickedFile.name;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToPickImage(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }

    // 投稿処理
    Future<void> handlePost() async {
      isLoading.value = true;

      try {
        final campaignService = ref.read(campaignServiceProvider);
        String? thumbnailUrl;

        // サムネイルがあればアップロード
        if (selectedImageBytes.value != null && selectedImageName.value != null) {
          thumbnailUrl = await campaignService.uploadThumbnail(
            selectedImageBytes.value!,
            selectedImageName.value!,
          );
        }

        // 案件登録
        await campaignService.createCampaign(
          project: project,
          thumbnailUrl: thumbnailUrl,
        );

        // プロジェクト状態リセット
        ref.read(projectProvider.notifier).reset();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.campaignPostedSuccess),
              backgroundColor: ColorPalette.positive500,
            ),
          );
          // OrganizerのMainLayoutに戻る（履歴クリア）
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainLayout(userRole: UserRole.organizer),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToPost(e.toString())), backgroundColor: Colors.red),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    // 投稿可能かチェック
    final canPost = project.projectName.isNotEmpty &&
        project.description.isNotEmpty &&
        project.category.isNotEmpty &&
        project.platforms.isNotEmpty &&
        project.targetViews > 0 &&
        project.budget > 0 &&
        project.endDate.isNotEmpty;

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.preview, style: TextStylePalette.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // サムネイル
                      InkWell(
                        onTap: pickThumbnail,
                        child: Container(
                          width: double.infinity,
                          height: (width - SpacePalette.base * 2) * 9 / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                            color: ColorPalette.neutral100,
                          ),
                          child: selectedImageBytes.value != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                                  child: Image.memory(
                                    selectedImageBytes.value!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIconsRegular.uploadSimple, size: 40, color: ColorPalette.neutral500),
                                    SizedBox(height: SpacePalette.sm),
                                    Text(
                                      AppLocalizations.of(context)!.uploadImage,
                                      style: TextStylePalette.smallHeader.copyWith(
                                        color: ColorPalette.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // プラットフォームチップ（Creator側と同じCategoryChip使用）
                      Wrap(
                        spacing: SpacePalette.sm,
                        runSpacing: SpacePalette.sm,
                        children: project.platforms.map((platform) {
                          return CategoryChip(
                            iconWidget: PlatformIcon.fromPlatform(platform, size: CategoryChipSize.iconSize),
                            label: platform,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // プロジェクト名
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          project.projectName.isEmpty ? AppLocalizations.of(context)!.projectName : project.projectName,
                          style: TextStylePalette.smallHeader,
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // 単価
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '￥${project.pricePerThousand.toStringAsFixed(0)} / 1000 Views',
                          style: TextStylePalette.header,
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      Divider(color: ColorPalette.neutral200, height: 1),

                      // 会社情報（実データ使用）
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: SpacePalette.base),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: ColorPalette.neutral200,
                              backgroundImage: profile?.avatarUrl != null
                                  ? NetworkImage(profile!.avatarUrl!)
                                  : null,
                              child: profile?.avatarUrl == null
                                  ? Icon(PhosphorIconsRegular.buildings, size: 20, color: ColorPalette.neutral600)
                                  : null,
                            ),
                            SizedBox(width: SpacePalette.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.displayName ?? '-',
                                  style: TextStylePalette.listTitle,
                                ),
                                SizedBox(height: SpacePalette.xs),
                                Text(
                                  AppLocalizations.of(context)!.organizer,
                                  style: TextStylePalette.listLeading,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Divider(color: ColorPalette.neutral200, height: 1),
                      SizedBox(height: SpacePalette.base),

                      // Description
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppLocalizations.of(context)!.description, style: TextStylePalette.smTitle),
                      ),
                      SizedBox(height: SpacePalette.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          project.description.isEmpty ? AppLocalizations.of(context)!.noDescription : project.description,
                          style: TextStylePalette.normalText,
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      Divider(color: ColorPalette.neutral200, height: 1),
                      SizedBox(height: SpacePalette.base),

                      // Resources
                      if (project.links.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!.resources, style: TextStylePalette.smTitle),
                        ),
                        SizedBox(height: SpacePalette.sm),
                        ...project.links.where((link) => link.isNotEmpty).map((link) => Padding(
                              padding: EdgeInsets.only(bottom: SpacePalette.xs),
                              child: Row(
                                children: [
                                  Icon(PhosphorIconsRegular.link, size: 16, color: ColorPalette.neutral500),
                                  SizedBox(width: SpacePalette.xs),
                                  Expanded(
                                    child: Text(
                                      link,
                                      style: TextStylePalette.smSubText,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: SpacePalette.base),
                      ],
                    ],
                  ),
                ),
              ),

              // Postボタン
              SizedBox(height: SpacePalette.base),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  boxShadow: canPost ? [
                    BoxShadow(
                      color: ColorPalette.smashedPumpkin800,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ] : [],
                ),
                child: ElevatedButton(
                  onPressed: canPost && !isLoading.value ? handlePost : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canPost ? ColorPalette.smashedPumpkin600 : ColorPalette.neutral100,
                    foregroundColor: ColorPalette.white,
                    disabledBackgroundColor: ColorPalette.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          AppLocalizations.of(context)!.post,
                          style: canPost
                              ? TextStylePalette.buttonTextWhite.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )
                              : TextStylePalette.buttonTextBlack.copyWith(
                                  color: ColorPalette.neutral400,
                                ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PlatformChip removed - using CategoryChip from app_theme.dart instead