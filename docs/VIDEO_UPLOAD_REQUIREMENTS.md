# 動画アップロード & 自動投稿 要件定義書

メモ
最新動画の切り抜きのみ


## 📌 概要

クリエイターが動画ファイルをZeroGridにアップロードし、Feed表示 & 各SNSへの自動投稿 & 視聴回数集計を実現する。

---

## 🎯 ゴール

```
クリエイター
    ↓ 動画ファイルをアップロード（元サイズ）
ZeroGrid
    ↓ 一時保存（元サイズ）
    ↓ 各SNSに元サイズで自動投稿（高画質維持）
    ↓ 投稿URL取得 & 保存
    ↓ 元動画を削除
    ↓ 圧縮版を保存（Feed表示用のみ）
    ↓ 視聴回数を定期取得
```

**ポイント:**
- SNSには元サイズ（高画質）で投稿
- ストレージには圧縮版のみ保存（コスト削減）
- 元動画は投稿完了後に削除

---

## 📊 現状

**実装済み:**
- URL添付式でYouTube動画表示（Feed: `youtube_player_iframe`）
- YouTube OAuth接続
- 視聴回数取得 Edge Function (`fetch-view-counts`)

**未実装:**
- 動画ファイルアップロード
- 動画圧縮 & ストレージ保存
- SNSへの自動投稿
- TikTok/Instagram OAuth（Edge Functionあり、未審査）

---

## 🔧 実装内容

### Phase 1: 動画アップロード & Feed表示

#### 1.1 DBスキーマ変更

**`submission_requests` テーブルに追加:**
```sql
ALTER TABLE submission_requests ADD COLUMN IF NOT EXISTS
  local_video_url TEXT,           -- ZeroGrid内の動画URL（Feed表示用）
  video_file_size INTEGER,        -- ファイルサイズ（bytes）
  video_duration INTEGER,         -- 動画長さ（秒）
  upload_status TEXT DEFAULT 'pending', -- pending/uploading/completed/failed
  platform_post_id TEXT,          -- 各SNSでの投稿ID
  platform_post_url TEXT;         -- 各SNSでの投稿URL（視聴回数取得用）
```

#### 1.2 動画アップロードUI

**ファイル:** `lib/features/creator/campaign/presentation/pages/upload_screen.dart`

**変更内容:**
- URL入力フィールド → ファイル選択ボタン
- `image_picker` or `file_picker` で動画選択
- アップロード進捗表示
- サムネイル自動生成 & プレビュー

```dart
// 必要なパッケージ
dependencies:
  file_picker: ^6.0.0
  video_compress: ^3.1.0  # 圧縮用
```

#### 1.3 動画アップロード & 処理

**新規 Edge Function:** `supabase/functions/process-video-upload/index.ts`

**処理フロー:**
1. クライアントから動画を受信（元サイズ）
2. 一時ストレージに保存
3. 各SNSに元サイズで投稿（Phase 2で実装）
4. 投稿完了後、FFmpeg で圧縮版を作成
5. 圧縮版を本ストレージに保存
6. 元動画を削除
7. `local_video_url`（圧縮版）を返却

**圧縮設定（Feed表示用）:**
```
解像度: 720p (1280x720)
コーデック: H.264
ビットレート: 2Mbps
フォーマット: MP4
目標サイズ: 元の 10-15%
```

**ストレージ構成:**
```
/temp/          # 一時保存（元サイズ、投稿後削除）
/videos/        # 本保存（圧縮版、Feed表示用）
/thumbnails/    # サムネイル
```

#### 1.4 Feed表示改修

**ファイル:** `lib/features/creator/feed/presentation/pages/feed_screen.dart`

**変更内容:**
- `youtube_player_iframe` → `video_player` に変更
- `local_video_url` がある場合はそれを再生
- ない場合（従来のURL入力分）は YouTube Player にフォールバック

```dart
// 必要なパッケージ
dependencies:
  video_player: ^2.8.0
  chewie: ^1.7.0  # 再生UIコントロール用（オプション）
```

---

### Phase 2: SNS自動投稿

#### 2.1 YouTube 自動投稿（優先実装）

**新規 Edge Function:** `supabase/functions/youtube-upload/index.ts`

**処理フロー:**
1. ユーザーの `access_token` を `social_connections` から取得
2. YouTube Data API v3 `videos.insert` で動画アップロード
3. レスポンスから `video_id` 取得
4. `platform_post_url` = `https://youtube.com/watch?v={video_id}` を保存

**必要なスコープ:**
```
https://www.googleapis.com/auth/youtube.upload
```

**OAuth更新:**
- `lib/features/auth/data/services/oauth_service.dart` の `connectYouTube()` にスコープ追加

#### 2.2 TikTok 自動投稿（審査通過後）

**新規 Edge Function:** `supabase/functions/tiktok-upload/index.ts`

**API:** TikTok Direct Post API

**処理フロー:**
1. `access_token` 取得
2. 動画を TikTok にアップロード
3. `publish_id` 取得
4. `platform_post_url` = `https://tiktok.com/@{username}/video/{publish_id}` を保存

**必要条件:**
- TikTok Developer Portal で Direct Post API 審査通過

#### 2.3 Instagram 自動投稿（審査通過後）

**新規 Edge Function:** `supabase/functions/instagram-upload/index.ts`

**API:** Instagram Graph API Content Publishing

**処理フロー:**
1. `access_token` 取得
2. メディアコンテナ作成（動画URLは公開URL必須）
3. 公開リクエスト
4. `permalink` から `platform_post_url` 取得

**必要条件:**
- Meta アプリ審査で `instagram_content_publish` 権限取得
- ユーザーがビジネス/クリエイターアカウント

---

### Phase 3: 視聴回数集計

#### 3.1 定期取得 Cron

**既存 Edge Function 改修:** `supabase/functions/fetch-view-counts/index.ts`

**変更内容:**
- `video_url` → `platform_post_url` を参照
- `platform_post_url` がない場合は従来の `video_url` にフォールバック

#### 3.2 バッチ処理

**既存 Edge Function:** `supabase/functions/update-all-view-counts/index.ts`

- 変更なし（`fetch-view-counts` を呼ぶだけ）

## 📝 補足

- 動画の最大サイズ: 500MB（圧縮前）
- 対応フォーマット: MP4, MOV, WebM
- 最大動画長: 10分（TikTok/IG制限に合わせる）
- ストレージ: Supabase Storage（将来的にCloudflare R2移行検討）
