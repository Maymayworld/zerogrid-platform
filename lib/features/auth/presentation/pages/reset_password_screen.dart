import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  final String? resetToken;
  final VoidCallback? onCompleted;

  const ResetPasswordScreen({
    Key? key,
    this.resetToken,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final isFormValid = useState(false);

    useEffect(() {
      void listener() {
        final password = passwordController.text;
        isFormValid.value = password.isNotEmpty && password.length >= 8;
      }

      passwordController.addListener(listener);
      return () {
        passwordController.removeListener(listener);
      };
    }, []);

    Future<void> handleContinue() async {
      if (!isFormValid.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordMinLength),
            backgroundColor: ColorPalette.critical500,
          ),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => _ConfirmResetPasswordScreen(
            resetToken: resetToken,
            initialPassword: passwordController.text,
            onCompleted: onCompleted,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.enterNewPasswordInstruction,
                style: TextStylePalette.subText,
              ),
              const SizedBox(height: SpacePalette.lg),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createNewPassword,
                      style: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: SpacePalette.sm),
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: passwordController,
                        textAlign: TextAlign.center,
                        style: TextStylePalette.header,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
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
                    DuolingoButton(
                      onPressed: handleContinue,
                      isEnabled: isFormValid.value,
                      isLoading: isLoading.value,
                      text: AppLocalizations.of(context)!.continueButton,
                    ),
                    const SizedBox(height: SpacePalette.base),
                    Text(
                      AppLocalizations.of(context)!.passwordMinLength,
                      style: TextStylePalette.subGuide,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmResetPasswordScreen extends HookConsumerWidget {
  final String? resetToken;
  final String initialPassword;
  final VoidCallback? onCompleted;

  const _ConfirmResetPasswordScreen({
    Key? key,
    required this.resetToken,
    required this.initialPassword,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmController = useTextEditingController();
    final isLoading = useState(false);
    final isFormValid = useState(false);

    useEffect(() {
      void listener() {
        final confirm = confirmController.text;
        isFormValid.value =
            confirm.isNotEmpty && confirm.length >= 8 && confirm == initialPassword;
      }

      confirmController.addListener(listener);
      return () => confirmController.removeListener(listener);
    }, []);

    Future<void> handleUpdatePassword() async {
      if (!isFormValid.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.passwordsMustMatch),
            backgroundColor: ColorPalette.critical500,
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        if (resetToken != null) {
          final authService = ref.read(authServiceProvider);
          await authService.confirmResetPassword(
            resetToken: resetToken!,
            newPassword: confirmController.text,
          );
        } else {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(password: confirmController.text),
          );
          await Supabase.instance.client.auth.signOut();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.passwordUpdated,
              ),
              backgroundColor: ColorPalette.positive500,
            ),
          );
        }
        onCompleted?.call();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } on AuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authErrorMessage(e.message)),
              backgroundColor: ColorPalette.critical500,
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
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.reEnterPasswordInstruction,
                style: TextStylePalette.subText,
              ),
              const SizedBox(height: SpacePalette.lg),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.confirmNewPassword,
                      style: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: SpacePalette.sm),
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: confirmController,
                        textAlign: TextAlign.center,
                        style: TextStylePalette.header,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
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
                    DuolingoButton(
                      onPressed: handleUpdatePassword,
                      isEnabled: isFormValid.value,
                      isLoading: isLoading.value,
                      text: AppLocalizations.of(context)!.updatePassword,
                    ),
                    const SizedBox(height: SpacePalette.base),
                    Text(
                      AppLocalizations.of(context)!.passwordMinLength,
                      style: TextStylePalette.subGuide,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
