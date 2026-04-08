// lib/app_wrapper.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/reset_password_screen.dart';
import 'features/auth/presentation/pages/select_role_screen.dart';
import 'features/auth/presentation/pages/signup_screen2.dart';
import 'features/auth/presentation/providers/user_profile_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/models/user_role.dart';
import 'features/organizer/payment/data/services/payment_service.dart';
import 'features/organizer/approval/presentation/providers/approval_provider.dart';
import 'features/organizer/payment/presentation/providers/payment_provider.dart';
import 'features/creator/submission/presentation/providers/submission_providers.dart';
import 'shared/theme/main_layout.dart';
import 'shared/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  bool _showResetPassword = false;
  StreamSubscription<AuthState>? _authStateSub;
  StreamSubscription<Uri>? _deepLinkSub;
  AppLinks? _appLinks;

  @override
  void initState() {
    super.initState();
    _initializeRecoveryHandlers();
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Map<String, String> _fragmentParams(String fragment) {
    if (fragment.isEmpty) return const {};
    return Uri.splitQueryString(fragment);
  }

  bool _isRecoveryUri(Uri uri) {
    final queryType = uri.queryParameters['type'];
    final fragmentType = _fragmentParams(uri.fragment)['type'];
    final isResetHost =
        uri.scheme == 'io.zerogrid.app' && uri.host == 'reset-password';
    final isResetWebPath = uri.path == '/auth/reset-password';
    return isResetHost ||
        isResetWebPath ||
        queryType == 'recovery' ||
        fragmentType == 'recovery';
  }

  void _handleRecoveryUri(Uri? uri) {
    if (uri == null || !_isRecoveryUri(uri) || !mounted) return;
    setState(() => _showResetPassword = true);
  }

  Future<void> _initializeRecoveryHandlers() async {
    _authStateSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        setState(() => _showResetPassword = true);
      } else if (data.event == AuthChangeEvent.signedIn ||
                 data.event == AuthChangeEvent.signedOut) {
        setState(() {});
      }
    });

    if (kIsWeb) {
      _handleRecoveryUri(Uri.base);
      return;
    }

    _appLinks = AppLinks();
    try {
      final initialUri = await _appLinks!.getInitialLink();
      _handleRecoveryUri(initialUri);
    } catch (_) {
      // Ignore malformed deep links and continue normal flow.
    }

    _deepLinkSub = _appLinks!.uriLinkStream.listen(
      _handleRecoveryUri,
      onError: (_) {},
    );
  }

  void _completeRecoveryFlow() {
    if (!mounted) return;
    setState(() => _showResetPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetPassword) {
      return ResetPasswordScreen(onCompleted: _completeRecoveryFlow);
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return SelectRoleScreen();
    }

    return _LoggedInWrapper();
  }
}

class _LoggedInWrapper extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    // プロフィールロード（未ロードの場合）
    if (!profileState.hasLoaded && !profileState.isLoading) {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).loadProfile();
      });
    }

    // 初回ローディング中（プロフィール未取得）
    if (!profileState.hasLoaded || (profileState.isLoading && profileState.profile == null)) {
      return Scaffold(
        backgroundColor: ColorPalette.white,
        body: Center(
          child: CircularProgressIndicator(color: ColorPalette.neutral800),
        ),
      );
    }

    // エラー or プロフィールがない → OAuthユーザーならプロフィール設定へ、それ以外はログアウト
    if (profileState.error != null || profileState.profile == null) {
      return _NoProfileScreen();
    }

    // 成功 → メイン画面
    final role = profileState.profile!.role == 'organizer'
        ? UserRole.organizer
        : UserRole.creator;

    return _CheckoutReturnHandler(
      child: MainLayout(userRole: role),
    );
  }
}

/// Handles Stripe Checkout return (processes pending checkout_session_id)
/// This is a fallback for when the app is restarted after Stripe payment.
/// The primary flow is handled in SelectAmountScreen.
class _CheckoutReturnHandler extends ConsumerStatefulWidget {
  final Widget child;
  const _CheckoutReturnHandler({required this.child});

  @override
  ConsumerState<_CheckoutReturnHandler> createState() =>
      _CheckoutReturnHandlerState();
}

class _CheckoutReturnHandlerState extends ConsumerState<_CheckoutReturnHandler>
    with WidgetsBindingObserver {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleCheckoutReturn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleCheckoutReturn();
    }
  }

  Future<void> _handleCheckoutReturn() async {
    if (_isProcessing) return;
    final prefs = await SharedPreferences.getInstance();

    // Handle deposit confirmation
    final sessionId = prefs.getString('pending_checkout_session_id');
    if (sessionId != null) {
      _isProcessing = true;
      await prefs.remove('pending_checkout_session_id');
      try {
        final paymentService = PaymentService();
        final newBalance =
            await paymentService.confirmCheckoutDeposit(sessionId);

        // Update balance provider so Dashboard reflects the new balance
        ref.read(walletBalanceProvider.notifier).state = newBalance;

        if (mounted) {
          _showSuccessDialog(
            AppLocalizations.of(context)!.depositSuccessful,
            '${AppLocalizations.of(context)!.depositProcessed}\n${AppLocalizations.of(context)!.newBalanceMessage(_formatNumber(newBalance))}',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.depositConfirmFailed(e.toString())),
              backgroundColor: ColorPalette.critical500,
            ),
          );
        }
      } finally {
        _isProcessing = false;
      }
    }

    // Handle payment method added
    final methodAdded = prefs.getBool('payment_method_added');
    if (methodAdded == true) {
      await prefs.remove('payment_method_added');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentMethodAdded),
            backgroundColor: ColorPalette.positive500,
          ),
        );
      }
    }
  }

  String _formatNumber(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIconsBold.checkCircle, color: ColorPalette.positive500),
            SizedBox(width: SpacePalette.sm),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// プロフィール未作成画面（OAuth後の新規ユーザー対応）
class _NoProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NoProfileScreen> createState() => _NoProfileScreenState();
}

class _NoProfileScreenState extends ConsumerState<_NoProfileScreen> {
  @override
  void initState() {
    super.initState();
    // SharedPreferencesからpending_oauth_roleを確認
    _checkOAuthRole();
  }

  Future<void> _checkOAuthRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString('pending_oauth_role');
    if (roleName != null && mounted) {
      await prefs.remove('pending_oauth_role');
      final role = roleName == 'organizer' ? UserRole.organizer : UserRole.creator;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SignUpScreen2(
            role: role,
            email: '',
            password: '',
            isOAuth: true,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsBold.userCircle, size: 64, color: ColorPalette.neutral400),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.profileNotFound,
                style: TextStylePalette.smallHeader,
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pleaseSignOutAndRegister,
                style: TextStylePalette.subText,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    ref.read(userProfileProvider.notifier).clear();
                    ref.invalidate(pendingRequestsProvider);
                    ref.invalidate(pendingRequestCountProvider);
                    ref.read(connectedProvidersProvider.notifier).state = {};
                    ref.read(socialConnectionsProvider.notifier).state = [];
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => SelectRoleScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.signOut, style: TextStylePalette.buttonTextWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
