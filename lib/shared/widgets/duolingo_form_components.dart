// lib/shared/widgets/duolingo_form_components.dart
import 'package:flutter/material.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';

/// Duolingoスタイルのテキストフィールド
class DuolingoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;

  const DuolingoTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  static const double shadowOffset = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ButtonSizePalette.button + shadowOffset,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: shadowOffset,
            child: Container(
              height: ButtonSizePalette.button,
              decoration: BoxDecoration(
                color: ColorPalette.neutral200,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: ButtonSizePalette.button,
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
                border: Border.all(color: ColorPalette.neutral200),
              ),
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStylePalette.hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SpacePalette.base,
                    vertical: SpacePalette.inner,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duolingoスタイルのボタン
class DuolingoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  final String text;
  final IconData? trailingIcon;
  final bool enablePressAnimation;
  final Color? buttonColor;
  final Color? shadowColor;

  const DuolingoButton({
    Key? key,
    required this.onPressed,
    required this.isEnabled,
    this.isLoading = false,
    required this.text,
    this.trailingIcon,
    this.enablePressAnimation = true,
    this.buttonColor,
    this.shadowColor,
  }) : super(key: key);

  @override
  State<DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton> {
  bool _isPressed = false;

  static const double shadowOffset = 4.0;

  @override
  Widget build(BuildContext context) {
    final bool isPressed = widget.enablePressAnimation && _isPressed;
    final bool showShadow = widget.isEnabled && !isPressed;
    final Color activeButtonColor =
        widget.buttonColor ?? ColorPalette.smashedPumpkin600;
    final Color activeShadowColor =
        widget.shadowColor ?? ColorPalette.smashedPumpkin700;

    final buttonFace = Container(
      height: ButtonSizePalette.button,
      decoration: BoxDecoration(
        color: widget.isEnabled
            ? activeButtonColor
            : ColorPalette.neutral200,
        borderRadius: BorderRadius.circular(RadiusPalette.full),
      ),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: ColorPalette.white,
                  strokeWidth: 2,
                ),
              )
            : widget.trailingIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style: widget.isEnabled
                        ? TextStylePalette.buttonTextWhite
                        : TextStylePalette.buttonTextDisabled,
                  ),
                  SizedBox(width: SpacePalette.sm),
                  Icon(
                    widget.trailingIcon!,
                    size: 20,
                    color: widget.isEnabled
                        ? ColorPalette.white
                        : ColorPalette.neutral400,
                  ),
                ],
              )
            : Text(
                widget.text,
                style: widget.isEnabled
                    ? TextStylePalette.buttonTextWhite
                    : TextStylePalette.buttonTextDisabled,
              ),
      ),
    );

    return GestureDetector(
      onTapDown: widget.isEnabled && widget.enablePressAnimation
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.isEnabled
          ? (_) {
              if (widget.enablePressAnimation) {
                setState(() => _isPressed = false);
              }
              widget.onPressed();
            }
          : null,
      onTapCancel: widget.isEnabled && widget.enablePressAnimation
          ? () => setState(() => _isPressed = false)
          : null,
      child: SizedBox(
        height: ButtonSizePalette.button + shadowOffset,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: shadowOffset,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 50),
                opacity: showShadow ? 1 : 0,
                child: Container(
                  height: ButtonSizePalette.button,
                  decoration: BoxDecoration(
                    color: activeShadowColor,
                    borderRadius: BorderRadius.circular(RadiusPalette.full),
                  ),
                ),
              ),
            ),
            if (widget.enablePressAnimation)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                left: 0,
                right: 0,
                top: isPressed ? shadowOffset : 0,
                child: buttonFace,
              )
            else
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: buttonFace,
              ),
          ],
        ),
      ),
    );
  }
}

/// Duolingoスタイルのアウトラインボタン（白背景 + neutral200影）
class DuolingoOutlineButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;

  const DuolingoOutlineButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  State<DuolingoOutlineButton> createState() => _DuolingoOutlineButtonState();
}

class _DuolingoOutlineButtonState extends State<DuolingoOutlineButton> {
  bool _isPressed = false;

  static const double shadowOffset = 4.0;
  static const double buttonHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final bool showShadow = !_isPressed;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacePalette.base),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon!, size: 18, color: ColorPalette.neutral800),
            const SizedBox(width: SpacePalette.sm),
          ],
          Text(widget.text, style: TextStylePalette.smTitle),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: IntrinsicWidth(
        child: SizedBox(
          height: buttonHeight + shadowOffset,
          child: Stack(
            children: [
              if (showShadow)
                Positioned(
                  left: 0,
                  right: 0,
                  top: shadowOffset,
                  child: Container(
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral200,
                      borderRadius: BorderRadius.circular(RadiusPalette.full),
                    ),
                  ),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                left: 0,
                right: 0,
                top: _isPressed ? shadowOffset : 0,
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    borderRadius: BorderRadius.circular(RadiusPalette.full),
                    border: Border.all(
                      color: ColorPalette.neutral200,
                      width: 2,
                    ),
                  ),
                  child: Center(child: content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
