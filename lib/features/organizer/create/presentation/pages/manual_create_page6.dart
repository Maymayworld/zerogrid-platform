// lib/features/organizer/create/presentation/pages/manual_create_page6.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/features/organizer/create/presentation/pages/loading_page.dart';
import 'package:zero_grid/features/organizer/create/presentation/pages/preview_page.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/features/organizer/create/presentation/providers/project_provider.dart';

class ManualCreatePage6 extends HookConsumerWidget{
  const ManualCreatePage6({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final links = useState<List<String>>(['']);

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

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
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
        // スクロール可能エリア
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
                    'Upload files or links to help creators produce better content',
                    style: TextStylePalette.subText,
                  ),
                ),
                SizedBox(height: SpacePalette.base),

                // Upload Filesボタン
                GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: ButtonSizePalette.innerButton,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorPalette.neutral800,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 20),
                        SizedBox(width: SpacePalette.sm),
                        Text('Upload Files', style: TextStylePalette.smTitle),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: SpacePalette.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Supported formats: JPG, PNG, SVG, MP4, PDF',
                    style: TextStylePalette.subGuide,
                  ),
                ),
                SizedBox(height: SpacePalette.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add Link', style: TextStylePalette.miniTitle),
                ),
                SizedBox(height: SpacePalette.sm),

                // リンクフィールドのリスト
                ...links.value.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(bottom: SpacePalette.sm),
                    child: SizedBox(
                      width: double.infinity,
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: TextEditingController(text: value),
                        onChanged: (text) => updateLink(index, text),
                        keyboardType: TextInputType.url,
                        cursorColor: ColorPalette.neutral800,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.link),
                          suffixIcon: links.value.length > 1
                              ? IconButton(
                                  constraints: BoxConstraints(),
                                  padding: EdgeInsets.only(right: 12),
                                  onPressed: () => removeLink(index),
                                  icon: Icon(
                                    Icons.close,
                                    color: ColorPalette.neutral400,
                                    size: 20,
                                  ),
                                )
                              : null,
                          hintText: 'Paste link here…',
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
                      Text('Add Another', style: TextStylePalette.guide),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 固定のNextボタン
        SizedBox(height: SpacePalette.base),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              ref.read(projectProvider.notifier).setLinks(links.value);
                Navigator.push(
                context, MaterialPageRoute(
                  builder: (context) => PreviewPage()
                )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.neutral800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
            ),
            child: Text('Next', style: TextStylePalette.buttonTextWhite),
          ),
        ),
      ],
    ),
  ),
),
    );
  }
}