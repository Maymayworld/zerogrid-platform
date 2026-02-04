// lib/screens/organizer/deposit/presentation/pages/select_amount_screen.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'deposit_success_screen.dart';

class SelectAmountScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selectedAmount = useState<int>(10000);
    final isTotalExpanded = useState(false);

    String formatCurrency(int amount) {
      return '¥${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }

    void incrementAmount() {
      selectedAmount.value = selectedAmount.value + 10000;
    }

    void decrementAmount() {
      if (selectedAmount.value > 10000) {
        selectedAmount.value = selectedAmount.value - 10000;
      }
    }

    int calculatePlatformFee() {
      return (selectedAmount.value * 0.1).round();
    }

    int calculateTotal() {
      return selectedAmount.value + calculatePlatformFee();
    }

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Deposit', style: TextStylePalette.title.copyWith(
          color: ColorPalette.neutral800,
        )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance Section - 両端まで伸びる（マージンなし、角丸なし）
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: SpacePalette.base,
                vertical: SpacePalette.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorPalette.smashedPumpkin500,
                    ColorPalette.smashedPumpkin700,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: TextStylePalette.smText.copyWith(
                      color: ColorPalette.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    '¥400,500',
                    style: TextStylePalette.header.copyWith(
                      color: ColorPalette.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Deposit Amount Card (金額設定部分のみ)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(SpacePalette.base),
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.lg),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.neutral800.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposit Amount',
                    style: TextStylePalette.title.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: SpacePalette.lg),

                  // Amount with +/- buttons (中央配置)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      GestureDetector(
                        onTap: decrementAmount,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: ColorPalette.neutral600,
                            size: 24,
                          ),
                        ),
                      ),

                      // Amount display
                      Container(
                        width: 160,
                        alignment: Alignment.center,
                        child: Text(
                          formatCurrency(selectedAmount.value),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.neutral800,
                          ),
                        ),
                      ),

                      // Plus button
                      GestureDetector(
                        onTap: incrementAmount,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorPalette.neutral200),
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          child: Icon(
                            Icons.add,
                            color: ColorPalette.neutral600,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: SpacePalette.lg),

                  // Quick amount selection buttons
                  Row(
                    children: [
                      _AmountButton(
                        amount: 10000,
                        isSelected: selectedAmount.value == 10000,
                        onTap: () => selectedAmount.value = 10000,
                        formatCurrency: formatCurrency,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _AmountButton(
                        amount: 50000,
                        isSelected: selectedAmount.value == 50000,
                        onTap: () => selectedAmount.value = 50000,
                        formatCurrency: formatCurrency,
                      ),
                      SizedBox(width: SpacePalette.sm),
                      _AmountButton(
                        amount: 100000,
                        isSelected: selectedAmount.value == 100000,
                        onTap: () => selectedAmount.value = 100000,
                        formatCurrency: formatCurrency,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Spacer(),

            // Bottom Section (Total & Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
              child: Column(
                children: [
                  // 内訳 (展開時のみ表示)
                  AnimatedCrossFade(
                    firstChild: SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deposit amount',
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.neutral500,
                              ),
                            ),
                            Text(
                              formatCurrency(selectedAmount.value),
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.neutral600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform fee',
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.neutral500,
                              ),
                            ),
                            Text(
                              formatCurrency(calculatePlatformFee()),
                              style: TextStylePalette.smText.copyWith(
                                color: ColorPalette.neutral600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SpacePalette.base),
                      ],
                    ),
                    crossFadeState: isTotalExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 200),
                  ),

                  // Total (タップで展開)
                  GestureDetector(
                    onTap: () => isTotalExpanded.value = !isTotalExpanded.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: TextStylePalette.normalText.copyWith(
                                color: ColorPalette.neutral600,
                              ),
                            ),
                            SizedBox(width: SpacePalette.xs),
                            Icon(
                              isTotalExpanded.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                              size: 20,
                              color: ColorPalette.neutral600,
                            ),
                          ],
                        ),
                        Text(
                          formatCurrency(calculateTotal()),
                          style: TextStylePalette.smTitle,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: SpacePalette.base),
                ],
              ),
            ),

            // Deposit Button with solid shadow (角丸full)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacePalette.base,
                0,
                SpacePalette.base,
                SpacePalette.base,
              ),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                  boxShadow: [
                    // ソリッドシャドウ（下にずらした黒い影）
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepositSuccessScreen(
                          amount: calculateTotal(),
                        ),
                      ),
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
                    'Deposit ${formatCurrency(selectedAmount.value)}',
                    style: TextStylePalette.buttonTextWhite.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;
  final String Function(int) formatCurrency;

  const _AmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? ColorPalette.smashedPumpkin600 : ColorPalette.white,
            borderRadius: BorderRadius.circular(RadiusPalette.base),
            border: Border.all(
              color: isSelected ? ColorPalette.smashedPumpkin600 : ColorPalette.neutral200,
            ),
          ),
          child: Center(
            child: Text(
              formatCurrency(amount),
              style: TextStylePalette.smTitle.copyWith(
                color: isSelected ? ColorPalette.white : ColorPalette.neutral800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
