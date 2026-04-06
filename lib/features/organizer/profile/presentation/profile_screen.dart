// lib/features/organizer/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/profile_menu_section.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../auth/presentation/pages/select_role_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';
import '../../payment/presentation/pages/payment_methods_screen.dart';
import '../../payment/presentation/providers/payment_provider.dart';
import '../../approval/presentation/providers/approval_provider.dart';
import '../../home/presentation/providers/organizer_stats_provider.dart';
import '../../../creator/submission/presentation/providers/submission_providers.dart';
import 'pages/account_settings_screen.dart';
import 'widgets/notification_settings_sheet.dart';
import '../../../../shared/widgets/language_settings_sheet.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBalanceVisible = useState(true);
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final balance = ref.watch(walletBalanceProvider);

    String formatCurrency(int amount) {
      return '¥${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }

    // Load balance + refresh profile on mount
    useEffect(() {
      Future.microtask(() async {
        // プロフィールをバックグラウンドで最新化
        ref.read(userProfileProvider.notifier).refreshProfile();
        try {
          final paymentService = ref.read(paymentServiceProvider);
          final bal = await paymentService.getBalance();
          ref.read(walletBalanceProvider.notifier).state = bal;
        } catch (_) {}
      });
      return null;
    }, []);

    Future<void> handleLogout() async {
      try {
        await ref.read(authServiceProvider).signOut();
        ref.read(userProfileProvider.notifier).clear();
        ref.invalidate(myCampaignStatsProvider);
        ref.invalidate(totalViewsProvider);
        ref.invalidate(activeCampaignCountProvider);
        ref.invalidate(pendingRequestsProvider);
        ref.invalidate(pendingRequestCountProvider);
        ref.read(walletBalanceProvider.notifier).state = 0;
        ref.read(connectedProvidersProvider.notifier).state = {};
        ref.read(socialConnectionsProvider.notifier).state = [];
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SelectRoleScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.logoutFailed(e.toString())), backgroundColor: Colors.red),
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
              SizedBox(height: SpacePalette.lg),

              // Profile avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: ColorPalette.neutral400,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            profile?.displayName.substring(0, 2).toUpperCase() ?? 'ZG',
                            style: TextStylePalette.header.copyWith(
                              color: ColorPalette.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickAndUploadAvatar(context, ref),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.neutral200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.pencilSimple,
                          size: 16,
                          color: ColorPalette.neutral800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.lg),

              // Name
              Text(
                profile?.displayName ?? '-',
                style: TextStylePalette.smallHeader,
              ),
              SizedBox(height: SpacePalette.sm),

              // Username
              Text(
                '@${profile?.username ?? ''}',
                style: TextStylePalette.subText,
              ),
              SizedBox(height: SpacePalette.xs),

              // Role
              Text(
                AppLocalizations.of(context)!.organizer,
                style: TextStylePalette.smSubText,
              ),
              SizedBox(height: SpacePalette.lg),

              // My Wallet Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(SpacePalette.base),
                decoration: BoxDecoration(
                  color: ColorPalette.neutral800,
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.wallet,
                          size: 16,
                          color: ColorPalette.white,
                        ),
                        SizedBox(width: SpacePalette.xs),
                        Text(
                          AppLocalizations.of(context)!.myWallet,
                          style: TextStylePalette.smText.copyWith(
                            color: ColorPalette.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.base),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isBalanceVisible.value ? formatCurrency(balance) : '¥******',
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.white,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                isBalanceVisible.value = !isBalanceVisible.value;
                              },
                              child: Icon(
                                isBalanceVisible.value
                                    ? PhosphorIconsRegular.eye
                                    : PhosphorIconsRegular.eyeSlash,
                                size: 20,
                                color: ColorPalette.white,
                              ),
                            ),
                            SizedBox(width: SpacePalette.base),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectAmountScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SpacePalette.inner,
                                  vertical: SpacePalette.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPalette.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                ),
                                child: Row(
                                  children: [
                                    Icon(PhosphorIconsRegular.plus, size: 16, color: ColorPalette.white),
                                    SizedBox(width: SpacePalette.xs),
                                    Text(
                                      AppLocalizations.of(context)!.deposit,
                                      style: TextStylePalette.smText.copyWith(
                                        color: ColorPalette.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const OrganizerAccountSettingsScreen(),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    iconAsset: 'assets/images/payment_icon.png',
                    label: AppLocalizations.of(context)!.payment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen(),
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
                        builder: (context) => const OrganizerNotificationSettingsSheet(),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    iconAsset: 'assets/images/language_icon.png',
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
                    icon: PhosphorIconsRegular.at,
                    iconBackgroundColor: ColorPalette.neutral100,
                    iconColor: ColorPalette.neutral800,
                    label: AppLocalizations.of(context)!.followZeroGrid,
                    onTap: () async {
                      final url = Uri.parse('https://www.instagram.com/zerogrid.jp?igsh=MTdqNzRoNWV2dWN3Yg==');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  ProfileMenuItem(
                    icon: PhosphorIconsRegular.fileText,
                    iconBackgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                    label: AppLocalizations.of(context)!.termsOfService,
                    onTap: () async {
                      final url = Uri.parse('https://kota1020.github.io/zerogrid-legal/terms-of-service.html');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  ProfileMenuItem(
                    icon: PhosphorIconsRegular.shield,
                    iconBackgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    label: AppLocalizations.of(context)!.privacyPolicy,
                    onTap: () async {
                      final url = Uri.parse('https://kota1020.github.io/zerogrid-legal/privacy-policy.html');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
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

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: ColorPalette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(PhosphorIconsFill.images),
                title: Text(AppLocalizations.of(context)!.chooseFromLibrary, style: TextStylePalette.normalText),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(PhosphorIconsFill.camera),
                title: Text(AppLocalizations.of(context)!.takePhoto, style: TextStylePalette.normalText),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final fileName = picked.name;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uploading)),
      );

      final authService = ref.read(authServiceProvider);
      final imageUrl = await authService.uploadAvatarBytes(bytes, fileName);
      await authService.updateProfile(avatarUrl: imageUrl);

      // Refresh profile
      await ref.read(userProfileProvider.notifier).loadProfile();

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileImageUpdated)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToUpdateImage(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }
}
