// lib/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/select_role_screen.dart';
import 'features/auth/presentation/pages/signup_screen2.dart';
import 'features/auth/presentation/providers/user_profile_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/models/user_role.dart';
import 'shared/theme/main_layout.dart';
import 'shared/theme/app_theme.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session == null) {
      return SelectRoleScreen();
    }

    return _LoggedInWrapper();
  }
}

class _LoggedInWrapper extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    // 初回ロード（まだロードしていない場合）
    if (!profileState.hasLoaded && !profileState.isLoading) {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).loadProfile();
      });

      // ローディング表示
      return Scaffold(
        backgroundColor: ColorPalette.white,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // ローディング中
    if (profileState.isLoading) {
      return Scaffold(
        backgroundColor: ColorPalette.white,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // エラー or プロフィールがない → OAuthユーザーならプロフィール設定へ、それ以外はログアウト
    if (profileState.error != null || profileState.profile == null) {
      return _NoProfileScreen();
    }

    // 成功 → メイン画面
    final role = profileState.profile!.role == 'organizer'
        ? UserRole.organizer
        : UserRole.creator;

    return MainLayout(userRole: role);
  }
}

/// プロフィール未作成画面（OAuth後の新規ユーザー対応）
class _NoProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NoProfileScreen> createState() => _NoProfileScreenState();
}

class _NoProfileScreenState extends ConsumerState<_NoProfileScreen> {
  @override
  void initState() {
    super.initState();
    // SharedPreferencesからpending_oauth_roleを確認
    _checkOAuthRole();
  }

  Future<void> _checkOAuthRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString('pending_oauth_role');
    if (roleName != null && mounted) {
      await prefs.remove('pending_oauth_role');
      final role = roleName == 'organizer' ? UserRole.organizer : UserRole.creator;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SignUpScreen2(
            role: role,
            email: '',
            password: '',
            isOAuth: true,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle_outlined, size: 64, color: ColorPalette.neutral400),
              SizedBox(height: 16),
              Text(
                'Profile not found',
                style: TextStylePalette.smallHeader,
              ),
              SizedBox(height: 8),
              Text(
                'Please sign out and register again.',
                style: TextStylePalette.subText,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    ref.read(userProfileProvider.notifier).clear();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => SelectRoleScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Sign Out', style: TextStylePalette.buttonTextWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}