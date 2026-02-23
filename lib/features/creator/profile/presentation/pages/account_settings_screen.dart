// lib/features/creator/profile/presentation/pages/account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/profile_menu_section.dart';
import '../../../submission/presentation/pages/connected_accounts_screen.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Account Settings',
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
              // Email
              ProfileMenuSection(
                header: 'Account',
                children: [
                  ProfileMenuItem(
                    icon: Icons.email_outlined,
                    iconBackgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    label: 'Email',
                    onTap: () {
                      // TODO: Email change screen
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock_outlined,
                    iconBackgroundColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                    label: 'Password',
                    onTap: () {
                      // TODO: Password change screen
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Connected Accounts
              ProfileMenuSection(
                header: 'Linked Accounts',
                children: [
                  ProfileMenuItem(
                    icon: Icons.link,
                    iconBackgroundColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Connected Accounts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectedAccountsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: SpacePalette.base),

              // Danger Zone
              ProfileMenuSection(
                children: [
                  ProfileMenuItem(
                    icon: Icons.delete_outline,
                    label: 'Delete Account',
                    isDestructive: true,
                    showChevron: false,
                    onTap: () {
                      _showDeleteConfirmation(context, ref);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStylePalette.title,
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStylePalette.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStylePalette.normalText.copyWith(
                color: ColorPalette.neutral600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account deletion is not yet available.')),
              );
            },
            child: Text(
              'Delete',
              style: TextStylePalette.normalText.copyWith(
                color: ColorPalette.critical500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
