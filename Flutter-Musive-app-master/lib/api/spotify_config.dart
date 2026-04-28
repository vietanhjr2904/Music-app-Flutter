/// Spotify Web API credentials.
///
/// Lấy tại https://developer.spotify.com/dashboard
///   1. Đăng nhập (tài khoản Spotify thường được).
///   2. Create app → đặt tên bất kỳ, Redirect URI có thể để http://localhost.
///   3. Vào Settings của app, copy Client ID và Client Secret vào đây.
///
/// Lưu ý:
///   - Preview của Spotify chỉ phát được ~30 giây.
///   - Một số bài có preview_url = null (do label chặn). Service sẽ tự lọc.
///   - KHÔNG commit Client Secret lên repo public.
class SpotifyConfig {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';

  /// Bật khi đã điền credentials. Khi false, app fallback về mock SoundHelix.
  static bool get isConfigured =>
      clientId != 'YOUR_SPOTIFY_CLIENT_ID' &&
      clientSecret != 'YOUR_SPOTIFY_CLIENT_SECRET' &&
      clientId.isNotEmpty &&
      clientSecret.isNotEmpty;

  /// Market code — VN để ưu tiên nhạc Việt.
  static const String market = 'VN';
}
