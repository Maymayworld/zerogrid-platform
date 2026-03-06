// lib/features/auth/presentation/pages/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'reset_code_input_screen.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  final UserRole role;

  const ForgotPasswordScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  static bool _isValidEmail(String value) {
    if (value.isEmpty) return false;
    return value.contains('@') && value.contains('.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = useState(false);
    final successMessage = useState<String?>(null);
    final isFormValid = useState(false);

    useEffect(() {
      void listener() {
        isFormValid.value = _isValidEmail(emailController.text);
      }
      emailController.addListener(listener);
      return () => emailController.removeListener(listener);
    }, []);

    Future<void> handleSendResetCode() async {
      final email = emailController.text.trim();
      if (!_isValidEmail(email)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pleaseEnterValidEmail),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
        return;
      }

      isLoading.value = true;
      successMessage.value = null;

      try {
        final authService = ref.read(authServiceProvider);
        await authService.requestPasswordReset(email);

        if (context.mounted) {
          successMessage.value =
              AppLocalizations.of(context)!.resetCodeSentSuccess;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ResetCodeInputScreen(
                email: email,
                role: role,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: SpacePalette.base,
                right: SpacePalette.base,
                bottom: keyboardInset + SpacePalette.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.forgotPasswordQuestion,
                      style: TextStylePalette.header,
                    ),
                    const SizedBox(height: SpacePalette.sm),
                    Text(
                      AppLocalizations.of(context)!.enterEmailForResetCode,
                      style: TextStylePalette.subText,
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Email（signup_screen2 と同じスタイル）
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: emailController,
                        textAlign: TextAlign.center,
                        style: TextStylePalette.header,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'example@mail.com',
                          hintStyle: TextStylePalette.header.copyWith(
                            color: ColorPalette.neutral400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.inner,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacePalette.lg),

                    // Send reset link（Duolingoスタイル）
                    DuolingoButton(
                      onPressed: handleSendResetCode,
                      isEnabled: isFormValid.value,
                      isLoading: isLoading.value,
                      text: AppLocalizations.of(context)!.sendCode,
                    ),
                    const SizedBox(height: SpacePalette.base),

                    if (successMessage.value != null) ...[
                      Text(
                        successMessage.value!,
                        style: TextStylePalette.subText,
                      ),
                      const SizedBox(height: SpacePalette.lg),
                    ],

                    const SizedBox(height: SpacePalette.lg * 2),

                    // Back to Log in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.backTo,
                          style: TextStylePalette.subGuide,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            AppLocalizations.of(context)!.logIn,
                            style: TextStylePalette.guideUnderline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacePalette.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
