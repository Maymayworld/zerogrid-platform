// lib/features/organizer/profile/presentation/widgets/notification_settings_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../creator/profile/data/services/notification_preferences_service.dart';

final _notifPrefServiceProvider = Provider<NotificationPreferencesService>((ref) {
  return NotificationPreferencesService();
});

class OrganizerNotificationSettingsSheet extends HookConsumerWidget {
  const OrganizerNotificationSettingsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotifications = useState(true);
    final chat = useState(true);
    final campaign = useState(true);
    final isLoaded = useState(false);

    final service = ref.read(_notifPrefServiceProvider);

    useEffect(() {
      Future.microtask(() async {
        try {
          final prefs = await service.getPreferences();
          allNotifications.value = prefs.allNotifications;
          chat.value = prefs.chat;
          campaign.value = prefs.campaign;
        } catch (_) {}
        isLoaded.value = true;
      });
      return null;
    }, []);

    Future<void> toggle(String key, ValueNotifier<bool> notifier) async {
      final newValue = !notifier.value;
      notifier.value = newValue;

      if (key == 'all_notifications') {
        chat.value = newValue;
        campaign.value = newValue;
        try {
          await service.updatePreference('all_notifications', newValue);
          await service.updatePreference('chat', newValue);
          await service.updatePreference('campaign', newValue);
        } catch (_) {}
      } else {
        try {
          await service.updatePreference(key, newValue);
          final allOn = chat.value && campaign.value;
          if (allNotifications.value != allOn) {
            allNotifications.value = allOn;
            await service.updatePreference('all_notifications', allOn);
          }
        } catch (_) {}
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadiusPalette.lg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              Text(AppLocalizations.of(context)!.notifications, style: TextStylePalette.smallHeader),
              SizedBox(height: SpacePalette.lg),

              // All Notifications
              _buildToggleRow(
                label: AppLocalizations.of(context)!.allNotifications,
                value: allNotifications.value,
                onTap: () => toggle('all_notifications', allNotifications),
              ),
              Divider(color: ColorPalette.neutral200, height: 1),
              SizedBox(height: SpacePalette.base),

              // Chat
              _buildToggleRow(
                label: AppLocalizations.of(context)!.chat,
                value: chat.value,
                onTap: () => toggle('chat', chat),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: SpacePalette.base),
                child: Text(
                  AppLocalizations.of(context)!.chatNotificationDesc,
                  style: TextStyle(fontSize: 14, color: ColorPalette.neutral500),
                ),
              ),

              // Campaign
              _buildToggleRow(
                label: AppLocalizations.of(context)!.navCampaign,
                value: campaign.value,
                onTap: () => toggle('campaign', campaign),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: SpacePalette.sm),
                child: Text(
                  AppLocalizations.of(context)!.newsNotificationDesc,
                  style: TextStyle(fontSize: 14, color: ColorPalette.neutral500),
                ),
              ),

              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: SpacePalette.sm),
      child: Row(
        children: [
          Text(label, style: TextStylePalette.normalText),
          Spacer(),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value ? ColorPalette.positive500 : ColorPalette.neutral200,
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.neutral800.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
