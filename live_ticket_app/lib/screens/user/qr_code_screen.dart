import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket.dart';

class QrCodeScreen extends HookConsumerWidget {
  final String ticketId;

  const QrCodeScreen({
    super.key,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTickets = ref.watch(ticketListProvider);
    
    // チケットを検索（nullableで取得）
    Ticket? ticket;
    try {
      ticket = allTickets.firstWhere((t) => t.id == ticketId);
    } catch (e) {
      ticket = null;
    }

    // チケットが見つからない場合のエラー画面
    if (ticket == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'チケットが見つかりません',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'チケットID: $ticketId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('戻る'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('yyyy年M月d日（E）', 'ja_JP');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingDefault),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'チケットQR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // バランス調整
                ],
              ),
            ),

            // QRコード表示エリア
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // イベント名
                      Text(
                        ticket.eventName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 日時
                      Text(
                        dateFormat.format(ticket.eventDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // QRコード
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: ticket.toQrData(),
                              version: QrVersions.auto,
                              size: 280.0,
                              backgroundColor: Colors.transparent,
                            ),
                            // 中央のロゴマーク
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.confirmation_number,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // チケット情報
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('券種', ticket.seatType),
                            Divider(
                              height: 24,
                              color: Colors.grey[300],
                            ),
                            _buildInfoRow('座席', ticket.ticketNumber.split('-').last),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // 注意事項
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'スタッフにこの画面を提示してください',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}