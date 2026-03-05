// lib/features/creator/submission/presentation/pages/connected_accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import '../../data/models/social_connection.dart';
import '../providers/submission_providers.dart';
import '../../../../auth/presentation/providers/oauth_provider.dart';

class ConnectedAccountsScreen extends HookConsumerWidget {
  const ConnectedAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = useState<List<SocialConnection>>([]);
    final isLoading = useState(true);

    final platforms = [
      _PlatformConfig(
        name: 'YouTube',
        provider: 'youtube',
        iconWidget: PlatformIcon.youtube(size: 22),
        color: Colors.red,
      ),
      _PlatformConfig(
        name: 'Instagram',
        provider: 'instagram',
        iconWidget: PlatformIcon.instagram(size: 22),
        color: Colors.pink,
      ),
      _PlatformConfig(
        name: 'TikTok',
        provider: 'tiktok',
        iconWidget: PlatformIcon.tiktok(size: 22),
        color: Colors.black,
      ),
    ];

    Future<void> loadConnections() async {
      isLoading.value = true;
      try {
        final service = ref.read(socialConnectionServiceProvider);
        final conns = await service.getMyConnections();
        connections.value = conns;

        // Update global state
        ref.read(connectedProvidersProvider.notifier).state = conns
            .map((c) => c.provider)
            .toSet();
        ref.read(socialConnectionsProvider.notifier).state = conns;
      } catch (e) {
        // Handle error
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

    List<SocialConnection> getConnectionsFor(String provider) {
      return connections.value
          .where((c) => c.provider == provider && c.isConnected)
          .toList();
    }

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
            SnackBar(
              content: Text('Failed to connect $provider: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> handleDisconnect(String connectionId) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Disconnect Account', style: TextStylePalette.miniTitle),
          content: Text(
            'Are you sure you want to disconnect this account?',
            style: TextStylePalette.normalText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Disconnect'),
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
              SnackBar(
                content: Text('Account disconnected'),
                backgroundColor: ColorPalette.neutral800,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to disconnect: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    final totalConnected = connections.value.where((c) => c.isConnected).length;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Link Account', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: isLoading.value
          ? Center(
              child: CircularProgressIndicator(color: ColorPalette.neutral800),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(SpacePalette.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SpacePalette.sm,
                              vertical: SpacePalette.xs,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius: BorderRadius.circular(RadiusPalette.full),
                              border: Border.all(color: ColorPalette.neutral200),
                            ),
                            child: Text(
                              '$totalConnected connected',
                              style: TextStylePalette.smTitle,
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),

                          // Platform sections
                          ...platforms.map((platform) {
                            final conns = getConnectionsFor(platform.provider);
                            return _buildPlatformSection(
                              platform: platform,
                              connections: conns,
                              onConnect: () => handleConnect(platform.provider),
                              onDisconnect: handleDisconnect,
                            );
                          }),

                          SizedBox(height: SpacePalette.base),
                          Text(
                            'Only posting permissions are requested. You can disconnect anytime.',
                            style: TextStylePalette.smSubText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom button
                  Container(
                    padding: EdgeInsets.fromLTRB(SpacePalette.base, SpacePalette.sm, SpacePalette.base, SpacePalette.base),
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral100,
                      border: Border(top: BorderSide(color: ColorPalette.neutral200, width: 1)),
                    ),
                    child: IgnorePointer(
                      ignoring: totalConnected == 0,
                      child: Opacity(
                        opacity: totalConnected == 0 ? 0.5 : 1,
                        child: DuolingoButton(
                          onPressed: () => Navigator.pop(context, true),
                          isEnabled: true,
                          text: 'Done',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformSection({
    required _PlatformConfig platform,
    required List<SocialConnection> connections,
    required VoidCallback onConnect,
    required Future<void> Function(String) onDisconnect,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: SpacePalette.base),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Column(
          children: [
            // Platform header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.base,
                vertical: SpacePalette.sm + 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: platform.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: platform.iconWidget),
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: Text(platform.name, style: TextStylePalette.bigText),
                  ),
                  // Add account button
                  GestureDetector(
                    onTap: onConnect,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacePalette.sm,
                        vertical: 6,
                      ),
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
                            'Add',
                            style: TextStylePalette.smTitle.copyWith(
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
              Divider(height: 1, indent: SpacePalette.base, endIndent: SpacePalette.base, color: ColorPalette.neutral200),
              ...connections.map((conn) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.base,
                    vertical: SpacePalette.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 32), // align with icon above
                      SizedBox(width: SpacePalette.sm),
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
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(RadiusPalette.full),
                            border: Border.all(color: ColorPalette.neutral300),
                          ),
                          child: Text(
                            'Disconnect',
                            style: TextStylePalette.smSubText.copyWith(color: ColorPalette.neutral500),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Empty state
            if (connections.isEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: SpacePalette.base,
                  right: SpacePalette.base,
                  bottom: SpacePalette.sm,
                ),
                child: Text(
                  'No account connected',
                  style: TextStylePalette.smSubText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlatformConfig {
  final String name;
  final String provider;
  final Widget iconWidget;
  final Color color;

  _PlatformConfig({
    required this.name,
    required this.provider,
    required this.iconWidget,
    required this.color,
  });
}
