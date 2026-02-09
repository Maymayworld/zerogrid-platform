# ZeroGrid 自動投稿システム 要件定義書

**作成日**: 2026年1月8日

**目的**: 実装アプローチのリサーチと技術選定

---

## 📋 1. システム概要

### 1.1 プロダクト概要

**ZeroGrid** は、企業がインフルエンサーを活用したキャンペーン動画の切り抜き拡散を促進し、視聴回数ベースで報酬を配分するプラットフォーム。

### 1.2 コアバリュー

`企業: キャンペーン予算を設定 → 切り抜き動画が拡散 → ROI を測定
クリエイター: 動画を切り抜き投稿 → 視聴回数を獲得 → 報酬を受け取る`

---

## 🎯 2. 主要機能（MVP）

### 2.1 ユーザー機能

| 機能 | 説明 | 優先度 |
| --- | --- | --- |
| **動画アップロード** | 切り抜き動画（MP4）をアップロード | ★★★ 必須 |
| **投稿設定** | キャプション、ハッシュタグ、投稿先SNS選択 | ★★★ 必須 |
| **SNS連携** | YouTube/Instagram/TikTok アカウント連携 | ★★★ 必須 |
| **投稿実行** | 複数SNSへの自動投稿 | ★★★ 必須 |
| **視聴回数確認** | 各SNSでの視聴回数を確認 | ★★☆ 重要 |
| **報酬確認** | 獲得報酬額を確認 | ★★☆ 重要 |

### 2.2 企業機能

| 機能 | 説明 | 優先度 |
| --- | --- | --- |
| **キャンペーン作成** | 元動画URL、予算、単価設定 | ★★★ 必須 |
| **動画確認** | ユーザーが投稿した動画を確認 | ★★★ 必須 |
| **承認/却下** | 動画の承認または却下 | ★★★ 必須 |
| **視聴回数モニタリング** | 各動画の視聴回数を確認 | ★★☆ 重要 |
| **報酬計算** | 視聴回数 × 単価で報酬を自動計算 | ★★☆ 重要 |
| **支払い管理** | 報酬の支払いステータス管理 | ★☆☆ 後回し |

---

## 👥 3. ユーザーフロー

### 3.1 クリエイター（投稿者）フロー

`1. キャンペーン一覧を閲覧
   ↓
2. 参加したいキャンペーンを選択
   ↓
3. 元動画から切り抜き動画を作成（外部ツール）
   ↓
4. ZeroGrid アプリで動画アップロード
   ↓
5. 投稿設定（キャプション、ハッシュタグ、投稿先SNS）
   ↓
6. SNSアカウント連携（初回のみ）
   ↓
7. 投稿実行ボタン
   ↓
8. 各SNSに自動投稿される
   ↓
9. 視聴回数が自動で集計される
   ↓
10. 報酬が計算される`

### 3.2 企業（キャンペーン主）フロー

`1. キャンペーン作成
   - 元動画URL
   - 予算: 10万円
   - 単価: 1再生 = 0.5円
   ↓
2. クリエイターが動画投稿
   ↓
3. 投稿動画の確認・承認
   ↓
4. 視聴回数をモニタリング
   ↓
5. 報酬を確認・支払い`

---

## 🔧 4. 技術要件

### 4.1 必須機能

| 機能 | 技術要件 | 難易度 |
| --- | --- | --- |
| **動画ストレージ** | R2 / S3 / Supabase Storage | ⭐☆☆ 簡単 |
| **SNS OAuth連携** | YouTube/Instagram/TikTok OAuth | ⭐⭐☆ 中 |
| **自動投稿** | 各SNS API経由で投稿 | ⭐⭐⭐ 難 |
| **視聴回数取得** | 各SNS Analytics API | ⭐⭐☆ 中 |
| **報酬計算** | 視聴回数 × 単価の計算 | ⭐☆☆ 簡単 |

### 4.2 データベース設計（概要）

`campaigns（キャンペーン）
- id, company_id, title, video_url, budget, rate_per_view

user_posts（ユーザー投稿）
- id, user_id, campaign_id, video_url, status（pending/approved/rejected）

social_connections（SNS連携）
- id, user_id, provider, access_token, refresh_token

post_targets（投稿先SNS）
- id, user_post_id, provider, provider_post_id, url, status

video_analytics（視聴回数）
- id, post_target_id, views, likes, comments, collected_at

revenue_distribution（報酬）
- id, user_post_id, total_views, amount, status`

