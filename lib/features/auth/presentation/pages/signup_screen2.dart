// lib/features/auth/presentation/pages/signup_screen2.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'signup_screen3.dart';

enum UsernameStatus { none, checking, taken, available }

class SignUpScreen2 extends HookConsumerWidget {
  final UserRole role;
  final String email;
  final String password;

  const SignUpScreen2({
    Key? key,
    required this.role,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final usernameStatus = useState(UsernameStatus.none);

    // デバウンス用
    final debounceTimer = useRef<Future<void>?>(null);

    // ユーザーネーム重複チェック（Supabase）
    Future<void> checkUsername(String username) async {
      if (username.isEmpty) {
        usernameStatus.value = UsernameStatus.none;
        return;
      }

      if (username.length < 3) {
        usernameStatus.value = UsernameStatus.none;
        return;
      }

      usernameStatus.value = UsernameStatus.checking;

      // デバウンス（500ms待ってからチェック）
      await Future.delayed(Duration(milliseconds: 500));

      try {
        final authService = ref.read(authServiceProvider);
        final isTaken = await authService.isUsernameTaken(username);

        if (isTaken) {
          usernameStatus.value = UsernameStatus.taken;
        } else {
          usernameStatus.value = UsernameStatus.available;
        }
      } catch (e) {
        usernameStatus.value = UsernameStatus.none;
      }
    }

    void handleNext() {
      if (usernameStatus.value != UsernameStatus.available) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen3(
            role: role,
            email: email,
            password: password,
            username: usernameController.text,
          ),
        ),
      );
    }

    Color getBorderColor() {
      switch (usernameStatus.value) {
        case UsernameStatus.taken:
          return ColorPalette.systemRed;
        case UsernameStatus.available:
          return ColorPalette.systemGreen;
        default:
          return ColorPalette.neutral200;
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800, size: 20),
          label: Text('Back', style: TextStylePalette.normalText),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacePalette.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick Your Username', style: TextStylePalette.header),
              SizedBox(height: SpacePalette.sm),
              Text(
                'This one\'s just for you and it has to be unique.\nThis can be changed later.',
                style: TextStylePalette.subText,
              ),
              SizedBox(height: SpacePalette.lg),

              // Username TextField
              SizedBox(
                height: 48,
                child: TextField(
                  controller: usernameController,
                  onChanged: checkUsername,
                  decoration: InputDecoration(
                    suffixIcon: _buildSuffixIcon(usernameStatus.value, usernameController),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                      borderSide: BorderSide(color: getBorderColor(), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                      borderSide: BorderSide(color: getBorderColor()),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                      borderSide: BorderSide(color: getBorderColor(), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SpacePalette.base,
                      vertical: SpacePalette.inner,
                    ),
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.sm),

              // ステータスメッセージ
              if (usernameStatus.value == UsernameStatus.checking)
                Text('Checking...', style: TextStylePalette.smSubText),
              if (usernameStatus.value == UsernameStatus.taken)
                Text(
                  'This username is already taken',
                  style: TextStylePalette.smSubText.copyWith(color: ColorPalette.systemRed),
                ),
              if (usernameStatus.value == UsernameStatus.available)
                Row(
                  children: [
                    Text(
                      'Username is available ',
                      style: TextStylePalette.smSubText.copyWith(color: ColorPalette.systemGreen),
                    ),
                    Text('🎉', style: TextStyle(fontSize: 12)),
                  ],
                ),

              SizedBox(height: SpacePalette.lg),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: usernameStatus.value == UsernameStatus.available ? handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: usernameStatus.value == UsernameStatus.available
                        ? ColorPalette.neutral800
                        : ColorPalette.neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: usernameStatus.value == UsernameStatus.available
                            ? TextStylePalette.buttonTextWhite
                            : TextStylePalette.buttonTextBlack.copyWith(color: ColorPalette.neutral400),
                      ),
                      SizedBox(width: SpacePalette.sm),
                      Icon(
                        Icons.arrow_forward,
                        color: usernameStatus.value == UsernameStatus.available
                            ? ColorPalette.neutral0
                            : ColorPalette.neutral400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(UsernameStatus status, TextEditingController controller) {
    switch (status) {
      case UsernameStatus.checking:
        return Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case UsernameStatus.taken:
        return IconButton(
          onPressed: () => controller.clear(),
          icon: Icon(Icons.close, color: ColorPalette.systemRed, size: 20),
        );
      case UsernameStatus.available:
        return Icon(Icons.check, color: ColorPalette.systemGreen, size: 20);
      default:
        return null;
    }
  }
}