// lib/features/creator/campaign/presentation/pages/download_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/theme/app_theme.dart';

class ProjectDownloadScreen extends StatelessWidget {
  final List<String> resources;
  final String? campaignName;

  const ProjectDownloadScreen({
    Key? key,
    required this.resources,
    this.campaignName,
  }) : super(key: key);

  IconData _getIconForUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.svg') ||
        lower.endsWith('.webp')) return Icons.image_outlined;
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm')) return Icons.videocam_outlined;
    if (lower.endsWith('.zip') ||
        lower.endsWith('.rar')) return Icons.folder_zip_outlined;
    if (lower.contains('drive.google.com')) return Icons.cloud_outlined;
    if (lower.contains('dropbox.com')) return Icons.cloud_outlined;
    if (lower.contains('docs.google.com')) return Icons.description_outlined;
    if (lower.contains('figma.com')) return Icons.design_services_outlined;
    if (lower.contains('notion.so') ||
        lower.contains('notion.site')) return Icons.article_outlined;
    return Icons.link_outlined;
  }

  String _getDisplayName(String url) {
    // Try to extract filename from URL
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final lastSegment = Uri.decodeComponent(pathSegments.last);
        // If it looks like a filename (has extension), use it
        if (lastSegment.contains('.') && lastSegment.length < 80) {
          return lastSegment;
        }
      }
      // For known services, show service name + path hint
      if (url.contains('drive.google.com')) return 'Google Drive file';
      if (url.contains('docs.google.com')) return 'Google Docs';
      if (url.contains('dropbox.com')) return 'Dropbox file';
      if (url.contains('figma.com')) return 'Figma design';
      if (url.contains('notion.so') || url.contains('notion.site')) {
        return 'Notion page';
      }
      // Fallback: show domain
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url.length > 40 ? '${url.substring(0, 40)}...' : url;
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open this link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final validResources =
        resources.where((r) => r.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Project Files', style: TextStylePalette.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: validResources.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 48,
                      color: ColorPalette.neutral400,
                    ),
                    SizedBox(height: SpacePalette.base),
                    Text(
                      'No files available',
                      style: TextStylePalette.normalText
                          .copyWith(color: ColorPalette.neutral500),
                    ),
                    SizedBox(height: SpacePalette.xs),
                    Text(
                      'The organizer hasn\'t shared any files yet',
                      style: TextStylePalette.smSubText,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(SpacePalette.base),
                itemCount: validResources.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: SpacePalette.sm),
                itemBuilder: (context, index) {
                  final url = validResources[index];
                  return _FileItem(
                    icon: _getIconForUrl(url),
                    fileName: _getDisplayName(url),
                    url: url,
                    onTap: () => _openUrl(context, url),
                  );
                },
              ),
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final IconData icon;
  final String fileName;
  final String url;
  final VoidCallback onTap;

  const _FileItem({
    required this.icon,
    required this.fileName,
    required this.url,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: Icon(icon, size: 24, color: ColorPalette.neutral800),
            ),
            SizedBox(width: SpacePalette.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStylePalette.listTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    url,
                    style: TextStylePalette.smSubText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: SpacePalette.sm),
            Icon(
              Icons.open_in_new,
              size: 20,
              color: ColorPalette.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
