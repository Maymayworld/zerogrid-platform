# ZeroGrid OAuth認証セットアップガイド

## 目的

ZeroGridの「自動投稿機能」を実現するため、クリエイターのSNSアカウント（Instagram, TikTok, YouTube）と連携する必要がある。

**ユーザーフロー:**
1. クリエイターがZeroGridにログイン
2. 「アカウント連携」からSNSを選択
3. OAuth認証でSNS側にログイン・許可
4. ZeroGridがアクセストークン取得 → 自動投稿が可能に

**必要な設定:**
- 各プラットフォームでOAuthアプリを作成
- Client ID / Client Secret を取得
- Supabase Edge Functionに設定

---

## 1. Google Cloud Console（YouTube用）⏱️ 15-20分

### 1.1 プロジェクト作成（既存あればスキップ）
1. https://console.cloud.google.com/ にアクセス
2. 左上のプロジェクト選択 → 「新しいプロジェクト」
3. プロジェクト名: `ZeroGrid` → 作成

### 1.2 YouTube Data API 有効化
1. 左メニュー「APIとサービス」→「ライブラリ」
2. 「YouTube Data API v3」を検索 → 有効にする

### 1.3 OAuth同意画面の設定
1. 左メニュー「OAuth同意画面」
2. User Type: 「外部」→ 作成
3. 入力項目:
   - アプリ名: `ZeroGrid`
   - ユーザーサポートメール: `kotamu1020@gmail.com`（または会社メール）
   - デベロッパー連絡先: 同上
4. 「保存して次へ」

### 1.4 スコープ設定
1. 「スコープを追加または削除」をクリック
2. 以下を追加:
   - `https://www.googleapis.com/auth/youtube.upload`
   - `https://www.googleapis.com/auth/youtube.readonly`
3. 「保存して次へ」

### 1.5 テストユーザー追加
1. 「ADD USERS」→ テスト用Googleアカウントを追加
2. 「保存して次へ」→ 「ダッシュボードに戻る」

### 1.6 OAuth 2.0 クライアントID作成
1. 左メニュー「認証情報」→「認証情報を作成」→「OAuthクライアントID」
2. アプリケーションの種類: 「ウェブアプリケーション」
3. 名前: `ZeroGrid Web`
4. 承認済みリダイレクトURI:
   ```
   https://<your-supabase-project>.supabase.co/functions/v1/oauth-callback
   http://localhost:3000/auth/callback (開発用)
   ```
5. 「作成」

### 1.7 認証情報を保存
- **Client ID**: `xxxxxxxxxxxx.apps.googleusercontent.com`
- **Client Secret**: `GOCSPX-xxxxxxxxxxxx`

⚠️ これらは安全な場所に保存！

---

## 2. Supabase Edge Function設定 ⏱️ 10-15分

### 2.1 Supabase Dashboardにアクセス
1. https://supabase.com/dashboard にログイン
2. ZeroGridプロジェクトを選択

### 2.2 シークレット設定
1. 左メニュー「Edge Functions」→「Secrets」
2. 以下を追加:

| Name | Value |
|------|-------|
| `GOOGLE_CLIENT_ID` | (上で取得したClient ID) |
| `GOOGLE_CLIENT_SECRET` | (上で取得したClient Secret) |
| `INSTAGRAM_CLIENT_ID` | (後で追加) |
| `INSTAGRAM_CLIENT_SECRET` | (後で追加) |
| `TIKTOK_CLIENT_KEY` | (後で追加) |
| `TIKTOK_CLIENT_SECRET` | (後で追加) |

### 2.3 Edge Function作成（必要な場合）
```bash
supabase functions new oauth-callback
```

---

## 3. Meta Developer Portal（Instagram用）⏱️ 30-45分

### 3.1 アカウント準備
- Facebookアカウントが必要
- ビジネスアカウントまたはクリエイターアカウント推奨

