// lib/features/auth/presentation/providers/user_profile_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/user_profile.dart';
import 'auth_provider.dart';

// プロフィール状態
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(const UserProfileState());

  // プロフィール読み込み
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _authService.getCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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