// lib/features/creator/earnings/presentation/pages/withdrawal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/presentation/providers/reward_provider.dart';
import '../../data/services/payout_service.dart';

final payoutServiceProvider = Provider<PayoutService>((ref) {
  return PayoutService();
});

class WithdrawalScreen extends HookConsumerWidget {
  final int currentBalance;

  const WithdrawalScreen({Key? key, required this.currentBalance}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(payoutServiceProvider);
    final connectStatus = useState<ConnectStatus?>(null);
    final isCheckingStatus = useState(true);
    final isProcessing = useState(false);
    final amountController = useTextEditingController();
    final errorText = useState<String?>(null);

    // Connect状態チェック
    useEffect(() {
      Future.microtask(() async {
        try {
          final status = await service.getConnectStatus();
          connectStatus.value = status;
        } catch (e) {
          debugPrint('Connect status check failed: $e');
          connectStatus.value = const ConnectStatus();
        }
        isCheckingStatus.value = false;
      });
      return null;
    }, []);

    String formatCurrency(int amount) {
      return '¥${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }

    Future<void> handleSetupPayout() async {
      isProcessing.value = true;
      try {
        final url = await service.getOnboardingUrl();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isProcessing.value = false;
      }
    }

    Future<void> refreshStatus() async {
      isCheckingStatus.value = true;
      try {
        final status = await service.getConnectStatus();
        connectStatus.value = status;
      } catch (_) {}
      isCheckingStatus.value = false;
    }

    Future<void> handleWithdraw() async {
      errorText.value = null;
      final amountStr = amountController.text.replaceAll(',', '').trim();
      final amount = int.tryParse(amountStr);

      if (amount == null || amount < 1000) {
        errorText.value = 'Minimum withdrawal is ¥1,000';
        return;
      }
      if (amount > currentBalance) {
        errorText.value = 'Insufficient balance';
        return;
      }

      // 確認ダイアログ
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Withdrawal'),
          content: Text('Withdraw ${formatCurrency(amount)} to your bank account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Confirm', style: TextStyle(color: ColorPalette.smashedPumpkin600)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isProcessing.value = true;
      try {
        await service.withdraw(amount);
        ref.invalidate(creatorBalanceProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${formatCurrency(amount)} withdrawal processed!'),
              backgroundColor: ColorPalette.positive500,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        errorText.value = e.toString().replaceFirst('Exception: ', '');
      } finally {
        isProcessing.value = false;
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        title: Text('Withdraw'),
        backgroundColor: ColorPalette.neutral100,
      ),
      body: isCheckingStatus.value
          ? Center(child: CircularProgressIndicator(color: ColorPalette.neutral800))
          : SingleChildScrollView(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 残高表示
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(SpacePalette.lg),
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral800,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStylePalette.smText.copyWith(
                            color: ColorPalette.neutral400,
                          ),
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Text(
                          formatCurrency(currentBalance),
                          style: TextStylePalette.header.copyWith(
                            color: ColorPalette.white,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SpacePalette.lg),

                  // Connectアカウント未設定の場合
                  if (connectStatus.value == null || !connectStatus.value!.hasConnect) ...[
                    _buildSetupSection(
                      icon: Icons.account_balance_outlined,
                      title: 'Set Up Payout Account',
                      description: 'To withdraw funds, you need to set up your payout account through Stripe. '
                          'This includes verifying your identity and adding your bank account.',
                      buttonText: 'Set Up Now',
                      isLoading: isProcessing.value,
                      onTap: handleSetupPayout,
                    ),
                  ]
                  // 設定済みだが確認未完了
                  else if (!connectStatus.value!.payoutsEnabled) ...[
                    _buildSetupSection(
                      icon: Icons.pending_outlined,
                      title: 'Verification Pending',
                      description: connectStatus.value!.detailsSubmitted
                          ? 'Your account is being verified by Stripe. This usually takes 1-2 business days.'
                          : 'Please complete your account setup to enable withdrawals.',
                      buttonText: connectStatus.value!.detailsSubmitted ? 'Refresh Status' : 'Continue Setup',
                      isLoading: isProcessing.value,
                      onTap: connectStatus.value!.detailsSubmitted ? refreshStatus : handleSetupPayout,
                    ),
                  ]
                  // 出金可能
                  else ...[
                    // ステータスバッジ
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacePalette.base,
                        vertical: SpacePalette.sm,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.positive50,
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        border: Border.all(color: ColorPalette.positive200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: ColorPalette.positive500),
                          SizedBox(width: SpacePalette.sm),
                          Text(
                            'Payout account verified',
                            style: TextStylePalette.smTitle.copyWith(
                              color: ColorPalette.positive700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // 金額入力
                    Text('Amount', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStylePalette.header.copyWith(fontSize: 24),
                      decoration: InputDecoration(
                        prefixText: '¥ ',
                        prefixStyle: TextStylePalette.header.copyWith(
                          fontSize: 24,
                          color: ColorPalette.neutral400,
                        ),
                        hintText: '0',
                        hintStyle: TextStylePalette.header.copyWith(
                          fontSize: 24,
                          color: ColorPalette.neutral300,
                        ),
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
                          borderSide: BorderSide(color: ColorPalette.neutral800),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // クイック選択ボタン
                    Row(
                      children: [
                        _QuickAmountButton(
                          label: '¥1,000',
                          onTap: () => amountController.text = '1000',
                        ),
                        SizedBox(width: SpacePalette.sm),
                        _QuickAmountButton(
                          label: '¥5,000',
                          onTap: () => amountController.text = '5000',
                        ),
                        SizedBox(width: SpacePalette.sm),
                        _QuickAmountButton(
                          label: 'All',
                          onTap: () => amountController.text = currentBalance.toString(),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Text(
                      'Minimum ¥1,000 · Funds arrive in 2-5 business days',
                      style: TextStylePalette.smSubText,
                    ),

                    if (errorText.value != null) ...[
                      SizedBox(height: SpacePalette.sm),
                      Text(
                        errorText.value!,
                        style: TextStylePalette.smText.copyWith(
                          color: ColorPalette.critical500,
                        ),
                      ),
                    ],

                    SizedBox(height: SpacePalette.lg),

                    // 出金ボタン
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isProcessing.value ? null : handleWithdraw,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.neutral800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                        ),
                        child: isProcessing.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorPalette.white,
                                ),
                              )
                            : Text(
                                'Withdraw',
                                style: TextStylePalette.buttonTextWhite,
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSetupSection({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(SpacePalette.lg),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: ColorPalette.neutral400),
          SizedBox(height: SpacePalette.base),
          Text(title, style: TextStylePalette.smallHeader),
          SizedBox(height: SpacePalette.sm),
          Text(
            description,
            style: TextStylePalette.subText,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SpacePalette.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.neutral800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorPalette.white,
                      ),
                    )
                  : Text(buttonText, style: TextStylePalette.buttonTextWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacePalette.base,
          vertical: SpacePalette.sm,
        ),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Text(label, style: TextStylePalette.smTitle),
      ),
    );
  }
}
