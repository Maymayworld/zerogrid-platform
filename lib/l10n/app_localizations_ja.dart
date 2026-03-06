// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Zero Grid';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get search => '検索';

  @override
  String get loading => '読み込み中...';

  @override
  String get uploading => 'アップロード中...';

  @override
  String get add => '追加';

  @override
  String get connect => '接続';

  @override
  String get disconnect => '接続解除';

  @override
  String get remove => '削除';

  @override
  String get submit => '提出';

  @override
  String get done => '完了';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get close => '閉じる';

  @override
  String get logIn => 'ログイン';

  @override
  String get signOut => 'ログアウト';

  @override
  String get newHere => '初めての方は ';

  @override
  String get welcome => 'ようこそ！';

  @override
  String get tellUsWhichSide => 'あなたはどちら側ですか？';

  @override
  String get contentMakers => 'コンテンツクリエイター・ストーリーテリングのプロ';

  @override
  String get brandsTeams => 'ブランド・チーム・キャンペーンオーナー';

  @override
  String get paidToCreators => '毎月50万円をクリエイターに支払い';

  @override
  String get talentedCreators => '500人以上の才能あるクリエイター';

  @override
  String get countMeIn => '参加する！';

  @override
  String get organizer => 'オーガナイザー';

  @override
  String get creator => 'クリエイター';

  @override
  String get pickYourUsername => 'ユーザー名を選択';

  @override
  String get checking => '確認中...';

  @override
  String get displayName => '表示名';

  @override
  String get optional => '（任意）';

  @override
  String get chooseFromLibrary => 'ライブラリから選択';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get pleaseEnterDisplayName => '表示名を入力してください';

  @override
  String get letsGo => '始めよう';

  @override
  String get forgotPassword => 'パスワードをお忘れですか';

  @override
  String get enterCode => 'コードを入力';

  @override
  String resetCodeSent(String email) {
    return '$emailに6桁のコードを送信しました。受信トレイを確認して以下に入力してください。';
  }

  @override
  String get verifyCode => 'コードを確認';

  @override
  String get resendCode => 'コードを再送信';

  @override
  String get enterResetCodeInstructions => 'メールに届いた6桁のコードを入力してください。';

  @override
  String get resetPassword => 'パスワードをリセット';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get profileNotFound => 'プロフィールが見つかりません';

  @override
  String get pleaseSignOutAndRegister => 'ログアウトして再度登録してください。';

  @override
  String authErrorMessage(String message) {
    return '認証エラー: $message';
  }

  @override
  String errorMessage(String message) {
    return 'エラー: $message';
  }

  @override
  String get navFind => '探す';

  @override
  String get navFeed => 'フィード';

  @override
  String get navCampaign => '案件';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCampaigns => 'キャンペーン';

  @override
  String get navChat => 'チャット';

  @override
  String get viewProfile => 'プロフィールを見る';

  @override
  String get accountSettings => 'アカウント設定';

  @override
  String get earnings => '収益';

  @override
  String get preferences => '設定';

  @override
  String get notifications => '通知';

  @override
  String get contactSupport => 'サポートに連絡';

  @override
  String get followZeroGrid => '@ZeroGridをフォロー';

  @override
  String get payoutAccount => '振込先口座';

  @override
  String get readyForWithdrawals => '出金可能';

  @override
  String get connected => '接続済み';

  @override
  String get verificationInProgress => '確認中';

  @override
  String get pending => '保留中';

  @override
  String get setupPayoutAccount => '収益を引き出すために振込先口座を設定してください';

  @override
  String get myWallet => 'マイウォレット';

  @override
  String get deposit => '入金';

  @override
  String get payment => 'お支払い';

  @override
  String get language => '言語';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get languageSettings => '言語';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get connectedAccounts => '連携アカウント';

  @override
  String get youtube => 'YouTube';

  @override
  String get instagram => 'Instagram';

  @override
  String get tiktok => 'TikTok';

  @override
  String get googleCalendar => 'Googleカレンダー';

  @override
  String disconnectProvider(String providerName) {
    return '$providerNameの接続を解除しますか？';
  }

  @override
  String get disconnectConfirm => 'このアカウントの接続を解除してもよろしいですか？';

  @override
  String get dangerZone => '危険な操作';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountWarning => 'アカウントを削除すると元に戻すことはできません';

  @override
  String get accountDeletionUnavailable => 'アカウント削除は現在利用できません。';

  @override
  String get settings => '設定';

  @override
  String get connectedServices => '連携サービス';

  @override
  String get utilities => 'ユーティリティ';

  @override
  String get connectSocialAccounts => '動画を各プラットフォームに投稿するためにソーシャルアカウントを連携';

  @override
  String get allNotifications => 'すべての通知';

  @override
  String get chat => 'チャット';

  @override
  String get chatNotificationDesc => 'プロジェクトオーナーやコラボレーターからのダイレクトメッセージ';

  @override
  String get earningsNotificationDesc => '再生回数や収益の更新に関する通知';

  @override
  String get news => 'ニュース';

  @override
  String get newsNotificationDesc => '新しいキャンペーンのお知らせとプラットフォームの更新情報';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get profile => 'プロフィール';

  @override
  String get bankName => '銀行名';

  @override
  String get branchName => '支店名';

  @override
  String get accountType => '口座種別';

  @override
  String get ordinary => '普通';

  @override
  String get checkingAccount => '当座';

  @override
  String get savingsAccount => '貯蓄';

  @override
  String get accountNumber => '口座番号';

  @override
  String get accountHolder => '口座名義人';

  @override
  String get profileImageUpdated => 'プロフィール画像を更新しました！';

  @override
  String failedToUpdateImage(String error) {
    return '画像の更新に失敗しました: $error';
  }

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get balance => '残高';

  @override
  String get cumulativeTotalViews => '累計再生回数';

  @override
  String get allTime => '全期間';

  @override
  String get totalViews => '総再生回数';

  @override
  String get yourProjects => 'あなたのプロジェクト';

  @override
  String get name => '名前';

  @override
  String get status => 'ステータス';

  @override
  String get myCampaigns => 'マイキャンペーン';

  @override
  String get searchCampaigns => 'キャンペーンを検索';

  @override
  String get failedToLoad => '読み込みに失敗しました';

  @override
  String get noCampaignsYet => 'まだキャンペーンがありません';

  @override
  String get joinCampaignsFromFind => '探すタブからキャンペーンに参加しよう！';

  @override
  String get createFirstCampaign => '最初のキャンペーンを作成して始めましょう';

  @override
  String get failedToLoadCampaigns => 'キャンペーンの読み込みに失敗しました';

  @override
  String get selectCampaign => 'キャンペーンを選択';

  @override
  String get noMatchingCampaigns => '一致するキャンペーンがありません';

  @override
  String get tryDifferentKeyword => '別のキーワードを試してください。';

  @override
  String get platforms => 'プラットフォーム';

  @override
  String get manage => '管理';

  @override
  String get video => '動画';

  @override
  String get title => 'タイトル';

  @override
  String get connectAnAccount => 'アカウントを接続';

  @override
  String get switchAccount => '切替';

  @override
  String get selectAccount => 'アカウントを選択';

  @override
  String get tapToSelectVideo => 'タップして動画を選択';

  @override
  String get maxFileSize => '最大500MB・10分まで';

  @override
  String get projectFiles => 'プロジェクトファイル';

  @override
  String get cannotOpenLink => 'このリンクを開けません';

  @override
  String get invalidUrl => '無効なURL';

  @override
  String get description => '説明';

  @override
  String get reviews => 'レビュー';

  @override
  String get noReviewsYet => 'まだレビューがありません';

  @override
  String get beFirstToReview => '最初のレビューを書きましょう！';

  @override
  String get leaveAReview => 'レビューを書く';

  @override
  String get rating => '評価';

  @override
  String get comment => 'コメント';

  @override
  String get submitReview => 'レビューを送信';

  @override
  String get likedProjects => 'いいねしたプロジェクト';

  @override
  String get noLikedProjectsYet => 'まだいいねしたプロジェクトがありません';

  @override
  String get findAndLikeCampaigns => 'キャンペーンを探して♥をタップして保存しよう';

  @override
  String get earningHistory => '収益履歴';

  @override
  String get views => '再生回数';

  @override
  String get earning => '収益';

  @override
  String get pastEarnings => '過去の収益';

  @override
  String get withdraw => '出金';

  @override
  String get messageHint => 'メッセージ...';

  @override
  String get noMessagesYetCreator => 'まだメッセージがありません。\nオーガナイザーに挨拶しましょう！';

  @override
  String get delivered => '配信済み';

  @override
  String get personalChat => '個人チャット';

  @override
  String get noMessagesYetStart => 'まだメッセージがありません。\n会話を始めましょう！';

  @override
  String get submissions => '提出物';

  @override
  String get all => 'すべて';

  @override
  String get approved => '承認済み';

  @override
  String get rejected => '却下';

  @override
  String get noSubmissionsYet => 'まだ提出物がありません';

  @override
  String get creatorsWillSubmitHere => 'クリエイターがここに動画を提出します';

  @override
  String get reject => '却下';

  @override
  String get approve => '承認';

  @override
  String get approveSubmission => '提出物を承認';

  @override
  String get rejectSubmission => '提出物を却下';

  @override
  String get approveConfirm => 'この提出物を承認してもよろしいですか？';

  @override
  String get rejectConfirm => 'この提出物を却下してもよろしいですか？';

  @override
  String get addNoteOptional => 'メモを追加（任意）...';

  @override
  String get editProject => 'プロジェクトを編集';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String get targetViews => '目標再生回数';

  @override
  String get budget => '予算';

  @override
  String get category => 'カテゴリ';

  @override
  String get viewSubmissions => '提出物を見る';

  @override
  String get reviewSubmissions => 'クリエイターの動画提出物を確認';

  @override
  String get tapToUpload => 'タップしてアップロード';

  @override
  String get removeCard => 'カードを削除';

  @override
  String removePaymentMethod(String method) {
    return '$methodを削除しますか？';
  }

  @override
  String get cardRemoved => 'カードを削除しました';

  @override
  String get paymentMethods => 'お支払い方法';

  @override
  String get depositSuccessful => '入金完了';

  @override
  String get depositProcessed => '入金が処理されました。';

  @override
  String get paymentMethodAdded => 'お支払い方法が正常に追加されました';

  @override
  String depositConfirmFailed(String error) {
    return '入金確認に失敗しました: $error';
  }

  @override
  String newBalanceMessage(String balance) {
    return '新しい残高: ¥$balance';
  }

  @override
  String get analytics => '分析';

  @override
  String get viewsAnalysis => '再生回数分析';

  @override
  String get userRanking => 'ユーザーランキング';

  @override
  String get user => 'ユーザー';

  @override
  String get videos => '動画';

  @override
  String get giveFeedback => 'フィードバックを送信';

  @override
  String get resources => 'リソース';

  @override
  String get account => 'アカウント';

  @override
  String logoutFailed(String error) {
    return 'ログアウトに失敗しました: $error';
  }

  @override
  String get approvalRequests => '承認リクエスト';

  @override
  String get approvalHistory => '承認履歴';

  @override
  String get noApprovalRequests => '承認リクエストはありません';

  @override
  String get createCampaign => 'キャンペーンを作成';

  @override
  String get campaignName => 'キャンペーン名';

  @override
  String get campaignDescription => 'キャンペーンの説明';

  @override
  String get per1000Views => '/ 1000再生';

  @override
  String get signUp => 'アカウント作成';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちの方は ';

  @override
  String get orContinueWith => 'または次の方法で続ける';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get username => 'ユーザー名';

  @override
  String get usernameAvailable => 'ユーザー名は使用可能です！';

  @override
  String get usernameTaken => 'このユーザー名は既に使用されています';

  @override
  String get usernameInvalid => 'ユーザー名は3〜20文字の小文字英字、数字、アンダースコアのみ使用可能です';

  @override
  String get signUpSuccess => '登録完了！';

  @override
  String get welcomeToZeroGrid => 'Zero Gridへようこそ！';

  @override
  String get activeCampaigns => 'アクティブなキャンペーン';

  @override
  String get completedCampaigns => '完了したキャンペーン';

  @override
  String get submissionSuccess => '提出完了！';

  @override
  String get submissionSuccessMessage => '動画がレビュー用に提出されました。';

  @override
  String get or => 'または';

  @override
  String get createAnAccount => 'アカウントを作成';

  @override
  String get createYourAccount => 'アカウントを作成';

  @override
  String get startBySettingUpLogin => 'ログイン情報を設定しましょう';

  @override
  String get continueButton => '続ける';

  @override
  String get haveAnAccount => 'アカウントをお持ちですか？ ';

  @override
  String get signIn => 'ログイン';

  @override
  String get pleaseFillInAllFields => 'すべてのフィールドを入力してください';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get uploadProfilePicture => 'プロフィール画像をアップロード';

  @override
  String get enterDisplayName => '表示名を入力';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String failedToPickImage(String error) {
    return '画像の選択に失敗しました: $error';
  }

  @override
  String get forgotPasswordQuestion => 'パスワードをお忘れですか？';

  @override
  String get enterEmailForResetCode =>
      'メールアドレスを入力してください。パスワードリセット用の6桁のコードを送信します。';

  @override
  String get pleaseEnterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get resetCodeSentSuccess => 'メールに6桁のコードを送信しました。次の画面で入力してください。';

  @override
  String get sendCode => 'コードを送信';

  @override
  String get backTo => '戻る: ';

  @override
  String resetCodeSentDescription(String email) {
    return '$emailに6桁のコードを送信しました。以下に入力して続けてください。';
  }

  @override
  String failedToVerifyCode(String error) {
    return 'コードの確認に失敗しました: $error';
  }

  @override
  String get newCodeSent => '新しいコードをメールに送信しました。';

  @override
  String failedToResendCode(String error) {
    return 'コードの再送信に失敗しました: $error';
  }

  @override
  String get enterNewPasswordInstruction => 'アカウント回復を完了するために新しいパスワードを入力してください。';

  @override
  String get createNewPassword => '新しいパスワードを作成';

  @override
  String get passwordMinLength => 'パスワードは8文字以上である必要があります。';

  @override
  String get reEnterPasswordInstruction => '確認のため新しいパスワードを再入力してください。';

  @override
  String get confirmNewPassword => '新しいパスワードを確認';

  @override
  String get updatePassword => 'パスワードを更新';

  @override
  String get passwordUpdated => 'パスワードが更新されました。新しいパスワードでログインしてください。';

  @override
  String get passwordsMustMatch => 'パスワードが一致し、8文字以上である必要があります。';

  @override
  String get signUpSuccessWelcome => 'Zero Gridへようこそ、';

  @override
  String get allSetMessage => '準備完了！稼いでクリエイトしよう！';

  @override
  String get failedToCreateUser => 'ユーザーの作成に失敗しました';

  @override
  String get filter => 'フィルター';

  @override
  String get platform => 'プラットフォーム';

  @override
  String get payPerView => '再生あたり報酬';

  @override
  String get noNotificationsYet => 'まだ通知はありません';

  @override
  String get failedToLoadNotifications => '通知の読み込みに失敗しました';

  @override
  String get share => '共有';

  @override
  String get messages => 'メッセージ';

  @override
  String get mail => 'メール';

  @override
  String get notes => 'メモ';

  @override
  String earnPerViews(String price, String views) {
    return '$views再生あたり¥$priceを獲得できます...';
  }

  @override
  String get feedbackHelpsUs => 'フィードバックはサービスの改善に役立ちます';

  @override
  String get tellUsSomething => 'お聞かせください';

  @override
  String get thankYouForFeedback => 'フィードバックありがとうございます！';

  @override
  String get shareFeedback => 'フィードバックを送信';

  @override
  String get campaignPostedSuccess => 'キャンペーンの投稿が完了しました！';

  @override
  String failedToPost(String error) {
    return '投稿に失敗しました: $error';
  }

  @override
  String get preview => 'プレビュー';

  @override
  String get uploadImage => '画像をアップロード';

  @override
  String get noDescription => '説明なし';

  @override
  String get post => '投稿';

  @override
  String get projectComingToLife => 'プロジェクトを準備しています！';

  @override
  String get projectReadyMessage => 'まもなく準備が整います。すべてをまとめています。';

  @override
  String get edit => '編集';

  @override
  String totalSpent(String amount) {
    return '合計支出 $amount';
  }

  @override
  String get needHelpSupport => 'お困りですか？サポートいたします';

  @override
  String get frequentlyAskedQuestions => 'よくある質問';

  @override
  String get browseFaqSubtitle => 'よくある質問と回答を閲覧';

  @override
  String get askForHelp => 'ヘルプを求める';

  @override
  String get askHelpSubtitle => 'お困りの内容をお知らせください';

  @override
  String get stillNeedHelp => 'まだお困りですか？';

  @override
  String get supportTeamReady => 'サポートチームがお手伝いいたします。';

  @override
  String get findQuickAnswers => 'すぐに回答を見つけるか、サポートを受けましょう';

  @override
  String get howCanWeHelp => 'どのようにお手伝いできますか？';

  @override
  String get tellUsAndHearBack => '状況をお聞かせください。メールで返信いたします';

  @override
  String get noSensitiveInfo => '機密情報は含めないでください';

  @override
  String get howFeelAboutZeroGrid => 'ZeroGridについてどう思いますか？';

  @override
  String get feedbackExampleHint => '例: アプリ最高！応援してます';

  @override
  String faqQuestion(int number) {
    return '質問 $number';
  }

  @override
  String faqAnswer(int number) {
    return '質問$numberの回答';
  }

  @override
  String get bankAccountSaved => '銀行口座を保存しました！';

  @override
  String get enterBankName => '銀行名を入力';

  @override
  String get enterBranchName => '支店名を入力';

  @override
  String get enterAccountNumber => '口座番号を入力';

  @override
  String get enterAccountHolderName => '口座名義人を入力';

  @override
  String get tellUsAboutYourself => '自己紹介を書いてください';

  @override
  String get pleaseSelectRating => '評価を選択してください';

  @override
  String get reviewSubmitted => 'レビューを送信しました！';

  @override
  String get shareExperienceHint => '体験を共有してください...';

  @override
  String failedToPickVideo(String error) {
    return '動画の選択に失敗しました: $error';
  }

  @override
  String get videoMaxSize500mb => '動画は500MB以下にしてください';

  @override
  String failedToUpload(String error) {
    return 'アップロードに失敗しました: $error';
  }

  @override
  String get videoTitle => '動画のタイトル';

  @override
  String get upload => 'アップロード';

  @override
  String get noAccountConnected => 'アカウントが接続されていません';

  @override
  String get estimated => '見込み';

  @override
  String get estimatedPending => '見込み保留中';

  @override
  String get noApprovedSubmissionsYet => '承認済みの提出物はまだありません';

  @override
  String get submitVideosToEarn => 'キャンペーンに動画を提出して収益を得よう！';

  @override
  String get postingPermissionsOnly => '投稿権限のみをリクエストします。いつでも接続を解除できます。';

  @override
  String get createWithAI => 'AIで作成';

  @override
  String get createManually => '手動で作成';

  @override
  String get letsStartWithBasics => '基本情報から始めましょう';

  @override
  String get giveCreatorsClearIdea => 'クリエイターにプロジェクトの内容を明確に伝えましょう';

  @override
  String get describeCreatorExpectations => 'クリエイターに期待することを説明してください';

  @override
  String get selectCategoryAndPlatforms => 'カテゴリとプラットフォームを選択';

  @override
  String get chooseCategoryFitsProject => 'プロジェクトに合ったカテゴリを選択';

  @override
  String get chooseWhereClipsPosted => 'クリエイターの動画が投稿されるプラットフォームを選択';

  @override
  String get setViewGoal => 'このプロジェクトで達成したい再生回数の目標を設定';

  @override
  String get adjustAnytime => 'いつでも調整できます';

  @override
  String get suggestRangesBasedOnCategory => 'カテゴリと目標再生回数に基づいて範囲を提案します';

  @override
  String insufficientBalanceAvailable(String available) {
    return '残高不足です。利用可能: ¥$available';
  }

  @override
  String get setProjectTimeline => 'プロジェクトのスケジュールを設定';

  @override
  String get chooseProjectDates => 'プロジェクトの開始日と終了日を選択';

  @override
  String get dateFormatPlaceholder => 'YYYY/MM/DD';

  @override
  String get projectAutoInactive => '終了日に達するとプロジェクトは自動的に無効になります';

  @override
  String uploadFailed(String error) {
    return 'アップロードに失敗しました: $error';
  }

  @override
  String get uploadFilesOrLinks => 'クリエイターがより良いコンテンツを制作できるよう、ファイルやリンクを追加';

  @override
  String get supportedFileFormats => '対応形式: JPG, PNG, SVG, MP4, PDF, ZIP';

  @override
  String get addLink => 'リンクを追加';

  @override
  String get pasteLinkHint => 'リンクを貼り付け...';

  @override
  String get addAnother => 'もう一つ追加';

  @override
  String get uploadedVideo => 'アップロード済み動画';

  @override
  String postedToPlatform(String platform) {
    return '$platformに投稿済み';
  }

  @override
  String get snsPostingFailed => 'SNS投稿に失敗しました';

  @override
  String postingToPlatform(String platform) {
    return '$platformに投稿中...';
  }

  @override
  String get submissionApprovedAutoPosting => '提出物が承認されました！SNSに自動投稿中...';

  @override
  String get submissionRejected => '提出物が却下されました';

  @override
  String get submissionApproved => '提出物が承認されました';

  @override
  String submissionApprovedBody(String campaignName) {
    return '「$campaignName」への提出物が承認されました！';
  }

  @override
  String submissionRejectedBody(String campaignName) {
    return '「$campaignName」への提出物が却下されました。';
  }

  @override
  String failedToSend(String error) {
    return '送信に失敗しました: $error';
  }

  @override
  String failedToLoadPaymentMethods(String error) {
    return 'お支払い方法の読み込みに失敗しました: $error';
  }

  @override
  String failedToAddCard(String error) {
    return 'カードの追加に失敗しました: $error';
  }

  @override
  String failedToRemoveCard(String error) {
    return 'カードの削除に失敗しました: $error';
  }

  @override
  String get paymentNotConfirmed =>
      'お支払いがまだ確認されていません。ブラウザで支払いを完了してから再度お試しください。';

  @override
  String paymentFailed(String error) {
    return '支払いに失敗しました: $error';
  }

  @override
  String get checkPaymentStatus => '支払い状況を確認';

  @override
  String addedToBalance(String amount) {
    return '$amountが残高に追加されました。';
  }

  @override
  String get minimumWithdrawal => '最低出金額は¥1,000です';

  @override
  String get insufficientBalance => '残高不足';

  @override
  String withdrawConfirm(String amount) {
    return '$amountを銀行口座に出金しますか？';
  }

  @override
  String withdrawalProcessed(String amount) {
    return '$amountの出金が処理されました！';
  }

  @override
  String get withdrawSetupDescription => '出金するには、Stripeを通じて振込先口座を設定する必要があります。';

  @override
  String get setUpNow => '今すぐ設定';

  @override
  String get accountVerifyingStripe => 'Stripeがアカウントを確認中です。通常1〜2営業日かかります。';

  @override
  String get completeSetupForWithdrawals => '出金を有効にするにはアカウント設定を完了してください。';

  @override
  String get refreshStatus => 'ステータスを更新';

  @override
  String get continueSetup => '設定を続ける';

  @override
  String get withdrawalMinAndTiming => '最低¥1,000・着金まで2〜5営業日';

  @override
  String get categoryBusiness => 'ビジネス';

  @override
  String get categoryEntertainment => 'エンタメ';

  @override
  String get categoryMusic => '音楽';

  @override
  String get categoryPodcast => 'ポッドキャスト';

  @override
  String get startDate => '開始日';

  @override
  String get endDate => '終了日';

  @override
  String get dateOfBirth => '生年月日';

  @override
  String get selectDate => '日付を選択';

  @override
  String get viewMore => 'もっと見る';

  @override
  String get anonymous => '匿名';

  @override
  String connectedCountLabel(int count) {
    return '$count件接続中';
  }

  @override
  String get howDoYouWantToCreate => 'どの方法でプロジェクトを作成しますか？';

  @override
  String get startFromShortIdea => '短いアイデアから始めて、AIに詳細を作成してもらいましょう';

  @override
  String get buildProjectStepByStep => '完全にコントロールしながらステップごとにプロジェクトを構築';
}
