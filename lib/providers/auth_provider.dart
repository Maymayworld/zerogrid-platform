// lib/providers/auth_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// テスト用認証サービス（Supabase不要）
class AuthService {
  // テスト用ログイン
  Future<bool> testLogin({
    required String email,
    required String password,
  }) async {
    // 実際のAPIコールをシミュレート
    await Future.delayed(Duration(milliseconds: 500));
    
    final testEmail = dotenv.env['TEST_EMAIL'] ?? '';
    final testPassword = dotenv.env['TEST_PASSWORD'] ?? '';
    
    if (email == testEmail && password == testPassword) {
      return true;
    }
    return false;
  }

  // 後でSupabaseを使う場合のメソッド（今はコメントアウト）
  /*
  final SupabaseClient _supabase;
  
  AuthService(this._supabase);

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
  */
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});