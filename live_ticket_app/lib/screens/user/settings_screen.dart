import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              const Text(
                '設定',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // 設定項目リスト
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingSection(
                      title: 'アカウント',
                      items: [
                        _buildSettingItem(
                          icon: Icons.person_outline,
                          title: 'プロフィール',
                          onTap: () {
                            // TODO: プロフィール画面へ遷移
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.email_outlined,
                          title: 'メールアドレス',
                          subtitle: 'user@example.com',
                          onTap: () {
                            // TODO: メールアドレス変更画面へ遷移
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    _buildSettingSection(
                      title: '通知',
                      items: [
                        _buildSettingItem(
                          icon: Icons.notifications_outlined,
                          title: 'プッシュ通知',
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // TODO: 通知設定の切り替え
                            },
                            activeColor: AppTheme.accentCyan,
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.email_outlined,
                          title: 'メール通知',
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {
                              // TODO: メール通知設定の切り替え
                            },
                            activeColor: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    _buildSettingSection(
                      title: 'その他',
                      items: [
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: 'ヘルプ',
                          onTap: () {
                            // TODO: ヘルプ画面へ遷移
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.description_outlined,
                          title: '利用規約',
                          onTap: () {
                            // TODO: 利用規約画面へ遷移
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'プライバシーポリシー',
                          onTap: () {
                            // TODO: プライバシーポリシー画面へ遷移
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: 'アプリバージョン',
                          subtitle: '1.0.0',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // ログアウトボタン
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'ログアウト',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          // TODO: ログアウト処理
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardBackground,
                              title: const Text(
                                'ログアウト',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'ログアウトしますか？',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'キャンセル',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // ロール選択画面に戻る
                                    context.go('/role-selection');
                                  },
                                  child: const Text(
                                    'ログアウト',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.paddingSmall,
            bottom: AppTheme.paddingSmall,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))
              : null),
      onTap: onTap,
    );
  }
}