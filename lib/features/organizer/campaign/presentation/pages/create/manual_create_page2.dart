// lib/features/organizer/campaign/presentation/pages/create/manual_create_page2.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/pages/create/manual_create_page3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'package:zero_grid/shared/widgets/platform_icon.dart';

class ManualCreatePage2 extends HookConsumerWidget{
  const ManualCreatePage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedCategory = useState(-1);
    final selectedPlatforms = useState<Set<int>>({});
    final categoryData = ['Business', 'Entertainment', 'Music', 'Podcast'];
    final categoryDisplay = [
      AppLocalizations.of(context)!.categoryBusiness,
      AppLocalizations.of(context)!.categoryEntertainment,
      AppLocalizations.of(context)!.categoryMusic,
      AppLocalizations.of(context)!.categoryPodcast,
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.selectCategoryAndPlatforms,
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.chooseCategoryFitsProject,
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Row(
                children: [
                  Expanded(
                    child: CategoryBox(
                    icon: Icon(Icons.business),
                    name: categoryDisplay[0],
                    isSelected: selectedCategory.value == 0,
                    onTap: () {selectedCategory.value = 0;}
                    )
                  ),
                  SizedBox(width: SpacePalette.base),
                  Expanded(
                    child: CategoryBox(
                      icon: Icon(Icons.gamepad),
                      name: categoryDisplay[1],
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
                    name: categoryDisplay[2],
                    isSelected: selectedCategory.value == 2,
                    onTap: () {selectedCategory.value = 2;}
                    )
                  ),
                  SizedBox(width: SpacePalette.base),
                  Expanded(
                    child: CategoryBox(
                      icon: Icon(Icons.voice_chat),
                      name: categoryDisplay[3],
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
                  AppLocalizations.of(context)!.chooseWhereClipsPosted,
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Row(
                children: [
                  Expanded(
                    child: PlatformBox(
                      icon: PlatformIcon.youtube(size: 24),
                      name: platform[0],
                      isSelected: selectedPlatforms.value.contains(0),
                      onTap: () => togglePlatform(0)
                    )
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: PlatformBox(
                      icon: PlatformIcon.instagram(size: 24),
                      name: platform[1],
                      isSelected: selectedPlatforms.value.contains(1),
                      onTap: () => togglePlatform(1)
                    )
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Expanded(
                    child: PlatformBox(
                      icon: PlatformIcon.tiktok(size: 24),
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
                child: DuolingoButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).setCategoryAndPlatforms(categoryData[selectedCategory.value], selectedPlatforms.value.map((index) => platform[index]).toList());
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => ManualCreatePage3()
                      )
                    );
                  },
                  isEnabled: true,
                  isLoading: false,
                  text: AppLocalizations.of(context)!.next,
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
          : ColorPalette.white,
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
  Widget icon;
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
          : ColorPalette.white,
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