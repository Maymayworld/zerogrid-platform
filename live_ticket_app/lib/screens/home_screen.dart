import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTickets = ref.watch(myTicketsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              const Text(
                'Myチケット',
                style: TextStyle(
                  fontSize: AppTheme.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: AppTheme.paddingSmall),

              // チケット件数表示
              Text(
                '${myTickets.length}件のチケット',
                style: TextStyle(
                  fontSize: AppTheme.textSizeNormal,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // チケットカードリスト
              Expanded(
                child: myTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppTheme.paddingDefault),
                            Text(
                              'チケットがありません',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: myTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = myTickets[index];
                          return TicketCard(
                            ticket: ticket,
                            onShowQrCode: () {
                              context.push('/qr-code/${ticket.id}');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}