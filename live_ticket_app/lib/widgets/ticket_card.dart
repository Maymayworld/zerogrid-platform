import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onShowQrCode;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onShowQrCode,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP');

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingDefault),
      decoration: BoxDecoration(
        gradient: AppTheme.blackGradient,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // イベント画像
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.buttonRadius),
              topRight: Radius.circular(AppTheme.buttonRadius),
            ),
            child: Container(
              width: double.infinity,
              height: 160,
              color: Colors.grey[800],
              child: ticket.eventImage.isNotEmpty
                  ? Image.network(
                      ticket.eventImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 48,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.confirmation_number,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
            ),
          ),

          // チケット情報
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // イベント名
                Text(
                  ticket.eventName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSmall),

                // 日時
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(ticket.eventDate),
                      style: const TextStyle(
                        fontSize: AppTheme.textSizeNormal,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 会場
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket.venue,
                        style: const TextStyle(
                          fontSize: AppTheme.textSizeNormal,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingDefault),

                // QRコード表示ボタン
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onShowQrCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: const Text(
                      'QRコードを表示',
                      style: TextStyle(
                        fontSize: AppTheme.textSizeNormal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}