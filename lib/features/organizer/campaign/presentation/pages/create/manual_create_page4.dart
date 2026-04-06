// lib/features/organizer/campaign/presentation/pages/create/manual_create_page4.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:zero_grid/features/organizer/campaign/data/services/campaign_service.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/pages/create/manual_create_page5.dart';
import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ManualCreatePage4 extends HookConsumerWidget{
  const ManualCreatePage4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final budgetController = useTextEditingController();
    final isChecking = useState(false);

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
        icon: Icon(PhosphorIconsRegular.arrowLeft, color: ColorPalette.neutral800),
        onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.budget,
                  style: TextStylePalette.header,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.suggestRangesBasedOnCategory,
                  style: TextStylePalette.subText,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  cursorColor: ColorPalette.neutral800,
                  decoration: InputDecoration(
                    suffixIcon: Center(
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: SpacePalette.inner),
                        child: Text(
                          '￥',
                          style: TextStylePalette.subText,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral200,
                        width: 1
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.neutral800,
                        width: 2
                      )
                    )
                  ),
                )
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: DuolingoButton(
                  onPressed: () async {
                    final budgetText = budgetController.text.trim();
                    if (budgetText.isEmpty) return;
                    final budget = int.tryParse(budgetText);
                    if (budget == null || budget <= 0) return;

                    isChecking.value = true;
                    try {
                      final available = await CampaignService().getAvailableBudget();
                      if (!context.mounted) return;

                      if (budget > available) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.insufficientBalanceAvailable(available.toString()),
                            ),
                          ),
                        );
                        return;
                      }

                      // 1000再生あたりの最低収益チェック（¥300）
                      final targetViews = ref.read(projectProvider).targetViews;
                      if (targetViews > 0) {
                        final cpm = (budget / targetViews) * 1000;
                        if (cpm < 300) {
                          final minBudget = (targetViews * 300 / 1000).ceil();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.minimumCpmRequired(minBudget.toString()),
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      ref.read(projectProvider.notifier).setBudget(budget);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualCreatePage5(),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString()))),
                      );
                    } finally {
                      isChecking.value = false;
                    }
                  },
                  isEnabled: !isChecking.value,
                  isLoading: isChecking.value,
                  text: AppLocalizations.of(context)!.next,
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}