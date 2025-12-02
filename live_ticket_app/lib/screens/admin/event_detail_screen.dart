import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event.dart';

class EventDetailScreen extends HookConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider);
    
    // イベントを検索
    Event? eventNullable;
    try {
      eventNullable = events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      eventNullable = null;
    }

    // イベントが見つからない場合
    if (eventNullable == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'イベントが見つかりません',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/admin/events'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                ),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    // nullチェック後、non-nullableな変数に代入
    final event = eventNullable;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ja_JP');
    final percentage = event.salesPercentage;

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
                    onPressed: () => context.go('/admin/events'),
                  ),
                  const Expanded(
                    child: Text(
                      'イベント詳細',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // TODO: 編集画面へ
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('編集機能は今後実装予定です')),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // イベント名
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(event.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // チケット販売状況カード
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cyanGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'チケット販売状況',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${event.soldTickets} / ${event.totalTickets} 枚',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // スタッフ認証パスコード
                    const Text(
                      'スタッフ認証パスコード',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // パスコード表示
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: event.staffPasscode.split('').map((digit) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: 48,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.accentCyan.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    digit,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentCyan,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // コピーボタン
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: event.staffPasscode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('パスコードをコピーしました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accentCyan,
                              side: const BorderSide(
                                color: AppTheme.accentCyan,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('コピー'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // セキュリティ設定
                    const Text(
                      'セキュリティ設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSecurityItem(
                            context: context,
                            ref: ref,
                            event: event,
                            icon: Icons.verified_user,
                            title: 'チケット署名',
                            subtitle: 'チケットの改ざんを防止',
                            value: event.security.ticketSignature,
                            onChanged: (value) {
                              ref.read(eventListProvider.notifier).updateSecurity(
                                eventId,
                                event.security.copyWith(ticketSignature: value),
                              );
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildSecurityItem(
                            context: context,
                            ref: ref,
                            event: event,
                            icon: Icons.lock,
                            title: 'BLE通信暗号化',
                            subtitle: '無線通信のセキュリティ強化',
                            value: event.security.bleEncryption,
                            onChanged: (value) {
                              ref.read(eventListProvider.notifier).updateSecurity(
                                eventId,
                                event.security.copyWith(bleEncryption: value),
                              );
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildSecurityItem(
                            context: context,
                            ref: ref,
                            event: event,
                            icon: Icons.key,
                            title: '公開鍵配布',
                            subtitle: '認証キーを自動配布',
                            value: event.security.publicKeyDistribution,
                            statusText: '完了',
                            onChanged: (value) {
                              ref.read(eventListProvider.notifier).updateSecurity(
                                eventId,
                                event.security.copyWith(publicKeyDistribution: value),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required BuildContext context,
    required WidgetRef ref,
    required Event event,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    String? statusText,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        icon,
        color: value ? Colors.green : AppTheme.accentCyan,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
      trailing: statusText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            )
          : Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
    );
  }
}