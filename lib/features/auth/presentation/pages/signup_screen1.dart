// lib/features/auth/presentation/pages/signup_screen1.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
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

    Future<void> handleLineSignUp() async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LINE signup coming soon...')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
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
                height: 48,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'mail@gmail.com',
                    hintStyle: TextStylePalette.hintText,
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
                      borderSide: BorderSide(color: ColorPalette.neutral800, width: 2),
                    ),
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
                height: 48,
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: '••••••',
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
                      borderSide: BorderSide(color: ColorPalette.neutral800, width: 2),
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
                height: 48,
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: '••••••',
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
                      borderSide: BorderSide(color: ColorPalette.neutral800, width: 2),
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
                height: 48,
                child: ElevatedButton(
                  onPressed: handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Text('Continue', style: TextStylePalette.buttonTextWhite),
                ),
              ),
              SizedBox(height: SpacePalette.lg),

              // or
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

              // Continue with LINE
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: handleLineSignUp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorPalette.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFF00B900),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Text('Continue with LINE', style: TextStylePalette.buttonTextBlack),
                    ],
                  ),
                ),
              ),
              Spacer(),

              // Have an account
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