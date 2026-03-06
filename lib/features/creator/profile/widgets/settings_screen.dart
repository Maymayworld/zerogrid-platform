// lib/features/creator/profile/widgets/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../auth/presentation/providers/oauth_provider.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedPlatformsAsync = ref.watch(connectedPlatformsProvider);
    
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
          AppLocalizations.of(context)!.settings,
          style: GoogleFonts.inter(
            fontSize: FontSizePalette.size16,
            fontWeight: FontWeight.w600,
            color: ColorPalette.neutral800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Connected Services
              Text(
                AppLocalizations.of(context)!.connectedServices,
                style: GoogleFonts.inter(
                  fontSize: FontSizePalette.size14,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.neutral600,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              
              connectedPlatformsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: ColorPalette.neutral800,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    AppLocalizations.of(context)!.failedToLoad,
                    style: TextStylePalette.subText,
                  ),
                ),
                data: (platforms) => Column(
                  children: [
                    // YouTube
                    _ServiceConnectionTile(
                      iconWidget: PlatformIcon.youtube(size: 20),
                      iconColor: Colors.red,
                      serviceName: 'YouTube',
                      isConnected: platforms['youtube'] ?? false,
                      connectedAccount: platforms['youtube_username'],
                      onConnect: () async {
                        await ref.read(oAuthServiceProvider).connectYouTube();
                        ref.invalidate(connectedPlatformsProvider);
                      },
                      onDisconnect: () async {
                        await _showDisconnectConfirmation(
                          context,
                          'YouTube',
                          () async {
                            await ref.read(oAuthServiceProvider).disconnectPlatform('youtube');
                            ref.invalidate(connectedPlatformsProvider);
                          },
                        );
                      },
                    ),
                    
                    // Instagram
                    _ServiceConnectionTile(
                      iconWidget: PlatformIcon.instagram(size: 20),
                      iconColor: Colors.purple,
                      serviceName: 'Instagram',
                      isConnected: platforms['instagram'] ?? false,
                      connectedAccount: platforms['instagram_username'],
                      onConnect: () async {
                        await ref.read(oAuthServiceProvider).connectInstagram();
                        ref.invalidate(connectedPlatformsProvider);
                      },
                      onDisconnect: () async {
                        await _showDisconnectConfirmation(
                          context,
                          'Instagram',
                          () async {
                            await ref.read(oAuthServiceProvider).disconnectPlatform('instagram');
                            ref.invalidate(connectedPlatformsProvider);
                          },
                        );
                      },
                    ),
                    
                    // TikTok
                    _ServiceConnectionTile(
                      iconWidget: PlatformIcon.tiktok(size: 20),
                      iconColor: Colors.black,
                      serviceName: 'TikTok',
                      isConnected: platforms['tiktok'] ?? false,
                      connectedAccount: platforms['tiktok_username'],
                      onConnect: () async {
                        await ref.read(oAuthServiceProvider).connectTikTok();
                        ref.invalidate(connectedPlatformsProvider);
                      },
                      onDisconnect: () async {
                        await _showDisconnectConfirmation(
                          context,
                          'TikTok',
                          () async {
                            await ref.read(oAuthServiceProvider).disconnectPlatform('tiktok');
                            ref.invalidate(connectedPlatformsProvider);
                          },
                        );
                      },
                    ),
                    
                    SizedBox(height: SpacePalette.base),
                    
                    // Divider with label
                    Row(
                      children: [
                        Expanded(child: Divider(color: ColorPalette.neutral200)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                          child: Text(
                            AppLocalizations.of(context)!.utilities,
                            style: GoogleFonts.inter(
                              fontSize: FontSizePalette.size12,
                              color: ColorPalette.neutral400,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: ColorPalette.neutral200)),
                      ],
                    ),
                    
                    SizedBox(height: SpacePalette.base),
                    
                    // Google Calendar
                    _ServiceConnectionTile(
                      iconWidget: Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF4285F4)),
                      iconColor: Color(0xFF4285F4), // Google blue
                      serviceName: 'Google Calendar',
                      description: 'Sync campaign deadlines to your calendar',
                      isConnected: platforms['google_calendar'] ?? false,
                      connectedAccount: platforms['google_calendar_email'],
                      onConnect: () async {
                        await ref.read(oAuthServiceProvider).connectGoogleCalendar();
                        ref.invalidate(connectedPlatformsProvider);
                      },
                      onDisconnect: () async {
                        await _showDisconnectConfirmation(
                          context,
                          'Google Calendar',
                          () async {
                            await ref.read(oAuthServiceProvider).disconnectPlatform('google_calendar');
                            ref.invalidate(connectedPlatformsProvider);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: SpacePalette.lg),
              
              // Info text
              Container(
                padding: EdgeInsets.all(SpacePalette.base),
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: ColorPalette.neutral600,
                    ),
                    SizedBox(width: SpacePalette.sm),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.connectSocialAccounts,
                        style: GoogleFonts.inter(
                          fontSize: FontSizePalette.size12,
                          color: ColorPalette.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showDisconnectConfirmation(
    BuildContext context,
    String serviceName,
    Future<void> Function() onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.disconnectProvider(serviceName)),
        content: Text(
          AppLocalizations.of(context)!.disconnectConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: ColorPalette.neutral600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.disconnect,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await onConfirm();
    }
  }
}

// Service connection tile widget
class _ServiceConnectionTile extends StatelessWidget {
  final Widget iconWidget;
  final Color iconColor;
  final String serviceName;
  final String? description;
  final bool isConnected;
  final String? connectedAccount;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _ServiceConnectionTile({
    required this.iconWidget,
    required this.iconColor,
    required this.serviceName,
    this.description,
    required this.isConnected,
    this.connectedAccount,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.sm),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
        border: Border.all(
          color: isConnected ? ColorPalette.neutral300 : ColorPalette.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Service icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(RadiusPalette.mini),
            ),
            child: Center(child: iconWidget),
          ),
          SizedBox(width: SpacePalette.base),
          
          // Service info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      serviceName,
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.size14,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.neutral800,
                      ),
                    ),
                    if (isConnected) ...[
                      SizedBox(width: SpacePalette.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Connected',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isConnected && connectedAccount != null) ...[
                  SizedBox(height: 2),
                  Text(
                    connectedAccount!,
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.size12,
                      color: ColorPalette.neutral500,
                    ),
                  ),
                ] else if (description != null) ...[
                  SizedBox(height: 2),
                  Text(
                    description!,
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.size12,
                      color: ColorPalette.neutral500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Connect/Disconnect button
          if (isConnected)
            TextButton(
              onPressed: onDisconnect,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Disconnect',
                style: GoogleFonts.inter(
                  fontSize: FontSizePalette.size12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.neutral800,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Connect',
                style: GoogleFonts.inter(
                  fontSize: FontSizePalette.size12,
                  fontWeight: FontWeight.w500,
                  color: ColorPalette.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
