// lib/features/auth/presentation/pages/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/platform_icon.dart';
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
    final isLoading = useState(false);
    
    // フォームが有効かどうか（email と password が入力されているか）
    final isFormValid = useState(false);
    
    // 入力値の変更を監視
    useEffect(() {
      void listener() {
        isFormValid.value = emailController.text.isNotEmpty && 
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
            MaterialPageRoute(
              builder: (context) => MainLayout(userRole: role),
            ),
          );
        }
      } on AuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('認証エラー: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
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

    Future<void> handleAppleLogin() async {
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

    Future<void> handleGoogleLogin() async {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
          child: Column(
            children: [
              const Spacer(flex: 2),

              SizedBox(height: SpacePalette.lg*3),
              
              // タイトル
              Text(
                'Log In',
                style: TextStylePalette.header,
              ),
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
                  const Expanded(child: Divider(color: ColorPalette.neutral200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: ColorPalette.neutral500,
                        fontSize: FontSizePalette.size14,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: ColorPalette.neutral200)),
                ],
              ),
              const SizedBox(height: SpacePalette.lg),
              
              // Email フィールド（Duolingoスタイル）
              DuolingoTextField(
                controller: emailController,
                hintText: 'email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: SpacePalette.base),
              
              // Password フィールド（Duolingoスタイル）
              DuolingoTextField(
                controller: passwordController,
                hintText: 'password',
                obscureText: true,
              ),
              const SizedBox(height: SpacePalette.lg),
              
              // Sign In Button（Duolingoスタイル）
              DuolingoButton(
                onPressed: handleLogin,
                isEnabled: isFormValid.value,
                isLoading: isLoading.value,
                text: 'sign in',
              ),
              const SizedBox(height: SpacePalette.base),
              
              // Forgot Password
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset coming soon...')),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStylePalette.guide,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Create account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New here? ',
                    style: TextStylePalette.subGuide,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen1(role: role),
                        ),
                      );
                    },
                    child: Text(
                      'Create an account',
                      style: TextStylePalette.guideUnderline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacePalette.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// ソーシャルログインボタン（pill shape）
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialLoginButton({
    required this.onTap,
    required this.child,
  });

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

/// Duolingoスタイルのテキストフィールド
class DuolingoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  const DuolingoTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  // 影のオフセット量
  static const double shadowOffset = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ButtonSizePalette.button + shadowOffset,
      child: Stack(
        children: [
          // 影（下のレイヤー）
          Positioned(
            left: 0,
            right: 0,
            top: shadowOffset,
            child: Container(
              height: ButtonSizePalette.button,
              decoration: BoxDecoration(
                color: ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
            ),
          ),
          // 本体（上のレイヤー）
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: ButtonSizePalette.button,
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                border: Border.all(color: ColorPalette.neutral200),
              ),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStylePalette.hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SpacePalette.base,
                    vertical: SpacePalette.inner,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duolingoスタイルのボタン
class DuolingoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  final String text;

  const DuolingoButton({
    Key? key,
    required this.onPressed,
    required this.isEnabled,
    this.isLoading = false,
    required this.text,
  }) : super(key: key);

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton> {
  bool _isPressed = false;

  // 影のオフセット量
  static const double shadowOffset = 4.0;

  @override
  Widget build(BuildContext context) {
    final bool showShadow = widget.isEnabled && !_isPressed;
    
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      child: SizedBox(
        height: ButtonSizePalette.button + shadowOffset,
        child: Stack(
          children: [
            // 影（有効時のみ表示）
            if (showShadow)
              Positioned(
                left: 0,
                right: 0,
                top: shadowOffset,
                child: Container(
                  height: ButtonSizePalette.button,
                  decoration: BoxDecoration(
                    color: ColorPalette.smashedPumpkin700,
                    borderRadius: BorderRadius.circular(RadiusPalette.full),
                  ),
                ),
              ),
            // 本体
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              left: 0,
              right: 0,
              // 押下時は下にずらして影を隠す
              top: _isPressed ? shadowOffset : 0,
              child: Container(
                height: ButtonSizePalette.button,
                decoration: BoxDecoration(
                  color: widget.isEnabled
                      ? ColorPalette.smashedPumpkin600
                      : ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(RadiusPalette.full),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: ColorPalette.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.text,
                          style: widget.isEnabled
                              ? TextStylePalette.buttonTextWhite
                              : TextStylePalette.buttonTextDisabled,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Duolingoスタイルのアウトラインボタン（白背景 + neutral200影）
class DuolingoOutlineButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;

  const DuolingoOutlineButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  State<DuolingoOutlineButton> createState() => _DuolingoOutlineButtonState();
}

class _DuolingoOutlineButtonState extends State<DuolingoOutlineButton> {
  bool _isPressed = false;

  static const double shadowOffset = 4.0;
  static const double buttonHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final bool showShadow = !_isPressed;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: ColorPalette.neutral800),
            const SizedBox(width: SpacePalette.sm),
          ],
          Text(widget.text, style: TextStylePalette.smTitle),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: IntrinsicWidth(
        child: SizedBox(
          height: buttonHeight + shadowOffset,
          child: Stack(
            children: [
              // 影（neutral200）
              if (showShadow)
                Positioned(
                  left: 0,
                  right: 0,
                  top: shadowOffset,
                  child: Container(
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral200,
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                  ),
                ),
              // 本体（白背景 + neutral200ボーダー）
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                left: 0,
                right: 0,
                top: _isPressed ? shadowOffset : 0,
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    borderRadius: BorderRadius.circular(RadiusPalette.full),
                    border: Border.all(color: ColorPalette.neutral200, width: 2),
                  ),
                  child: Center(child: content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}