import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

class StaffEventSelectionScreen extends HookConsumerWidget {
  const StaffEventSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja_JP');

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
                    onPressed: () => context.go('/role-selection'),
                  ),
                  const Expanded(
                    child: Text(
                      'イベント選択',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      context.go('/role-selection');
                    },
                  ),
                ],
              ),
            ),

            // サブタイトル
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'スキャンするイベントを選択してください',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // イベント一覧
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'イベントがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final isActive = event.status == '開催中';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.go('/staff/passcode/${event.id}');
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ステータスバッジ
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          '開催中',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),

                                    // イベント名
                                    Text(
                                      event.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // 日時
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
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
                                    const SizedBox(height: 8),

                                    // 会場
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          event.venue,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 矢印アイコン
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentCyan.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: AppTheme.accentCyan,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}