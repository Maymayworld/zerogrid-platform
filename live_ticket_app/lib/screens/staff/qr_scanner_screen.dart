import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

class QrScannerScreen extends HookConsumerWidget {
  final String eventId;

  const QrScannerScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider);

    // イベントを検索
    final event = events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => events.first,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              color: AppTheme.darkBackground,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/staff/passcode/$eventId'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'QRコードをスキャン',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // スキャンエリア
            Expanded(
              child: Stack(
                children: [
                  // 黒背景
                  Container(
                    color: Colors.black,
                  ),

                  // スキャンフレーム
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // スキャンフレーム
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.accentCyan,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // 角の装飾（左上）
                              Positioned(
                                left: -3,
                                top: -3,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                      top: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 角の装飾（右上）
                              Positioned(
                                right: -3,
                                top: -3,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                      top: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 角の装飾（左下）
                              Positioned(
                                left: -3,
                                bottom: -3,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                      bottom: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 角の装飾（右下）
                              Positioned(
                                right: -3,
                                bottom: -3,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                      bottom: BorderSide(
                                        color: AppTheme.accentCyan,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // スキャンライン（アニメーション用）
                              Center(
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  size: 120,
                                  color: AppTheme.accentCyan.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 説明文
                        Text(
                          'QRコードをフレーム内に収めてください',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // デモ用ボタン（実際のカメラ実装時は削除）
            Container(
              color: AppTheme.darkBackground,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'デモモード: 実際のカメラ機能は今後実装予定',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(
                              '/staff/result/true?eventName=${Uri.encodeComponent(event.name)}&seatType=VIP&seat=A-12&eventId=$eventId',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle, size: 24),
                          label: const Text(
                            '入場OK (デモ)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(
                              '/staff/result/false?eventName=${Uri.encodeComponent(event.name)}&eventId=$eventId',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cancel, size: 24),
                          label: const Text(
                            '入場NG (デモ)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}