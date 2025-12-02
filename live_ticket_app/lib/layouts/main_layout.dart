import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/app_theme.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/ticket_list_screen.dart';
import '../screens/user/settings_screen.dart';

// 現在のタブインデックスを管理するプロバイダー
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends HookConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    // 各タブの画面
    final screens = [
      const HomeScreen(),
      const TicketListScreen(isFromBottomNav: true),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(currentTabIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardBackground,
          selectedItemColor: AppTheme.accentCyan,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: '購入済み',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'チケット一覧',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}