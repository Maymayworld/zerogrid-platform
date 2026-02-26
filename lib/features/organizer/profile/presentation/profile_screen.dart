// lib/features/organizer/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/profile_menu_section.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../auth/presentation/pages/select_role_screen.dart';
import '../../deposit/presentation/pages/select_amount_screen.dart';
import '../../payment/presentation/pages/payment_methods_screen.dart';
import '../../payment/presentation/providers/payment_provider.dart';

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

    // Load balance on mount
    useEffect(() {
      Future.microtask(() async {
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
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SelectRoleScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit profile image...')),
                        );
                      },
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
                          Icons.edit,
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
                'Organizer',
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
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: ColorPalette.white,
                        ),
                        SizedBox(width: SpacePalette.xs),
                        Text(
                          'My Wallet',
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
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
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
                                    Icon(Icons.add, size: 16, color: ColorPalette.white),
                                    SizedBox(width: SpacePalette.xs),
                                    Text(
                                      'Deposit',
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
                    icon: Icons.person_outlined,
                    iconBackgroundColor: ColorPalette.smashedPumpkin100,
                    iconColor: ColorPalette.smashedPumpkin600,
                    label: 'Account Settings',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.payment_outlined,
                    iconBackgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Payment',
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
                header: 'Preferences',
                children: [
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    iconBackgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.verified_user_outlined,
                    iconBackgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                    label: 'Permissions',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Resources section
              ProfileMenuSection(
                header: 'Resources',
                children: [
                  ProfileMenuItem(
                    icon: Icons.headset_mic_outlined,
                    iconBackgroundColor: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF9C27B0),
                    label: 'Contact Support',
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.alternate_email,
                    iconBackgroundColor: ColorPalette.neutral100,
                    iconColor: ColorPalette.neutral800,
                    label: 'Follow @ZeroGrid',
                    onTap: () async {
                      final url = Uri.parse('https://www.instagram.com/zerogrid.jp?igsh=MTdqNzRoNWV2dWN3Yg==');
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
                    icon: Icons.power_settings_new,
                    label: 'Sign Out',
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
}
