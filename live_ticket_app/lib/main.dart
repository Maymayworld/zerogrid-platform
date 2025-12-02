import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'layouts/main_layout.dart';
import 'screens/qr_code_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 日本語ロケールの初期化
  await initializeDateFormatting('ja_JP');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Live Ticket App',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ルーター設定
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: '/qr-code/:ticketId',
      builder: (context, state) {
        final ticketId = state.pathParameters['ticketId']!;
        return QrCodeScreen(ticketId: ticketId);
      },
    ),
  ],
);