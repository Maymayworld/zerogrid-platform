// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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