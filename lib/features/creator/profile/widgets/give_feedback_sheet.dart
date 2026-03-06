// lib/screens/creator/profile/widgets/give_feedback_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';

class GiveFeedbackSheet extends HookWidget {
  const GiveFeedbackSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedEmoji = useState<int?>(null);
    final feedbackController = useTextEditingController();

    final emojis = ['😞', '😟', '😐', '😊', '😄'];

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.neutral100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
      ),
      padding: EdgeInsets.all(SpacePalette.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Text(
              AppLocalizations.of(context)!.giveFeedback,
              style: TextStylePalette.title
            ),
            SizedBox(height: SpacePalette.sm),
            Text(
              AppLocalizations.of(context)!.feedbackHelpsUs,
              textAlign: TextAlign.center,
              style: TextStylePalette.subText
            ),
            SizedBox(height: SpacePalette.lg),
            
            // 絵文字選択
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                emojis.length,
                (index) => GestureDetector(
                  onTap: () {
                    selectedEmoji.value = index;
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selectedEmoji.value == index
                          ? ColorPalette.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                      border: Border.all(
                        color: selectedEmoji.value == index
                            ? ColorPalette.neutral800
                            : ColorPalette.neutral200,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emojis[index],
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: SpacePalette.lg),
            
            // テキスト入力欄
            TextField(
              controller: feedbackController,
              maxLines: 5,
              style: TextStylePalette.normalText,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.tellUsSomething,
                hintStyle: TextStylePalette.hintText,
                filled: true,
                fillColor: ColorPalette.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(SpacePalette.base),
              ),
            ),
            SizedBox(height: SpacePalette.lg),
            
            // Share Feedbackボタン
            SizedBox(
              width: double.infinity,
              height: ButtonSizePalette.button,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedEmoji.value != null || feedbackController.text.isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.thankYouForFeedback)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.neutral800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.shareFeedback,
                  style: TextStylePalette.buttonTextWhite
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}