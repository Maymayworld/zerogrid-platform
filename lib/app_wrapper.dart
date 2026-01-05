// lib/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/select_role_screen.dart';
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

    // 初回ロード（まだ何も始まってない場合）
    if (profileState.profile == null && !profileState.isLoading && profileState.error == null) {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).loadProfile();
      });
      
      // ローディング表示
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // ローディング中
    if (profileState.isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // エラー or プロフィールがない → ログアウトして再登録
    if (profileState.error != null || profileState.profile == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
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

    // 成功 → メイン画面
    final role = profileState.profile!.role == 'organizer'
        ? UserRole.organizer
        : UserRole.creator;

    return MainLayout(userRole: role);
  }
}