---

## 📊 5. API制約と課題（添付資料より）

### 5.1 YouTube

| 項目 | 内容 |
| --- | --- |
| **投稿** | ✅ 可能（Data API v3） |
| **視聴回数取得** | ✅ 可能（Analytics API、自分のアカウントのみ） |
| **クオータ** | 10,000ユニット/日（無料） |
| **コスト** | 動画アップロード 約100ユニット |
| **制約** | 90日未使用でアクセス無効化 |

### 5.2 Instagram

| 項目 | 内容 |
| --- | --- |
| **投稿** | ✅ 可能（Graph API） |
| **視聴回数取得** | ✅ 可能（Insights API） |
| **制約** | ビジネスアカウント必須、Facebookページ連携必須 |
| **レート制限** | 200リクエスト/時間、25投稿/24時間 |

### 5.3 TikTok

| 項目 | 内容 |
| --- | --- |
| **投稿** | ⚠️ 審査必須、未審査は**非公開のみ** |
| **視聴回数取得** | ❌ API非提供（Display APIは動画メタデータのみ） |
| **審査** | 厳格、通常5-7日、フィードバック対応必要 |
| **制約** | 未審査: 5ユーザー/24時間、非公開投稿のみ |

### 5.4 Twitter/X

| 項目 | 内容 |
| --- | --- |
| **投稿** | ✅ 可能（API v2） |
| **視聴回数取得** | ⚠️ Basic $100/月〜 |
| **コスト** | Free: 実質使用不可、Basic: $100/月 |

---

## 🛠️ 6. 実装アプローチの選択肢

### 選択肢A: Supabase Edge Functions + pg_cron

**概要**: Supabase の Edge Functions で投稿処理、pg_cron で定期的な視聴回数取得

**メリット**:

- ✅ コストが安い（無料〜）
- ✅ フルコントロール
- ✅ Flutter → Supabase の統合が簡単

**デメリット**:

- ❌ 自分で全部実装する必要がある
- ❌ エラーハンドリングが複雑
- ❌ スケーリングに課題

**実装イメージ**:

typescript

`// Supabase Edge Function: /functions/v1/post-to-sns
export async function handler(req: Request) {
  const { user_post_id, provider } = await req.json();
  
  // 1. トークン取得
  const token = await getAccessToken(user_id, provider);
  
  // 2. 動画ダウンロード（R2から）
  const video = await downloadFromR2(video_key);
  
  // 3. SNS API呼び出し
  if (provider === 'youtube') {
    await uploadToYouTube(video, token);
  }
  
  // 4. 結果をDBに保存
  await saveResult(user_post_id, result);
}`

**コスト**: $0 〜 $25/月（Supabase Pro）

---

### 選択肢B: サードパーティAPI（Buffer、Ayrshare等）

**概要**: 既存のSNS投稿サービスのAPIを利用

**メリット**:

- ✅ 実装が簡単
- ✅ エラーハンドリング済み
- ✅ 複数SNSに対応済み

**デメリット**:

- ❌ コストが高い
- ❌ 視聴回数取得は別途実装が必要
- ❌ カスタマイズに制限

**実装イメージ**:

typescript

`// Ayrshare API
const response = await fetch('https://app.ayrshare.com/api/post', {
  method: 'POST',
  body: JSON.stringify({
    post: "キャプション",
    mediaUrls: ["https://r2.dev/video.mp4"],
    platforms: ["youtube", "instagram"]
  })
});
```

**コスト**: 
- Ayrshare: $49/月（25投稿/月）〜 $249/月（500投稿/月）
- Buffer: $6/月〜（投稿管理のみ、API別料金）

---

### 選択肢C: 手動投稿（API不使用）

**概要**: ユーザーが各SNSで手動投稿、投稿URLを登録する方式

**メリット**:
- ✅ 実装が超簡単
- ✅ API制約を回避
- ✅ コストゼロ

**デメリット**:
- ❌ ユーザー体験が悪い
- ❌ 投稿URLの偽装リスク
- ❌ 自動化のメリットがない

