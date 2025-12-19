// lib/screens/organizer/deposit/presentation/pages/select_amount_screen.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'deposit_success_screen.dart';

class SelectAmountScreen extends HookWidget {

  @override
  Widget build(BuildContext context) {
    final selectedAmount = useState<int?>(null);
    final isAmountSelected = useState(false);

    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width - SpacePalette.base * 4) / 3;

    void selectAmount(int amount) {
      selectedAmount.value = amount;
      isAmountSelected.value = true;
    }

    void incrementAmount() {
      if (selectedAmount.value != null) {
        selectedAmount.value = selectedAmount.value! + 10000;
      }
    }

    void decrementAmount() {
      if (selectedAmount.value != null && selectedAmount.value! > 10000) {
        selectedAmount.value = selectedAmount.value! - 10000;
      }
    }

    int calculateTotal() {
      if (selectedAmount.value == null) return 0;
      final platformFee = (selectedAmount.value! * 0.1).round();
      return selectedAmount.value! + platformFee;
    }

    int calculatePlatformFee() {
      if (selectedAmount.value == null) return 0;
      return (selectedAmount.value! * 0.1).round();
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        title: Text('Deposit', style: TextStylePalette.title),
      ),
      body: Column(
        children: [
          // Balance Section
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isAmountSelected.value ? 'Deposit Amount' : 'Select Deposit Amount',
                      style: TextStylePalette.title
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  
                  // メインコンテンツ
                  if (!isAmountSelected.value) ...[
                    // 初期状態: GridView
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
                          color: ColorPalette.neutral0,
                          child: InkWell(
                            onTap: () => selectAmount(amounts[index]),
                            splashColor: ColorPalette.neutral200.withOpacity(0.3),
                            highlightColor: ColorPalette.neutral200.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(RadiusPalette.lg),
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
                  ] else ...[
                    // 選択後: 金額調整UI
                    // 大きな金額表示とプラス・マイナスボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, size: 20),
                            onPressed: decrementAmount,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(width: SpacePalette.lg),
                        Text(
                          '¥${selectedAmount.value!.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )}',
                          style: TextStylePalette.header,
                        ),
                        SizedBox(width: SpacePalette.lg),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.mini),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, size: 20),
                            onPressed: incrementAmount,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: SpacePalette.lg),
                    
                    // 金額選択ボタン
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => selectedAmount.value = 10000,
                            child: Container(
                              height: ButtonSizePalette.filter,
                              decoration: BoxDecoration(
                                color: selectedAmount.value == 10000 
                                  ? ColorPalette.neutral800 
                                  : ColorPalette.neutral0,
                                borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                border: Border.all(
                                  color: selectedAmount.value == 10000
                                    ? ColorPalette.neutral800
                                    : ColorPalette.neutral200,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '¥10,000',
                                  style: TextStylePalette.smTitle.copyWith(
                                    color: selectedAmount.value == 10000
                                      ? ColorPalette.neutral0
                                      : ColorPalette.neutral800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => selectedAmount.value = 50000,
                            child: Container(
                              height: ButtonSizePalette.filter,
                              decoration: BoxDecoration(
                                color: selectedAmount.value == 50000 
                                  ? ColorPalette.neutral800 
                                  : ColorPalette.neutral0,
                                borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                border: Border.all(
                                  color: selectedAmount.value == 50000
                                    ? ColorPalette.neutral800
                                    : ColorPalette.neutral200,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '¥50,000',
                                  style: TextStylePalette.smTitle.copyWith(
                                    color: selectedAmount.value == 50000
                                      ? ColorPalette.neutral0
                                      : ColorPalette.neutral800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => selectedAmount.value = 100000,
                            child: Container(
                              height: ButtonSizePalette.filter,
                              decoration: BoxDecoration(
                                color: selectedAmount.value == 100000 
                                  ? ColorPalette.neutral800 
                                  : ColorPalette.neutral0,
                                borderRadius: BorderRadius.circular(RadiusPalette.mini),
                                border: Border.all(
                                  color: selectedAmount.value == 100000
                                    ? ColorPalette.neutral800
                                    : ColorPalette.neutral200,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '¥100,000',
                                  style: TextStylePalette.smTitle.copyWith(
                                    color: selectedAmount.value == 100000
                                      ? ColorPalette.neutral0
                                      : ColorPalette.neutral800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    Spacer(),
                    
                    // 内訳表示
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deposit amount',
                              style: TextStylePalette.normalText,
                            ),
                            Text(
                              '¥${selectedAmount.value!.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              )}',
                              style: TextStylePalette.normalText,
                            ),
                          ],
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform fee',
                              style: TextStylePalette.normalText,
                            ),
                            Text(
                              '¥${calculatePlatformFee().toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              )}',
                              style: TextStylePalette.normalText,
                            ),
                          ],
                        ),
                        SizedBox(height: SpacePalette.base),
                        Divider(color: ColorPalette.neutral200, height: 1),
                        SizedBox(height: SpacePalette.base),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStylePalette.smTitle,
                            ),
                            Text(
                              '¥${calculateTotal().toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              )}',
                              style: TextStylePalette.smTitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.base),
                  ],
                  
                  Spacer(),
                  
                  // Depositボタン
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isAmountSelected.value ? () {
                        // デポジット処理 → 成功画面に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DepositSuccessScreen(
                              amount: calculateTotal(),
                            ),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.neutral800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                      ),
                      child: Text(
                        isAmountSelected.value 
                          ? 'Deposit ¥${selectedAmount.value!.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}'
                          : 'Deposit',
                        style: TextStylePalette.buttonTextWhite
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}