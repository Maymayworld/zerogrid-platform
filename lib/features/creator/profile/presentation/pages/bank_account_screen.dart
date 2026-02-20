import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../data/models/bank_account.dart';
import '../providers/bank_account_provider.dart';

class BankAccountScreen extends HookConsumerWidget {
  const BankAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAccount = ref.watch(bankAccountProvider);
    final isLoading = ref.watch(bankAccountLoadingProvider);

    final bankNameController = useTextEditingController(
      text: bankAccount?.bankName ?? '',
    );
    final branchNameController = useTextEditingController(
      text: bankAccount?.branchName ?? '',
    );
    final accountNumberController = useTextEditingController(
      text: bankAccount?.accountNumber ?? '',
    );
    final accountHolderController = useTextEditingController(
      text: bankAccount?.accountHolder ?? '',
    );
    final selectedAccountType = useState(bankAccount?.accountType ?? 'ordinary');

    // Load bank account on mount
    useEffect(() {
      Future.microtask(() async {
        ref.read(bankAccountLoadingProvider.notifier).state = true;
        try {
          final service = ref.read(bankAccountServiceProvider);
          final account = await service.getBankAccount();
          ref.read(bankAccountProvider.notifier).state = account;
          if (account != null) {
            bankNameController.text = account.bankName;
            branchNameController.text = account.branchName;
            accountNumberController.text = account.accountNumber;
            accountHolderController.text = account.accountHolder;
            selectedAccountType.value = account.accountType;
          }
        } catch (_) {}
        ref.read(bankAccountLoadingProvider.notifier).state = false;
      });
      return null;
    }, []);

    Future<void> handleSave() async {
      final bankName = bankNameController.text.trim();
      final branchName = branchNameController.text.trim();
      final accountNumber = accountNumberController.text.trim();
      final accountHolder = accountHolderController.text.trim();

      if (bankName.isEmpty ||
          branchName.isEmpty ||
          accountNumber.isEmpty ||
          accountHolder.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      ref.read(bankAccountLoadingProvider.notifier).state = true;
      try {
        final service = ref.read(bankAccountServiceProvider);
        final saved = await service.saveBankAccount(
          bankName: bankName,
          branchName: branchName,
          accountType: selectedAccountType.value,
          accountNumber: accountNumber,
          accountHolder: accountHolder,
        );
        ref.read(bankAccountProvider.notifier).state = saved;
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank account saved!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      ref.read(bankAccountLoadingProvider.notifier).state = false;
    }

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Account',
          style: TextStylePalette.title,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview card (if bank account exists)
                    if (bankAccount != null) ...[
                      _BankAccountCard(bankAccount: bankAccount),
                      SizedBox(height: SpacePalette.lg),
                    ],

                    // Bank Name
                    Text('Bank Name', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: bankNameController,
                      style: TextStylePalette.normalText,
                      decoration: InputDecoration(
                        hintText: 'Enter bank name',
                        hintStyle: TextStylePalette.hintText,
                        filled: true,
                        fillColor: ColorPalette.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Branch Name
                    Text('Branch Name', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: branchNameController,
                      style: TextStylePalette.normalText,
                      decoration: InputDecoration(
                        hintText: 'Enter branch name',
                        hintStyle: TextStylePalette.hintText,
                        filled: true,
                        fillColor: ColorPalette.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Account Type
                    Text('Account Type', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacePalette.base,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.white,
                        borderRadius:
                            BorderRadius.circular(RadiusPalette.base),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedAccountType.value,
                          isExpanded: true,
                          style: TextStylePalette.normalText,
                          items: const [
                            DropdownMenuItem(
                              value: 'ordinary',
                              child: Text('Ordinary'),
                            ),
                            DropdownMenuItem(
                              value: 'checking',
                              child: Text('Checking'),
                            ),
                            DropdownMenuItem(
                              value: 'savings',
                              child: Text('Savings'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              selectedAccountType.value = value;
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Account Number
                    Text('Account Number', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: accountNumberController,
                      style: TextStylePalette.normalText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter account number',
                        hintStyle: TextStylePalette.hintText,
                        filled: true,
                        fillColor: ColorPalette.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Account Holder
                    Text('Account Holder', style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: accountHolderController,
                      style: TextStylePalette.normalText,
                      decoration: InputDecoration(
                        hintText: 'Enter account holder name',
                        hintStyle: TextStylePalette.hintText,
                        filled: true,
                        fillColor: ColorPalette.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                border: Border(
                  top: BorderSide(
                    color: ColorPalette.neutral200,
                    width: 1.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(RadiusPalette.base),
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
                      : Text('Save', style: TextStylePalette.buttonTextWhite),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccount bankAccount;

  const _BankAccountCard({required this.bankAccount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.neutral800,
        borderRadius: BorderRadius.circular(RadiusPalette.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                size: 16,
                color: ColorPalette.neutral100,
              ),
              SizedBox(width: SpacePalette.xs),
              Text(
                'Bank Account',
                style: TextStylePalette.smText.copyWith(
                  color: ColorPalette.neutral100,
                ),
              ),
            ],
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            bankAccount.accountHolder,
            style: TextStylePalette.smallHeader.copyWith(
              color: ColorPalette.neutral100,
            ),
          ),
          SizedBox(height: SpacePalette.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bankAccount.bankName} - ${bankAccount.branchName}',
                style: TextStylePalette.smText.copyWith(
                  color: ColorPalette.neutral100.withOpacity(0.7),
                ),
              ),
              Text(
                bankAccount.maskedAccountNumber,
                style: TextStylePalette.normalText.copyWith(
                  color: ColorPalette.neutral100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
