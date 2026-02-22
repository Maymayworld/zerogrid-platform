import 'package:flutter/material.dart';

/// プラットフォームロゴ画像を提供するヘルパー
class PlatformIcon {
  static Widget youtube({double size = 20}) =>
      Image.asset('assets/images/youtube_logo.png', width: size, height: size);

  static Widget instagram({double size = 20}) =>
      Image.asset('assets/images/instagram_logo.png', width: size, height: size);

  static Widget tiktok({double size = 20}) =>
      Image.asset('assets/images/tiktok_logo.png', width: size, height: size);

  static Widget apple({double size = 24}) =>
      Image.asset('assets/images/apple_logo.png', width: size, height: size);

  static Widget google({double size = 20}) =>
      Image.asset('assets/images/google_logo.png', width: size, height: size);

  /// プラットフォーム名からアイコンWidgetを返す
  static Widget fromPlatform(String platform, {double size = 20}) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return youtube(size: size);
      case 'instagram':
        return instagram(size: size);
      case 'tiktok':
        return tiktok(size: size);
      default:
        return Icon(Icons.video_library, size: size);
    }
  }

  /// プラットフォームリストから最初にマッチするアイコンWidgetを返す
  static Widget fromPlatforms(List<String> platforms, {double size = 20}) {
    if (platforms.contains('YouTube')) return youtube(size: size);
    if (platforms.contains('Instagram')) return instagram(size: size);
    if (platforms.contains('TikTok')) return tiktok(size: size);
    return Icon(Icons.video_library, size: size);
  }
}