### 3.2 アプリ作成
1. https://developers.facebook.com/ にアクセス
2. 右上「マイアプリ」→「アプリを作成」
3. ユースケース: 「その他」→「次へ」
4. アプリタイプ: 「ビジネス」→「次へ」
5. アプリ名: `ZeroGrid`
6. アプリの連絡先メールアドレス: 入力 → 「アプリを作成」

### 3.3 Instagram Basic Display 追加
1. ダッシュボードで「製品を追加」
2. 「Instagram Basic Display」→「設定」
3. 「新しいアプリを作成」

### 3.4 Instagram設定
1. 「Instagram Basic Display」→「基本表示」
2. 入力項目:
   - 有効なOAuthリダイレクトURI:
     ```
     https://<your-supabase-project>.supabase.co/functions/v1/oauth-callback
     ```
   - Deauthorize Callback URL: (同上)
   - Data Deletion Request URL: (同上)
3. 「変更を保存」

### 3.5 アプリレビュー（本番用）
⚠️ テスト段階では不要、本番公開時に必要

1. 「アプリレビュー」→「リクエスト」
2. 必要な権限:
   - `instagram_basic`
   - `instagram_content_publish`（投稿用）
3. 審査提出 → 数日〜数週間待ち

### 3.6 認証情報を保存
1. 「設定」→「ベーシック」
2. **アプリID** = Client ID
3. **app secret** = Client Secret（「表示」をクリック）

---

## 4. TikTok Developer Portal ⏱️ 30-45分

### 4.1 開発者アカウント作成
1. https://developers.tiktok.com/ にアクセス
2. 「Log in」→ TikTokアカウントでログイン
3. 開発者登録がまだなら完了させる

### 4.2 アプリ作成
1. 「Manage apps」→「Create an app」
2. App name: `ZeroGrid`
3. Description: `Video creator marketplace platform`
4. App icon: アップロード
5. Category: `Social Media`
6. 「Save」

### 4.3 製品追加
1. 「Add products」→「Login Kit」を追加
2. 「Add products」→「Content Posting API」を追加（投稿用）

### 4.4 Login Kit設定
1. 「Login Kit」→「Configure」
2. 入力項目:
   - Redirect URI:
     ```
     https://<your-supabase-project>.supabase.co/functions/v1/oauth-callback
     ```
   - Terms of Service URL: `https://zerogrid.jp/terms`
   - Privacy Policy URL: `https://zerogrid.jp/privacy`
3. 「Save」

### 4.5 スコープ設定
1. 必要なスコープ:
   - `user.info.basic`
   - `video.list`
   - `video.upload`（Content Posting API）
2. 各スコープで「Apply」

### 4.6 審査提出
⚠️ TikTokは審査必須

1. 「Submit for review」
2. 審査内容:
   - アプリの説明
   - 使用目的
   - スクリーンショット
3. 審査通過 → 本番キー発行

### 4.7 認証情報を保存
1. 「App details」
2. **Client Key** = Client ID
3. **Client Secret** = 「Show」をクリック

---

## 認証情報まとめテンプレート

```
# ZeroGrid OAuth Credentials
# ⚠️ このファイルは安全な場所に保管、Gitにコミットしない

## Google (YouTube)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

## Meta (Instagram)
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=

## TikTok
TIKTOK_CLIENT_KEY=
TIKTOK_CLIENT_SECRET=

## Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

---

## 次のステップ

1. 上記すべて完了したら、Supabaseにシークレット設定
2. Edge Function実装（oauth-callback）
3. Flutter側でOAuthフロー実装
4. テスト → 本番申請

---

## トラブルシューティング

### 「redirect_uri_mismatch」エラー
→ リダイレクトURIが完全一致してない。末尾スラッシュ、http/https確認

### 「invalid_client」エラー
→ Client IDまたはSecretが間違ってる

### Instagram「アプリが審査中」
→ テストユーザーを追加すればテスト可能（Roles → Testers）

### TikTok審査落ち
→ 説明文・スクリーンショットを詳細に。英語で書く

---

*作成日: 2026-02-10*
*作成者: Kota AI*
