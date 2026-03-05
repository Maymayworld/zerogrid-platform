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

    // Get connection for a provider
    SocialConnection? getConnectionFor(String provider) {
      try {
        return connections.value.firstWhere(
          (c) => c.provider == provider && c.isConnected,
        );
      } catch (_) {
        return null;
      }
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
            SnackBar(content: Text('Failed to connect: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    // Handle disconnect
    Future<void> handleDisconnect(String connectionId, String providerName) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Disconnect $providerName?', style: TextStylePalette.title),
          content: Text('Are you sure you want to disconnect this account?', style: TextStylePalette.normalText),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Disconnect', style: TextStyle(color: ColorPalette.critical500)),
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
              SnackBar(content: Text('$providerName disconnected')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to disconnect: $e'), backgroundColor: Colors.red),
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
                    Builder(builder: (context) {
                      final conn = getConnectionFor('youtube');
                      return _PlatformRow(
                        icon: PlatformIcon.youtube(size: 24),
                        name: 'YouTube',
                        connection: conn,
                        onAdd: () => handleConnect('youtube'),
                        onDisconnect: conn != null ? () => handleDisconnect(conn.id, 'YouTube') : null,
                      );
                    }),
                    SizedBox(height: SpacePalette.sm),

                    // Instagram
                    Builder(builder: (context) {
                      final conn = getConnectionFor('instagram');
                      return _PlatformRow(
                        icon: PlatformIcon.instagram(size: 24),
                        name: 'Instagram',
                        connection: conn,
                        onAdd: () => handleConnect('instagram'),
                        onDisconnect: conn != null ? () => handleDisconnect(conn.id, 'Instagram') : null,
                      );
                    }),
                    SizedBox(height: SpacePalette.sm),

                    // TikTok
                    Builder(builder: (context) {
                      final conn = getConnectionFor('tiktok');
                      return _PlatformRow(
                        icon: PlatformIcon.tiktok(size: 24),
                        name: 'TikTok',
                        connection: conn,
                        onAdd: () => handleConnect('tiktok'),
                        onDisconnect: conn != null ? () => handleDisconnect(conn.id, 'TikTok') : null,
                      );
                    }),

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

/// Platform row with icon and Add/Connected button
class _PlatformRow extends StatelessWidget {
  final Widget icon;
  final String name;
  final SocialConnection? connection;
  final VoidCallback onAdd;
  final VoidCallback? onDisconnect;

  const _PlatformRow({
    required this.icon,
    required this.name,
    required this.onAdd,
    this.connection,
    this.onDisconnect,
  });

  bool get isConnected => connection != null && connection!.isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
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
          // Platform name + connected account
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStylePalette.listTitle),
                if (isConnected && connection!.providerAccountName != null)
                  Text(
                    '@${connection!.providerAccountName}',
                    style: TextStylePalette.smSubText,
                  ),
              ],
            ),
          ),
          // Add/Connected button (Duolingo solid shadow style)
          if (isConnected)
            GestureDetector(
              onTap: onDisconnect,
              child: Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorPalette.positive500,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    // Shadow layer
                    Positioned(
                      left: 0, right: 0, top: 3, height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.positive600,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    // Surface layer
                    Positioned(
                      left: 0, right: 0, top: 0, height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.positive500,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, size: 14, color: ColorPalette.white),
                            SizedBox(width: SpacePalette.xs),
                            Text(
                              'Connected',
                              style: TextStylePalette.smText.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorPalette.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
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
                      left: 0, right: 0, top: 3, height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral200,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    // Surface layer
                    Positioned(
                      left: 0, right: 0, top: 0, height: 32,
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
