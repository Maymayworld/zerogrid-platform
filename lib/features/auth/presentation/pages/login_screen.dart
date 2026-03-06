// lib/features/auth/presentation/pages/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forgot_password_screen.dart';
import 'signup_screen1.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';

class LoginScreen extends HookConsumerWidget {
  final UserRole role;

  const LoginScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);

    // フォームが有効かどうか（email と password が入力されているか）
    final isFormValid = useState(false);

    // 入力値の変更を監視
    useEffect(() {
      void listener() {
        isFormValid.value =
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty;
      }

      emailController.addListener(listener);
      passwordController.addListener(listener);
      return () {
        emailController.removeListener(listener);
        passwordController.removeListener(listener);
      };
    }, []);

    // ログイン処理
    Future<void> handleLogin() async {
      if (!isFormValid.value) return;

      isLoading.value = true;

      try {
        final authService = ref.read(authServiceProvider);

        final response = await authService.signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );

        if (response.user != null && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainLayout(userRole: role)),
          );
        }
      } on AuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authErrorMessage(e.message)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())), backgroundColor: Colors.red),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleAppleLogin() async {
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

    Future<void> handleGoogleLogin() async {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SpacePalette.lg * 2),

                    // タイトル
                    Text(AppLocalizations.of(context)!.logIn, style: TextStylePalette.header),
                    const SizedBox(height: SpacePalette.lg),

                    // ソーシャルログインボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Apple
                        _SocialLoginButton(
                          onTap: handleAppleLogin,
                          child: PlatformIcon.apple(size: 24),
                        ),
                        const SizedBox(width: SpacePalette.base),
                        // Google
                        _SocialLoginButton(
                          onTap: handleGoogleLogin,
                          child: PlatformIcon.google(size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacePalette.lg),

                    // Divider with "or"
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: ColorPalette.neutral200),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.or,
                            style: TextStyle(
                              color: ColorPalette.neutral500,
                              fontSize: FontSizePalette.size14,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: ColorPalette.neutral200),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacePalette.lg),

                    // Email フィールド（Duolingoスタイル）
                    DuolingoTextField(
                      controller: emailController,
                      hintText: AppLocalizations.of(context)!.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: SpacePalette.base),

                    // Password フィールド（Duolingoスタイル）
                    DuolingoTextField(
                      controller: passwordController,
                      hintText: AppLocalizations.of(context)!.password,
                      obscureText: true,
                    ),
                    const SizedBox(height: SpacePalette.lg),

                    // Sign In Button（Duolingoスタイル）
                    DuolingoButton(
                      onPressed: handleLogin,
                      isEnabled: isFormValid.value,
                      isLoading: isLoading.value,
                      text: AppLocalizations.of(context)!.signIn,
                    ),
                    const SizedBox(height: SpacePalette.base),

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ForgotPasswordScreen(role: role),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgotPasswordQuestion,
                        style: TextStylePalette.guide,
                      ),
                    ),
                    const SizedBox(height: SpacePalette.lg * 2),

                    // Create account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.newHere, style: TextStylePalette.subGuide),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen1(role: role),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.createAnAccount,
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

/// ソーシャルログインボタン（pill shape）
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialLoginButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: ButtonSizePalette.socialButton,
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.full),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Center(child: child),
      ),
    );
  }
}
