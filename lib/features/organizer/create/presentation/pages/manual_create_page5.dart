// lib/features/organizer/create/presentation/pages/manual_create_page5.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/features/organizer/create/presentation/pages/manual_create_page6.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/features/organizer/create/presentation/providers/project_provider.dart';

class ManualCreatePage5 extends HookConsumerWidget{
  const ManualCreatePage5({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final timelineController = useTextEditingController();

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 5),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ColorPalette.neutral800,
                onPrimary: ColorPalette.neutral0,
                surface: ColorPalette.neutral0,
                onSurface: ColorPalette.neutral800
              )
            ),
            child: child!,
          );
        }
      );

      if (picked != null) {
        final formatted = '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
        timelineController.text = formatted;
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set Your Project Timeline',
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose when the project starts and when it wraps up',
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: TextField(
                  controller: timelineController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  cursorColor: ColorPalette.neutral800,
                  decoration: InputDecoration(
                    hintText: 'YYYY/MM/DD',
                    hintStyle: TextStylePalette.hintText,
                    suffixIcon: IconButton(
                      constraints: BoxConstraints(),
                      onPressed: selectDate,
                      icon: Icon(
                        Icons.calendar_month,
                        color: ColorPalette.neutral400,
                        size: 24,
                      )
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
                  'The project will automatically become inactive when the end date is reached',
                  style: TextStylePalette.subGuide,
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).setEndDate(timelineController.text);
                    Navigator.push(
                      context, (MaterialPageRoute(
                        builder: (context) => ManualCreatePage6()
                        )
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