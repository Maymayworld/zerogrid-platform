// lib/features/creator/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/profile_menu_section.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/providers/user_profile_provider.dart';
import '../../auth/presentation/pages/select_role_screen.dart';
import 'presentation/pages/account_settings_screen.dart';
import 'presentation/pages/profile_detail_screen.dart';
import 'presentation/widgets/notification_settings_sheet.dart';
import '../../../shared/widgets/language_settings_sheet.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../earnings/data/services/payout_service.dart';
import '../earnings/presentation/pages/earnings_screen.dart';
import '../earnings/presentation/pages/withdrawal_screen.dart';
import '../feed/presentation/providers/feed_provider.dart';
import '../campaign/presentation/providers/participation_service_provider.dart';
import '../likes/presentation/providers/like_service_provider.dart';
import '../submission/presentation/providers/submission_providers.dart';
import '../../organizer/approval/presentation/providers/approval_provider.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final connectStatus = useState<ConnectStatus?>(null);
    final connectLoading = useState(true);

    // Load Stripe Connect status + refresh profile on mount
    useEffect(() {
      Future.microtask(() async {
        // プロフィールをバックグラウンドで最新化
        ref.read(userProfileProvider.notifier).refreshProfile();
        try {
          final service = PayoutService();
          final status = await service.getConnectStatus();
          connectStatus.value = status;
        } catch (_) {}
        connectLoading.value = false;
      });
      return null;
    }, []);

    Future<void> handleLogout() async {
      try {
        await ref.read(authServiceProvider).signOut();
        ref.read(userProfileProvider.notifier).clear();
        ref.read(feedLikedIdsProvider.notifier).state = {};
        ref.read(participatingCampaignIdsProvider.notifier).state = {};
        ref.read(likedCampaignIdsProvider.notifier).state = {};
        ref.read(connectedProvidersProvider.notifier).state = {};
        ref.read(socialConnectionsProvider.notifier).state = [];
        ref.invalidate(pendingRequestsProvider);
        ref.invalidate(pendingRequestCountProvider);
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SelectRoleScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.logoutFailed(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              SizedBox(height: SpacePalette.sm),

              // Profile card tile
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileDetailScreen(),
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    borderRadius: BorderRadius.circular(RadiusPalette.lg),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.neutral800.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.base,
                    vertical: SpacePalette.inner,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
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
                                style: TextStylePalette.smTitle.copyWith(
                                  color: ColorPalette.white,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: SpacePalette.inner),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ?? '-',
                              style: TextStylePalette.bigText.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.viewProfile,
                              style: TextStylePalette.smSubText,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: ColorPalette.neutral400,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.base),

              // Payout Account Card
              _buildPayoutCard(
                context,
                connectStatus.value,
                connectLoading.value,
              ),
              SizedBox(height: SpacePalette.lg),

              // Account section
              ProfileMenuSection(
                children: [
                  ProfileMenuItem(
                    iconAsset: 'assets/images/setting_icon.png',
                    iconBackgroundColor: ColorPalette.smashedPumpkin100,
                    label: AppLocalizations.of(context)!.accountSettings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    iconAsset: 'assets/images/payment_icon.png',
                    label: AppLocalizations.of(context)!.earnings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EarningsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Preferences section
              ProfileMenuSection(
                header: AppLocalizations.of(context)!.preferences,
                children: [
                  ProfileMenuItem(
                    iconAsset: 'assets/images/notification_icon.png',
                    label: AppLocalizations.of(context)!.notifications,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const NotificationSettingsSheet(),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.language,
                    iconBackgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                    label: AppLocalizations.of(context)!.language,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const LanguageSettingsSheet(),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Resources section
              ProfileMenuSection(
                header: AppLocalizations.of(context)!.resources,
                children: [
                  ProfileMenuItem(
                    iconAsset: 'assets/images/support_icon.png',
                    label: AppLocalizations.of(context)!.contactSupport,
                    onTap: () async {
                      final url = Uri.parse('https://discord.gg/TUWMqNJfUX');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.alternate_email,
                    iconBackgroundColor: ColorPalette.neutral100,
                    iconColor: ColorPalette.neutral800,
                    label: AppLocalizations.of(context)!.followZeroGrid,
                    onTap: () async {
                      final url = Uri.parse(
                        'https://www.instagram.com/zerogrid.jp?igsh=MTdqNzRoNWV2dWN3Yg==',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Sign Out section
              ProfileMenuSection(
                children: [
                  ProfileMenuItem(
                    iconAsset: 'assets/images/signout_icon.png',
                    label: AppLocalizations.of(context)!.signOut,
                    isDestructive: true,
                    showChevron: false,
                    onTap: handleLogout,
                  ),
                ],
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutCard(
    BuildContext context,
    ConnectStatus? status,
    bool isLoading,
  ) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.neutral800,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 24,
              color: ColorPalette.white,
            ),
            SizedBox(width: SpacePalette.inner),
            Text(
              AppLocalizations.of(context)!.payoutAccount,
              style: TextStylePalette.smallHeader.copyWith(
                color: ColorPalette.white,
              ),
            ),
            Spacer(),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorPalette.white,
              ),
            ),
          ],
        ),
      );
    }

    final isConnected =
        status?.hasConnect == true && status?.payoutsEnabled == true;
    final isPending =
        status?.hasConnect == true && status?.payoutsEnabled != true;

    if (isConnected) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.neutral800,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance, size: 24, color: ColorPalette.white),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.payoutAccount,
                    style: TextStylePalette.smallHeader.copyWith(
                      color: ColorPalette.white,
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    AppLocalizations.of(context)!.readyForWithdrawals,
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.neutral100.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.sm,
                vertical: SpacePalette.xs,
              ),
              decoration: BoxDecoration(
                color: ColorPalette.positive500.withOpacity(0.2),
                borderRadius: BorderRadius.circular(RadiusPalette.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: ColorPalette.positive500,
                  ),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.connected,
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.positive500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (isPending) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawalScreen(currentBalance: 0),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(SpacePalette.base),
          decoration: BoxDecoration(
            color: ColorPalette.neutral800,
            borderRadius: BorderRadius.circular(RadiusPalette.base),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 24,
                color: ColorPalette.white,
              ),
              SizedBox(width: SpacePalette.inner),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.payoutAccount,
                      style: TextStylePalette.smallHeader.copyWith(
                        color: ColorPalette.white,
                      ),
                    ),
                    SizedBox(height: SpacePalette.xs),
                    Text(
                      AppLocalizations.of(context)!.verificationInProgress,
                      style: TextStylePalette.smText.copyWith(
                        color: ColorPalette.neutral100.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SpacePalette.sm,
                  vertical: SpacePalette.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                ),
                child: Text(
                  AppLocalizations.of(context)!.pending,
                  style: TextStylePalette.smText.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Not connected - prompt to set up
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WithdrawalScreen(currentBalance: 0),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.neutral800,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 24,
              color: ColorPalette.white,
            ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.payoutAccount,
                    style: TextStylePalette.smallHeader.copyWith(
                      color: ColorPalette.white,
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    AppLocalizations.of(context)!.setupPayoutAccount,
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.neutral100.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: ColorPalette.white),
          ],
        ),
      ),
    );
  }
}
