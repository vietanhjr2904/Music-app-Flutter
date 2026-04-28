/// Stub for non-web platforms. Calls become no-ops so assets_audio_player
/// handles playback natively on mobile/desktop.
class WebAudio {
  static void play(String url) {}
  static void pause() {}
  static void resume() {}
  static void stop() {}
  static void seek(Duration position) {}
  static Duration get position => Duration.zero;
  static Duration get duration => Duration.zero;
  static Stream<Duration> get onPosition => const Stream.empty();
}
