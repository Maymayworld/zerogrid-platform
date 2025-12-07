// lib/widgets/project/upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProjectUploadScreen extends HookWidget {
  const ProjectUploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final youtubeController = useTextEditingController();
    final instagramController = useTextEditingController();
    final tiktokController = useTextEditingController();
    final isUploading = useState(false);
    final uploadProgress = useState(0.0);

    void _handleUpload() {
      if (youtubeController.text.isEmpty &&
          instagramController.text.isEmpty &&
          tiktokController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please paste at least one link')),
        );
        return;
      }

      isUploading.value = true;
      uploadProgress.value = 0.0;

      // シミュレーション: 3秒でアップロード完了
      Future.delayed(Duration(seconds: 1), () {
        uploadProgress.value = 0.33;
      });
      Future.delayed(Duration(seconds: 2), () {
        uploadProgress.value = 0.66;
      });
      Future.delayed(Duration(seconds: 3), () {
        uploadProgress.value = 1.0;
        isUploading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload complete!')),
        );
      });
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload',
          style: TextStylePalette.title
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 注意書き
                    Container(
                      padding: EdgeInsets.all(SpacePalette.base),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEF3C7), // 薄い黄色
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
                              'After you upload your video, drop the link in the submission field for view tracking',
                              style: TextStylePalette.subText
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacePalette.lg),
                    
                    // Submission 1
                    Row(
                      children: [
                        Text(
                          'Submission 1',
                          style: TextStylePalette.tagText
                        ),
                        SizedBox(width: SpacePalette.sm),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Add submission coming soon...')),
                            );
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: ColorPalette.neutral500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.base),
                    
                    // YouTube
                    _PlatformLinkField(
                      icon: Icons.play_arrow,
                      platformName: 'YouTube',
                      iconColor: Colors.red,
                      controller: youtubeController,
                      hintText: 'Paste link here...',
                    ),
                    SizedBox(height: SpacePalette.base),
                    
                    // Instagram
                    _PlatformLinkField(
                      icon: Icons.camera_alt,
                      platformName: 'Instagram',
                      iconColor: Colors.pink,
                      controller: instagramController,
                      hintText: 'Paste link here...',
                    ),
                    SizedBox(height: SpacePalette.base),
                    
                    // TikTok
                    _PlatformLinkField(
                      icon: Icons.music_note,
                      platformName: 'TikTok',
                      iconColor: Colors.black,
                      controller: tiktokController,
                      hintText: 'Paste link here...',
                    ),
                    SizedBox(height: SpacePalette.lg),
                    
                    // アップロード中の表示
                    if (isUploading.value)
                      Container(
                        padding: EdgeInsets.all(SpacePalette.base),
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral100,
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'file_name.mp4',
                              style: TextStylePalette.subText
                            ),
                            SizedBox(height: SpacePalette.sm),
                            LinearProgressIndicator(
                              value: uploadProgress.value,
                              backgroundColor: ColorPalette.neutral200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorPalette.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // アップロードボタン
            Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette.neutral0,
                border: Border(
                  top: BorderSide(
                    color: ColorPalette.neutral200,
                    width: 1.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.heightMd,
                child: ElevatedButton(
                  onPressed: isUploading.value ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.sm),
                    ),
                    disabledBackgroundColor: ColorPalette.neutral400,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_outlined,
                        color: ColorPalette.neutral0,
                        size: 20,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Text(
                        isUploading.value ? 'Uploading...' : 'Upload',
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

// プラットフォームリンクフィールド
class _PlatformLinkField extends StatelessWidget {
  final IconData icon;
  final String platformName;
  final Color iconColor;
  final TextEditingController controller;
  final String hintText;

  const _PlatformLinkField({
    required this.icon,
    required this.platformName,
    required this.iconColor,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.neutral100,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              SizedBox(width: SpacePalette.sm),
              Text(
                platformName,
                style: TextStylePalette.miniTitle
              ),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          Container(
            decoration: BoxDecoration(
              color: ColorPalette.neutral0,
              borderRadius: BorderRadius.circular(RadiusPalette.sm),
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
                        vertical: SpacePalette.sm,
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