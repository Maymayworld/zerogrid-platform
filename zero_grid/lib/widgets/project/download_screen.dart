// lib/widgets/project/download_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProjectDownloadScreen extends StatelessWidget {
  const ProjectDownloadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette().neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette().neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Download',
          style: GoogleFonts.inter(
            fontSize: FontSizePalette.md,
            fontWeight: FontWeight.w600,
            color: ColorPalette().neutral900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(SpacePalette.base),
          children: [
            _FileItem(
              icon: Icons.description_outlined,
              fileName: 'project-brief.pdf',
              modifiedDate: 'Modified Nov 25, 2025',
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading project-brief.pdf...')),
                );
              },
            ),
            SizedBox(height: SpacePalette.base),
            _FileItem(
              icon: Icons.image_outlined,
              fileName: 'image_preview.jpg',
              modifiedDate: 'Modified Nov 25, 2025',
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading image_preview.jpg...')),
                );
              },
            ),
            SizedBox(height: SpacePalette.base),
            _FileItem(
              icon: Icons.folder_outlined,
              fileName: 'File 1',
              modifiedDate: 'Modified Nov 26, 2025',
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading File 1...')),
                );
              },
            ),
            SizedBox(height: SpacePalette.base),
            _FileItem(
              icon: Icons.videocam_outlined,
              fileName: 'product-b-roll.mp4',
              modifiedDate: 'Modified Nov 25, 2025',
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading product-b-roll.mp4...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ファイルアイテム
class _FileItem extends StatelessWidget {
  final IconData icon;
  final String fileName;
  final String modifiedDate;
  final VoidCallback onDownload;

  const _FileItem({
    required this.icon,
    required this.fileName,
    required this.modifiedDate,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette().neutral100,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: ColorPalette().neutral800,
          ),
          SizedBox(width: SpacePalette.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.base,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette().neutral900,
                  ),
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  modifiedDate,
                  style: GoogleFonts.inter(
                    fontSize: FontSizePalette.xs,
                    color: ColorPalette().neutral500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDownload,
            child: Icon(
              Icons.download_outlined,
              size: 24,
              color: ColorPalette().neutral800,
            ),
          ),
        ],
      ),
    );
  }
}