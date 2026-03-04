// lib/features/organizer/campaign/presentation/pages/create/manual_create_page6.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/pages/create/preview_page.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';

class ManualCreatePage6 extends HookConsumerWidget {
  const ManualCreatePage6({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = useState<List<String>>(['']);
    final uploadedFiles = useState<List<_UploadedFile>>([]);
    final isUploading = useState(false);

    void addLink() {
      links.value = [...links.value, ''];
    }

    void updateLink(int index, String value) {
      final newLinks = [...links.value];
      newLinks[index] = value;
      links.value = newLinks;
    }

    void removeLink(int index) {
      if (links.value.length > 1) {
        final newLinks = [...links.value];
        newLinks.removeAt(index);
        links.value = newLinks;
      }
    }

    Future<void> pickAndUploadFiles() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: [
            'jpg', 'jpeg', 'png', 'svg', 'webp',
            'mp4', 'mov',
            'pdf',
            'zip', 'rar',
          ],
          withData: true,
        );

        if (result == null || result.files.isEmpty) return;

        isUploading.value = true;
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser?.id ?? 'unknown';
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        for (final file in result.files) {
          if (file.bytes == null || file.name.isEmpty) continue;

          final storagePath = '$userId/$timestamp/${file.name}';

          await supabase.storage.from('campaign-files').uploadBinary(
            storagePath,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: _getMimeType(file.extension ?? ''),
              upsert: true,
            ),
          );

          final publicUrl = supabase.storage
              .from('campaign-files')
              .getPublicUrl(storagePath);

          uploadedFiles.value = [
            ...uploadedFiles.value,
            _UploadedFile(name: file.name, url: publicUrl, size: file.size),
          ];
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isUploading.value = false;
      }
    }

    void removeUploadedFile(int index) {
      final newFiles = [...uploadedFiles.value];
      newFiles.removeAt(index);
      uploadedFiles.value = newFiles;
    }

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Resources for Creators',
                          style: TextStylePalette.header,
                        ),
                      ),
                      SizedBox(height: SpacePalette.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Upload files or add links to help creators produce better content',
                          style: TextStylePalette.subText,
                        ),
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Upload Files ボタン
                      GestureDetector(
                        onTap: isUploading.value ? null : pickAndUploadFiles,
                        child: Container(
                          width: double.infinity,
                          height: ButtonSizePalette.innerButton,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorPalette.neutral800,
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isUploading.value)
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorPalette.neutral800,
                                  ),
                                )
                              else
                                Icon(Icons.upload, size: 20),
                              SizedBox(width: SpacePalette.sm),
                              Text(
                                isUploading.value
                                    ? 'Uploading...'
                                    : 'Upload Files',
                                style: TextStylePalette.smTitle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: SpacePalette.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Supported: JPG, PNG, SVG, MP4, PDF, ZIP',
                          style: TextStylePalette.subGuide,
                        ),
                      ),

                      // Uploaded files list
                      if (uploadedFiles.value.isNotEmpty) ...[
                        SizedBox(height: SpacePalette.base),
                        ...uploadedFiles.value.asMap().entries.map((entry) {
                          final file = entry.value;
                          return Container(
                            margin:
                                EdgeInsets.only(bottom: SpacePalette.sm),
                            padding: EdgeInsets.symmetric(
                              horizontal: SpacePalette.base,
                              vertical: SpacePalette.sm,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.positive500
                                  .withValues(alpha: 0.05),
                              borderRadius:
                                  BorderRadius.circular(RadiusPalette.base),
                              border: Border.all(
                                color: ColorPalette.positive500
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: ColorPalette.positive500,
                                ),
                                SizedBox(width: SpacePalette.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        style: TextStylePalette.listTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        file.formattedSize,
                                        style: TextStylePalette.smSubText,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      removeUploadedFile(entry.key),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: ColorPalette.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      SizedBox(height: SpacePalette.lg),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Add Link',
                            style: TextStylePalette.miniTitle),
                      ),
                      SizedBox(height: SpacePalette.sm),

                      // Link fields
                      ...links.value.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;

                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: SpacePalette.sm),
                          child: SizedBox(
                            width: double.infinity,
                            height: ButtonSizePalette.button,
                            child: TextField(
                              controller:
                                  TextEditingController(text: value),
                              onChanged: (text) =>
                                  updateLink(index, text),
                              keyboardType: TextInputType.url,
                              cursorColor: ColorPalette.neutral800,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.link),
                                suffixIcon: links.value.length > 1
                                    ? IconButton(
                                        constraints: BoxConstraints(),
                                        padding: EdgeInsets.only(
                                            right: 12),
                                        onPressed: () =>
                                            removeLink(index),
                                        icon: Icon(
                                          Icons.close,
                                          color:
                                              ColorPalette.neutral400,
                                          size: 20,
                                        ),
                                      )
                                    : null,
                                hintText: 'Paste link here...',
                                hintStyle: TextStylePalette.hintText,
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.neutral200,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.neutral800,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      SizedBox(height: SpacePalette.base),
                      GestureDetector(
                        onTap: addLink,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: SpacePalette.sm),
                            Text('Add Another',
                                style: TextStylePalette.guide),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next button
              SizedBox(height: SpacePalette.base),
              SizedBox(
                width: double.infinity,
                child: DuolingoButton(
                  onPressed: () {
                    // Combine uploaded file URLs and manual links
                    final allResources = [
                      ...uploadedFiles.value.map((f) => f.url),
                      ...links.value
                          .where((l) => l.trim().isNotEmpty),
                    ];
                    ref
                        .read(projectProvider.notifier)
                        .setLinks(allResources);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewPage(),
                      ),
                    );
                  },
                  isEnabled: !isUploading.value,
                  isLoading: isUploading.value,
                  text: 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'svg':
        return 'image/svg+xml';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}

class _UploadedFile {
  final String name;
  final String url;
  final int size;

  _UploadedFile({
    required this.name,
    required this.url,
    required this.size,
  });

  String get formattedSize {
    final mb = size / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = size / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}
