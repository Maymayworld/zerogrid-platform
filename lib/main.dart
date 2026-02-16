// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/pages/select_role_screen.dart';
import 'app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: 'https://gfzpegwatwyzbbbkcuvu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmenBlZ3dhdHd5emJiYmtjdXZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNzk0MjQsImV4cCI6MjA3OTk1NTQyNH0.qlORhEgzNvH2kPxQznyaGNvtXJjjpDCpMdZfSvZr6E8',
  );

  // Stripe initialization (test mode)
  Stripe.publishableKey = 'pk_test_51SiYNHKD2iO5N0nyRN7KmBGnRGLemlhUTafKUvOlC265zFe2ZfqzLWu5qFcXZ8FyfIZOOA4fNOZ4hEUzMtWcO3og00I4A02fXk';
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Stripe init error: $e');
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Grid',
      theme: AppTheme.lightTheme,
      home: AppWrapper(),  // ここでセッション確認
    );
  }
}