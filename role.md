# Zero Grid - Page Role Map

Zero Gridは、インフルエンサーマーケティングのためのFlutterアプリです。
企業（Organizer）がキャンペーンを作成し、クリエイター（Creator）が動画を投稿して報酬を得る仕組みです。

---

## 共通画面（認証・起動）

### SplashScreen
- アプリ起動時のロゴアニメーション画面（2秒間表示）
- → AppWrapper へ自動遷移

### AppWrapper
- ログイン状態を判定するルーティングハブ
- 未ログイン → SelectRoleScreen
- ログイン済み → プロフィール読み込み → MainLayout（Creator or Organizer）
- Stripe決済からの復帰処理もここで実行（SharedPreferences経由）

### SelectRoleScreen
- 初回表示画面。CreatorかOrganizerかを選択するスライダー
- 選択に応じてバッジ画像・ボタン色がアニメーション切替
- → LoginScreen（選んだロール付き）

### LoginScreen
- メールアドレス＋パスワードでログイン
- Apple / Google のOAuthログインも対応
- → ログイン成功 → MainLayout
- → 「Create an account」 → SignUpScreen1

### SignUpScreen1
- サインアップ 1/3: メールアドレス・パスワード・確認パスワードを入力
- Apple / Google でのOAuthサインアップも可
- → SignUpScreen2

### SignUpScreen2
- サインアップ 2/3: ユーザー名（@username）を設定
- リアルタイムで重複チェック（サーバー問い合わせ）
- → SignUpScreen3

### SignUpScreen3
- サインアップ 3/3: 表示名＋プロフィール画像をアップロード
- アカウント作成・プロフィールをDBに保存
- → SignUpSuccessScreen

### SignUpSuccessScreen
- 「Welcome to Zero Grid」の完了画面
- → MainLayout（メイン画面へ）

---

## Creator側（クリエイター = 動画投稿者）

ボトムナビゲーション 5タブ ＋ フローティング投稿ボタン

```
CreatorMainLayout
├── [0] FindScreen        … キャンペーン探し
├── [1] FeedScreen        … 動画フィード
├── [2] DashboardScreen   … 収益・アナリティクス
├── [3] CampaignScreen    … 参加中キャンペーン一覧
├── [4] ProfileScreen     … プロフィール・設定
└── [FAB] 投稿ボタン       … 動画アップロード
```

---

### Tab 0: FindScreen（キャンペーン探し）
- 全キャンペーンをカード形式で一覧表示
- カテゴリフィルター（All, Business, Entertainment, Music, Podcast）
- いいね機能、検索、広告バナー
- → ProjectDetailScreen（カードタップ）
- → ProfileDetailScreen（自分のアバタータップ）
- → NotificationSheet（通知ベル → モーダル）

### Tab 1: FeedScreen（動画フィード）
- 全画面縦スクロールの動画フィード（TikTok風）
- ローカル動画（video_player）とYouTube動画（youtube_player_iframe）に対応
- いいねボタン、JOINボタン
- → ProjectDetailScreen（JOINボタン）

### Tab 2: DashboardScreen（アナリティクス）
- 自分の収益・再生回数のダッシュボード
- 4つのステータスカード: Total Views / Total Earnings / Active Campaigns / Estimated Pending
- Earning History: キャンペーンごとの再生数・報酬一覧（プラットフォームアイコン付き）
- Past Earnings: 過去の確定報酬
- ※閲覧専用、ナビゲーションなし

### Tab 3: CampaignScreen（参加中キャンペーン一覧）
- 自分が参加しているキャンペーンをリスト表示
- 検索バー、リフレッシュボタン
- → ProjectMenuScreen（カードタップ）
- → NotificationSheet（通知ベル）

### Tab 4: ProfileScreen（プロフィール）
- アバター・表示名、Payout Accountステータス表示
- メニュー: Account Settings / Earnings / Notifications / Follow @ZeroGrid / Sign Out
- → ProfileDetailScreen（プロフィールカードタップ）
- → AccountSettingsScreen（アカウント設定）
- → EarningsScreen（収益詳細）
- → WithdrawalScreen（出金）
- → NotificationSettingsSheet（通知設定 → モーダル）

