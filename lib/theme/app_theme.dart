// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// フォントはinterを使用
// 太字はFontWeight.w600を使用

Color backgroundColor = const Color(0xFFF5F5F5);
Color subBackgroundColor = const Color(0xFFFFFFFF);
Color progressColor = const Color(0xFF22C55E);

// カラーパレット
class ColorPalette {
  // 基本色
  // 基本背景色, 白テキスト色
  static const Color neutral0 = Color(0xFFf5f5f5);
  static const Color neutral50 = Color(0xFFfafafa);
  // 薄いボックス背景色
  static const Color neutral100 = Color(0xFFffffff);
  // 区切り線, 枠線色
  static const Color neutral200 = Color(0xFFe5e5e5);
  static const Color neutral300 = Color(0xFFd4d4d4);
  // ヒントテキスト色
  static const Color neutral400 = Color(0xFFa3a3a3);
  // グレーテキスト色
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  // 黒テキスト色
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0a0a0a);
  static const Color neutral1000 = Color(0xFF000000);

  // システムカラー
  static const Color systemGreen = Color(0xFF22C55E);
  static const Color systemRed = Color(0xFFEF4444);
}

// フォントサイズ
class FontSizePalette {
  // 注意書き、カード内テキスト、タグチップ内、リストタイル2の文字サイズ
  static const double sm = 12.0;
  // チャット、フィールド上、カード内ボタン内（通常文字）
  static const double base = 14.0;
  // 横長ボタン、AppBarヘッダー、リストタイル1の文字サイズ
  static const double md = 16.0;
  // 小見出し
  static const double smTitle = 18.0;
  // リスト関係（大）のタイトル
  static const double bigListTitle = 20.0;
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

// テキストスタイル
class TextStylePalette {
  // サブガイドテキスト
  static const TextStyle subGuide = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.sm,
  );
  // ガイドテキスト
  static const TextStyle guide = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.sm,
    fontWeight: FontWeight.bold
  );
  // Dividerテキスト
  static const TextStyle dividerText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.sm,
    fontWeight: FontWeight.bold
  );
  // サブテキスト（小）
  static const TextStyle subMiniText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.sm,
  );
  // テキスト（小）
  static const TextStyle miniText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.sm,
  );
  // タグテキスト
  static const TextStyle tagText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.sm,
    fontWeight: FontWeight.bold
  );
  // リスト関係（小）のタイトル
  static const TextStyle smallListTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.md,
    fontWeight: FontWeight.bold
  );
  // リスト関係（小）のサブタイトル
  static const TextStyle smallListSubTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.sm,
  );
  // ヒントテキスト
  static const TextStyle hintText = TextStyle(
    color: ColorPalette.neutral400,
    fontSize: FontSizePalette.base,
  );
  // サブテキスト
  static const TextStyle subText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.base,
  );
  // サブミニタイトル
  static const TextStyle subMiniTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.sm,
  );
  // テキスト（通常）
  static const TextStyle normalText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.base,
  );
  // ミニタイトル
  static const TextStyle miniTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.base,
    fontWeight: FontWeight.bold
  );
  // サブテキスト（大）
  static const TextStyle bigSubText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.md,
  );
  // テキスト（大）
  static const TextStyle bigText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.md,
  );
  // リスト関係（大）のタイトル
  static const TextStyle bigListTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.bigListTitle,
    fontWeight: FontWeight.bold
  );
  // リスト関係（大）のサブタイトル
  static const TextStyle bigListSubTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.md,
  );
  // ボタン内テキスト（白）
  static const TextStyle buttonTextWhite = TextStyle(
    color: ColorPalette.neutral0,
    fontSize: FontSizePalette.md,
    fontWeight: FontWeight.bold
  );
  // ボタン内テキスト（黒）
  static const TextStyle buttonTextBlack = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.md,
    fontWeight: FontWeight.bold
  );
  // AppBar/タイトル
  static const TextStyle title = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.md,
    fontWeight: FontWeight.bold
  );
  // 小見出し
  static const TextStyle smallHeader = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.smTitle,
    fontWeight: FontWeight.bold
  );
  // ヘッダーテキスト
  static const TextStyle header = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.lg,
    fontWeight: FontWeight.bold
  );
}

// リストをタップして開く詳細ページの上部にリスト（大）を用いる