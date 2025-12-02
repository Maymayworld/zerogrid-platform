import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';

class QrCodeScreen extends HookConsumerWidget {
  final String ticketId;

  const QrCodeScreen({
    super.key,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTickets = ref.watch(ticketListProvider);
    final ticket = allTickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => throw Exception('Ticket not found'),
    );

    final dateFormat = DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingDefault),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                    color: AppTheme.textColor,
                  ),
                  const Expanded(
                    child: Text(
                      'QRコード',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
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
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),

                      // 日時
                      Text(
                        dateFormat.format(ticket.eventDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.textSizeNormal,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),

                      // 会場
                      Text(
                        ticket.venue,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.textSizeNormal,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // QRコード
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: ticket.toQrData(),
                          version: QrVersions.auto,
                          size: 280.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // チケット情報カード
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.paddingDefault),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'チケット番号',
                              ticket.ticketNumber,
                            ),
                            const SizedBox(height: AppTheme.paddingSmall),
                            _buildInfoRow(
                              '席種',
                              ticket.seatType,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),

                      // 注意事項
                      Container(
                        padding: const EdgeInsets.all(AppTheme.paddingDefault),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '注意事項',
                                  style: TextStyle(
                                    fontSize: AppTheme.textSizeNormal,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• 入場時にこのQRコードをスタッフに提示してください\n• スクリーンショットでの入場はできません\n• 他人への譲渡・転売は禁止です',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.5,
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

            // 画面の明るさを最大にするボタン
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingDefault),
              child: SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 画面明るさを最大にする処理
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('画面の明るさを最大にしました'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.brightness_high),
                  label: const Text('画面の明るさを最大にする'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    ),
                    side: BorderSide(color: Colors.grey[400]!),
                    foregroundColor: AppTheme.textColor,
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
            fontSize: AppTheme.textSizeNormal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.textSizeNormal,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}