import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';

enum ContactSupportPage {
  home,
  faq,
  askHelp,
  feedback,
}

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
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusPalette.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ハンドル
            Padding(
              padding: EdgeInsets.only(top: SpacePalette.sm),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // タイトル行（戻るボタン含む）
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacePalette.base,
                SpacePalette.base,
                SpacePalette.base,
                SpacePalette.sm,
              ),
              child: Row(
                children: [
                  if (_page != ContactSupportPage.home)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () {
                        if (_page == ContactSupportPage.home) {
                          Navigator.of(context).pop();
                        } else {
                          _goTo(ContactSupportPage.home);
                        }
                      },
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Contact Support',
                      style: TextStylePalette.smallHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildPage(context),
              ),
            ),
          ],
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(SpacePalette.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need help? We’re here to support you',
            style: TextStylePalette.smallHeader,
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Find quick answers, ask for help, or share feedback with the ZeroGrid team.',
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          _SupportOptionTile(
            icon: Icons.help_outline,
            title: 'Frequently Asked Questions',
            subtitle: 'Browse common questions and answers',
            onTap: onTapFaq,
          ),
          SizedBox(height: SpacePalette.sm),
          _SupportOptionTile(
            icon: Icons.chat_bubble_outline,
            title: 'Ask for Help',
            subtitle: 'Tell us what you need help with',
            onTap: onTapAskHelp,
          ),
          SizedBox(height: SpacePalette.sm),
          _SupportOptionTile(
            icon: Icons.feedback_outlined,
            title: 'Give Feedback',
            subtitle: 'Share ideas and help us improve',
            onTap: onTapFeedback,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _FaqView extends StatelessWidget {
  final VoidCallback onAskHelp;

  const _FaqView({required this.onAskHelp});

  @override
  Widget build(BuildContext context) {
    final questions = [
      'Question 1',
      'Question 2',
      'Question 3',
      'Question 4',
      'Question 5',
      'Question 6',
    ];

    return Padding(
      padding: EdgeInsets.all(SpacePalette.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find quick answers or get help when you need it',
            style: TextStylePalette.smallHeader,
          ),
          SizedBox(height: SpacePalette.sm),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          Expanded(
            child: ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: ColorPalette.neutral200,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    questions[index],
                    style: TextStylePalette.normalText,
                  ),
                  subtitle: index == 1
                      ? Text(
                          'Answer of question',
                          style: TextStylePalette.smSubText,
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ),
          SizedBox(height: SpacePalette.base),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SpacePalette.base),
            decoration: BoxDecoration(
              color: ColorPalette.white,
              borderRadius: BorderRadius.circular(RadiusPalette.base),
              border: Border.all(color: ColorPalette.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStylePalette.smTitle,
                ),
                SizedBox(height: SpacePalette.xs),
                Text(
                  'Our support team is ready to assist you.',
                  style: TextStylePalette.smSubText,
                ),
                SizedBox(height: SpacePalette.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAskHelp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.neutral800,
                      foregroundColor: ColorPalette.white,
                      padding: EdgeInsets.symmetric(
                        vertical: SpacePalette.inner,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(RadiusPalette.base),
                      ),
                    ),
                    child: const Text('Contact Support'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask for Help',
            style: TextStylePalette.smallHeader,
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Tell us what you need help with. We’ll get back to you as soon as we can.',
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          Text(
            'Subject',
            style: TextStylePalette.smTitle,
          ),
          SizedBox(height: SpacePalette.xs),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Briefly describe your issue',
            ),
          ),
          SizedBox(height: SpacePalette.base),
          Text(
            'Details',
            style: TextStylePalette.smTitle,
          ),
          SizedBox(height: SpacePalette.xs),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText:
                    'Please provide any details that can help us understand the situation.',
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.neutral800,
                foregroundColor: ColorPalette.white,
                padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
              ),
              child: const Text('Send'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Give Feedback',
            style: TextStylePalette.smallHeader,
          ),
          SizedBox(height: SpacePalette.sm),
          Text(
            'Your feedback helps us improve and serve you better.',
            style: TextStylePalette.subText,
          ),
          SizedBox(height: SpacePalette.lg),
          Text(
            'How do you feel about ZeroGrid?',
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
          Text(
            'Tell us something',
            style: TextStylePalette.smTitle,
          ),
          SizedBox(height: SpacePalette.xs),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g. love the app! keep it up',
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.neutral800,
                foregroundColor: ColorPalette.white,
                padding: EdgeInsets.symmetric(vertical: SpacePalette.inner),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
              ),
              child: const Text('Share Feedback'),
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
      borderRadius: BorderRadius.circular(RadiusPalette.base),
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
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
              child: Icon(
                icon,
                size: 22,
                color: ColorPalette.neutral800,
              ),
            ),
            SizedBox(width: SpacePalette.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.xs),
                  Text(
                    subtitle,
                    style: TextStylePalette.smSubText,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: ColorPalette.neutral400,
            ),
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

  static const _emojis = ['😡', '😕', '😐', '🙂', '😂'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_emojis.length, (index) {
        final style = _cellStyle(index);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacePalette.xs),
            child: OutlinedButton(
              onPressed: () => onSelected(index),
              style: OutlinedButton.styleFrom(
                backgroundColor: style.backgroundColor,
                side: BorderSide(
                  color: style.borderColor,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                ),
              ),
              child: Text(
                _emojis[index],
                style: const TextStyle(fontSize: 22),
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
    Color? bg;

    if (index == selectedIndex) {
      // very negative
      if (index == 0) {
        border = Colors.redAccent;
        bg = const Color(0xFFFFEBEE); // light red
      }
      // negative
      else if (index == 1) {
        border = Colors.redAccent;
        bg = Colors.white;
      }
      // neutral
      else if (index == 2) {
        border = ColorPalette.neutral800;
        bg = Colors.white;
      }
      // positive
      else if (index == 3) {
        border = const Color(0xFF4CAF50);
        bg = Colors.white;
      }
      // very positive
      else if (index == 4) {
        border = const Color(0xFF4CAF50);
        bg = const Color(0xFFE8F5E9); // light green
      }
    }

    return _EmojiCellStyle(borderColor: border, backgroundColor: bg);
  }
}

class _EmojiCellStyle {
  final Color borderColor;
  final Color? backgroundColor;

  const _EmojiCellStyle({
    required this.borderColor,
    required this.backgroundColor,
  });
}


