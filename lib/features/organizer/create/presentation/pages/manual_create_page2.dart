// lib/features/organizer/create/presentation/pages/manual_create_page2.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/features/organizer/create/presentation/pages/manual_create_page3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/features/organizer/create/presentation/providers/project_provider.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/features/organizer/create/presentation/pages/manual_create_page2.dart';

class ManualCreatePage2 extends HookConsumerWidget{
  const ManualCreatePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedCategory = useState(-1);
    final selectedPlatforms = useState<Set<int>>({});
    final category = [
      'Business',
      'Entertainment',
      'Music',
      'Podcast'
    ];
    final platform = [
      'YouTube',
      'Instagram',
      'TikTok'
    ];

    // プラットフォームのトグル
    void togglePlatform(int index) {
      final current = {...selectedPlatforms.value};
        if (current.contains(index)) {
          current.remove(index);
        } else {
        current.add(index);
      }
      selectedPlatforms.value = current;
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Category and Platforms',
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose category that fits your project',
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Row(
                children: [
                  Expanded(
                    child: CategoryBox(
                    icon: Icon(Icons.business),
                    name: category[0],
                    isSelected: selectedCategory.value == 0,
                    onTap: () {selectedCategory.value = 0;}
                    )
                  ),
                  SizedBox(width: SpacePalette.base),
                  Expanded(
                    child: CategoryBox(
                      icon: Icon(Icons.gamepad),
                      name: category[1],
                      isSelected: selectedCategory.value == 1,
                      onTap: () {selectedCategory.value = 1;}
                    )
                  )
                ],
              ),
              SizedBox(height: SpacePalette.base),
              Row(
                children: [
                  Expanded(
                    child: CategoryBox(
                    icon: Icon(Icons.music_note),
                    name: category[2],
                    isSelected: selectedCategory.value == 2,
                    onTap: () {selectedCategory.value = 2;}
                    )
                  ),
                  SizedBox(width: SpacePalette.base),
                  Expanded(
                    child: CategoryBox(
                      icon: Icon(Icons.voice_chat),
                      name: category[3],
                      isSelected: selectedCategory.value == 3,
                      onTap: () {selectedCategory.value = 3;}
                    )
                  )
                ],
              ),
              SizedBox(height: SpacePalette.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose where the creators’ clips will be posted',
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Row(
                children: [
                  Expanded(
                    child: PlatformBox(
                      icon: Icon(Icons.video_call),
                      name: platform[0],
                      isSelected: selectedPlatforms.value.contains(0),
                      onTap: () => togglePlatform(0)
                    )
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: PlatformBox(
                      icon: Icon(Icons.camera),
                      name: platform[1],
                      isSelected: selectedPlatforms.value.contains(1),
                      onTap: () => togglePlatform(1)
                    )
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: PlatformBox(
                      icon: Icon(Icons.music_note),
                      name: platform[2],
                      isSelected: selectedPlatforms.value.contains(2),
                      onTap: () => togglePlatform(2)
                    )
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).setCategoryAndPlatforms(category[selectedCategory.value], selectedPlatforms.value.map((index) => platform[index]).toList());
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => ManualCreatePage3()
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStylePalette.buttonTextWhite
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  Icon icon;
  String name;
  bool isSelected;
  VoidCallback onTap;
  
  CategoryBox({
    super.key,
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(SpacePalette.inner),
        decoration: BoxDecoration(
          color: isSelected
          ? ColorPalette.neutral100
          : ColorPalette.neutral0,
          border: Border.all(
            color: isSelected
            ? ColorPalette.neutral800
            : ColorPalette.neutral200,
            width: isSelected
            ? 2
            : 1
          ),
          borderRadius: BorderRadius.circular(RadiusPalette.base)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: SpacePalette.sm),
            Text(
              name,
              style: isSelected
              ? TextStylePalette.smTitle
              : TextStylePalette.normalText
            )
          ],
        ),
      ),
    );
  }
}

class PlatformBox extends StatelessWidget {
  Icon icon;
  String name;
  bool isSelected;
  VoidCallback onTap;
  
  PlatformBox({
    super.key,
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(SpacePalette.inner),
        decoration: BoxDecoration(
          color: isSelected
          ? ColorPalette.neutral100
          : ColorPalette.neutral0,
          border: Border.all(
            color: isSelected
            ? ColorPalette.neutral800
            : ColorPalette.neutral200,
            width: isSelected
            ? 2
            : 1
          ),
          borderRadius: BorderRadius.circular(RadiusPalette.base)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: SpacePalette.sm),
            Text(
              name,
              style: isSelected
              ? TextStylePalette.smTitle
              : TextStylePalette.normalText
            )
          ],
        ),
      ),
    );
  }
}