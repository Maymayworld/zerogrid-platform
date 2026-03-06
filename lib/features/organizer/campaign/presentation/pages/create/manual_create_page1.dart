// lib/features/organizer/campaign/presentation/pages/create/manual_create_page1.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/pages/create/manual_create_page2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';

class ManualCreatePage1 extends HookConsumerWidget{
  const ManualCreatePage1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final projectNameController = useTextEditingController();
    final descriptionController = useTextEditingController();

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
                  AppLocalizations.of(context)!.letsStartWithBasics,
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.giveCreatorsClearIdea,
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.projectName,
                  style: TextStylePalette.miniTitle,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: TextField(
                  controller: projectNameController,
                  cursorColor: ColorPalette.neutral800,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral200,
                        width: 1
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral800,
                        width: 2
                      )
                    )
                  ),
                )
              ),
              SizedBox(height: SpacePalette.base),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.description,
                  style: TextStylePalette.miniTitle,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: ColorPalette.neutral800,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorPalette.neutral200)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral200,
                        width: 1
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral800,
                        width: 2
                      )
                    )
                  )
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.describeCreatorExpectations,
                  style: TextStylePalette.subGuide,
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              SizedBox(
                width: double.infinity,
                child: DuolingoButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).setBasicInfo(projectNameController.text, descriptionController.text);
                    Navigator.push(
                      context, (MaterialPageRoute(
                        builder: (context) => ManualCreatePage2()
                        )
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