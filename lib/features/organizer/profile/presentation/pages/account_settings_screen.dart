// lib/features/organizer/profile/presentation/pages/account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';

class OrganizerAccountSettingsScreen extends HookConsumerWidget {
  const OrganizerAccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'No email';
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: screenHeight * 0.9,
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.xl)),
        ),
        child: SafeArea(
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
                          PhosphorIconsRegular.x,
                          size: 18,
                          color: ColorPalette.neutral800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.accountSettings,
                        style: TextStylePalette.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 32),
                  ],
                ),
              ),

              SizedBox(height: SpacePalette.base),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Section
                      Text(AppLocalizations.of(context)!.email, style: TextStylePalette.smTitle),
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
                        child: Text(email, style: TextStylePalette.normalText),
                      ),

                      SizedBox(height: 24),

                      // Password Section
                      Text(AppLocalizations.of(context)!.password, style: TextStylePalette.smTitle),
                      SizedBox(height: SpacePalette.sm),
                      _DuolingoButton(
                        text: AppLocalizations.of(context)!.changePassword,
                        onPressed: () {
                          // TODO: Change password
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
                                  PhosphorIconsRegular.warning,
                                  size: 18,
                                  color: ColorPalette.critical500,
                                ),
                                SizedBox(width: SpacePalette.xs),
                                Text(
                                  AppLocalizations.of(context)!.dangerZone,
                                  style: TextStylePalette.smTitle.copyWith(
                                    color: ColorPalette.critical500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SpacePalette.sm),
                            Text(AppLocalizations.of(context)!.deleteAccount, style: TextStylePalette.miniTitle),
                            SizedBox(height: SpacePalette.xs),
                            Text(
                              AppLocalizations.of(context)!.deleteAccountWarning,
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.neutral500,
                              ),
                            ),
                            SizedBox(height: SpacePalette.base),
                            _DuolingoButton(
                              text: AppLocalizations.of(context)!.deleteAccount,
                              isDestructive: true,
                              onPressed: () {
                                _showDeleteConfirmation(context);
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
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount, style: TextStylePalette.title),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountWarning,
          style: TextStylePalette.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStylePalette.normalText.copyWith(color: ColorPalette.neutral600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.accountDeletionUnavailable)),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
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
    final shadowColor = isDestructive ? ColorPalette.critical500 : ColorPalette.neutral200;
    final textColor = isDestructive ? ColorPalette.critical500 : ColorPalette.neutral800;
    final borderColor = isDestructive ? ColorPalette.critical500 : ColorPalette.neutral200;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0, right: 0, top: 4, height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, top: 0, height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.white,
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
