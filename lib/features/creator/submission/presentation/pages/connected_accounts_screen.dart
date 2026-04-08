// lib/features/creator/submission/presentation/pages/connected_accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/platform_icon.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import '../../data/models/social_connection.dart';
import '../providers/submission_providers.dart';
import '../../../../auth/presentation/providers/oauth_provider.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

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
          .where((c) => c.provider == provider && (c.isConnected || c.isExpired))
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
              content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
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
          title: Text(AppLocalizations.of(context)!.disconnect, style: TextStylePalette.miniTitle),
          content: Text(
            AppLocalizations.of(context)!.disconnectConfirm,
            style: TextStylePalette.normalText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.disconnect),
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
                content: Text(AppLocalizations.of(context)!.disconnect),
                backgroundColor: ColorPalette.neutral800,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    final totalConnected = connections.value.where((c) => c.isConnected && !c.needsReconnect).length;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.connectedAccounts, style: TextStylePalette.title),
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
                              AppLocalizations.of(context)!.connectedCountLabel(totalConnected),
                              style: TextStylePalette.smTitle,
                            ),
                          ),
                          SizedBox(height: SpacePalette.base),

                          // Platform sections
                          ...platforms.map((platform) {
                            final conns = getConnectionsFor(platform.provider);
                            return _buildPlatformSection(
                              context: context,
                              platform: platform,
                              connections: conns,
                              onConnect: () => handleConnect(platform.provider),
                              onDisconnect: handleDisconnect,
                              onReconnect: () => handleConnect(platform.provider),
                            );
                          }),

                          SizedBox(height: SpacePalette.base),
                          Text(
                            AppLocalizations.of(context)!.postingPermissionsOnly,
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
                          text: AppLocalizations.of(context)!.done,
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
    required BuildContext context,
    required _PlatformConfig platform,
    required List<SocialConnection> connections,
    required VoidCallback onConnect,
    required Future<void> Function(String) onDisconnect,
    required VoidCallback onReconnect,
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
                          Icon(PhosphorIconsBold.plus, size: 14, color: ColorPalette.neutral700),
                          SizedBox(width: 2),
                          Text(
                            AppLocalizations.of(context)!.add,
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
                final expired = conn.needsReconnect;
                final expiringSoon = conn.isExpiringSoon && !expired;
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${conn.providerAccountName ?? conn.providerAccountId}',
                              style: TextStylePalette.normalText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (expired)
                              Text(
                                AppLocalizations.of(context)!.tokenExpired,
                                style: TextStylePalette.smSubText.copyWith(color: Colors.orange.shade700),
                              ),
                            if (expiringSoon)
                              Text(
                                AppLocalizations.of(context)!.tokenExpiringSoon,
                                style: TextStylePalette.smSubText.copyWith(color: Colors.orange.shade600),
                              ),
                          ],
                        ),
                      ),
                      if (expired)
                        Padding(
                          padding: EdgeInsets.only(right: SpacePalette.xs),
                          child: GestureDetector(
                            onTap: () => onConnect(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(RadiusPalette.full),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.reconnect,
                                style: TextStylePalette.smSubText.copyWith(color: Colors.orange.shade700),
                              ),
                            ),
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
                            AppLocalizations.of(context)!.disconnect,
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
                  AppLocalizations.of(context)!.connectAnAccount,
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
