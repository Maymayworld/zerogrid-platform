// lib/screens/organizer/home_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              color: ColorPalette.neutral800,
              child: Padding(
                padding: EdgeInsets.all(SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SpacePalette.base),
                    Text(
                      'Dashboard', 
                      style: TextStylePalette.smallHeader.copyWith(
                        color: ColorPalette.neutral0
                      )
                    ),
                    SizedBox(height: SpacePalette.lg),
                    Text(
                      'Total Spent',
                      style: TextStylePalette.normalText.copyWith(
                        color: ColorPalette.neutral0
                      )
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '¥400,500',
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.neutral0
                          )
                        ),
                        Icon(
                          Icons.arrow_upward,
                          color: ColorPalette.neutral0
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}