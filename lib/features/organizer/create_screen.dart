// lib/screens/organizer/create_screen.dart
import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descriptionController = useTextEditingController();
    final hasText = useState(false);

    useEffect(() {
      void listener() {
        hasText.value = descriptionController.text.trim().isNotEmpty;
      }
      descriptionController.addListener(listener);
      return () => descriptionController.removeListener(listener);
    }, [descriptionController]);

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
          padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              
              // グラデーション球体アイコン
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D9488), // teal-600
                      Color(0xFF06B6D4), // cyan-500
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0D9488).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: SpacePalette.lg),
              
              // タイトル
              Text(
                "What's the project about?",
                style: TextStylePalette.header,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: SpacePalette.lg),
              
              Spacer(flex: 1),
              
              // テキストフィールド
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'We run a debate-style YouTube show',
                  hintStyle: TextStylePalette.hintText,
                  filled: true,
                  fillColor: ColorPalette.neutral0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                    borderSide: BorderSide(color: ColorPalette.neutral200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                    borderSide: BorderSide(color: ColorPalette.neutral200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                    borderSide: BorderSide(color: ColorPalette.neutral800, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(SpacePalette.base),
                ),
              ),
              SizedBox(height: SpacePalette.base),
              // Generate Project Detailsボタン
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: hasText.value ? () {
                    // プロジェクト生成処理
                    print('Generate project with: ${descriptionController.text}');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasText.value 
                      ? ColorPalette.neutral800 
                      : ColorPalette.neutral200,
                    disabledBackgroundColor: ColorPalette.neutral200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: hasText.value 
                          ? ColorPalette.neutral0 
                          : ColorPalette.neutral400,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Text(
                        'Generate Project Details',
                        style: TextStylePalette.buttonTextWhite.copyWith(
                          color: hasText.value 
                            ? ColorPalette.neutral0 
                            : ColorPalette.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: SpacePalette.sm),
              
              // 説明文
              Text(
                'We will handle the project details based on your description',
                style: TextStylePalette.smSubText,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: SpacePalette.lg),
            ],
          ),
        ),
      ),
    );
  }
}