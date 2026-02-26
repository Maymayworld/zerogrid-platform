/// YouTube URL からビデオIDを抽出
String? extractYoutubeVideoId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  // youtube.com/watch?v=ID
  if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
    return uri.queryParameters['v'];
  }
  // youtu.be/ID
  if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first;
  }
  // youtube.com/shorts/ID or youtube.com/embed/ID
  if (uri.host.contains('youtube.com') && uri.pathSegments.length >= 2) {
    final first = uri.pathSegments[0];
    if (first == 'shorts' || first == 'embed') {
      return uri.pathSegments[1];
    }
  }
  return null;
}

/// ビデオIDからYouTubeサムネイルURLを生成
String getYoutubeThumbnailUrl(String videoId) {
  return 'https://img.youtube.com/vi/$videoId/0.jpg';
}

/// 動画URLからサムネイルURLを生成（URLからID抽出→サムネイル）
String? getThumbnailFromVideoUrl(String videoUrl) {
  final videoId = extractYoutubeVideoId(videoUrl);
  if (videoId == null) return null;
  return getYoutubeThumbnailUrl(videoId);
}
