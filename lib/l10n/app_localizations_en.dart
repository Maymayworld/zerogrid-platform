// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zero Grid';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get uploading => 'Uploading...';

  @override
  String get add => 'Add';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get remove => 'Remove';

  @override
  String get submit => 'Submit';

  @override
  String get joinCampaign => 'Join';

  @override
  String get jumpToList => 'Jump to List';

  @override
  String nMembers(Object count) {
    return '$count members';
  }

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get logIn => 'Log In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get newHere => 'New here? ';

  @override
  String get welcome => 'Welcome! ';

  @override
  String get tellUsWhichSide => 'Tell us which side are you?';

  @override
  String get contentMakers => 'Content-makers and storytelling pros';

  @override
  String get brandsTeams => 'Brands, teams, and campaign owners';

  @override
  String get paidToCreators => '¥500,000 paid to creators every month';

  @override
  String get talentedCreators => '500+ talented creators';

  @override
  String get countMeIn => 'Count Me In!';

  @override
  String get organizer => 'Organizer';

  @override
  String get creator => 'Creator';

  @override
  String get creators => 'creators';

  @override
  String get pickYourUsername => 'Pick Your Username';

  @override
  String get checking => 'Checking...';

  @override
  String get displayName => 'Display Name';

  @override
  String get optional => '(optional)';

  @override
  String get chooseFromLibrary => 'Choose From Library';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get pleaseEnterDisplayName => 'Please enter a display name';

  @override
  String get letsGo => 'Let\'s Go';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get enterCode => 'Enter Code';

  @override
  String resetCodeSent(String email) {
    return 'We sent a 6-digit code to $email. Check your inbox and enter it below.';
  }

  @override
  String get verifyCode => 'Verify code';

  @override
  String get resendCode => 'Resend code';

  @override
  String get enterResetCodeInstructions =>
      'Enter the 6-digit code from your email.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get pleaseSignOutAndRegister => 'Please sign out and register again.';

  @override
  String authErrorMessage(String message) {
    return 'Authentication error: $message';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get navFind => 'Find';

  @override
  String get navFeed => 'Feed';

  @override
  String get navCampaign => 'Campaign';

  @override
  String get navProfile => 'Profile';

  @override
  String get navHome => 'Home';

  @override
  String get navCampaigns => 'Campaigns';

  @override
  String get navChat => 'Chat';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get earnings => 'Earnings';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get followZeroGrid => 'Follow @ZeroGrid';

  @override
  String get payoutAccount => 'Payout Account';

  @override
  String get readyForWithdrawals => 'Ready for withdrawals';

  @override
  String get connected => 'Connected';

  @override
  String get verificationInProgress => 'Verification in progress';

  @override
  String get pending => 'Pending';

  @override
  String get setupPayoutAccount =>
      'Set up your payout account to withdraw earnings';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get deposit => 'Deposit';

  @override
  String get payment => 'Payment';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get languageSettings => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get connectedAccounts => 'Connected Accounts';

  @override
  String get youtube => 'YouTube';

  @override
  String get instagram => 'Instagram';

  @override
  String get tiktok => 'TikTok';

  @override
  String get googleCalendar => 'Google Calendar';

  @override
  String disconnectProvider(String providerName) {
    return 'Disconnect $providerName?';
  }

  @override
  String get disconnectConfirm =>
      'Are you sure you want to disconnect this account?';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'Once you delete your account there is no going back';

  @override
  String get accountDeletionUnavailable =>
      'Account deletion is not yet available.';

  @override
  String get settings => 'Settings';

  @override
  String get connectedServices => 'Connected Services';

  @override
  String get utilities => 'Utilities';

  @override
  String get connectSocialAccounts =>
      'Connect your social accounts to submit videos across platforms';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get chat => 'Chat';

  @override
  String get chatNotificationDesc =>
      'Direct messages from project owners and collaborators';

  @override
  String get earningsNotificationDesc =>
      'Notifications about your view count and earnings updates';

  @override
  String get news => 'News';

  @override
  String get newsNotificationDesc => 'New campaign alerts and platform updates';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profile => 'Profile';

  @override
  String get bankName => 'Bank Name';

  @override
  String get branchName => 'Branch Name';

  @override
  String get accountType => 'Account Type';

  @override
  String get ordinary => 'Ordinary';

  @override
  String get checkingAccount => 'Checking';

  @override
  String get savingsAccount => 'Savings';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get accountHolder => 'Account Holder';

  @override
  String get profileImageUpdated => 'Profile image updated!';

  @override
  String failedToUpdateImage(String error) {
    return 'Failed to update image: $error';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get balance => 'Balance';

  @override
  String get cumulativeTotalViews => 'Cumulative Total Views';

  @override
  String get allTime => 'All Time';

  @override
  String get totalViews => 'Total Views';

  @override
  String get yourProjects => 'Your Projects';

  @override
  String get name => 'Name';

  @override
  String get status => 'Status';

  @override
  String get myCampaigns => 'My Campaigns';

  @override
  String get searchCampaigns => 'Search campaigns';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get noCampaignsYet => 'No campaigns yet';

  @override
  String get joinCampaignsFromFind => 'Join campaigns from the Find tab!';

  @override
  String get createFirstCampaign => 'Create your first campaign to get started';

  @override
  String get failedToLoadCampaigns => 'Failed to load campaigns';

  @override
  String get selectCampaign => 'Select Campaign';

  @override
  String get noMatchingCampaigns => 'No matching campaigns';

  @override
  String get tryDifferentKeyword => 'Try a different keyword.';

  @override
  String get platforms => 'Platforms';

  @override
  String get manage => 'Manage';

  @override
  String get video => 'Video';

  @override
  String get title => 'Title';

  @override
  String get connectAnAccount => 'Connect an account';

  @override
  String get switchAccount => 'Switch';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get tapToSelectVideo => 'Tap to select a video';

  @override
  String get maxFileSize => 'Max 500MB · Up to 10 minutes';

  @override
  String get projectFiles => 'Project Files';

  @override
  String get cannotOpenLink => 'Cannot open this link';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get description => 'Description';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to leave a review!';

  @override
  String get leaveAReview => 'Leave a Review';

  @override
  String get rating => 'Rating';

  @override
  String get comment => 'Comment';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get likedProjects => 'Liked Projects';

  @override
  String get noLikedProjectsYet => 'No liked projects yet';

  @override
  String get findAndLikeCampaigns =>
      'Find campaigns and tap ♥ to save them here';

  @override
  String get earningHistory => 'Earning History';

  @override
  String get views => 'Views';

  @override
  String get earning => 'Earning';

  @override
  String get pastEarnings => 'Past Earnings';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get messageHint => 'Message...';

  @override
  String get noMessagesYetCreator =>
      'No messages yet.\nSay hi to the organizer!';

  @override
  String get delivered => 'Delivered';

  @override
  String get personalChat => 'Personal Chat';

  @override
  String get noMessagesYetStart => 'No messages yet.\nStart the conversation!';

  @override
  String get submissions => 'Submissions';

  @override
  String get all => 'All';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get noSubmissionsYet => 'No submissions yet';

  @override
  String get creatorsWillSubmitHere => 'Creators will submit videos here';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get approveSubmission => 'Approve Submission';

  @override
  String get rejectSubmission => 'Reject Submission';

  @override
  String get approveConfirm =>
      'Are you sure you want to approve this submission?';

  @override
  String get rejectConfirm =>
      'Are you sure you want to reject this submission?';

  @override
  String get addNoteOptional => 'Add a note (optional)...';

  @override
  String get editProject => 'Edit Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get targetViews => 'Target Views';

  @override
  String get budget => 'Budget';

  @override
  String get category => 'Category';

  @override
  String get viewSubmissions => 'View Submissions';

  @override
  String get reviewSubmissions => 'Review creator video submissions';

  @override
  String get tapToUpload => 'Tap to upload';

  @override
  String get removeCard => 'Remove Card';

  @override
  String removePaymentMethod(String method) {
    return 'Remove $method?';
  }

  @override
  String get cardRemoved => 'Card removed';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get depositSuccessful => 'Deposit Successful';

  @override
  String get depositProcessed => 'Your deposit has been processed.';

  @override
  String get paymentMethodAdded => 'Payment method added successfully';

  @override
  String depositConfirmFailed(String error) {
    return 'Deposit confirmation failed: $error';
  }

  @override
  String newBalanceMessage(String balance) {
    return 'New balance: ¥$balance';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get viewsAnalysis => 'Views Analysis';

  @override
  String get userRanking => 'User Ranking';

  @override
  String get user => 'User';

  @override
  String get videos => 'Videos';

  @override
  String get giveFeedback => 'Give Feedback';

  @override
  String get resources => 'Resources';

  @override
  String get account => 'Account';

  @override
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get approvalRequests => 'Approval Requests';

  @override
  String get approvalHistory => 'Approval History';

  @override
  String get noApprovalRequests => 'No approval requests';

  @override
  String get createCampaign => 'Create Campaign';

  @override
  String get campaignName => 'Campaign Name';

  @override
  String get campaignDescription => 'Campaign Description';

  @override
  String get per1000Views => '/ 1000 views';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get username => 'Username';

  @override
  String get usernameAvailable => 'Username is available!';

  @override
  String get usernameTaken => 'Username is already taken';

  @override
  String get usernameInvalid =>
      'Username must be 3-20 characters, lowercase letters, numbers, underscores only';

  @override
  String get signUpSuccess => 'Sign Up Successful!';

  @override
  String get welcomeToZeroGrid => 'Welcome to Zero Grid!';

  @override
  String get activeCampaigns => 'Active Campaigns';

  @override
  String get completedCampaigns => 'Completed Campaigns';

  @override
  String get submissionSuccess => 'Submission Successful!';

  @override
  String get submissionSuccessMessage =>
      'Your video has been submitted for review.';

  @override
  String get joinSuccess => 'Joined Successfully!';

  @override
  String get joinSuccessMessage => 'You have successfully joined the campaign.';

  @override
  String get or => 'or';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get startBySettingUpLogin => 'Start by setting up your login details';

  @override
  String get continueButton => 'Continue';

  @override
  String get haveAnAccount => 'Have an account? ';

  @override
  String get signIn => 'Sign In';

  @override
  String get pleaseFillInAllFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get uploadProfilePicture => 'Upload Profile Picture';

  @override
  String get enterDisplayName => 'Enter Display Name';

  @override
  String get createAccount => 'Create Account';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get enterEmailForResetCode =>
      'Enter your email and we\'ll send you a 6-digit code to reset your password.';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get resetCodeSentSuccess =>
      'We sent a 6-digit code to your email. Enter it in the next screen.';

  @override
  String get sendCode => 'Send code';

  @override
  String get backTo => 'Back to ';

  @override
  String resetCodeSentDescription(String email) {
    return 'We sent a 6-digit code to $email. Enter it below to continue.';
  }

  @override
  String failedToVerifyCode(String error) {
    return 'Failed to verify code: $error';
  }

  @override
  String get newCodeSent => 'We sent a new code to your email.';

  @override
  String failedToResendCode(String error) {
    return 'Failed to resend code: $error';
  }

  @override
  String get enterNewPasswordInstruction =>
      'Enter a new password to finish account recovery.';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters.';

  @override
  String get reEnterPasswordInstruction =>
      'Re-enter your new password to confirm.';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get passwordUpdated =>
      'Password updated. Please log in with your new password.';

  @override
  String get passwordsMustMatch =>
      'Passwords must match and be at least 8 characters.';

  @override
  String get signUpSuccessWelcome => 'Welcome to Zero Grid,';

  @override
  String get allSetMessage => 'You\'re all set. Time to earn and create!';

  @override
  String get failedToCreateUser => 'Failed to create user';

  @override
  String get filter => 'Filter';

  @override
  String get platform => 'Platform';

  @override
  String get payPerView => 'Pay per View';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get share => 'Share';

  @override
  String get messages => 'Messages';

  @override
  String get mail => 'Mail';

  @override
  String get notes => 'Notes';

  @override
  String earnPerViews(String price, String views) {
    return 'You can earn ¥$price per $views views...';
  }

  @override
  String get feedbackHelpsUs =>
      'Your feedback helps us improve\nand serve you better';

  @override
  String get tellUsSomething => 'Tell us something';

  @override
  String get thankYouForFeedback => 'Thank you for your feedback!';

  @override
  String get shareFeedback => 'Share Feedback';

  @override
  String get campaignPostedSuccess => 'Campaign posted successfully!';

  @override
  String failedToPost(String error) {
    return 'Failed to post: $error';
  }

  @override
  String get preview => 'Preview';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get noDescription => 'No description';

  @override
  String get post => 'Post';

  @override
  String get projectComingToLife => 'Your Project is Coming to Life!';

  @override
  String get projectReadyMessage =>
      'It\'ll be ready in just a moment — we\'re putting everything together for you.';

  @override
  String get edit => 'Edit';

  @override
  String totalSpent(String amount) {
    return '$amount total spent';
  }

  @override
  String get needHelpSupport => 'Need help? We\'re here to support you';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get browseFaqSubtitle => 'Browse common questions and answers';

  @override
  String get askForHelp => 'Ask for Help';

  @override
  String get askHelpSubtitle => 'Tell us what you need help with';

  @override
  String get stillNeedHelp => 'Still need help?';

  @override
  String get supportTeamReady => 'Our support team is ready to assist you.';

  @override
  String get findQuickAnswers =>
      'Find quick answers or get help when you need it';

  @override
  String get howCanWeHelp => 'How can we help?';

  @override
  String get tellUsAndHearBack =>
      'Tell us what\'s going on, and you\'ll hear back by email';

  @override
  String get noSensitiveInfo => 'Please don\'t include sensitive information';

  @override
  String get howFeelAboutZeroGrid => 'How do you feel about ZeroGrid?';

  @override
  String get feedbackExampleHint => 'e.g. love the app! keep it up';

  @override
  String faqQuestion(int number) {
    return 'Question $number';
  }

  @override
  String faqAnswer(int number) {
    return 'Answer of question $number';
  }

  @override
  String get bankAccountSaved => 'Bank account saved!';

  @override
  String get enterBankName => 'Enter bank name';

  @override
  String get enterBranchName => 'Enter branch name';

  @override
  String get enterAccountNumber => 'Enter account number';

  @override
  String get enterAccountHolderName => 'Enter account holder name';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get reviewSubmitted => 'Review submitted!';

  @override
  String get shareExperienceHint => 'Share your experience...';

  @override
  String failedToPickVideo(String error) {
    return 'Failed to pick video: $error';
  }

  @override
  String get videoMaxSize500mb => 'Video must be under 500MB';

  @override
  String failedToUpload(String error) {
    return 'Failed to upload: $error';
  }

  @override
  String get videoTitle => 'Video title';

  @override
  String get upload => 'Upload';

  @override
  String get noAccountConnected => 'No account connected';

  @override
  String get estimated => 'estimated';

  @override
  String get estimatedPending => 'Estimated Pending';

  @override
  String get noApprovedSubmissionsYet => 'No approved submissions yet';

  @override
  String get submitVideosToEarn =>
      'Submit videos to campaigns to start earning!';

  @override
  String get postingPermissionsOnly =>
      'Only posting permissions are requested. You can disconnect anytime.';

  @override
  String get createWithAI => 'Create with AI';

  @override
  String get createManually => 'Create Manually';

  @override
  String get letsStartWithBasics => 'Let\'s Start with the Basics';

  @override
  String get giveCreatorsClearIdea =>
      'Give creators a clear idea of what this project is about';

  @override
  String get describeCreatorExpectations =>
      'Describe what creators are expected to do';

  @override
  String get selectCategoryAndPlatforms => 'Select Category and Platforms';

  @override
  String get chooseCategoryFitsProject =>
      'Choose category that fits your project';

  @override
  String get chooseWhereClipsPosted =>
      'Choose where the creators\' clips will be posted';

  @override
  String get setViewGoal => 'Set the view goal you want this project to reach';

  @override
  String get adjustAnytime => 'You can adjust this anytime';

  @override
  String get suggestRangesBasedOnCategory =>
      'We\'ll suggest ranges based on your category and target views';

  @override
  String insufficientBalanceAvailable(String available) {
    return 'Insufficient balance. Available: ¥$available';
  }

  @override
  String get setProjectTimeline => 'Set Your Project Timeline';

  @override
  String get chooseProjectDates =>
      'Choose when the project starts and when it wraps up';

  @override
  String get dateFormatPlaceholder => 'YYYY/MM/DD';

  @override
  String get projectAutoInactive =>
      'The project will automatically become inactive when the end date is reached';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get uploadFilesOrLinks =>
      'Upload files or add links to help creators produce better content';

  @override
  String get supportedFileFormats => 'Supported: JPG, PNG, SVG, MP4, PDF, ZIP';

  @override
  String get addLink => 'Add Link';

  @override
  String get pasteLinkHint => 'Paste link here...';

  @override
  String get addAnother => 'Add Another';

  @override
  String get uploadedVideo => 'Uploaded video';

  @override
  String postedToPlatform(String platform) {
    return 'Posted to $platform';
  }

  @override
  String get snsPostingFailed => 'SNS posting failed';

  @override
  String postingToPlatform(String platform) {
    return 'Posting to $platform...';
  }

  @override
  String get submissionApprovedAutoPosting =>
      'Submission approved! Auto-posting to SNS...';

  @override
  String get submissionRejected => 'Submission rejected';

  @override
  String get submissionApproved => 'Submission Approved';

  @override
  String submissionApprovedBody(String campaignName) {
    return 'Your submission for \"$campaignName\" was approved!';
  }

  @override
  String submissionRejectedBody(String campaignName) {
    return 'Your submission for \"$campaignName\" was rejected.';
  }

  @override
  String failedToSend(String error) {
    return 'Failed to send: $error';
  }

  @override
  String failedToLoadPaymentMethods(String error) {
    return 'Failed to load payment methods: $error';
  }

  @override
  String failedToAddCard(String error) {
    return 'Failed to add card: $error';
  }

  @override
  String failedToRemoveCard(String error) {
    return 'Failed to remove card: $error';
  }

  @override
  String get paymentNotConfirmed =>
      'Payment not yet confirmed. Please complete payment in the browser and try again.';

  @override
  String paymentFailed(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get checkPaymentStatus => 'Check Payment Status';

  @override
  String addedToBalance(String amount) {
    return '$amount added to your balance.';
  }

  @override
  String get minimumWithdrawal => 'Minimum withdrawal is ¥1,000';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String withdrawConfirm(String amount) {
    return 'Withdraw $amount to your bank account?';
  }

  @override
  String withdrawalProcessed(String amount) {
    return '$amount withdrawal processed!';
  }

  @override
  String get withdrawSetupDescription =>
      'To withdraw funds, you need to set up your payout account through Stripe.';

  @override
  String get setUpNow => 'Set Up Now';

  @override
  String get accountVerifyingStripe =>
      'Your account is being verified by Stripe. This usually takes 1-2 business days.';

  @override
  String get completeSetupForWithdrawals =>
      'Please complete your account setup to enable withdrawals.';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get continueSetup => 'Continue Setup';

  @override
  String get withdrawalMinAndTiming =>
      'Minimum ¥1,000 · Funds arrive in 2-5 business days';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryPodcast => 'Podcast';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get viewMore => 'View More';

  @override
  String get anonymous => 'Anonymous';

  @override
  String connectedCountLabel(int count) {
    return '$count connected';
  }

  @override
  String get howDoYouWantToCreate => 'How Do You Want to Create This Project?';

  @override
  String get startFromShortIdea =>
      'Start from a short idea and let AI draft the details for you';

  @override
  String get buildProjectStepByStep =>
      'Build your project step by step with full control';

  @override
  String get tokenExpired => 'Token expired — reconnect required';

  @override
  String get tokenExpiringSoon => 'Token expires soon';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get completed => 'Completed';
}
