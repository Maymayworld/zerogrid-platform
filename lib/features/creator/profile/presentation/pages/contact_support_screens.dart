import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/duolingo_form_components.dart';
import 'package:zero_grid/l10n/app_localizations.dart';

enum ContactSupportPage { home, faq, askHelp, feedback }

class ContactSupportHomeScreen extends StatefulWidget {
  const ContactSupportHomeScreen({super.key});

  @override
  State<ContactSupportHomeScreen> createState() =>
      _ContactSupportHomeScreenState();
}

class _ContactSupportHomeScreenState extends State<ContactSupportHomeScreen> {
  ContactSupportPage _page = ContactSupportPage.home;

  void _goTo(ContactSupportPage page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.94,
          ),
          decoration: BoxDecoration(
            color: ColorPalette.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(RadiusPalette.lg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpacePalette.base,
                  SpacePalette.base,
                  SpacePalette.base,
                  SpacePalette.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E5E5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(PhosphorIconsRegular.x, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 22,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.contactSupport,
                        style: TextStylePalette.smallHeader,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildPage(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    switch (_page) {
      case ContactSupportPage.faq:
        return _FaqView(onAskHelp: () => _goTo(ContactSupportPage.askHelp));
      case ContactSupportPage.askHelp:
        return const _AskHelpView();
      case ContactSupportPage.feedback:
        return const _FeedbackView();
      case ContactSupportPage.home:
        return _HomeView(
          onTapFaq: () => _goTo(ContactSupportPage.faq),
          onTapAskHelp: () => _goTo(ContactSupportPage.askHelp),
          onTapFeedback: () => _goTo(ContactSupportPage.feedback),
        );
    }
  }
}

class _HomeView extends StatelessWidget {
  final VoidCallback onTapFaq;
  final VoidCallback onTapAskHelp;
  final VoidCallback onTapFeedback;

  const _HomeView({
    required this.onTapFaq,
    required this.onTapAskHelp,
    required this.onTapFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SpacePalette.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.needHelpSupport,
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          _SupportOptionTile(
            icon: PhosphorIconsRegular.question,
            title: AppLocalizations.of(context)!.frequentlyAskedQuestions,
            subtitle: AppLocalizations.of(context)!.browseFaqSubtitle,
            onTap: onTapFaq,
          ),
          SizedBox(height: SpacePalette.base),
          _SupportOptionTile(
            icon: PhosphorIconsRegular.chatCircle,
            title: AppLocalizations.of(context)!.askForHelp,
            subtitle: AppLocalizations.of(context)!.askHelpSubtitle,
            onTap: onTapAskHelp,
          ),
          SizedBox(height: SpacePalette.base),
          _SupportOptionTile(
            icon: PhosphorIconsRegular.chatText,
            title: AppLocalizations.of(context)!.giveFeedback,
            subtitle: AppLocalizations.of(context)!.resources,
            onTap: onTapFeedback,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _FaqView extends StatefulWidget {
  final VoidCallback onAskHelp;

  const _FaqView({required this.onAskHelp});

  @override
  State<_FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<_FaqView> {
  static const double _floatingHelpCardReservedSpace = 220;
  static const int _questionCount = 10;

  late final List<bool> _expanded = List<bool>.filled(
    _questionCount,
    false,
    growable: false,
  );

  Widget _buildQuestionCard(BuildContext context, int index) {
    final isExpanded = _expanded[index];
    return InkWell(
      borderRadius: BorderRadius.circular(RadiusPalette.xl),
      onTap: () {
        setState(() {
          _expanded[index] = !_expanded[index];
        });
      },
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusPalette.xl),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.faqQuestion(index + 1),
                    style: TextStylePalette.normalText,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    PhosphorIconsRegular.caretDown,
                    color: ColorPalette.neutral600,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: SpacePalette.xs),
              Text(
                AppLocalizations.of(context)!.faqAnswer(index + 1),
                style: TextStylePalette.smSubText,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SpacePalette.base),
      decoration: BoxDecoration(
        color: ColorPalette.white,
        borderRadius: BorderRadius.circular(RadiusPalette.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F737373),
            offset: Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.stillNeedHelp, style: TextStylePalette.smTitle),
          SizedBox(height: SpacePalette.xs),
          Text(
            AppLocalizations.of(context)!.supportTeamReady,
            style: TextStylePalette.smSubText,
          ),
          SizedBox(height: SpacePalette.sm),
          SizedBox(
            width: double.infinity,
            child: DuolingoOutlineButton(
              onPressed: widget.onAskHelp,
              text: AppLocalizations.of(context)!.contactSupport,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
            SpacePalette.base,
            SpacePalette.base,
            SpacePalette.base,
            _floatingHelpCardReservedSpace,
          ),
          children: [
            Text(
              AppLocalizations.of(context)!.findQuickAnswers,
              style: TextStylePalette.subText,
            ),
            SizedBox(height: SpacePalette.sm),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search,
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, color: Color(0xFFA3A3A3)),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            for (int i = 0; i < _questionCount; i++) ...[
              if (i > 0) SizedBox(height: SpacePalette.base),
              _buildQuestionCard(context, i),
            ],
          ],
        ),
        Positioned(
          left: SpacePalette.base,
          right: SpacePalette.base,
          bottom: SpacePalette.base,
          child: _buildFloatingHelpCard(context),
        ),
      ],
    );
  }
}

class _AskHelpView extends StatelessWidget {
  const _AskHelpView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SpacePalette.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.howCanWeHelp, style: TextStylePalette.smallHeader),
          SizedBox(height: SpacePalette.sm),
          Text(
            AppLocalizations.of(context)!.tellUsAndHearBack,
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.tellUsSomething, style: TextStylePalette.smTitle),
            ],
          ),
          SizedBox(height: SpacePalette.xs),
          SizedBox(
            height: 150,
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.noSensitiveInfo,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: SpacePalette.inner,
                  horizontal: SpacePalette.sm,
                ),
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          SizedBox(
            width: double.infinity,
            child: DuolingoButton(
              onPressed: () {},
              isEnabled: true,
              text: AppLocalizations.of(context)!.submit,
              buttonColor: const Color(0xFFFC6736),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  int _selectedIndex = 2; // デフォルトはニュートラル

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SpacePalette.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.giveFeedback, style: TextStylePalette.smallHeader),
          SizedBox(height: SpacePalette.sm),
          Text(
            AppLocalizations.of(context)!.feedbackHelpsUs,
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          Text(
            AppLocalizations.of(context)!.howFeelAboutZeroGrid,
            style: TextStylePalette.smTitle,
          ),
          SizedBox(height: SpacePalette.sm),
          _EmojiRatingRow(
            selectedIndex: _selectedIndex,
            onSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          SizedBox(height: SpacePalette.lg),
          Text(AppLocalizations.of(context)!.tellUsSomething, style: TextStylePalette.smTitle),
          SizedBox(height: SpacePalette.xs),
          SizedBox(
            height: 120,
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.feedbackExampleHint,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: SpacePalette.inner,
                  horizontal: SpacePalette.sm,
                ),
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          SizedBox(
            width: double.infinity,
            child: DuolingoButton(
              onPressed: () {},
              isEnabled: true,
              text: AppLocalizations.of(context)!.shareFeedback,
              buttonColor: const Color(0xFFFC6736),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusPalette.xl),
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.xl),
          border: Border.all(color: ColorPalette.neutral200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorPalette.neutral100,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: Icon(icon, size: 22, color: ColorPalette.neutral800),
            ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStylePalette.smTitle),
                  SizedBox(height: SpacePalette.xs),
                  Text(subtitle, style: TextStylePalette.smSubText),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, size: 20, color: ColorPalette.neutral400),
          ],
        ),
      ),
    );
  }
}

