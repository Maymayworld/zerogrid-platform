// lib/app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/select_role_screen.dart';
import 'features/auth/presentation/providers/user_profile_provider.dart';
import 'features/auth/data/models/user_role.dart';
import 'shared/theme/main_layout.dart';
import 'shared/theme/app_theme.dart';

class AppWrapper extends HookConsumerWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 初回ロード中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: ColorPalette.neutral800),
            ),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // ログイン済み → プロフィール取得してメイン画面へ
          return _LoggedInWrapper();
        } else {
          // 未ログイン → ロール選択画面へ
          return SelectRoleScreen();
        }
      },
    );
  }
}

class _LoggedInWrapper extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    // 初回ロード
    if (profileState.profile == null && !profileState.isLoading) {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).loadProfile();
      });
    }

    // ローディング中
    if (profileState.isLoading || profileState.profile == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // ロールに基づいてメイン画面表示
    final role = profileState.profile!.role == 'organizer'
        ? UserRole.organizer
        : UserRole.creator;

    return MainLayout(userRole: role);
  }
}