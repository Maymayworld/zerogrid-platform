// lib/features/auth/presentation/pages/login_screen.dart
// 確認済み
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/theme/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_screen1.dart';

class LoginScreen extends HookConsumerWidget {
  final UserRole role;

  const LoginScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    // パスワード状態はデフォルトで非表示
    final isPasswordVisible = useState(false);
    // ローディング状態はデフォルトでfalse
    final isLoading = useState(false);

    // ログイン処理
    Future<void> handleLogin() async {
      isLoading.value = true;
  
      try {
        final authService = ref.read(authServiceProvider);
    
        // Supabaseでログイン
        final response = await authService.signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );

        // ユーザーが取得できたら成功
        if (response.user != null && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainLayout(userRole: role),
            ),
          );
        }
      // Supabase認証のエラーだけキャッチ
      } on AuthException catch (e) {
        // Supabase認証エラー
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('認証エラー: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // その他のエラー
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleLineLogin() async {
      // LINE ログインの実装（後で実装）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LINE login coming soon...')),
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
              SizedBox(height: SpacePalette.lg),
              
              // タイトル
              Text(
                'Good to see you again!',
                style: TextStylePalette.header
              ),
              SizedBox(height: SpacePalette.lg),
              
              // Email
              Text(
                'Email',
                style: TextStylePalette.smTitle
              ),
              SizedBox(height: SpacePalette.sm),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'mail@gmail.com',
                    hintStyle: TextStylePalette.hintText,
                    filled: true,
                    fillColor: Colors.transparent,
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
              Text(
                'Password',
                style: TextStylePalette.smTitle
              ),
              SizedBox(height: SpacePalette.sm),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: '••••••',
                    hintStyle: TextStyle(color: ColorPalette.neutral400),
                    filled: true,
                    fillColor: Colors.transparent,
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
              SizedBox(height: SpacePalette.sm),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // パスワードリセット画面へ遷移（後で実装）
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset coming soon...')),
                    );
                  },
                  child: Text(
                    'Forgot Password',
                    style: TextStylePalette.guide
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.base),
              
              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStylePalette.buttonTextWhite
                        ),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              
              // or
              Row(
                children: [
                  Expanded(child: Divider(color: ColorPalette.neutral200)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
                    child: Text(
                      'or',
                        style: TextStylePalette.dividerText
                    ),
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
                  onPressed: handleLineLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorPalette.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // LINEアイコン（緑の四角）
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFF00B900), // LINE緑
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
                      Text(
                        'Continue with LINE',
                        style: TextStylePalette.buttonTextBlack,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              
              // Create account
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New here? ',
                      style: TextStylePalette.subGuide
                    ),
                    TextButton(
                      onPressed: () {
                        // サインアップ画面へ遷移
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen1(role: role),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Create an account',
                        style: TextStylePalette.guide
                      ),
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