// lib/features/creator/feed/presentation/pages/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: ColorPalette.neutral300,
              ),
              SizedBox(height: SpacePalette.base),
              Text(
                'Feed',
                style: TextStylePalette.header.copyWith(
                  color: ColorPalette.neutral400,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Text(
                'Coming Soon',
                style: TextStylePalette.smSubText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
