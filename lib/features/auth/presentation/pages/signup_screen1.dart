// lib/features/auth/presentation/pages/signup_screen1.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    void handleContinue() {
      // バリデーション
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
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
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_oauth_role', role.name);
        final authService = ref.read(authServiceProvider);
        await authService.signInWithApple();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    Future<void> handleGoogleSignUp() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_oauth_role', role.name);
        final authService = ref.read(authServiceProvider);
        await authService.signInWithGoogle();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        child: Padding(
          padding: const EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                'Create Your Account',
                style: TextStylePalette.header,
              ),
              SizedBox(height: SpacePalette.sm),
              Text(
                'Start by setting up your login details',
                style: TextStylePalette.subText,
              ),
              SizedBox(height: SpacePalette.lg),

              // Email
              Text('Email', style: TextStylePalette.smTitle),
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
              Text('Password', style: TextStylePalette.smTitle),
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
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
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
              Text('Confirm Password', style: TextStylePalette.smTitle),
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
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: ColorPalette.neutral500,
                        size: 20,
                      ),
                      onPressed: () {
                        isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SpacePalette.base,
                      vertical: SpacePalette.inner,
                    ),
                  ),
                ),
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
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                  ),
                  child: Text('Continue', style: TextStylePalette.buttonTextWhite),
                ),
              ),
              SizedBox(height: SpacePalette.lg),

              // or divider
              Row(
                children: [
                  Expanded(child: Divider(color: ColorPalette.neutral200)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                    child: Text('or', style: TextStylePalette.dividerText),
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

              Spacer(),

              // Have an account? Sign In
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Have an account? ', style: TextStylePalette.subGuide),
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
                      child: Text('Sign In', style: TextStylePalette.guide),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
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
