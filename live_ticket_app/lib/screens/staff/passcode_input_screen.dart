import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

class PasscodeInputScreen extends HookConsumerWidget {
  final String eventId;

  const PasscodeInputScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider);
    final passcode = useState('');
    final isError = useState(false);

    // イベントを検索
    final event = events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => events.first,
    );

    void onNumberTap(String number) {
      if (passcode.value.length < 5) {
        passcode.value += number;
        isError.value = false;

        // 5桁入力完了時に自動チェック
        if (passcode.value.length == 5) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (passcode.value == event.staffPasscode) {
              context.go('/staff/scanner/$eventId');
            } else {
              isError.value = true;
              Future.delayed(const Duration(seconds: 1), () {
                passcode.value = '';
                isError.value = false;
              });
            }
          });
        }
      }
    }

    void onBackspace() {
      if (passcode.value.isNotEmpty) {
        passcode.value = passcode.value.substring(0, passcode.value.length - 1);
        isError.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/staff/events'),
                  ),
                  const Expanded(
                    child: Text(
                      'パスコード入力',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // イベント名
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // パスコード表示（5桁）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final hasValue = index < passcode.value.length;
                      final showError = isError.value && index < passcode.value.length;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 56,
                        height: 64,
                        decoration: BoxDecoration(
                          color: showError
                              ? Colors.red.withOpacity(0.2)
                              : hasValue
                                  ? AppTheme.accentCyan.withOpacity(0.2)
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: showError
                                ? Colors.red
                                : hasValue
                                    ? AppTheme.accentCyan
                                    : Colors.grey[700]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: hasValue
                              ? Text(
                                  passcode.value[index],
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: showError ? Colors.red : AppTheme.accentCyan,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // エラーメッセージ
                  SizedBox(
                    height: 24,
                    child: isError.value
                        ? const Text(
                            'パスコードが正しくありません',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 40),

                  // テンキー
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // 1行目: 1, 2, 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('1', onNumberTap),
                            _buildNumberButton('2', onNumberTap),
                            _buildNumberButton('3', onNumberTap),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 2行目: 4, 5, 6
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('4', onNumberTap),
                            _buildNumberButton('5', onNumberTap),
                            _buildNumberButton('6', onNumberTap),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3行目: 7, 8, 9
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('7', onNumberTap),
                            _buildNumberButton('8', onNumberTap),
                            _buildNumberButton('9', onNumberTap),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 4行目: 空白, 0, バックスペース
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 80, height: 64), // 空白
                            _buildNumberButton('0', onNumberTap),
                            _buildBackspaceButton(onBackspace),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number, Function(String) onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(number),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}