// lib/screens/organizer/deposit/presentation/pages/select_amount_screen.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SelectAmountScreen extends HookWidget {

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - SpacePalette.base * 4) / 3;

    return Scaffold(
      backgroundColor: ColorPalette.neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral0,
        title: Text('Deposit', style: TextStylePalette.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Spent Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SpacePalette.base),
              color: ColorPalette.neutral800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SpacePalette.base),
                  Text(
                    'Balance',
                    style: TextStylePalette.normalText.copyWith(
                      color: ColorPalette.neutral0
                    )
                  ),
                  SizedBox(height: SpacePalette.sm),
                  Text(
                    '¥400,500',
                    style: TextStylePalette.header.copyWith(color: ColorPalette.neutral0),
                  ),
                  SizedBox(height: SpacePalette.base),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select Deposit Amount', style: TextStylePalette.title),
                  ),
                  SizedBox(height: SpacePalette.base),
                  // カード
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: SpacePalette.sm,
                      mainAxisSpacing: SpacePalette.sm,
                      childAspectRatio: cardWidth / 100,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final amounts = [10000, 50000, 100000];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            // 金額選択時の処理
                          },
                          child: Center(
                            child: Text(
                              '¥${amounts[index].toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              )}',
                              style: TextStylePalette.smTitle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}