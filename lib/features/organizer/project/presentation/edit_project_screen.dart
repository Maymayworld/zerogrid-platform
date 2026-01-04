// lib/features/organizer/project/presentation/edit_project_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../organizer/create/data/models/campaign.dart';
import '../../../organizer/create/presentation/providers/campaign_service_provider.dart';

class EditProjectScreen extends HookConsumerWidget {
  final String campaignId;

  const EditProjectScreen({
    Key? key,
    required this.campaignId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態管理
    final campaign = useState<Campaign?>(null);
    final isLoading = useState(true);
    final isSaving = useState(false);
    final error = useState<String?>(null);

    // コントローラー
    final projectNameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final targetViewsController = useTextEditingController();
    final budgetController = useTextEditingController();
    final selectedCategory = useState<String?>(null);
    final selectedPlatforms = useState<Set<String>>({});
    
    // サムネイル
    final selectedImageBytes = useState<Uint8List?>(null);
    final selectedImageName = useState<String?>(null);
    final currentThumbnailUrl = useState<String?>(null);

    final picker = ImagePicker();

    final categories = ['Business', 'Entertainment', 'Music', 'Podcast'];
    final platforms = ['YouTube', 'Instagram', 'TikTok'];

    // 初回読み込み
    useEffect(() {
      Future<void> loadCampaign() async {
        try {
          final campaignService = ref.read(campaignServiceProvider);
          final loadedCampaign = await campaignService.getCampaign(campaignId);
          
          if (loadedCampaign != null) {
            campaign.value = loadedCampaign;
            projectNameController.text = loadedCampaign.name;
            descriptionController.text = loadedCampaign.description;
            targetViewsController.text = loadedCampaign.targetViews.toString();
            budgetController.text = loadedCampaign.budget.toString();
            selectedCategory.value = loadedCampaign.category;
            selectedPlatforms.value = loadedCampaign.platforms.toSet();
            currentThumbnailUrl.value = loadedCampaign.thumbnailUrl;
          }
        } catch (e) {
          error.value = e.toString();
        } finally {
          isLoading.value = false;
        }
      }

      loadCampaign();
      return null;
    }, [campaignId]);

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
            SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    // 保存処理
    Future<void> handleSave() async {
      isSaving.value = true;

      try {
        final campaignService = ref.read(campaignServiceProvider);
        String? thumbnailUrl = currentThumbnailUrl.value;

        // 新しい画像があればアップロード
        if (selectedImageBytes.value != null && selectedImageName.value != null) {
          thumbnailUrl = await campaignService.uploadThumbnail(
            selectedImageBytes.value!,
            selectedImageName.value!,
          );
        }

        // 更新
        await campaignService.updateCampaign(
          campaignId: campaignId,
          name: projectNameController.text,
          description: descriptionController.text,
          thumbnailUrl: thumbnailUrl,
          budget: int.tryParse(budgetController.text) ?? 0,
          targetViews: int.tryParse(targetViewsController.text) ?? 0,
          category: selectedCategory.value,
          platforms: selectedPlatforms.value.toList(),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Project updated successfully!'),
              backgroundColor: ColorPalette.systemGreen,
            ),
          );
          Navigator.pop(context, true); // trueを返して更新を通知
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    // ローディング中
    if (isLoading.value) {
      return Scaffold(
        backgroundColor: ColorPalette.neutral0,
        appBar: AppBar(
          backgroundColor: ColorPalette.neutral0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Edit Project', style: TextStylePalette.title),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // エラー
    if (error.value != null) {
      return Scaffold(
        backgroundColor: ColorPalette.neutral0,
        appBar: AppBar(
          backgroundColor: ColorPalette.neutral0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text('Error: ${error.value}', style: TextStylePalette.subText),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Project', style: TextStylePalette.title),
        centerTitle: true,
        actions: [
          if (campaign.value != null)
            Padding(
              padding: EdgeInsets.only(right: SpacePalette.base),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.sm,
                    vertical: SpacePalette.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral100,
                    borderRadius: BorderRadius.circular(RadiusPalette.mini),
                  ),
                  child: Text(
                    '¥${campaign.value!.budget.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}',
                    style: TextStylePalette.smTitle,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // サムネイル
                  GestureDetector(
                    onTap: pickThumbnail,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        color: ColorPalette.neutral200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 画像表示
                            if (selectedImageBytes.value != null)
                              Image.memory(
                                selectedImageBytes.value!,
                                fit: BoxFit.cover,
                              )
                            else if (currentThumbnailUrl.value != null)
                              Image.network(
                                currentThumbnailUrl.value!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _PlaceholderImage(),
                              )
                            else
                              _PlaceholderImage(),
                            
                            // 編集ボタン
                            Positioned(
                              bottom: SpacePalette.sm,
                              right: SpacePalette.sm,
                              child: Container(
                                padding: EdgeInsets.all(SpacePalette.sm),
                                decoration: BoxDecoration(
                                  color: ColorPalette.neutral800,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: ColorPalette.neutral0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SpacePalette.lg),

                  // Project Name
                  Text('Project Name', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: projectNameController,
                    decoration: _inputDecoration('Enter project name'),
                  ),
                  SizedBox(height: SpacePalette.base),

                  // Description
                  Text('Description', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: _inputDecoration('Enter description'),
                  ),
                  SizedBox(height: SpacePalette.base),

                  // Target Views
                  Text('Target Views', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: targetViewsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('200000').copyWith(
                      suffixText: 'Views',
                      suffixStyle: TextStylePalette.normalText,
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),

                  // Budget
                  Text('Budget', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('3000').copyWith(
                      prefixText: '¥ ',
                      prefixStyle: TextStylePalette.normalText,
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),

                  // Category
                  Text('Category', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral0,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory.value,
                      decoration: InputDecoration(
                        hintText: 'Select category',
                        hintStyle: TextStylePalette.hintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                      items: categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      )).toList(),
                      onChanged: (value) {
                        selectedCategory.value = value;
                      },
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),

                  // Platforms
                  Text('Platforms', style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.sm),
                  Wrap(
                    spacing: SpacePalette.sm,
                    children: platforms.map((platform) {
                      final isSelected = selectedPlatforms.value.contains(platform);
                      return FilterChip(
                        label: Text(platform),
                        selected: isSelected,
                        onSelected: (selected) {
                          final current = {...selectedPlatforms.value};
                          if (selected) {
                            current.add(platform);
                          } else {
                            current.remove(platform);
                          }
                          selectedPlatforms.value = current;
                        },
                        selectedColor: ColorPalette.neutral800,
                        checkmarkColor: ColorPalette.neutral0,
                        labelStyle: TextStyle(
                          color: isSelected ? ColorPalette.neutral0 : ColorPalette.neutral800,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: SpacePalette.lg),
                ],
              ),
            ),
          ),

          // Updateボタン
          Container(
            padding: EdgeInsets.all(SpacePalette.base),
            decoration: BoxDecoration(
              color: ColorPalette.neutral0,
              border: Border(
                top: BorderSide(color: ColorPalette.neutral200, width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: isSaving.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Update Project', style: TextStylePalette.buttonTextWhite),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStylePalette.hintText,
      filled: true,
      fillColor: ColorPalette.neutral0,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.all(SpacePalette.base),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorPalette.neutral200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: ColorPalette.neutral400),
          SizedBox(height: SpacePalette.sm),
          Text('Tap to upload', style: TextStylePalette.subText),
        ],
      ),
    );
  }
}