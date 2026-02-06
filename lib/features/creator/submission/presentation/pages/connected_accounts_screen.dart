// lib/features/creator/submission/presentation/pages/connected_accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../data/models/social_connection.dart';
import '../providers/submission_providers.dart';

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
        icon: Icons.play_arrow,
        color: Colors.red,
        description: 'Connect your YouTube channel to verify video ownership',
      ),
      _PlatformConfig(
        name: 'Instagram',
        provider: 'instagram',
        icon: Icons.camera_alt,
        color: Colors.pink,
        description: 'Connect your Instagram account to verify reel ownership',
      ),
      _PlatformConfig(
        name: 'TikTok',
        provider: 'tiktok',
        icon: Icons.music_note,
        color: Colors.black,
        description: 'Connect your TikTok account to verify video ownership',
      ),
    ];

    Future<void> loadConnections() async {
      isLoading.value = true;
      try {
        final service = ref.read(socialConnectionServiceProvider);
        final conns = await service.getMyConnections();
        connections.value = conns;

        // Update global state
        ref.read(connectedProvidersProvider.notifier).state =
            conns.map((c) => c.provider).toSet();
        ref.read(socialConnectionsProvider.notifier).state = conns;
      } catch (e) {
        // Handle error
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadConnections();
      return null;
    }, []);

    SocialConnection? getConnectionFor(String provider) {
      try {
        return connections.value.firstWhere(
          (c) => c.provider == provider && c.isConnected,
        );
      } catch (_) {
        return null;
      }
    }

    Future<void> handleConnect(String provider) async {
      // TODO: Implement full OAuth flow with flutter_web_auth_2
      // For now, show a placeholder message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OAuth connection for $provider requires API credentials. '
            'Set up your developer app credentials first.',
          ),
          backgroundColor: ColorPalette.neutral800,
          duration: Duration(seconds: 3),
        ),
      );
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

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Connected Accounts', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: isLoading.value
          ? Center(
              child: CircularProgressIndicator(color: ColorPalette.neutral800),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.all(SpacePalette.base),
                    decoration: BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 20,
                            color: Colors.blue),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          child: Text(
                            'Connect your social accounts to verify ownership when submitting videos to campaigns.',
                            style: TextStylePalette.subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SpacePalette.lg),

                  // Platform cards
                  ...platforms.map((platform) {
                    final conn = getConnectionFor(platform.provider);
                    final isConnected = conn != null;

                    return Padding(
                      padding: EdgeInsets.only(bottom: SpacePalette.base),
                      child: Container(
                        padding: EdgeInsets.all(SpacePalette.base),
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: platform.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    platform.icon,
                                    size: 22,
                                    color: platform.color,
                                  ),
                                ),
                                SizedBox(width: SpacePalette.base),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(platform.name,
                                          style: TextStylePalette.listTitle),
                                      if (isConnected &&
                                          conn.providerAccountName != null)
                                        Text(
                                          '@${conn.providerAccountName}',
                                          style: TextStylePalette.smSubText,
                                        )
                                      else
                                        Text(
                                          'Not connected',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorPalette.neutral400,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isConnected)
                                  Icon(
                                    Icons.check_circle,
                                    color: ColorPalette.positive500,
                                    size: 24,
                                  ),
                              ],
                            ),
                            SizedBox(height: SpacePalette.sm),
                            Text(
                              platform.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorPalette.neutral500,
                              ),
                            ),
                            SizedBox(height: SpacePalette.base),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: isConnected
                                  ? OutlinedButton(
                                      onPressed: () =>
                                          handleDisconnect(conn.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: BorderSide(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              RadiusPalette.base),
                                        ),
                                      ),
                                      child: Text('Disconnect'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () =>
                                          handleConnect(platform.provider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorPalette.neutral800,
                                        foregroundColor: ColorPalette.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              RadiusPalette.base),
                                        ),
                                      ),
                                      child: Text('Connect ${platform.name}'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _PlatformConfig {
  final String name;
  final String provider;
  final IconData icon;
  final Color color;
  final String description;

  _PlatformConfig({
    required this.name,
    required this.provider,
    required this.icon,
    required this.color,
    required this.description,
  });
}