**実装イメージ**:
```
1. ユーザーが動画をアップロード
2. ユーザーが自分で各SNSに投稿
3. 投稿URLをZeroGridに登録
4. 管理者が確認
5. 視聴回数を定期的に取得
```

**コスト**: $0

---

### 選択肢D: Cloudflare Workers + R2

**概要**: Cloudflare Workers で投稿処理、R2 で動画保存

**メリット**:
- ✅ コストが安い
- ✅ エッジで高速処理
- ✅ R2 とのネイティブ統合

**デメリット**:
- ❌ Supabase との連携が複雑
- ❌ Cron Jobs は別途設定が必要

**コスト**: $5/月〜

---

## 💰 7. コスト比較

| アプローチ | 初期開発 | 月額コスト | 保守コスト |
|-----------|---------|-----------|-----------|
| **A: Supabase Edge Functions** | 高（全部実装） | $0〜$25 | 高 |
| **B: サードパーティAPI** | 低（簡単） | $49〜$249 | 低 |
| **C: 手動投稿** | 超低 | $0 | 低 |
| **D: Cloudflare Workers** | 中 | $5〜 | 中 |

---

## ⚠️ 8. リスクと制約

### 8.1 技術的リスク

| リスク | 影響度 | 対策 |
|--------|--------|------|
| **TikTok審査不合格** | 高 | YouTube/Instagram を優先、TikTok は Phase 2 |
| **API レート制限** | 中 | キャッシュ、リトライ処理 |
| **OAuth トークン期限切れ** | 中 | 自動リフレッシュ機能 |
| **動画形式の互換性** | 低 | アップロード時に変換 |

### 8.2 ビジネスリスク

| リスク | 影響度 | 対策 |
|--------|--------|------|
| **視聴回数の偽装** | 高 | 定期的な自動取得、異常検知 |
| **不適切な動画投稿** | 中 | 事前承認フロー |
| **予算超過** | 中 | 予算上限設定、アラート |

---

## 📅 9. 実装優先順位（推奨）

### Phase 1: MVP（2-3ヶ月）
```
✅ YouTube のみ対応
✅ 手動承認フロー
✅ 基本的な視聴回数取得
✅ シンプルな報酬計算
✅ Supabase Edge Functions で実装
```

**理由**:
- YouTube は無料で使える
- API が安定している
- クオータが十分

### Phase 2: Instagram 追加（1ヶ月）
```
✅ Instagram 投稿対応
✅ Instagram Insights API
✅ ビジネスアカウント連携フロー
```

### Phase 3: TikTok 追加（2-3ヶ月）
```
✅ TikTok 審査申請
✅ TikTok 投稿対応
✅ 視聴回数取得の代替手段（手動入力 or スクレイピング）
```

---

## 🔍 10. 次のステップ（リサーチ項目）

### 10.1 技術選定のための調査

- [ ] Supabase Edge Functions のタイムアウト制限（動画アップロード）
- [ ] Cloudflare R2 vs Supabase Storage の比較
- [ ] YouTube Data API のクオータ実測
- [ ] Instagram Business アカウント連携の手順確認
- [ ] TikTok 審査申請の詳細要件

### 10.2 コスト試算

- [ ] 想定ユーザー数 × 投稿数でのAPI コスト
- [ ] ストレージコスト（動画サイズ × 投稿数）
- [ ] サードパーティAPI の比較検討

### 10.3 プロトタイプ検証

- [ ] YouTube 投稿のプロトタイプ（Supabase Edge Functions）
- [ ] OAuth フローの実装
- [ ] 視聴回数取得の動作確認

---

## 📝 11. 推奨実装アプローチ（結論）

### **Phase 1 推奨: 選択肢A（Supabase Edge Functions）**

**理由**:
1. ✅ コストが最小（無料〜$25/月）
2. ✅ Flutter との統合が簡単
3. ✅ フルコントロール可能
4. ✅ スケールしやすい

**実装範囲**:
```
- YouTube のみ対応
- 動画アップロード: R2
- 投稿処理: Edge Functions
- 視聴回数取得: Edge Functions + pg_cron
- OAuth: Supabase Auth + Edge Functions`

**Phase 2 以降の検討**:

- ユーザー数が増えたら、サードパーティAPIの検討
- TikTok は視聴回数API がないため、手動入力 or 別の方法を検討