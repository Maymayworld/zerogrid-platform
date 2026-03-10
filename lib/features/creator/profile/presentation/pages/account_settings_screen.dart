// lib/features/creator/profile/presentation/pages/account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import '../../../../auth/presentation/providers/oauth_provider.dart';
import '../../../../creator/submission/presentation/providers/submission_providers.dart';
import '../../../../creator/submission/data/models/social_connection.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class AccountSettingsScreen extends HookConsumerWidget {
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
    
    // Social connections state
    final connections = useState<List<SocialConnection>>([]);
    final isLoading = useState(true);

    // Load connections on mount
    Future<void> loadConnections() async {
      isLoading.value = true;
      try {
        final service = ref.read(socialConnectionServiceProvider);
        final conns = await service.getMyConnections();
        connections.value = conns;
        ref.read(connectedProvidersProvider.notifier).state =
            conns.map((c) => c.provider).toSet();
        ref.read(socialConnectionsProvider.notifier).state = conns;
      } catch (e) {
        // Handle error silently
      } finally {
        isLoading.value = false;
      }
    }

    // Auto-refresh when app resumes (after returning from browser OAuth)
    final appLifecycleState = useAppLifecycleState();

    useEffect(() {
      loadConnections();
      return null;
    }, []);

    useEffect(() {
      if (appLifecycleState == AppLifecycleState.resumed) {
        loadConnections();
      }
      return null;
    }, [appLifecycleState]);

    // Get all connections for a provider
    List<SocialConnection> getConnectionsFor(String provider) {
      return connections.value
          .where((c) => c.provider == provider && (c.isConnected || c.isExpired))
          .toList();
    }

    // Handle OAuth connect
    Future<void> handleConnect(String provider) async {
      try {
        final oauthService = ref.read(oAuthServiceProvider);
        switch (provider) {
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
        await loadConnections();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }

    // Handle disconnect
    Future<void> handleDisconnect(String connectionId, String providerName) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.disconnectProvider(providerName), style: TextStylePalette.title),
          content: Text(AppLocalizations.of(context)!.disconnectConfirm, style: TextStylePalette.normalText),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.disconnect, style: TextStyle(color: ColorPalette.critical500)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final service = ref.read(socialConnectionServiceProvider);
          await service.disconnectProvider(connectionId);
          await loadConnections();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.disconnectProvider(providerName))),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
            );
          }
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        height: screenHeight * 0.9, // 90% of screen height
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
                        Icons.close,
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
                      AppLocalizations.of(context)!.email,
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
                      AppLocalizations.of(context)!.password,
                      style: TextStylePalette.smTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),
                    _DuolingoButton(
                      text: AppLocalizations.of(context)!.changePassword,
                      onPressed: () {
                        // TODO: Change password
                      },
                    ),

                    SizedBox(height: 24),

                    // Connected Accounts Section
                    Text(
                      AppLocalizations.of(context)!.connectedAccounts,
                      style: TextStylePalette.smTitle,
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // YouTube
                    _PlatformSection(
                      icon: PlatformIcon.youtube(size: 24),
                      name: 'YouTube',
                      connections: getConnectionsFor('youtube'),
                      onAdd: () => handleConnect('youtube'),
                      onDisconnect: (id) => handleDisconnect(id, 'YouTube'),
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // Instagram
                    _PlatformSection(
                      icon: PlatformIcon.instagram(size: 24),
                      name: 'Instagram',
                      connections: getConnectionsFor('instagram'),
                      onAdd: () => handleConnect('instagram'),
                      onDisconnect: (id) => handleDisconnect(id, 'Instagram'),
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // TikTok
                    _PlatformSection(
                      icon: PlatformIcon.tiktok(size: 24),
                      name: 'TikTok',
                      connections: getConnectionsFor('tiktok'),
                      onAdd: () => handleConnect('tiktok'),
                      onDisconnect: (id) => handleDisconnect(id, 'TikTok'),
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
                                AppLocalizations.of(context)!.dangerZone,
                                style: TextStylePalette.smTitle.copyWith(
                                  color: ColorPalette.critical500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SpacePalette.sm),
                          Text(
                            AppLocalizations.of(context)!.deleteAccount,
                            style: TextStylePalette.miniTitle,
                          ),
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
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: TextStylePalette.title,
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountWarning,
          style: TextStylePalette.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
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

/// Platform section with header + multiple connected accounts
class _PlatformSection extends StatelessWidget {
  final Widget icon;
  final String name;
  final List<SocialConnection> connections;
  final VoidCallback onAdd;
  final void Function(String connectionId) onDisconnect;

  const _PlatformSection({
    required this.icon,
    required this.name,
    required this.connections,
    required this.onAdd,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.white,
        border: Border.all(color: ColorPalette.neutral200, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header row: icon + name + add button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SpacePalette.base,
              vertical: SpacePalette.sm + 2,
            ),
            child: Row(
              children: [
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
                Expanded(
                  child: Text(name, style: TextStylePalette.listTitle),
                ),
                // Add button
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral100,
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                      border: Border.all(color: ColorPalette.neutral300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: ColorPalette.neutral700),
                        SizedBox(width: 2),
                        Text(
                          AppLocalizations.of(context)!.add,
                          style: TextStylePalette.smText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Connected accounts list
          if (connections.isNotEmpty) ...[
            Divider(
              height: 1,
              indent: SpacePalette.base,
              endIndent: SpacePalette.base,
              color: ColorPalette.neutral200,
            ),
            ...connections.map((conn) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.base,
                vertical: SpacePalette.sm,
              ),
              child: Row(
                children: [
                  SizedBox(width: 40 + SpacePalette.base), // align with name above
                  Expanded(
                    child: Text(
                      '@${conn.providerAccountName ?? conn.providerAccountId}',
                      style: TextStylePalette.normalText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onDisconnect(conn.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacePalette.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(RadiusPalette.full),
                        border: Border.all(color: ColorPalette.neutral300),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.disconnect,
                        style: TextStylePalette.smSubText.copyWith(
                          color: ColorPalette.neutral500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}
