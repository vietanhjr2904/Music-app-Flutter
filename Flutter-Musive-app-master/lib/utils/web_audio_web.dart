// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: plays audio via a singleton <audio> element.
/// Used on web to bypass assets_audio_player's unreliable web backend.
class WebAudio {
  static final html.AudioElement _el = html.AudioElement()
    ..crossOrigin = 'anonymous'
    ..preload = 'auto';

  static String? _currentSrc;

  static void play(String url) {
    if (_currentSrc != url) {
      _el.src = url;
      _currentSrc = url;
    }
    _el.play();
  }

  static void pause() => _el.pause();
  static void resume() => _el.play();

  static void stop() {
    _el.pause();
    _el.currentTime = 0;
  }

  static void seek(Duration position) {
    _el.currentTime = position.inMilliseconds / 1000.0;
  }

  static Duration get position =>
      Duration(milliseconds: (_el.currentTime * 1000).round());

  static Duration get duration {
    final d = _el.duration;
    if (d.isNaN || d.isInfinite) return Duration.zero;
    return Duration(milliseconds: (d * 1000).round());
  }

  static Stream<Duration> get onPosition =>
      Stream.periodic(const Duration(milliseconds: 250), (_) => position);
}
