// lib/screens/organizer/deposit/presentation/pages/select_amount_screen.dart
import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'deposit_success_screen.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../payment/presentation/pages/payment_methods_screen.dart';

class SelectAmountScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAmount = useState<int>(10000);
    final isProcessing = useState(false);
    final balance = ref.watch(walletBalanceProvider);

    // Load balance on mount
    useEffect(() {
      Future.microtask(() async {
        try {
          final paymentService = ref.read(paymentServiceProvider);
          final bal = await paymentService.getBalance();
          ref.read(walletBalanceProvider.notifier).state = bal;
        } catch (_) {}
      });
      return null;
    }, []);

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

    int calculateTotal() {
      return selectedAmount.value;
    }

    Future<void> handleDeposit() async {
      try {
        isProcessing.value = true;
        final paymentService = ref.read(paymentServiceProvider);

        // Check if user has payment methods
        final methods = await paymentService.listPaymentMethods();
        if (methods.isEmpty) {
          if (!context.mounted) return;
          final shouldAdd = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('No Payment Method'),
              content: Text('Please add a payment method first.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Add Card'),
                ),
              ],
            ),
          );
          if (shouldAdd == true && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
            );
          }
          return;
        }

        // Create PaymentIntent
        final result = await paymentService.createPaymentIntent(calculateTotal());
        final clientSecret = result['client_secret']!;
        final paymentIntentId = result['payment_intent_id']!;

        // Present payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            customerId: result['customer_id']!,
            customerEphemeralKeySecret: result['ephemeral_key_secret']!,
            merchantDisplayName: 'Zero Grid',
            style: ThemeMode.light,
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        // Confirm deposit on server
        final newBalance = await paymentService.confirmDeposit(paymentIntentId);
        ref.read(walletBalanceProvider.notifier).state = newBalance;

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepositSuccessScreen(
              amount: calculateTotal(),
            ),
          ),
        );
      } on StripeException catch (e) {
        if (e.error.code == FailureCode.Canceled) return;
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage}'),
            backgroundColor: ColorPalette.critical500,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: ColorPalette.critical500,
          ),
        );
      } finally {
        isProcessing.value = false;
      }
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
            // Balance Section
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
                    formatCurrency(balance),
                    style: TextStylePalette.header.copyWith(
                      color: ColorPalette.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Deposit Amount Card
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

                  // Amount with +/- buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStylePalette.normalText.copyWith(
                      color: ColorPalette.neutral600,
                    ),
                  ),
                  Text(
                    formatCurrency(calculateTotal()),
                    style: TextStylePalette.smTitle,
                  ),
                ],
              ),
            ),
            SizedBox(height: SpacePalette.base),

            // Deposit Button
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
                    BoxShadow(
                      color: ColorPalette.smashedPumpkin800,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isProcessing.value ? null : handleDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.smashedPumpkin600,
                    foregroundColor: ColorPalette.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                    elevation: 0,
                  ),
                  child: isProcessing.value
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorPalette.white,
                          ),
                        )
                      : Text(
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
