// lib/features/creator/campaign/presentation/pages/upload_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../auth/presentation/providers/oauth_provider.dart';
import '../providers/submission_service_provider.dart';
import 'success_screen.dart';

class ProjectUploadScreen extends HookConsumerWidget {
  final String? campaignId;
  final String? campaignName;

  const ProjectUploadScreen({
    Key? key,
    this.campaignId,
    this.campaignName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeController = useTextEditingController();
    final instagramController = useTextEditingController();
    final tiktokController = useTextEditingController();
    final isSubmitting = useState(false);
    final scheduledDate = useState<DateTime?>(null);

    Future<void> _selectDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: scheduledDate.value ?? now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ColorPalette.neutral800,
                onPrimary: Colors.white,
                surface: ColorPalette.white,
                onSurface: ColorPalette.neutral800,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        // Also pick time
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorPalette.neutral800,
                  onPrimary: Colors.white,
                  surface: ColorPalette.white,
                  onSurface: ColorPalette.neutral800,
                ),
              ),
              child: child!,
            );
          },
        );
        
        if (time != null) {
          scheduledDate.value = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        } else {
          scheduledDate.value = picked;
        }
      }
    }

    Future<void> _handleSubmit() async {
      if (youtubeController.text.isEmpty &&
          instagramController.text.isEmpty &&
          tiktokController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please paste at least one link'),
            backgroundColor: ColorPalette.critical500,
          ),
        );
        return;
      }

      if (campaignId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Campaign ID not found'),
            backgroundColor: ColorPalette.critical500,
          ),
        );
        return;
      }

      isSubmitting.value = true;

      try {
        final submissionService = ref.read(submissionServiceProvider);
        
        await submissionService.createSubmission(
          campaignId: campaignId!,
          youtubeUrl: youtubeController.text.isNotEmpty ? youtubeController.text : null,
          instagramUrl: instagramController.text.isNotEmpty ? instagramController.text : null,
          tiktokUrl: tiktokController.text.isNotEmpty ? tiktokController.text : null,
          scheduledPostDate: scheduledDate.value,
        );

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectSuccessScreen(
                campaignName: campaignName,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit: $e'),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
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
        title: Text(
          'Submit Video',
          style: TextStylePalette.title,
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
                              'Paste your video links below. The organizer will review your submission.',
                              style: TextStylePalette.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Scheduled Post Date
                    Text(
                      'Scheduled Post Date',
                      style: TextStylePalette.miniTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),
                    GestureDetector(
                      onTap: _selectDate,
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
                              color: ColorPalette.neutral600,
                            ),
                            SizedBox(width: SpacePalette.base),
                            Expanded(
                              child: Text(
                                scheduledDate.value != null
                                    ? DateFormat('MMM d, yyyy • HH:mm').format(scheduledDate.value!)
                                    : 'Select date and time',
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
                              )
                            else
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: ColorPalette.neutral400,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Video Links
                    Text(
                      'Video Links',
                      style: TextStylePalette.miniTitle,
                    ),
                    SizedBox(height: SpacePalette.base),

                    // YouTube
                    _PlatformLinkField(
                      icon: Icons.play_circle_filled,
                      platformName: 'YouTube',
                      iconColor: Colors.red,
                      controller: youtubeController,
                      hintText: 'https://youtube.com/watch?v=...',
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Instagram
                    _PlatformLinkField(
                      icon: Icons.camera_alt,
                      platformName: 'Instagram',
                      iconColor: Color(0xFFE1306C),
                      controller: instagramController,
                      hintText: 'https://instagram.com/reel/...',
                    ),
                    SizedBox(height: SpacePalette.base),

                    // TikTok
                    _PlatformLinkField(
                      icon: Icons.music_note,
                      platformName: 'TikTok',
                      iconColor: Colors.black,
                      controller: tiktokController,
                      hintText: 'https://tiktok.com/@user/video/...',
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // OAuth Section
                    _OAuthSection(),
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
                  onPressed: isSubmitting.value ? null : _handleSubmit,
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
}

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
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              SizedBox(width: SpacePalette.sm),
              Text(
                platformName,
                style: TextStylePalette.smTitle,
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

class _ConnectButton extends StatelessWidget {
  final String platform;
  final IconData icon;
  final Color color;
  final bool isConnected;
  final VoidCallback onTap;

  const _ConnectButton({
    required this.platform,
    required this.icon,
    required this.color,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isConnected ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          color: isConnected ? ColorPalette.positive100 : ColorPalette.neutral100,
          borderRadius: BorderRadius.circular(RadiusPalette.mini),
          border: Border.all(
            color: isConnected ? ColorPalette.positive500 : ColorPalette.neutral200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: SpacePalette.sm),
            Expanded(
              child: Text(
                platform,
                style: TextStylePalette.normalText,
              ),
            ),
            if (isConnected)
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
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
              )
            else
              Text(
                'Connect',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorPalette.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OAuthSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedPlatforms = ref.watch(connectedPlatformsProvider);
    final isConnecting = useState<String?>(null);

    Future<void> connectPlatform(String platform) async {
      isConnecting.value = platform;
      try {
        final oauthService = ref.read(oauthServiceProvider);
        switch (platform) {
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
        // Refresh connected platforms
        ref.invalidate(connectedPlatformsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect: $e'),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isConnecting.value = null;
      }
    }

    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        border: Border.all(
          color: ColorPalette.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: 20,
                color: ColorPalette.neutral600,
              ),
              SizedBox(width: SpacePalette.sm),
              Text(
                'Connect Accounts',
                style: TextStylePalette.smTitle,
              ),
            ],
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Connect your social accounts for automatic view tracking',
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.base),
          connectedPlatforms.when(
            data: (platforms) => Column(
              children: [
                _ConnectButton(
                  platform: 'YouTube',
                  icon: Icons.play_circle_filled,
                  color: Colors.red,
                  isConnected: platforms['youtube'] ?? false,
                  onTap: () => connectPlatform('youtube'),
                ),
                SizedBox(height: SpacePalette.sm),
                _ConnectButton(
                  platform: 'Instagram',
                  icon: Icons.camera_alt,
                  color: Color(0xFFE1306C),
                  isConnected: platforms['instagram'] ?? false,
                  onTap: () => connectPlatform('instagram'),
                ),
                SizedBox(height: SpacePalette.sm),
                _ConnectButton(
                  platform: 'TikTok',
                  icon: Icons.music_note,
                  color: Colors.black,
                  isConnected: platforms['tiktok'] ?? false,
                  onTap: () => connectPlatform('tiktok'),
                ),
              ],
            ),
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(SpacePalette.base),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorPalette.neutral400,
                ),
              ),
            ),
            error: (_, __) => Column(
              children: [
                _ConnectButton(
                  platform: 'YouTube',
                  icon: Icons.play_circle_filled,
                  color: Colors.red,
                  isConnected: false,
                  onTap: () => connectPlatform('youtube'),
                ),
                SizedBox(height: SpacePalette.sm),
                _ConnectButton(
                  platform: 'Instagram',
                  icon: Icons.camera_alt,
                  color: Color(0xFFE1306C),
                  isConnected: false,
                  onTap: () => connectPlatform('instagram'),
                ),
                SizedBox(height: SpacePalette.sm),
                _ConnectButton(
                  platform: 'TikTok',
                  icon: Icons.music_note,
                  color: Colors.black,
                  isConnected: false,
                  onTap: () => connectPlatform('tiktok'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
