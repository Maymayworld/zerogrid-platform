// lib/features/organizer/campaign/presentation/pages/create/loading_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';

class LoadingPage extends HookWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsetsGeometry.all(SpacePalette.base),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: ColorPalette.primaryColor,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Your Project is Coming to Life!',
                  style: TextStylePalette.smallHeader,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'It’ll be ready in just a moment — we’re putting everything together for you.',
                  style: TextStylePalette.subText,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}