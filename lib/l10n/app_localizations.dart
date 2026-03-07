import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zero Grid'**
  String get appTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @joinCampaign.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinCampaign;

  /// No description provided for @jumpToList.
  ///
  /// In en, this message translates to:
  /// **'Jump to List'**
  String get jumpToList;

  /// No description provided for @nMembers.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String nMembers(Object count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get newHere;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! '**
  String get welcome;

  /// No description provided for @tellUsWhichSide.
  ///
  /// In en, this message translates to:
  /// **'Tell us which side are you?'**
  String get tellUsWhichSide;

  /// No description provided for @contentMakers.
  ///
  /// In en, this message translates to:
  /// **'Content-makers and storytelling pros'**
  String get contentMakers;

  /// No description provided for @brandsTeams.
  ///
  /// In en, this message translates to:
  /// **'Brands, teams, and campaign owners'**
  String get brandsTeams;

  /// No description provided for @paidToCreators.
  ///
  /// In en, this message translates to:
  /// **'¥500,000 paid to creators every month'**
  String get paidToCreators;

  /// No description provided for @talentedCreators.
  ///
  /// In en, this message translates to:
  /// **'500+ talented creators'**
  String get talentedCreators;

  /// No description provided for @countMeIn.
  ///
  /// In en, this message translates to:
  /// **'Count Me In!'**
  String get countMeIn;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @creators.
  ///
  /// In en, this message translates to:
  /// **'creators'**
  String get creators;

  /// No description provided for @pickYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Pick Your Username'**
  String get pickYourUsername;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose From Library'**
  String get chooseFromLibrary;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @pleaseEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get pleaseEnterDisplayName;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go'**
  String get letsGo;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Check your inbox and enter it below.'**
  String resetCodeSent(String email);

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @enterResetCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your email.'**
  String get enterResetCodeInstructions;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @pleaseSignOutAndRegister.
  ///
  /// In en, this message translates to:
  /// **'Please sign out and register again.'**
  String get pleaseSignOutAndRegister;

  /// No description provided for @authErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {message}'**
  String authErrorMessage(String message);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @navFind.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get navFind;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get navCampaign;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get navCampaigns;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @followZeroGrid.
  ///
  /// In en, this message translates to:
  /// **'Follow @ZeroGrid'**
  String get followZeroGrid;

  /// No description provided for @payoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout Account'**
  String get payoutAccount;

  /// No description provided for @readyForWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Ready for withdrawals'**
  String get readyForWithdrawals;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @verificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Verification in progress'**
  String get verificationInProgress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @setupPayoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up your payout account to withdraw earnings'**
  String get setupPayoutAccount;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettings;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get connectedAccounts;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @googleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get googleCalendar;

  /// No description provided for @disconnectProvider.
  ///
  /// In en, this message translates to:
  /// **'Disconnect {providerName}?'**
  String disconnectProvider(String providerName);

  /// No description provided for @disconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect this account?'**
  String get disconnectConfirm;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Once you delete your account there is no going back'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeletionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is not yet available.'**
  String get accountDeletionUnavailable;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connectedServices.
  ///
  /// In en, this message translates to:
  /// **'Connected Services'**
  String get connectedServices;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @connectSocialAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connect your social accounts to submit videos across platforms'**
  String get connectSocialAccounts;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct messages from project owners and collaborators'**
  String get chatNotificationDesc;

  /// No description provided for @earningsNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications about your view count and earnings updates'**
  String get earningsNotificationDesc;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @newsNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'New campaign alerts and platform updates'**
  String get newsNotificationDesc;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @ordinary.
  ///
  /// In en, this message translates to:
  /// **'Ordinary'**
  String get ordinary;

  /// No description provided for @checkingAccount.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get checkingAccount;

  /// No description provided for @savingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savingsAccount;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @accountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account Holder'**
  String get accountHolder;

  /// No description provided for @profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated!'**
  String get profileImageUpdated;

  /// No description provided for @failedToUpdateImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update image: {error}'**
  String failedToUpdateImage(String error);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @cumulativeTotalViews.
  ///
  /// In en, this message translates to:
  /// **'Cumulative Total Views'**
  String get cumulativeTotalViews;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @totalViews.
  ///
  /// In en, this message translates to:
  /// **'Total Views'**
  String get totalViews;

  /// No description provided for @yourProjects.
  ///
  /// In en, this message translates to:
  /// **'Your Projects'**
  String get yourProjects;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @myCampaigns.
  ///
  /// In en, this message translates to:
  /// **'My Campaigns'**
  String get myCampaigns;

  /// No description provided for @searchCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Search campaigns'**
  String get searchCampaigns;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @noCampaignsYet.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get noCampaignsYet;

  /// No description provided for @joinCampaignsFromFind.
  ///
  /// In en, this message translates to:
  /// **'Join campaigns from the Find tab!'**
  String get joinCampaignsFromFind;

  /// No description provided for @createFirstCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create your first campaign to get started'**
  String get createFirstCampaign;

  /// No description provided for @failedToLoadCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Failed to load campaigns'**
  String get failedToLoadCampaigns;

  /// No description provided for @selectCampaign.
  ///
  /// In en, this message translates to:
  /// **'Select Campaign'**
  String get selectCampaign;

  /// No description provided for @noMatchingCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No matching campaigns'**
  String get noMatchingCampaigns;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword.'**
  String get tryDifferentKeyword;

  /// No description provided for @platforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get platforms;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @connectAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect an account'**
  String get connectAnAccount;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAccount;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @tapToSelectVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a video'**
  String get tapToSelectVideo;

  /// No description provided for @maxFileSize.
  ///
  /// In en, this message translates to:
  /// **'Max 500MB · Up to 10 minutes'**
  String get maxFileSize;

  /// No description provided for @projectFiles.
  ///
  /// In en, this message translates to:
  /// **'Project Files'**
  String get projectFiles;

  /// No description provided for @cannotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this link'**
  String get cannotOpenLink;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a review!'**
  String get beFirstToReview;

  /// No description provided for @leaveAReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get leaveAReview;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @likedProjects.
  ///
  /// In en, this message translates to:
  /// **'Liked Projects'**
  String get likedProjects;

  /// No description provided for @noLikedProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No liked projects yet'**
  String get noLikedProjectsYet;

  /// No description provided for @findAndLikeCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Find campaigns and tap ♥ to save them here'**
  String get findAndLikeCampaigns;

  /// No description provided for @earningHistory.
  ///
  /// In en, this message translates to:
  /// **'Earning History'**
  String get earningHistory;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @earning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earning;

  /// No description provided for @pastEarnings.
  ///
  /// In en, this message translates to:
  /// **'Past Earnings'**
  String get pastEarnings;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @noMessagesYetCreator.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nSay hi to the organizer!'**
  String get noMessagesYetCreator;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @personalChat.
  ///
  /// In en, this message translates to:
  /// **'Personal Chat'**
  String get personalChat;

  /// No description provided for @noMessagesYetStart.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nStart the conversation!'**
  String get noMessagesYetStart;

  /// No description provided for @submissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get submissions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noSubmissionsYet.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet'**
  String get noSubmissionsYet;

  /// No description provided for @creatorsWillSubmitHere.
  ///
  /// In en, this message translates to:
  /// **'Creators will submit videos here'**
  String get creatorsWillSubmitHere;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approveSubmission.
  ///
  /// In en, this message translates to:
  /// **'Approve Submission'**
  String get approveSubmission;

  /// No description provided for @rejectSubmission.
  ///
  /// In en, this message translates to:
  /// **'Reject Submission'**
  String get rejectSubmission;

  /// No description provided for @approveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this submission?'**
  String get approveConfirm;

  /// No description provided for @rejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this submission?'**
  String get rejectConfirm;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)...'**
  String get addNoteOptional;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @targetViews.
  ///
  /// In en, this message translates to:
  /// **'Target Views'**
  String get targetViews;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @viewSubmissions.
  ///
  /// In en, this message translates to:
  /// **'View Submissions'**
  String get viewSubmissions;

  /// No description provided for @reviewSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Review creator video submissions'**
  String get reviewSubmissions;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get tapToUpload;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove Card'**
  String get removeCard;

  /// No description provided for @removePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Remove {method}?'**
  String removePaymentMethod(String method);

  /// No description provided for @cardRemoved.
  ///
  /// In en, this message translates to:
  /// **'Card removed'**
  String get cardRemoved;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @depositSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Deposit Successful'**
  String get depositSuccessful;

  /// No description provided for @depositProcessed.
  ///
  /// In en, this message translates to:
  /// **'Your deposit has been processed.'**
  String get depositProcessed;

  /// No description provided for @paymentMethodAdded.
  ///
  /// In en, this message translates to:
  /// **'Payment method added successfully'**
  String get paymentMethodAdded;

  /// No description provided for @depositConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Deposit confirmation failed: {error}'**
  String depositConfirmFailed(String error);

  /// No description provided for @newBalanceMessage.
  ///
  /// In en, this message translates to:
  /// **'New balance: ¥{balance}'**
  String newBalanceMessage(String balance);

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @viewsAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Views Analysis'**
  String get viewsAnalysis;

  /// No description provided for @userRanking.
  ///
  /// In en, this message translates to:
  /// **'User Ranking'**
  String get userRanking;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @giveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give Feedback'**
  String get giveFeedback;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// No description provided for @approvalRequests.
  ///
  /// In en, this message translates to:
  /// **'Approval Requests'**
  String get approvalRequests;

  /// No description provided for @approvalHistory.
  ///
  /// In en, this message translates to:
  /// **'Approval History'**
  String get approvalHistory;

  /// No description provided for @noApprovalRequests.
  ///
  /// In en, this message translates to:
  /// **'No approval requests'**
  String get noApprovalRequests;

  /// No description provided for @createCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create Campaign'**
  String get createCampaign;

  /// No description provided for @campaignName.
  ///
  /// In en, this message translates to:
  /// **'Campaign Name'**
  String get campaignName;

  /// No description provided for @campaignDescription.
  ///
  /// In en, this message translates to:
  /// **'Campaign Description'**
  String get campaignDescription;

  /// No description provided for @per1000Views.
  ///
  /// In en, this message translates to:
  /// **'/ 1000 views'**
  String get per1000Views;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available!'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username must be 3-20 characters, lowercase letters, numbers, underscores only'**
  String get usernameInvalid;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Successful!'**
  String get signUpSuccess;

  /// No description provided for @welcomeToZeroGrid.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zero Grid!'**
  String get welcomeToZeroGrid;

  /// No description provided for @activeCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Active Campaigns'**
  String get activeCampaigns;

  /// No description provided for @completedCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Completed Campaigns'**
  String get completedCampaigns;

  /// No description provided for @submissionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submission Successful!'**
  String get submissionSuccess;

  /// No description provided for @submissionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your video has been submitted for review.'**
  String get submissionSuccessMessage;

  /// No description provided for @joinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Joined Successfully!'**
  String get joinSuccess;

  /// No description provided for @joinSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You have successfully joined the campaign.'**
  String get joinSuccessMessage;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @startBySettingUpLogin.
  ///
  /// In en, this message translates to:
  /// **'Start by setting up your login details'**
  String get startBySettingUpLogin;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @haveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @pleaseFillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillInAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @uploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Upload Profile Picture'**
  String get uploadProfilePicture;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter Display Name'**
  String get enterDisplayName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @enterEmailForResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a 6-digit code to reset your password.'**
  String get enterEmailForResetCode;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @resetCodeSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your email. Enter it in the next screen.'**
  String get resetCodeSentSuccess;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @backTo.
  ///
  /// In en, this message translates to:
  /// **'Back to '**
  String get backTo;

  /// No description provided for @resetCodeSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it below to continue.'**
  String resetCodeSentDescription(String email);

  /// No description provided for @failedToVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify code: {error}'**
  String failedToVerifyCode(String error);

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code to your email.'**
  String get newCodeSent;

  /// No description provided for @failedToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code: {error}'**
  String failedToResendCode(String error);

  /// No description provided for @enterNewPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password to finish account recovery.'**
  String get enterNewPasswordInstruction;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinLength;

  /// No description provided for @reEnterPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password to confirm.'**
  String get reEnterPasswordInstruction;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please log in with your new password.'**
  String get passwordUpdated;

  /// No description provided for @passwordsMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match and be at least 8 characters.'**
  String get passwordsMustMatch;

  /// No description provided for @signUpSuccessWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zero Grid,'**
  String get signUpSuccessWelcome;

  /// No description provided for @allSetMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set. Time to earn and create!'**
  String get allSetMessage;

  /// No description provided for @failedToCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to create user'**
  String get failedToCreateUser;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @payPerView.
  ///
  /// In en, this message translates to:
  /// **'Pay per View'**
  String get payPerView;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @earnPerViews.
  ///
  /// In en, this message translates to:
  /// **'You can earn ¥{price} per {views} views...'**
  String earnPerViews(String price, String views);

  /// No description provided for @feedbackHelpsUs.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve\nand serve you better'**
  String get feedbackHelpsUs;

  /// No description provided for @tellUsSomething.
  ///
  /// In en, this message translates to:
  /// **'Tell us something'**
  String get tellUsSomething;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @shareFeedback.
  ///
  /// In en, this message translates to:
  /// **'Share Feedback'**
  String get shareFeedback;

  /// No description provided for @campaignPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Campaign posted successfully!'**
  String get campaignPostedSuccess;

  /// No description provided for @failedToPost.
  ///
  /// In en, this message translates to:
  /// **'Failed to post: {error}'**
  String failedToPost(String error);

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @projectComingToLife.
  ///
  /// In en, this message translates to:
  /// **'Your Project is Coming to Life!'**
  String get projectComingToLife;

  /// No description provided for @projectReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'ll be ready in just a moment — we\'re putting everything together for you.'**
  String get projectReadyMessage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} total spent'**
  String totalSpent(String amount);

  /// No description provided for @needHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Need help? We\'re here to support you'**
  String get needHelpSupport;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @browseFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse common questions and answers'**
  String get browseFaqSubtitle;

  /// No description provided for @askForHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask for Help'**
  String get askForHelp;

  /// No description provided for @askHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you need help with'**
  String get askHelpSubtitle;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get stillNeedHelp;

  /// No description provided for @supportTeamReady.
  ///
  /// In en, this message translates to:
  /// **'Our support team is ready to assist you.'**
  String get supportTeamReady;

  /// No description provided for @findQuickAnswers.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers or get help when you need it'**
  String get findQuickAnswers;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get howCanWeHelp;

  /// No description provided for @tellUsAndHearBack.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s going on, and you\'ll hear back by email'**
  String get tellUsAndHearBack;

  /// No description provided for @noSensitiveInfo.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t include sensitive information'**
  String get noSensitiveInfo;

  /// No description provided for @howFeelAboutZeroGrid.
  ///
  /// In en, this message translates to:
  /// **'How do you feel about ZeroGrid?'**
  String get howFeelAboutZeroGrid;

  /// No description provided for @feedbackExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. love the app! keep it up'**
  String get feedbackExampleHint;

  /// No description provided for @faqQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String faqQuestion(int number);

  /// No description provided for @faqAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer of question {number}'**
  String faqAnswer(int number);

  /// No description provided for @bankAccountSaved.
  ///
  /// In en, this message translates to:
  /// **'Bank account saved!'**
  String get bankAccountSaved;

  /// No description provided for @enterBankName.
  ///
  /// In en, this message translates to:
  /// **'Enter bank name'**
  String get enterBankName;

  /// No description provided for @enterBranchName.
  ///
  /// In en, this message translates to:
  /// **'Enter branch name'**
  String get enterBranchName;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get enterAccountNumber;

  /// No description provided for @enterAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter account holder name'**
  String get enterAccountHolderName;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted!'**
  String get reviewSubmitted;

  /// No description provided for @shareExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get shareExperienceHint;

  /// No description provided for @failedToPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick video: {error}'**
  String failedToPickVideo(String error);

  /// No description provided for @videoMaxSize500mb.
  ///
  /// In en, this message translates to:
  /// **'Video must be under 500MB'**
  String get videoMaxSize500mb;

  /// No description provided for @failedToUpload.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload: {error}'**
  String failedToUpload(String error);

  /// No description provided for @videoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video title'**
  String get videoTitle;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'No account connected'**
  String get noAccountConnected;

  /// No description provided for @estimated.
  ///
  /// In en, this message translates to:
  /// **'estimated'**
  String get estimated;

  /// No description provided for @estimatedPending.
  ///
  /// In en, this message translates to:
  /// **'Estimated Pending'**
  String get estimatedPending;

  /// No description provided for @noApprovedSubmissionsYet.
  ///
  /// In en, this message translates to:
  /// **'No approved submissions yet'**
  String get noApprovedSubmissionsYet;

  /// No description provided for @submitVideosToEarn.
  ///
  /// In en, this message translates to:
  /// **'Submit videos to campaigns to start earning!'**
  String get submitVideosToEarn;

  /// No description provided for @postingPermissionsOnly.
  ///
  /// In en, this message translates to:
  /// **'Only posting permissions are requested. You can disconnect anytime.'**
  String get postingPermissionsOnly;

  /// No description provided for @createWithAI.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get createWithAI;

  /// No description provided for @createManually.
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get createManually;

  /// No description provided for @letsStartWithBasics.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start with the Basics'**
  String get letsStartWithBasics;

  /// No description provided for @giveCreatorsClearIdea.
  ///
  /// In en, this message translates to:
  /// **'Give creators a clear idea of what this project is about'**
  String get giveCreatorsClearIdea;

  /// No description provided for @describeCreatorExpectations.
  ///
  /// In en, this message translates to:
  /// **'Describe what creators are expected to do'**
  String get describeCreatorExpectations;

  /// No description provided for @selectCategoryAndPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Select Category and Platforms'**
  String get selectCategoryAndPlatforms;

  /// No description provided for @chooseCategoryFitsProject.
  ///
  /// In en, this message translates to:
  /// **'Choose category that fits your project'**
  String get chooseCategoryFitsProject;

  /// No description provided for @chooseWhereClipsPosted.
  ///
  /// In en, this message translates to:
  /// **'Choose where the creators\' clips will be posted'**
  String get chooseWhereClipsPosted;

  /// No description provided for @setViewGoal.
  ///
  /// In en, this message translates to:
  /// **'Set the view goal you want this project to reach'**
  String get setViewGoal;

  /// No description provided for @adjustAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can adjust this anytime'**
  String get adjustAnytime;

  /// No description provided for @suggestRangesBasedOnCategory.
  ///
  /// In en, this message translates to:
  /// **'We\'ll suggest ranges based on your category and target views'**
  String get suggestRangesBasedOnCategory;

  /// No description provided for @insufficientBalanceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Available: ¥{available}'**
  String insufficientBalanceAvailable(String available);

  /// No description provided for @setProjectTimeline.
  ///
  /// In en, this message translates to:
  /// **'Set Your Project Timeline'**
  String get setProjectTimeline;

  /// No description provided for @chooseProjectDates.
  ///
  /// In en, this message translates to:
  /// **'Choose when the project starts and when it wraps up'**
  String get chooseProjectDates;

  /// No description provided for @dateFormatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'YYYY/MM/DD'**
  String get dateFormatPlaceholder;

  /// No description provided for @projectAutoInactive.
  ///
  /// In en, this message translates to:
  /// **'The project will automatically become inactive when the end date is reached'**
  String get projectAutoInactive;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @uploadFilesOrLinks.
  ///
  /// In en, this message translates to:
  /// **'Upload files or add links to help creators produce better content'**
  String get uploadFilesOrLinks;

  /// No description provided for @supportedFileFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported: JPG, PNG, SVG, MP4, PDF, ZIP'**
  String get supportedFileFormats;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get addLink;

  /// No description provided for @pasteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste link here...'**
  String get pasteLinkHint;

  /// No description provided for @addAnother.
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get addAnother;

  /// No description provided for @uploadedVideo.
  ///
  /// In en, this message translates to:
  /// **'Uploaded video'**
  String get uploadedVideo;

  /// No description provided for @postedToPlatform.
  ///
  /// In en, this message translates to:
  /// **'Posted to {platform}'**
  String postedToPlatform(String platform);

  /// No description provided for @snsPostingFailed.
  ///
  /// In en, this message translates to:
  /// **'SNS posting failed'**
  String get snsPostingFailed;

  /// No description provided for @postingToPlatform.
  ///
  /// In en, this message translates to:
  /// **'Posting to {platform}...'**
  String postingToPlatform(String platform);

  /// No description provided for @submissionApprovedAutoPosting.
  ///
  /// In en, this message translates to:
  /// **'Submission approved! Auto-posting to SNS...'**
  String get submissionApprovedAutoPosting;

  /// No description provided for @submissionRejected.
  ///
  /// In en, this message translates to:
  /// **'Submission rejected'**
  String get submissionRejected;

  /// No description provided for @submissionApproved.
  ///
  /// In en, this message translates to:
  /// **'Submission Approved'**
  String get submissionApproved;

  /// No description provided for @submissionApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your submission for \"{campaignName}\" was approved!'**
  String submissionApprovedBody(String campaignName);

  /// No description provided for @submissionRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your submission for \"{campaignName}\" was rejected.'**
  String submissionRejectedBody(String campaignName);

  /// No description provided for @failedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSend(String error);

  /// No description provided for @failedToLoadPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment methods: {error}'**
  String failedToLoadPaymentMethods(String error);

  /// No description provided for @failedToAddCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to add card: {error}'**
  String failedToAddCard(String error);

  /// No description provided for @failedToRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove card: {error}'**
  String failedToRemoveCard(String error);

  /// No description provided for @paymentNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment not yet confirmed. Please complete payment in the browser and try again.'**
  String get paymentNotConfirmed;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailed(String error);

  /// No description provided for @checkPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Payment Status'**
  String get checkPaymentStatus;

  /// No description provided for @addedToBalance.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to your balance.'**
  String addedToBalance(String amount);

  /// No description provided for @minimumWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Minimum withdrawal is ¥1,000'**
  String get minimumWithdrawal;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @withdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount} to your bank account?'**
  String withdrawConfirm(String amount);

  /// No description provided for @withdrawalProcessed.
  ///
  /// In en, this message translates to:
  /// **'{amount} withdrawal processed!'**
  String withdrawalProcessed(String amount);

  /// No description provided for @withdrawSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'To withdraw funds, you need to set up your payout account through Stripe.'**
  String get withdrawSetupDescription;

  /// No description provided for @setUpNow.
  ///
  /// In en, this message translates to:
  /// **'Set Up Now'**
  String get setUpNow;

  /// No description provided for @accountVerifyingStripe.
  ///
  /// In en, this message translates to:
  /// **'Your account is being verified by Stripe. This usually takes 1-2 business days.'**
  String get accountVerifyingStripe;

  /// No description provided for @completeSetupForWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Please complete your account setup to enable withdrawals.'**
  String get completeSetupForWithdrawals;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// No description provided for @continueSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get continueSetup;

  /// No description provided for @withdrawalMinAndTiming.
  ///
  /// In en, this message translates to:
  /// **'Minimum ¥1,000 · Funds arrive in 2-5 business days'**
  String get withdrawalMinAndTiming;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryPodcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get categoryPodcast;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @connectedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} connected'**
  String connectedCountLabel(int count);

  /// No description provided for @howDoYouWantToCreate.
  ///
  /// In en, this message translates to:
  /// **'How Do You Want to Create This Project?'**
  String get howDoYouWantToCreate;

  /// No description provided for @startFromShortIdea.
  ///
  /// In en, this message translates to:
  /// **'Start from a short idea and let AI draft the details for you'**
  String get startFromShortIdea;

  /// No description provided for @buildProjectStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Build your project step by step with full control'**
  String get buildProjectStepByStep;

  /// No description provided for @tokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Token expired — reconnect required'**
  String get tokenExpired;

  /// No description provided for @tokenExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Token expires soon'**
  String get tokenExpiringSoon;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
