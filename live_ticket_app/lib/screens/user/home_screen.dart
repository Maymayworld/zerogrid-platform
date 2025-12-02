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
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // TODO: 戻る処理
                        },
                      ),
                      const SizedBox(width: AppTheme.paddingSmall),
                      const Text(
                        'マイチケット',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      // TODO: 更新処理
                    },
                  ),
                ],
              ),
            ),

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
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: AppTheme.paddingDefault),
                          Text(
                            'チケットがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingDefault,
                      ),
                      itemCount: myTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = myTickets[index];
                        return TicketCard(
                          ticket: ticket,
                          onShowQrCode: () {
                            context.push('/user/qr-code/${ticket.id}');
                          },
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