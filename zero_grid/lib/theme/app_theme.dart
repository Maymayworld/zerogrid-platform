// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// フォントはinterを使用
// 太字はFontWeight.w600を使用

Color backgroundColor = const Color(0xFFFFFFFF);
Color subBackgroundColor = const Color(0xFFF5F5F5);
Color progressColor = const Color(0xFF22C55E);

// カラーパレット
class ColorPalette {
  // 基本色
  // 基本背景色, 白テキスト色
  Color neutral0 = const Color(0xFFffffff);
  Color neutral50 = const Color(0xFFfafafa);
  // 薄いボックス背景色
  Color neutral100 = const Color(0xFFf5f5f5);
  // 区切り線, 枠線色
  Color neutral200 = const Color(0xFFe5e5e5);
  Color neutral300 = const Color(0xFFd4d4d4);
  // ヒントテキスト色
  Color neutral400 = const Color(0xFFa3a3a3);
  // グレーテキスト色
  Color neutral500 = const Color(0xFF737373);
  Color neutral600 = const Color(0xFF525252);
  Color neutral700 = const Color(0xFF404040);
  Color neutral800 = const Color(0xFF262626);
  // 黒テキスト色
  Color neutral900 = const Color(0xFF171717);
  Color neutral950 = const Color(0xFF0a0a0a);
  Color neutral1000 = const Color(0xFF000000);

  // システムカラー
  Color systemGreen = const Color(0xFF22C55E);
}

// フォントサイズ
class FontSizePalette {
  static const double xs = 10.0;
  // 注意書き、カード内テキスト等の文字サイズ
  static const double sm = 12.0;
  // フィールド上、カード内ボタン内等の文字サイズ
  static const double base = 14.0;
  // 横長ボタン, AppBarヘッダーの文字サイズ
  static const double md = 16.0;
  // 見出し
  static const double lg = 24.0;
}

// 間隔
class SpacePalette {
  static const double xs = 4.0;
  // 付随項目（タイトルとフィールドなど）の間隔
  static const double sm = 8.0;
  static const double md = 12.0;
    // 全体padding, 別機能間隔
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 56.0;
}

class RadiusPalette {
  static const double xs = 4.0;
  // 横長ボタンの角丸度
  static const double sm = 8.0;
  static const double base = 12.0;
  static const double lg = 16.0;
}

// Button Sizes
class ButtonSizePalette {
  // フィルターボックス
  static const double heightXs = 36.0;
  // カード内横長ボタン
  static const double heightSm = 40.0;
  // 横長ボタン、入力フィールド
  static const double heightMd = 48.0;
}