### FAB: 投稿ボタン（＋アイコン）
- 参加中キャンペーン選択モーダル → 選択したキャンペーンへ動画投稿
- → ProjectUploadScreen

---

### キャンペーン詳細系

#### ProjectDetailScreen（キャンペーン詳細）
- キャンペーンの全情報: サムネイル、説明文、予算、締切、対象プラットフォーム
- オーガナイザー情報、レビュー一覧、平均評価
- 「Join」ボタンで参加
- → ReviewScreen（レビュー追加）

#### ProjectMenuScreen（参加済みキャンペーンのハブ）
- キャンペーン名・メンバー数・予算進捗を表示
- 4つのアクションカード
- → ProjectDetailScreen（画像タップ → 詳細へ戻る）
- → ProjectChatScreen（グループチャット）
- → CreatorPersonalChatScreen（1対1チャット）
- → ProjectDownloadScreen（素材ダウンロード）
- → ProjectUploadScreen（動画投稿）

#### ProjectUploadScreen（動画投稿）
- 動画ファイル選択・プレビュー
- 投稿先プラットフォーム選択（YouTube / Instagram / TikTok）
- キャプション入力、接続アカウント確認
- → ProjectSuccessScreen（投稿成功）

#### ProjectSuccessScreen（投稿完了）
- 「You're in!」チェックマーク画面
- → CreatorMainLayout（キャンペーンタブへ）

#### ProjectDownloadScreen（素材ダウンロード）
- オーガナイザーがアップロードしたファイル・リンク一覧
- PDF、画像、動画、Google Drive、Figma等を自動アイコン判定
- タップで外部URLを開く

#### ReviewScreen（レビュー）
- キャンペーンのレビュー一覧と星評価
- 自分のレビュー投稿フォーム

---

### プロフィール・収益系

#### ProfileDetailScreen（プロフィール詳細）
- 自分のアバター・表示名・自己紹介
- 投稿一覧タブ / いいね一覧タブ
- → プロフィール編集画面（ペンアイコン）

#### AccountSettingsScreen（アカウント設定）
- メールアドレス表示
- SNS連携状態（YouTube / Instagram / TikTok）の接続・切断

#### EarningsScreen（収益詳細）
- 残高表示、収益履歴、キャンペーン別内訳
- → WithdrawalScreen（出金ボタン）

#### WithdrawalScreen（出金）
- Stripe Connect連携状態の確認
- 未連携 → Stripeオンボーディングページへ（外部URL）
- 連携済み → 出金金額入力・出金実行

---

### チャット系

#### ProjectChatScreen（グループチャット）
- キャンペーン参加者全員のグループチャット
- Supabase Realtimeでリアルタイムメッセージ更新

#### CreatorPersonalChatScreen（1対1チャット）
- オーガナイザーとの個別チャット
- Supabase Realtimeでリアルタイム更新

---

## Organizer側（オーガナイザー = 企業/キャンペーン主催者）

ボトムナビゲーション 5タブ（中央ボタンは動的切替）

```
OrganizerMainLayout
├── [0] HomeScreen              … ダッシュボード
├── [1] CampaignScreen          … キャンペーン管理
├── [2] CreateScreen             … キャンペーン作成
│   └─ (承認リクエストあり時) ApprovalRequestScreen
├── [3] ChatListScreen           … チャット一覧
├── [4] ProfileScreen            … プロフィール・設定
```

---

### Tab 0: HomeScreen（ダッシュボード）
- ウォレット残高表示、Depositボタン
- 累計再生数グラフ
- アクティブキャンペーン一覧（上位5件）
- → SelectAmountScreen（デポジット）
- → AnalyticsScreen（キャンペーンタップ → 詳細分析）
- → NotificationSheet（通知ベル）

### Tab 1: CampaignScreen（キャンペーン管理）
- 作成済みキャンペーン一覧（検索・フィルター付き）
- サムネイル・名前・予算・再生数・ステータスを表示
- → EditCampaignScreen（キャンペーン編集）
- → ApprovalHistoryScreen（履歴アイコン）

