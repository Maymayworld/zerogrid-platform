// lib/features/organizer/campaign/presentation/pages/create/manual_create_page3.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/pages/create/manual_create_page4.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ManualCreatePage3 extends HookConsumerWidget{
  const ManualCreatePage3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final targetviewController = useTextEditingController();

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
                  'Set Your Target Views',
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set the view goal you want this project to reach',
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: TextField(
                  controller: targetviewController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  cursorColor: ColorPalette.neutral800,
                  decoration: InputDecoration(
                    suffixIcon: Center(
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: SpacePalette.inner),
                        child: Text(
                          'Views',
                          style: TextStylePalette.smSubText,
                        ),
                      ),
                    ),
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
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You can adjust this anytime',
                  style: TextStylePalette.subGuide,
                ),
              ),
              Spacer(),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.smashedPumpkin800,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).setTargetViews(int.parse(targetviewController.text));
                    Navigator.push(
                      context, (MaterialPageRoute(
                        builder: (context) => ManualCreatePage4()
                        )
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.smashedPumpkin600,
                    foregroundColor: ColorPalette.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: TextStylePalette.buttonTextWhite.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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