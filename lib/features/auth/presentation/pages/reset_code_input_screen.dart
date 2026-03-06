import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'package:zero_grid/shared/widgets/duolingo_form_components.dart';
import 'reset_password_screen.dart';

class ResetCodeInputScreen extends HookConsumerWidget {
  final String email;
  final UserRole role;

  const ResetCodeInputScreen({
    Key? key,
    required this.email,
    required this.role,
  }) : super(key: key);

  bool _isValidCode(String value) {
    if (value.length != 6) return false;
    return int.tryParse(value) != null;
  }

  String? _normalizeDigit(String value) {
    if (value.isEmpty) return null;
    final last = value.characters.last;
    final code = last.codeUnitAt(0);

    // Full-width digit '０'..'９' -> ASCII '0'..'9'
    if (code >= 0xFF10 && code <= 0xFF19) {
      return String.fromCharCode(code - 0xFEE0);
    }

    if (RegExp(r'^[0-9]$').hasMatch(last)) {
      return last;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final isFormValid = useState(false);
    final codeValue = useState('');
    final digitControllers = useMemoized(
      () => List.generate(6, (_) => TextEditingController()),
      [],
    );
    final digitFocusNodes = useMemoized(
      () => List.generate(6, (_) => FocusNode()),
      [],
    );

    useEffect(() {
      void updateCode() {
        final current = digitControllers.map((c) => c.text).join();
        codeValue.value = current;
        isFormValid.value = _isValidCode(current);
      }

      for (final controller in digitControllers) {
        controller.addListener(updateCode);
      }

      return () {
        for (final controller in digitControllers) {
          controller.removeListener(updateCode);
          controller.dispose();
        }
        for (final node in digitFocusNodes) {
          node.dispose();
        }
      };
    }, [digitControllers, digitFocusNodes]);

    void moveFocusTo(int index) {
      if (index < 0 || index >= digitFocusNodes.length) return;
      FocusScope.of(context).requestFocus(digitFocusNodes[index]);
    }

    Future<void> handleVerifyCode() async {
      final code = codeValue.value;
      if (!_isValidCode(code)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.enterResetCodeInstructions),
            backgroundColor: ColorPalette.critical500,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        final authService = ref.read(authServiceProvider);
        final resetToken = await authService.verifyResetCode(
          email: email,
          code: code,
        );

        if (!context.mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ResetPasswordScreen(
              resetToken: resetToken,
              onCompleted: () {
                Navigator.of(ctx).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToVerifyCode(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleResendCode() async {
      isLoading.value = true;
      try {
        final authService = ref.read(authServiceProvider);
        await authService.requestPasswordReset(email);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.newCodeSent),
              backgroundColor: ColorPalette.neutral800,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToResendCode(e.toString())),
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
        title: Text(AppLocalizations.of(context)!.forgotPassword, style: TextStylePalette.smallHeader),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
            final code = codeValue.value;

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
                    Text(AppLocalizations.of(context)!.enterCode, style: TextStylePalette.header),
                    const SizedBox(height: SpacePalette.sm),
                    Text(
                      AppLocalizations.of(context)!.resetCodeSentDescription(email),
                      style: TextStylePalette.subText,
                    ),
                    const SizedBox(height: SpacePalette.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final isActive =
                            index == code.length && code.length < 6;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: index == 0 || index == 5
                                  ? 2
                                  : SpacePalette.xs,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: Focus(
                                    onKeyEvent: (node, event) {
                                      if (event is KeyDownEvent &&
                                          event.logicalKey ==
                                              LogicalKeyboardKey.backspace &&
                                          digitControllers[index].text.isEmpty &&
                                          index > 0) {
                                        digitControllers[index - 1].clear();
                                        moveFocusTo(index - 1);
                                        return KeyEventResult.handled;
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                    child: TextField(
                                      controller: digitControllers[index],
                                      focusNode: digitFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      style: TextStylePalette.header,
                                      keyboardType: TextInputType.number,
                                      textInputAction: index == 5
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        counterText: '',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        final digit = _normalizeDigit(value);
                                        if (digit != null) {
                                          digitControllers[index]
                                            ..text = digit
                                            ..selection =
                                                const TextSelection.collapsed(
                                                  offset: 1,
                                                );
                                          if (index < 5) {
                                            moveFocusTo(index + 1);
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }
                                        } else if (value.isEmpty && index > 0) {
                                          // カレントが空になった時に前の桁を削除して戻る
                                          digitControllers[index - 1].clear();
                                          moveFocusTo(index - 1);
                                        } else {
                                          digitControllers[index].clear();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 2,
                                  color: isActive
                                      ? ColorPalette.neutral800
                                      : ColorPalette.neutral300,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: SpacePalette.lg),
                    DuolingoButton(
                      onPressed: handleVerifyCode,
                      isEnabled: isFormValid.value,
                      isLoading: isLoading.value,
                      text: AppLocalizations.of(context)!.verifyCode,
                    ),
                    const SizedBox(height: SpacePalette.base),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: isLoading.value ? null : handleResendCode,
                        child: Text(
                          AppLocalizations.of(context)!.resendCode,
                          style: TextStylePalette.guideUnderline,
                        ),
                      ),
                    ),
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
