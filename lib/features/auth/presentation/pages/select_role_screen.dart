// lib/features/auth/presentation/pages/select_role_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../data/models/user_role.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/duolingo_form_components.dart';

class SelectRoleScreen extends StatefulWidget {
  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen>
{
  // true = Creator (yellow), false = Organizer (blue)
  bool _isCreator = true;

  // Duolingo button colors
  static const Color _organizerButtonColor = Color(0xFF2090FF);
  static const Color _organizerShadowColor = Color(0xFF1A73CC);
  static const Color _creatorButtonColor = Color(0xFFFBBF24);
  static const Color _creatorShadowColor = Color(0xFFF59E0B);

  void _selectRole(bool isCreator) {
    if (_isCreator == isCreator) return;
    setState(() {
      _isCreator = isCreator;
    });
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          role: _isCreator ? UserRole.creator : UserRole.organizer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Top gradient area
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _isCreator
                            ? _creatorButtonColor.withOpacity(0.15)
                            : _organizerButtonColor.withOpacity(0.15),
                        ColorPalette.white,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacePalette.lg,
                      vertical: SpacePalette.lg,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: SpacePalette.lg),
                        // Welcome text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome! ',
                              style: TextStylePalette.header.copyWith(
                                fontSize: 32,
                                color: ColorPalette.neutral800,
                              ),
                            ),
                            const Text(
                              '👋',
                              style: TextStyle(fontSize: FontSizePalette.size24),
                            ),
                          ],
                        ),
                        SizedBox(height: SpacePalette.sm),
                        Text(
                          'Tell us which side are you?',
                          style: TextStylePalette.normalText.copyWith(
                            color: ColorPalette.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacePalette.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge - centered, fade only
                        SizedBox(
                          height: 140,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Image.asset(
                              _isCreator
                                  ? 'assets/images/welcome_creator_badge.png'
                                  : 'assets/images/welcome_organizer_badge.png',
                              key: ValueKey('badge_$_isCreator'),
                              height: 120,
                            ),
                          ),
                        ),

                        SizedBox(height: SpacePalette.base),

                        // Description text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isCreator
                                ? 'Content-makers and storytelling pros'
                                : 'Brands, teams, and campaign owners',
                            key: ValueKey(_isCreator),
                            style: TextStylePalette.normalText.copyWith(
                              color: ColorPalette.neutral500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: SpacePalette.lg * 3),

                        // Role selector slider
                        _buildRoleSelector(),

                        SizedBox(height: SpacePalette.lg * 3),

                        // Stats text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isCreator
                                ? '¥500,000 paid to creators every month'
                                : '500+ talented creators',
                            key: ValueKey('stats_$_isCreator'),
                            style: TextStylePalette.smText.copyWith(
                              color: ColorPalette.neutral400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.all(SpacePalette.base),
                  child: DuolingoButton(
                    onPressed: _onContinue,
                    isEnabled: true,
                    isLoading: false,
                    text: 'Count Me In!',
                    buttonColor: _isCreator
                        ? _creatorButtonColor
                        : _organizerButtonColor,
                    shadowColor: _isCreator
                        ? _creatorShadowColor
                        : _organizerShadowColor,
                  ),
                ),

                // Home indicator area
                Container(
                  width: 134,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: SpacePalette.sm),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral800,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ColorPalette.neutral100,
        borderRadius: BorderRadius.circular(RadiusPalette.lg),
      ),
      child: Stack(
        children: [
          // Animated indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: _isCreator ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 48,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  borderRadius: BorderRadius.circular(RadiusPalette.base),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.neutral800.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectRole(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStylePalette.miniTitle.copyWith(
                        color: !_isCreator
                            ? _organizerButtonColor
                            : ColorPalette.neutral400,
                        fontWeight: !_isCreator ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: const Text('Organizer'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectRole(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStylePalette.miniTitle.copyWith(
                        color: _isCreator
                            ? _creatorButtonColor
                            : ColorPalette.neutral400,
                        fontWeight: _isCreator ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: const Text('Creator'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
