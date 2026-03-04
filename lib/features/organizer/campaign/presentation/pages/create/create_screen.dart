// lib/features/organizer/campaign/presentation/pages/create/create_screen.dart
import 'package:flutter/material.dart';
import '../../../../../../shared/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/features/organizer/home/presentation/providers/organizer_tab_index_provider.dart';
import 'manual_create_page1.dart';

class CreateScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descriptionController = useTextEditingController();
    final hasText = useState(false);

    // useEffect(() {
    //   void listener() {
    //     hasText.value = descriptionController.text.trim().isNotEmpty;
    //   }
    //   descriptionController.addListener(listener);
    //   return () => descriptionController.removeListener(listener);
    // }, [descriptionController]);

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        title: Text('Create Project', style: TextStylePalette.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () {
            ref.read(organizerTabIndexProvider.notifier).state = 0;
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              Text(
                'How Do You Want to Create This Project?',
                style: TextStylePalette.header,
              ),
              SizedBox(height: SpacePalette.base),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 160,
                  padding: EdgeInsets.all(SpacePalette.inner),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorPalette.neutral200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 32),
                      SizedBox(height: SpacePalette.base),
                      Text('Create with AI', style: TextStylePalette.title),
                      SizedBox(height: SpacePalette.sm),
                      Text(
                        'Start from a short idea and let AI draft the details for you',
                        style: TextStylePalette.subText,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.base),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManualCreatePage1(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 160,
                  padding: EdgeInsets.all(SpacePalette.inner),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorPalette.neutral200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(RadiusPalette.base),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, size: 32),
                      SizedBox(height: SpacePalette.base),
                      Text('Create Manually', style: TextStylePalette.title),
                      SizedBox(height: SpacePalette.sm),
                      Text(
                        'Build your project step by step with full control',
                        style: TextStylePalette.subText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
