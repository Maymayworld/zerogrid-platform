// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/select_role/select_role_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み
  await dotenv.load(fileName: ".env");
  
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
      title: 'ZeroGrid',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: SelectRoleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}