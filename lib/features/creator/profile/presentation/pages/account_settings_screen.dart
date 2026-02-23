// lib/features/creator/profile/presentation/pages/account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  /// Show as modal bottom sheet (90% height)
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountSettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'No email';
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9, // 90% of screen height
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header with X button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.base,
                vertical: SpacePalette.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ColorPalette.neutral200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: ColorPalette.neutral800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Account Settings',
                      style: TextStylePalette.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 32), // Balance for X button
                ],
              ),
            ),

            SizedBox(height: SpacePalette.base), // Space between header and Email

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Section
                    Text(
                      'Email',
                      style: TextStylePalette.smTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Container(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                      decoration: BoxDecoration(
                        color: ColorPalette.neutral100,
                        border: Border.all(color: ColorPalette.neutral200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        email,
                        style: TextStylePalette.normalText,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Password Section
                    Text(
                      'Password',
                      style: TextStylePalette.smTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),
                    _DuolingoButton(
                      text: 'Change Password',
                      onPressed: () {
                        // TODO: Change password
                      },
                    ),

                    SizedBox(height: 24),

                    // Connected Accounts Section
                    Text(
                      'Connected Accounts',
                      style: TextStylePalette.smTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // YouTube
                    _PlatformRow(
                      icon: PlatformIcon.youtube(size: 24),
                      name: 'YouTube',
                      onAdd: () {
                        // TODO: Connect YouTube
                      },
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // Instagram
                    _PlatformRow(
                      icon: PlatformIcon.instagram(size: 24),
                      name: 'Instagram',
                      onAdd: () {
                        // TODO: Connect Instagram
                      },
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // TikTok
                    _PlatformRow(
                      icon: PlatformIcon.tiktok(size: 24),
                      name: 'Tiktok',
                      onAdd: () {
                        // TODO: Connect TikTok
                      },
                    ),

                    SizedBox(height: 56),

                    // Danger Zone
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(SpacePalette.base),
                      decoration: BoxDecoration(
                        color: ColorPalette.white,
                        border: Border.all(color: ColorPalette.critical500),
                        borderRadius: BorderRadius.circular(RadiusPalette.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_outlined,
                                size: 18,
                                color: ColorPalette.critical500,
                              ),
                              SizedBox(width: SpacePalette.xs),
                              Text(
                                'Danger Zone',
                                style: TextStylePalette.smTitle.copyWith(
                                  color: ColorPalette.critical500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SpacePalette.sm),
                          Text(
                            'Delete Account',
                            style: TextStylePalette.miniTitle,
                          ),
                          SizedBox(height: SpacePalette.xs),
                          Text(
                            'Once you delete your account there is no going back',
                            style: TextStylePalette.smText.copyWith(
                              color: ColorPalette.neutral500,
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),
                          _DuolingoButton(
                            text: 'Delete Account',
                            isDestructive: true,
                            onPressed: () {
                              _showDeleteConfirmation(context, ref);
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SpacePalette.lg),
                  ],
                ),
              ),
            ),
          ],
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

/// Duolingo-style button with full radius
class _DuolingoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _DuolingoButton({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDestructive
        ? ColorPalette.white
        : ColorPalette.white;
    final shadowColor = isDestructive
        ? ColorPalette.critical500
        : ColorPalette.neutral200;
    final textColor = isDestructive
        ? ColorPalette.critical500
        : ColorPalette.neutral800;
    final borderColor = isDestructive
        ? ColorPalette.critical500
        : ColorPalette.neutral200;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(100), // full radius
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            // Shadow layer (4px below)
            Positioned(
              left: 0,
              right: 0,
              top: 4,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            // Surface layer
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStylePalette.miniTitle.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Platform row with icon and Add button
class _PlatformRow extends StatelessWidget {
  final Widget icon;
  final String name;
  final VoidCallback onAdd;

  const _PlatformRow({
    required this.icon,
    required this.name,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white, // neutral0
        border: Border.all(color: ColorPalette.neutral200, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon background box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: icon),
          ),
          SizedBox(width: SpacePalette.base),
          // Platform name
          Expanded(
            child: Text(
              name,
              style: TextStylePalette.listTitle,
            ),
          ),
          // Add button (Duolingo solid shadow style)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 72,
              height: 36,
              decoration: BoxDecoration(
                color: ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: ColorPalette.neutral200, width: 1),
              ),
              child: Stack(
                children: [
                  // Shadow layer (3px below)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 3,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.neutral200,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  // Surface layer
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: ColorPalette.neutral200, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 14, color: ColorPalette.neutral800),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            'Add',
                            style: TextStylePalette.smText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
