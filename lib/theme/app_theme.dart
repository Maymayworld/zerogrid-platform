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
  // 薄いボックス背景色
  static const Color neutral100 = Color(0xFFffffff);
  // 区切り線, 枠線色
  static const Color neutral200 = Color(0xFFe5e5e5);
  // ヒントテキスト色
  static const Color neutral400 = Color(0xFFa3a3a3);
  // グレーテキスト色
  static const Color neutral500 = Color(0xFF737373);
  // 黒テキスト色
  static const Color neutral800 = Color(0xFF262626);

  // システムカラー
  static const Color systemGreen = Color(0xFF22C55E);
  static const Color systemRed = Color(0xFFEF4444);
}

// フォントサイズ
class FontSizePalette {
  // 注意書き、カード内テキスト、タグチップ内、リストタイル2の文字サイズ
  static const double size12 = 12.0;
  // チャット、フィールド上、カード内ボタン内（通常文字）
  static const double size14 = 14.0;
  // 横長ボタン、AppBarヘッダー、リストタイル1の文字サイズ
  static const double size16 = 16.0;
  // 小見出し
  static const double size18 = 18.0;
  // リスト関係（大）のタイトル
  static const double size20 = 20.0;
  // 見出し
  static const double size24 = 24.0;
}

// 間隔
class SpacePalette {
  // 隣接間隔
  static const double xs = 4.0;
  // 付随項目（タイトルとフィールドなど）の間隔
  static const double sm = 8.0;
  // 内部padding
  static const double inner = 12.0;
  // 全体padding、別機能間隔
  static const double base = 16.0;
  // 大きめの間隔
  static const double lg = 24.0;
}

class RadiusPalette {
  // ミニボタンの角丸度
  static const double mini = 4.0;
  // 横長ボタンの角丸度
  static const double base = 8.0;
  // カードの角丸度
  static const double lg = 12.0;
}

// Button Sizes
class ButtonSizePalette {
  // タグチップ高さ
  static const double tag = 30.0;
  // フィルターボックス
  static const double filter = 36.0;
  // カード内横長ボタン
  static const double innerButton = 40.0;
  // 横長ボタン、入力フィールド
  static const double button = 48.0;
}

// テキストスタイル
class TextStylePalette {
  // サブガイドテキスト
  // ガイドテキストを補助する役割
  static const TextStyle subGuide = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
  );
  // ガイドテキスト
  // 例：「パスワードを忘れた方はこちら」
  static const TextStyle guide = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // Dividerテキスト
  // Divider上に表示するテキスト
  // 例：「または」
  static const TextStyle dividerText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // サブテキスト（小）
  static const TextStyle subMiniText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
  );
  // テキスト（小）
  static const TextStyle miniText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
  );
    // サブミニタイトル
  static const TextStyle subMiniTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // タグテキスト
  static const TextStyle tagText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // リスト内のtitleテキスト
  static const TextStyle listTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // リスト内のleadingテキスト
  static const TextStyle listLeading = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
  );
  // ヒントテキスト
  static const TextStyle hintText = TextStyle(
    color: ColorPalette.neutral400,
    fontSize: FontSizePalette.size14,
  );
  // サブテキスト
  static const TextStyle subText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size14,
  );
  // テキスト（通常）
  static const TextStyle normalText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size14,
  );
  // ミニタイトル
  static const TextStyle miniTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size14,
    fontWeight: FontWeight.bold
  );
  // サブテキスト（大）
  static const TextStyle bigSubText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size16,
  );
  // テキスト（大）
  static const TextStyle bigText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size16,
  );
  // リスト関係（大）のタイトル
  static const TextStyle bigListTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size20,
    fontWeight: FontWeight.bold
  );
  // リスト関係（大）のサブタイトル
  static const TextStyle bigListSubTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size16,
  );
  // ボタン内テキスト（白）
  static const TextStyle buttonTextWhite = TextStyle(
    color: ColorPalette.neutral0,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // ボタン内テキスト（黒）
  static const TextStyle buttonTextBlack = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // AppBar/タイトル
  static const TextStyle title = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // 小見出し
  static const TextStyle smallHeader = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size18,
    fontWeight: FontWeight.bold
  );
  // ヘッダーテキスト
  static const TextStyle header = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size24,
    fontWeight: FontWeight.bold
  );
}

// リストをタップして開く詳細ページの上部にリスト（大）を用いる