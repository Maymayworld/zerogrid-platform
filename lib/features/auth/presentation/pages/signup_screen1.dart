// lib/features/auth/presentation/pages/signup_screen1.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'signup_screen2.dart';

class SignUpScreen1 extends HookConsumerWidget {
  final UserRole role;

  const SignUpScreen1({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);
    final agreedToTerms = useState(false);

    void handleContinue() {
      // バリデーション
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillInAllFields),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!agreedToTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseAgreeToTerms),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 次の画面へ
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen2(
            role: role,
            email: emailController.text,
            password: passwordController.text,
          ),
        ),
      );
    }

    Future<void> handleAppleSignUp() async {
      if (!agreedToTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseAgreeToTerms),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_oauth_role', role.name);
        final authService = ref.read(authServiceProvider);
        await authService.signInWithApple();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }

    Future<void> handleGoogleSignUp() async {
      if (!agreedToTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseAgreeToTerms),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_oauth_role', role.name);
        final authService = ref.read(authServiceProvider);
        await authService.signInWithGoogle();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
          );
        }
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
                top: SpacePalette.base,
                bottom: keyboardInset + SpacePalette.base,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // タイトル
                    Text(
                      AppLocalizations.of(context)!.createYourAccount,
                      style: TextStylePalette.header,
                    ),
                    SizedBox(height: SpacePalette.sm),
                    Text(
                      AppLocalizations.of(context)!.startBySettingUpLogin,
                      style: TextStylePalette.subText,
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Email
                    Text(AppLocalizations.of(context)!.email, style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'mail@gmail.com',
                          hintStyle: TextStylePalette.hintText,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.inner,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Password
                    Text(AppLocalizations.of(context)!.password, style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: '\u2022\u2022\u2022\u2022\u2022\u2022',
                          hintStyle: TextStyle(color: ColorPalette.neutral400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible.value
                                  ? PhosphorIconsBold.eye
                                  : PhosphorIconsBold.eyeSlash,
                              color: ColorPalette.neutral500,
                              size: 20,
                            ),
                            onPressed: () {
                              isPasswordVisible.value = !isPasswordVisible.value;
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.inner,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Confirm Password
                    Text(AppLocalizations.of(context)!.confirmPassword, style: TextStylePalette.smTitle),
                    SizedBox(height: SpacePalette.sm),
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: '\u2022\u2022\u2022\u2022\u2022\u2022',
                          hintStyle: TextStyle(color: ColorPalette.neutral400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordVisible.value
                                  ? PhosphorIconsBold.eye
                                  : PhosphorIconsBold.eyeSlash,
                              color: ColorPalette.neutral500,
                              size: 20,
                            ),
                            onPressed: () {
                              isConfirmPasswordVisible.value =
                                  !isConfirmPasswordVisible.value;
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.inner,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),

                    // Terms & Privacy checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: agreedToTerms.value,
                            onChanged: (v) => agreedToTerms.value = v ?? false,
                            activeColor: ColorPalette.neutral800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: SpacePalette.sm),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStylePalette.smSubText,
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.agreeToTerms(
                                    '\u0000privacy\u0000',
                                    '\u0000terms\u0000',
                                  ).split('\u0000terms\u0000')[0],
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.termsOfService,
                                  style: TextStylePalette.smSubText.copyWith(
                                    color: ColorPalette.smashedPumpkin600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse('https://kota1020.github.io/zerogrid-legal/terms-of-service.html'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.agreeToTerms(
                                    '\u0000privacy\u0000',
                                    '\u0000terms\u0000',
                                  ).split('\u0000terms\u0000')[1].split('\u0000privacy\u0000')[0],
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.privacyPolicy,
                                  style: TextStylePalette.smSubText.copyWith(
                                    color: ColorPalette.smashedPumpkin600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                        Uri.parse('https://kota1020.github.io/zerogrid-legal/privacy-policy.html'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.agreeToTerms(
                                    '\u0000privacy\u0000',
                                    '\u0000terms\u0000',
                                  ).split('\u0000privacy\u0000').last,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: ButtonSizePalette.button,
                      child: ElevatedButton(
                        onPressed: handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.neutral800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RadiusPalette.full,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.continueButton,
                          style: TextStylePalette.buttonTextWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // or divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: ColorPalette.neutral200)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                          ),
                          child: Text(AppLocalizations.of(context)!.or, style: TextStylePalette.dividerText),
                        ),
                        Expanded(child: Divider(color: ColorPalette.neutral200)),
                      ],
                    ),
                    SizedBox(height: SpacePalette.lg),

                    // Social Login Buttons（Apple / Google）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialSignUpButton(
                          onTap: handleAppleSignUp,
                          child: PlatformIcon.apple(size: 24),
                        ),
                        SizedBox(width: SpacePalette.base),
                        _SocialSignUpButton(
                          onTap: handleGoogleSignUp,
                          child: PlatformIcon.google(size: 20),
                        ),
                      ],
                    ),

                    SizedBox(height: SpacePalette.lg * 2),

                    // Have an account? Sign In
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context)!.haveAnAccount, style: TextStylePalette.subGuide),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(role: role),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(AppLocalizations.of(context)!.signIn, style: TextStylePalette.guide),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),
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

/// ソーシャルサインアップボタン（pill shape、丸アイコン）
class _SocialSignUpButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialSignUpButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ButtonSizePalette.socialButton,
        height: ButtonSizePalette.socialButton,
        decoration: BoxDecoration(
          color: ColorPalette.white,
          shape: BoxShape.circle,
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Center(child: child),
      ),
    );
  }
}
