import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../data/models/payment_method.dart';
import '../providers/payment_provider.dart';

class PaymentMethodsScreen extends HookConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final isAdding = useState(false);
    final paymentMethods = ref.watch(paymentMethodsProvider);

    Future<void> loadPaymentMethods() async {
      try {
        isLoading.value = true;
        final service = ref.read(paymentServiceProvider);
        final methods = await service.listPaymentMethods();
        ref.read(paymentMethodsProvider.notifier).state = methods;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToLoadPaymentMethods(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> addPaymentMethod() async {
      try {
        isAdding.value = true;
        final service = ref.read(paymentServiceProvider);

        final baseUrl = kIsWeb ? Uri.base.origin : 'https://zerogrid.app';

        final checkoutUrl = await service.createSetupCheckoutSession(
          successUrl: baseUrl,
          cancelUrl: baseUrl,
        );

        // Open Stripe Checkout setup page (same tab on web)
        final uri = Uri.parse(checkoutUrl);
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self',
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToAddCard(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isAdding.value = false;
      }
    }

    Future<void> removePaymentMethod(PaymentMethodModel method) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.removeCard),
          content: Text(AppLocalizations.of(context)!.removePaymentMethod(method.displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: ColorPalette.critical500,
              ),
              child: Text(AppLocalizations.of(context)!.remove),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        final service = ref.read(paymentServiceProvider);
        await service.detachPaymentMethod(method.id);
        await loadPaymentMethods();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cardRemoved),
              backgroundColor: ColorPalette.positive500,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToRemoveCard(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      }
    }

    // Load on mount
    useEffect(() {
      Future.microtask(() => loadPaymentMethods());
      return null;
    }, []);

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.paymentMethods,
          style: TextStylePalette.title.copyWith(color: ColorPalette.neutral800),
        ),
        centerTitle: true,
      ),
      body: isLoading.value
          ? Center(child: CircularProgressIndicator(color: ColorPalette.smashedPumpkin600))
          : Column(
              children: [
                Expanded(
                  child: paymentMethods.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(SpacePalette.base),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            return _PaymentMethodCard(
                              method: method,
                              onRemove: () => removePaymentMethod(method),
                            );
                          },
                        ),
                ),
                // Add Card Button
                Padding(
                  padding: EdgeInsets.all(SpacePalette.base),
                  child: SizedBox(
                    width: double.infinity,
                    height: ButtonSizePalette.button,
                    child: ElevatedButton.icon(
                      onPressed: isAdding.value ? null : addPaymentMethod,
                      icon: isAdding.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorPalette.white,
                              ),
                            )
                          : Icon(PhosphorIconsBold.plus),
                      label: Text(
                        isAdding.value ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.paymentMethods,
                        style: TextStylePalette.buttonTextWhite,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.smashedPumpkin600,
                        foregroundColor: ColorPalette.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SpacePalette.base),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsBold.creditCard,
            size: 64,
            color: ColorPalette.neutral300,
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            AppLocalizations.of(context)!.paymentMethods,
            style: TextStylePalette.title.copyWith(
              color: ColorPalette.neutral500,
            ),
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            AppLocalizations.of(context)!.payment,
            style: TextStylePalette.subText,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onRemove;

  const _PaymentMethodCard({
    required this.method,
    required this.onRemove,
  });

  IconData _getBrandIcon() {
    switch (method.brand.toLowerCase()) {
      case 'visa':
        return FontAwesomeIcons.ccVisa;
      case 'mastercard':
        return FontAwesomeIcons.ccMastercard;
      case 'amex':
        return FontAwesomeIcons.ccAmex;
      case 'jcb':
        return FontAwesomeIcons.ccJcb;
      default:
        return PhosphorIconsBold.creditCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SpacePalette.sm),
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.lg),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.neutral800.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Brand icon
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              borderRadius: BorderRadius.circular(RadiusPalette.mini),
            ),
            child: Center(
              child: FaIcon(
                _getBrandIcon(),
                size: 24,
                color: ColorPalette.neutral700,
              ),
            ),
          ),
          SizedBox(width: SpacePalette.inner),

          // Card details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${method.displayBrand} ****${method.last4}',
                      style: TextStylePalette.listTitle,
                    ),
                    if (method.isDefault) ...[
                      SizedBox(width: SpacePalette.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SpacePalette.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.smashedPumpkin100,
                          borderRadius: BorderRadius.circular(RadiusPalette.mini),
                        ),
                        child: Text(
                          'Default',
                          style: TextStylePalette.miniTitle.copyWith(
                            color: ColorPalette.smashedPumpkin600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  'Expires ${method.expiry}',
                  style: TextStylePalette.smSubText,
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              PhosphorIconsBold.trash,
              color: ColorPalette.neutral400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
