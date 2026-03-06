// lib/features/creator/campaign/presentation/pages/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../chat/presentation/chat_screen.dart';
import '../../../chat/presentation/creator_personal_chat_screen.dart';
import 'detail_screen.dart';
import 'download_screen.dart';
import 'upload_screen.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

class ProjectMenuScreen extends HookConsumerWidget {
  final Campaign? campaign;
  // 後方互換のための個別パラメータ
  final String? imageUrl;
  final String projectName;
  final int currentViews;
  final int targetViews;
  final double pricePerView;

  const ProjectMenuScreen({
    Key? key,
    this.campaign,
    this.imageUrl,
    this.projectName = 'Project Name',
    this.currentViews = 0,
    this.targetViews = 0,
    this.pricePerView = 1,
  }) : super(key: key);

  // 実際に使う値を取得
  String get _projectName => campaign?.name ?? projectName;
  String? get _imageUrl => campaign?.thumbnailUrl ?? imageUrl;
  int get _targetViews => campaign?.targetViews ?? targetViews;
  int get _currentViews => campaign?.totalViews ?? currentViews;
  double get _pricePerView => campaign?.pricePerThousand ?? pricePerView;

  String _getImageUrl() {
    if (_imageUrl != null && _imageUrl!.isNotEmpty && _imageUrl != 'placeholder') {
      return _imageUrl!;
    }
    return 'https://picsum.photos/seed/${hashCode}/400/225';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = _targetViews > 0 ? _currentViews / _targetViews : 0.0;
    final percentage = (progress * 100).toInt();
    final creatorCount = useState<int>(0);

    // 参加者数を取得
    useEffect(() {
      if (campaign != null) {
        Future.microtask(() async {
          try {
            final result = await Supabase.instance.client
                .rpc('get_participant_count', params: {'p_campaign_id': campaign!.id});
            creatorCount.value = (result as int?) ?? 0;
          } catch (e) {
            debugPrint('Failed to load creator count: $e');
          }
        });
      }
      return null;
    }, [campaign?.id]);

    String formatNumber(int n) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: ColorPalette.neutral800,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: SpacePalette.base),
                  Text(AppLocalizations.of(context)!.back, style: TextStylePalette.normalText),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name & Creators
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_projectName, style: TextStylePalette.lgListTitle),
                          SizedBox(height: SpacePalette.xs),
                          Text(
                            '${creatorCount.value} ${AppLocalizations.of(context)!.creators}',
                            style: TextStylePalette.lgListLeading,
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),

                      // 画像（タップ可能）
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailScreen(
                                campaign: campaign,
                                imageUrl: _getImageUrl(),
                                projectName: _projectName,
                                pricePerView: _pricePerView,
                                currentViews: _currentViews,
                                targetViews: _targetViews,
                                showAddReview: true,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              _getImageUrl(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: ColorPalette.white,
                                  child: Center(
                                    child: Icon(Icons.image, size: 50, color: ColorPalette.neutral400),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // 金額とプログレスバー
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatNumber(_currentViews)} / ${formatNumber(_targetViews)} views',
                            style: TextStylePalette.miniTitle,
                          ),
                          Text('$percentage%', style: TextStylePalette.normalText),
                        ],
                      ),
                      SizedBox(height: SpacePalette.sm),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: ColorPalette.neutral200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorPalette.positive500,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.lg),

                      // チャットボックス
                      Row(
                        children: [
                          Expanded(
                            child:                           _ChatBox(
                              icon: Icons.group,
                              label: AppLocalizations.of(context)!.chat,
                              onTap: () {
                                if (campaign != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectChatScreen(
                                        campaignId: campaign!.id,
                                        projectName: _projectName,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(width: SpacePalette.base),
                          Expanded(
                            child:                           _ChatBox(
                              icon: Icons.person,
                              label: AppLocalizations.of(context)!.personalChat,
                              onTap: () {
                                if (campaign != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreatorPersonalChatScreen(
                                        campaignId: campaign!.id,
                                        organizerId: campaign!.organizerId,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Download Project Files
                      _ActionSection(
                        icon: Icons.download,
                        title: AppLocalizations.of(context)!.projectFiles,
                        subtitle: '${campaign?.resources.length ?? 0} items',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDownloadScreen(
                                resources: campaign?.resources ?? [],
                                campaignName: _projectName,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Submit Your Video
                      _ActionSection(
                        icon: Icons.upload,
                        title: AppLocalizations.of(context)!.submit,
                        subtitle: AppLocalizations.of(context)!.video,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectUploadScreen(
                                campaignId: campaign?.id ?? '',
                                campaignName: _projectName,
                                organizerId: campaign?.organizerId ?? '',
                                platforms: campaign?.platforms ?? [],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 100),
                    ],
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

class _ChatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChatBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: ColorPalette.white,
            borderRadius: BorderRadius.circular(RadiusPalette.base),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: ColorPalette.neutral800),
              SizedBox(height: SpacePalette.sm),
              Text(label, style: TextStylePalette.listTitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: ColorPalette.neutral800),
            SizedBox(width: SpacePalette.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStylePalette.listTitle),
                  Text(subtitle, style: TextStylePalette.listLeading),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: ColorPalette.neutral400),
          ],
        ),
      ),
    );
  }
}