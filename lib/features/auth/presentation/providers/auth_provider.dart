// lib/features/auth/presentation/providers/auth_provider.dart
import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? get currentUser => _supabase.auth.currentUser;
  
  // セッション状態を監視するStream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // 現在のプロフィールを取得
  Future<UserProfile?> getCurrentProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromMap(response);
  }

  // メール＆パスワードでログイン
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // メール＆パスワードで新規登録
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // ユーザーネーム重複チェック
  Future<bool> isUsernameTaken(String username) async {
    final response = await _supabase
        .from('profiles')
        .select('username')
        .eq('username', username.toLowerCase())
        .maybeSingle();
    return response != null;
  }

  // プロフィール作成
  Future<void> createProfile({
    required String username,
    required String displayName,
    required String role,
    String? avatarUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('profiles').insert({
      'id': userId,
      'username': username.toLowerCase(),
      'display_name': displayName,
      'role': role,
      'avatar_url': avatarUrl,
    });
  }

  // プロフィール更新
  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  // アバター画像アップロード（Web対応）
  Future<String> uploadAvatarBytes(Uint8List imageBytes, String fileName) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final fileExt = fileName.split('.').last;
    final filePath = '$userId/avatar.$fileExt';

    await _supabase.storage.from('avatars').uploadBinary(
      filePath,
      imageBytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
    );

    final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
    return imageUrl;
  }

  // ログアウト
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // パスワードリセット
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});