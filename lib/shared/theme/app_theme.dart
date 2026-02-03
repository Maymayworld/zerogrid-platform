// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 太字はFontWeight.w600を使用

// カラーパレット
class ColorPalette {

  // Foundation
  // 基本背景色, 白テキスト色
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Neutral
  static const Color neutral50 = Color(0xFFfafafa);
  // 薄いボックス背景色
  static const Color neutral100 = Color(0xFFf5f5f5);
  // 区切り線, 枠線色
  static const Color neutral200 = Color(0xFFe5e5e5);
  static const Color neutral300 = Color(0xFFd4d4d4); // ほぼ使わない
  // ヒントテキスト色
  static const Color neutral400 = Color(0xFFa3a3a3);
  // グレーテキスト色
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252); // ほぼ使わない
  static const Color neutral700 = Color(0xFF404040); // ほぼ使わない
  // 黒テキスト色
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717); // ほぼ使わない
  static const Color neutral950 = Color(0xFF0a0a0a); // ほぼ使わない

  // Chill Blue
  static const Color chillBlue100 = Color(0xFFe8f6f7);
  static const Color chillBlue200 = Color(0xFFc2e9ec);
  static const Color chillBlue300 = Color(0xFF99d7de);
  static const Color chillBlue400 = Color(0xFF66c3cd);
  static const Color chillBlue500 = Color(0xFF33afbd); 
  static const Color chillBlue600 = Color(0xFF009bac); // primaryColor
  static const Color chillBlue700 = Color(0xFF007c8a);
  static const Color chillBlue800 = Color(0xFF005d67);
  static const Color chillBlue900 = Color(0xFF003e45);

  // States
  // Positive
  static const Color positive50 = Color(0xFFf0fdf4);
  static const Color positive100 = Color(0xFFdcfce7);
  static const Color positive200 = Color(0xFFbbf7d0);
  static const Color positive300 = Color(0xFF86efac);
  static const Color positive400 = Color(0xFF4ade80);
  static const Color positive500 = Color(0xFF22c55e);
  static const Color positive600 = Color(0xFF16a34a);
  static const Color positive700 = Color(0xFF15803d);
  static const Color positive800 = Color(0xFF166534);
  static const Color positive900 = Color(0xFF14532d);
  static const Color positive950 = Color(0xFF052e16);

  // Critical
  static const Color critical50 = Color(0xFFfef2f2);
  static const Color critical100 = Color(0xFFfee2e2);
  static const Color critical200 = Color(0xFFfecaca);
  static const Color critical300 = Color(0xFFfca5a5);
  static const Color critical400 = Color(0xFFf87171);
  static const Color critical500 = Color(0xFFef4444);
  static const Color critical600 = Color(0xFFdc2626);
  static const Color critical700 = Color(0xFFb91c1c);
  static const Color critical800 = Color(0xFF991b1b);
  static const Color critical900 = Color(0xFF7f1d1d);
  static const Color critical950 = Color(0xFF450a0a);
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
  // 完全な丸（pill shape）
  static const double full = 999.0;
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
  // ソーシャルログインボタン
  static const double socialButton = 50.0;
}

// テキストスタイル
class TextStylePalette {
  // スモールサブテキスト
  static const TextStyle smSubText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
  );
  // スモールテキスト
  static const TextStyle smText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
  );
  // ミニタイトル
  // タグ内のテキスト
  static const TextStyle miniTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // スモールサブタイトル
  static const TextStyle smSubTitle = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // ヒントテキスト
  // 入力フィールド上のヒントテキストなど
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
  // チャット欄のテキストなど
  static const TextStyle normalText = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size14,
  );
  // スモールタイトル
  // 入力フィールド上のタイトルなど
  // 例: 「メールアドレス」
  static const TextStyle smTitle = TextStyle(
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
  // ガイドテキスト（下線付き）
  static const TextStyle guideUnderline = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );
  // Dividerテキスト
  // Divider上に表示するテキスト
  // 例：「または」
  static const TextStyle dividerText = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
    fontWeight: FontWeight.bold
  );
  // リスト内のtitleテキスト
  static const TextStyle listTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size14,
    fontWeight: FontWeight.bold
  );
  // リスト内のleadingテキスト
  static const TextStyle listLeading = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size12,
  );
  // リストタップ後の詳細画面に表示するリストのtitleテキスト
  static const TextStyle lgListTitle = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size20,
    fontWeight: FontWeight.bold
  );
  // リストタップ後の詳細画面に表示するリストのleadingテキスト
  static const TextStyle lgListLeading = TextStyle(
    color: ColorPalette.neutral500,
    fontSize: FontSizePalette.size16,
  );
  // ボタン内テキスト（白）
  static const TextStyle buttonTextWhite = TextStyle(
    color: ColorPalette.white,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // ボタン内テキスト（黒）
  static const TextStyle buttonTextBlack = TextStyle(
    color: ColorPalette.neutral800,
    fontSize: FontSizePalette.size16,
    fontWeight: FontWeight.bold
  );
  // ボタン内テキスト（無効時）
  static const TextStyle buttonTextDisabled = TextStyle(
    color: ColorPalette.neutral400,
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

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ColorPalette.neutral800,
        surface: ColorPalette.white,
        onPrimary: ColorPalette.neutral100,
        onSurface: ColorPalette.neutral800,
        outline: ColorPalette.neutral200,
      ),
      scaffoldBackgroundColor: ColorPalette.white,
      textTheme: textTheme,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ColorPalette.white,
        foregroundColor: ColorPalette.neutral800,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStylePalette.title,
      ),
      
      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        // filled: true,
        fillColor: ColorPalette.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacePalette.inner,
          vertical: SpacePalette.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          borderSide: const BorderSide(color: ColorPalette.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          borderSide: const BorderSide(color: ColorPalette.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          borderSide: const BorderSide(color: ColorPalette.chillBlue500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          borderSide: const BorderSide(color: ColorPalette.chillBlue500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.base),
          borderSide: const BorderSide(color: ColorPalette.chillBlue500, width: 2),
        ),
        labelStyle: TextStylePalette.normalText,
        hintStyle: TextStylePalette.hintText,
      ),
      
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.chillBlue500,
          foregroundColor: ColorPalette.neutral100,
          minimumSize: const Size(double.infinity, ButtonSizePalette.button),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusPalette.base),
          ),
          textStyle: TextStylePalette.buttonTextWhite,
        ),
      ),
      
      // Card - neutral100背景
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shadowColor: ColorPalette.neutral800.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusPalette.lg),
        ),
        color: ColorPalette.white,
      ),
    );
  }
}