class _EmojiRatingRow extends StatelessWidget {
  const _EmojiRatingRow({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _emojis = ['😠', '😔', '😐', '😊', '🤩'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_emojis.length, (index) {
        final style = _cellStyle(index);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 56,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => onSelected(index),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: style.backgroundColor,
                    side: BorderSide(
                      color: style.borderColor,
                      width: style.borderWidth,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.lg),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _emojis[index],
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  _EmojiCellStyle _cellStyle(int index) {
    // 未選択状態
    Color border = ColorPalette.neutral200;
    double borderWidth = 1;
    Color? bg;

    if (index == selectedIndex) {
      borderWidth = 1.5;
      // very negative
      if (index == 0) {
        border = const Color(0xFFB91C1C);
        bg = const Color(0xFFFEE2E2);
      }
      // negative
      else if (index == 1) {
        border = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
      }
      // neutral
      else if (index == 2) {
        border = const Color(0xFF262626);
        bg = const Color(0xFFF5F5F5);
      }
      // positive
      else if (index == 3) {
        border = const Color(0xFF16A34A);
        bg = const Color(0xFFF0FDF4);
      }
      // very positive
      else if (index == 4) {
        border = const Color(0xFF15803D);
        bg = const Color(0xFFDCFCE7);
      }
    }

    return _EmojiCellStyle(
      borderColor: border,
      borderWidth: borderWidth,
      backgroundColor: bg,
    );
  }
}

class _EmojiCellStyle {
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;

  const _EmojiCellStyle({
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
  });
}
