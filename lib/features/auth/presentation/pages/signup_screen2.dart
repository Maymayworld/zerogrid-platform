// lib/features/auth/presentation/pages/signup_screen2.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'signup_screen3.dart';

enum UsernameStatus { none, checking, taken, available }

class SignUpScreen2 extends HookConsumerWidget {
  final UserRole role;
  final String email;
  final String password;
  final bool isOAuth;

  const SignUpScreen2({
    Key? key,
    required this.role,
    required this.email,
    required this.password,
    this.isOAuth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final usernameStatus = useState(UsernameStatus.none);

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
            isOAuth: isOAuth,
          ),
        ),
      );
    }

    final bool isAvailable = usernameStatus.value == UsernameStatus.available;

    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              // プログレスバー（ステップ 1/3）
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 / 3,
                  minHeight: 4,
                  backgroundColor: ColorPalette.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorPalette.neutral800,
                  ),
                ),
              ),
              SizedBox(height: SpacePalette.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(flex: 2),

                    // タイトル（中央寄せ）
                    Text(AppLocalizations.of(context)!.pickYourUsername, style: TextStylePalette.header),
                    SizedBox(height: SpacePalette.lg),

                    // Username TextField（@プレフィックス付き）
                    SizedBox(
                      height: ButtonSizePalette.button,
                      child: TextField(
                        controller: usernameController,
                        onChanged: checkUsername,
                        textAlign: TextAlign.center,
                        style: TextStylePalette.header,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: SpacePalette.base),
                            child: Text(
                              '@',
                              style: TextStylePalette.header.copyWith(
                                color: ColorPalette.neutral400,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: SpacePalette.base,
                            vertical: SpacePalette.inner,
                          ),
                          suffixIcon: _buildSuffixIcon(
                            usernameStatus.value,
                            usernameController,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),

                    // ステータスメッセージ
                    if (usernameStatus.value == UsernameStatus.checking)
                      Text(AppLocalizations.of(context)!.checking, style: TextStylePalette.smSubText),
                    if (usernameStatus.value == UsernameStatus.taken)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.x,
                            size: 14,
                            color: ColorPalette.critical500,
                          ),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            AppLocalizations.of(context)!.usernameTaken,
                            style: TextStylePalette.smSubText.copyWith(
                              color: ColorPalette.critical500,
                            ),
                          ),
                        ],
                      ),
                    if (usernameStatus.value == UsernameStatus.available)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.check,
                            size: 14,
                            color: ColorPalette.positive500,
                          ),
                          SizedBox(width: SpacePalette.xs),
                          Text(
                            AppLocalizations.of(context)!.usernameAvailable,
                            style: TextStylePalette.smSubText.copyWith(
                              color: ColorPalette.positive500,
                            ),
                          ),
                          Text('\u{1F389}', style: TextStyle(fontSize: 12)),
                        ],
                      ),

                    Spacer(flex: 3),
                  ],
                ),
              ),

              // Next Button（Duolingoスタイル）
              DuolingoButton(
                onPressed: handleNext,
                isEnabled: isAvailable,
                text: AppLocalizations.of(context)!.next,
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(
    UsernameStatus status,
    TextEditingController controller,
  ) {
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
          icon: Icon(PhosphorIconsRegular.x, color: ColorPalette.critical500, size: 20),
        );
      case UsernameStatus.available:
        return Icon(PhosphorIconsRegular.check, color: ColorPalette.positive500, size: 20);
      default:
        return null;
    }
  }
}
