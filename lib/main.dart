// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/theme/app_theme.dart';
import 'shared/presentation/providers/locale_provider.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ステータスバーの色を黒に設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: ColorPalette.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://gfzpegwatwyzbbbkcuvu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmenBlZ3dhdHd5emJiYmtjdXZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNzk0MjQsImV4cCI6MjA3OTk1NTQyNH0.qlORhEgzNvH2kPxQznyaGNvtXJjjpDCpMdZfSvZr6E8',
  );

  // Handle Stripe Checkout return URL (web only)
  if (kIsWeb) {
    final uri = Uri.base;
    final checkoutSessionId = uri.queryParameters['checkout_session_id'];
    final setupSuccess = uri.queryParameters['setup_success'];

    if (checkoutSessionId != null || setupSuccess != null) {
      final prefs = await SharedPreferences.getInstance();
      if (checkoutSessionId != null) {
        await prefs.setString('pending_checkout_session_id', checkoutSessionId);
      }
      if (setupSuccess == 'true') {
        await prefs.setBool('payment_method_added', true);
      }
    }
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Zero Grid',
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashScreen(nextScreen: AppWrapper()),
    );
  }
}
