// lib/features/creator/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/profile_menu_section.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/providers/user_profile_provider.dart';
import '../../auth/presentation/pages/select_role_screen.dart';
import 'presentation/pages/account_settings_screen.dart';
import 'data/models/bank_account.dart';
import 'presentation/providers/bank_account_provider.dart';
import 'presentation/pages/bank_account_screen.dart';
import '../earnings/presentation/pages/earnings_screen.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final bankAccount = ref.watch(bankAccountProvider);

    // Load bank account on mount
    useEffect(() {
      Future.microtask(() async {
        try {
          final service = ref.read(bankAccountServiceProvider);
          final account = await service.getBankAccount();
          ref.read(bankAccountProvider.notifier).state = account;
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
              CircleAvatar(
                radius: 50,
                backgroundColor: ColorPalette.neutral400,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? Text(
                        profile?.displayName.substring(0, 2).toUpperCase() ?? 'CR',
                        style: TextStylePalette.header.copyWith(
                          color: ColorPalette.white,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: SpacePalette.lg),

              // Name
              Text(
                profile?.displayName ?? 'Loading...',
                style: TextStylePalette.smallHeader,
              ),
              SizedBox(height: SpacePalette.sm),

              // Role badge
              Text(
                'Creator',
                style: TextStylePalette.subText,
              ),
              SizedBox(height: SpacePalette.lg),

              // Bank Account Card
              _buildBankAccountCard(context, bankAccount),
              SizedBox(height: SpacePalette.lg),

              // Account section
              ProfileMenuSection(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outlined,
                    iconBackgroundColor: ColorPalette.smashedPumpkin100,
                    iconColor: ColorPalette.smashedPumpkin600,
                    label: 'Account Settings',
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
                    icon: Icons.account_balance_outlined,
                    iconBackgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                    label: 'Bank Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BankAccountScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.payments_outlined,
                    iconBackgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Earnings',
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
                    onTap: () {},
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

  Widget _buildBankAccountCard(BuildContext context, BankAccount? bankAccount) {
    if (bankAccount != null) {
      return Container(
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
                  Icons.account_balance,
                  size: 16,
                  color: ColorPalette.neutral100,
                ),
                SizedBox(width: SpacePalette.xs),
                Text(
                  'Bank Account',
                  style: TextStylePalette.smText.copyWith(
                    color: ColorPalette.neutral100,
                  ),
                ),
              ],
            ),
            SizedBox(height: SpacePalette.base),
            Text(
              bankAccount.accountHolder,
              style: TextStylePalette.smallHeader.copyWith(
                color: ColorPalette.neutral100,
              ),
            ),
            SizedBox(height: SpacePalette.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bankAccount.bankName} - ${bankAccount.branchName}',
                  style: TextStylePalette.smText.copyWith(
                    color: ColorPalette.neutral100.withOpacity(0.7),
                  ),
                ),
                Text(
                  bankAccount.maskedAccountNumber,
                  style: TextStylePalette.normalText.copyWith(
                    color: ColorPalette.neutral100,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Empty state - prompt to add bank account
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BankAccountScreen(),
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
                    'Bank Account',
                    style: TextStylePalette.smallHeader.copyWith(
                      color: ColorPalette.white,
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    'Add your bank account for payouts',
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.neutral100.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline,
              size: 20,
              color: ColorPalette.white,
            ),
          ],
        ),
      ),
    );
  }
}
