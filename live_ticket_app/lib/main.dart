import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';

// Auth screens
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/user_login_screen.dart';
import 'screens/auth/admin_login_screen.dart';

// User screens
import 'layouts/main_layout.dart';
import 'screens/user/qr_code_screen.dart';

// Staff screens
import 'screens/staff/event_selection_screen.dart';
import 'screens/staff/passcode_input_screen.dart';
import 'screens/staff/qr_scanner_screen.dart';
import 'screens/staff/scan_result_screen.dart';

// Admin screens
import 'screens/admin/event_management_screen.dart';
import 'screens/admin/event_detail_screen.dart';

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
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ルーター設定
final _router = GoRouter(
  initialLocation: '/role-selection',
  routes: [
    // ============================================
    // 認証関連
    // ============================================
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/user-login',
      builder: (context, state) => const UserLoginScreen(),
    ),
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),

    // ============================================
    // ユーザー側
    // ============================================
    GoRoute(
      path: '/user',
      builder: (context, state) => const MainLayout(),
    ),
    GoRoute(
      path: '/user/qr-code/:ticketId',
      builder: (context, state) {
        final ticketId = state.pathParameters['ticketId'] ?? '';
        return QrCodeScreen(ticketId: ticketId);
      },
    ),

    // ============================================
    // スタッフ側
    // ============================================
    GoRoute(
      path: '/staff/events',
      builder: (context, state) => const StaffEventSelectionScreen(),
    ),
    GoRoute(
      path: '/staff/passcode/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId'] ?? '';
        return PasscodeInputScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/staff/scanner/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId'] ?? '';
        return QrScannerScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/staff/result/:success',
      builder: (context, state) {
        final success = state.pathParameters['success'] == 'true';
        final eventName = state.uri.queryParameters['eventName'];
        final seatType = state.uri.queryParameters['seatType'];
        final seat = state.uri.queryParameters['seat'];
        final eventId = state.uri.queryParameters['eventId'] ?? '';
        return ScanResultScreen(
          success: success,
          eventName: eventName,
          seatType: seatType,
          seat: seat,
          eventId: eventId,
        );
      },
    ),

    // ============================================
    // 管理者側
    // ============================================
    GoRoute(
      path: '/admin/events',
      builder: (context, state) => const EventManagementScreen(),
    ),
    GoRoute(
      path: '/admin/event/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId'] ?? '';
        return EventDetailScreen(eventId: eventId);
      },
    ),
  ],
  
  // エラーページ
  errorBuilder: (context, state) => Scaffold(
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
            'ページが見つかりません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/role-selection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
            ),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    ),
  ),
);