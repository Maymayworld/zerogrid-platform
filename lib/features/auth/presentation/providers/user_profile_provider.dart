// lib/features/auth/presentation/providers/user_profile_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/user_profile.dart';
import 'auth_provider.dart';

// プロフィール状態
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool hasLoaded; // ロード済みかどうか（nullでも完了した場合true）
  final String? error;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(const UserProfileState());

  // プロフィール読み込み
  Future<void> loadProfile() async {
    print('[loadProfile] start');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('[loadProfile] calling getCurrentProfile');
      final profile = await _authService.getCurrentProfile();
      print('[loadProfile] profile = $profile');
      state = state.copyWith(profile: profile, isLoading: false, hasLoaded: true);
      print('[loadProfile] done');
    } catch (e) {
      print('[loadProfile] error = $e');
      state = state.copyWith(isLoading: false, hasLoaded: true, error: e.toString());
    }
  }

  // バックグラウンドでプロフィールを再取得（ローディング表示なし）
  Future<void> refreshProfile() async {
    try {
      final profile = await _authService.getCurrentProfile();
      if (profile != null) {
        state = state.copyWith(profile: profile, hasLoaded: true);
      }
    } catch (_) {}
  }

  // プロフィール更新
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    try {
      await _authService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      // 更新後に再読み込み
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ログアウト時にクリア
  void clear() {
    state = const UserProfileState();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserProfileNotifier(authService);
});