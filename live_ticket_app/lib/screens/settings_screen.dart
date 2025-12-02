import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
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
                  fontSize: AppTheme.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
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
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
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
                              title: const Text('ログアウト'),
                              content: const Text('ログアウトしますか？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('キャンセル'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // TODO: ログアウト処理
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
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
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
      leading: Icon(icon, color: AppTheme.textColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTheme.textSizeNormal,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
      onTap: onTap,
    );
  }
}