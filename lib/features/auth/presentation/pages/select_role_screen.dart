// lib/features/auth/presentation/pages/select_role_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../data/models/user_role.dart';
import '../../../../shared/theme/app_theme.dart';

class SelectRoleScreen extends StatefulWidget {
  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen>
    with SingleTickerProviderStateMixin {
  // true = Creator (yellow), false = Organizer (blue)
  bool _isCreator = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _buttonColorAnimation;
  late Animation<Color?> _buttonShadowAnimation;

  // Duolingo button colors
  static const Color _organizerButtonColor = Color(0xFF2090FF);
  static const Color _organizerShadowColor = Color(0xFF1A73CC);
  static const Color _creatorButtonColor = Color(0xFFFBBF24);
  static const Color _creatorShadowColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _buttonColorAnimation = ColorTween(
      begin: _creatorButtonColor,
      end: _organizerButtonColor,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _buttonShadowAnimation = ColorTween(
      begin: _creatorShadowColor,
      end: _organizerShadowColor,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectRole(bool isCreator) {
    if (_isCreator == isCreator) return;
    setState(() {
      _isCreator = isCreator;
    });
    if (isCreator) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
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
        child: Column(
          children: [
            // Top gradient area - animated color
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
                  stops: const [0.0, 0.7],
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

                    SizedBox(height: SpacePalette.lg + SpacePalette.sm),

                    // Role selector slider
                    _buildRoleSelector(),

                    SizedBox(height: SpacePalette.lg),

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
              padding: const EdgeInsets.all(SpacePalette.lg),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return _buildDuolingoButton(
                    text: 'Count Me In!',
                    color: _buttonColorAnimation.value ?? _creatorButtonColor,
                    shadowColor: _buttonShadowAnimation.value ?? _creatorShadowColor,
                    onPressed: _onContinue,
                  );
                },
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
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - SpacePalette.lg - 4,
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

  Widget _buildDuolingoButton({
    required String text,
    required Color color,
    required Color shadowColor,
    required VoidCallback onPressed,
  }) {
    const double shadowOffset = 4.0;
    const double buttonHeight = 52.0;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: buttonHeight + shadowOffset,
        child: Stack(
          children: [
            // Shadow layer (4px below)
            Positioned(
              left: 0,
              right: 0,
              top: shadowOffset,
              height: buttonHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(RadiusPalette.lg),
                ),
              ),
            ),
            // Surface layer (top)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: buttonHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(RadiusPalette.lg),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStylePalette.miniTitle.copyWith(
                      color: ColorPalette.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