### Tab 2: CreateScreen / ApprovalRequestScreen（動的切替）

#### CreateScreen（キャンペーン作成）
- 「AI作成」と「手動作成」の2つの選択肢を表示
- → ManualCreatePage1（手動作成開始）

#### ApprovalRequestScreen（承認リクエスト）
- 未承認の動画投稿をカードスタックで表示
- スワイプ操作: 右=承認 / 左=却下 / 上=スキップ
- ※承認待ちがある場合、中央ボタンがこの画面に切り替わる

### Tab 3: ChatListScreen（チャット一覧）
- キャンペーンごとのチャットルーム一覧
- グループチャットと個別チャットの切替
- → GroupChatScreen（グループチャット）
- → PersonalChatListScreen → PersonalChatScreen（個別チャット）

### Tab 4: ProfileScreen（プロフィール）
- アバター・表示名・ロールバッジ表示
- My Wallet: 残高表示＋Depositボタン
- メニュー: Account Settings / Payment / Notifications / Contact Support / Sign Out
- → OrganizerAccountSettingsScreen（モーダル）
- → PaymentMethodsScreen（決済方法管理）
- → SelectAmountScreen（デポジット）
- → NotificationSettingsSheet（通知設定モーダル）

---

### キャンペーン作成フロー（6ステップ）

```
CreateScreen
→ ManualCreatePage1（基本情報: 名前・説明）
→ ManualCreatePage2（詳細設定）
→ ManualCreatePage3（予算・目標再生数）
→ ManualCreatePage4（対象プラットフォーム選択）
→ ManualCreatePage5（カテゴリ選択）
→ ManualCreatePage6（クリエイター向け素材アップロード / リンク追加）
→ PreviewPage（プレビュー確認 → 公開）
```

---

### キャンペーン管理系

#### EditCampaignScreen（キャンペーン編集）
- サムネイル変更、名前・説明・予算・カテゴリ・プラットフォームの編集
- → SubmissionReviewScreen（投稿一覧を見る）

#### SubmissionReviewScreen（投稿レビュー画面）
- キャンペーンへの全投稿をフィルター表示（All / Pending / Approved / Rejected）
- クリエイター情報・再生数・投稿ステータス表示

#### ApprovalHistoryScreen（承認履歴）
- 過去に承認・却下した投稿の履歴一覧

#### AnalyticsScreen（キャンペーン分析）
- キャンペーンの詳細パフォーマンス分析
- 再生数と目標の進捗バー
- プラットフォーム別内訳（YouTube / Instagram / TikTok）
- クリエイターランキング（メダル付き）

---

### 決済系

#### SelectAmountScreen（デポジット金額選択）
- 現在の残高表示
- 金額選択（±ボタン、クイック選択: ¥10,000 / ¥50,000 / ¥100,000）
- → Stripe Checkoutページ（外部リダイレクト）→ 決済完了後アプリに復帰

#### PaymentMethodsScreen（決済方法管理）
- 登録済みカード一覧（ブランドアイコン・下4桁・有効期限）
- カード追加 → Stripe Checkout（setupモード → 外部リダイレクト）
- カード削除

---

### チャット系

#### GroupChatScreen（グループチャット）
- キャンペーン参加者全員とのチャット

#### PersonalChatListScreen（個別チャットリスト）
- キャンペーン内のクリエイター一覧（最新メッセージ・未読バッジ付き）
- → PersonalChatScreen（個別チャット画面）

#### PersonalChatScreen（個別チャット）
- 特定クリエイターとの1対1チャット

---

## 画面遷移の全体像

```
[アプリ起動]
    │
    ▼
SplashScreen → AppWrapper
    │
    ├── 未ログイン ──────────────────────────────┐
    │                                             ▼
    │                                      SelectRoleScreen
    │                                        │         │
    │                                        ▼         ▼
    │                                  LoginScreen  SignUpScreen1→2→3→Success
    │                                        │
    ├── ログイン済み ─────────────────────────┘
    │
    ▼
MainLayout
    ├── Creator → CreatorMainLayout (5タブ + FAB)
    └── Organizer → OrganizerMainLayout (5タブ)
```
