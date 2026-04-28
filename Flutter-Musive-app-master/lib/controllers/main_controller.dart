import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song_model.dart';
import '../utils/web_audio.dart';

class MainController extends ChangeNotifier {
  var audios = <Audio>[
    Audio.network(
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      metas: Metas(
        id: 'Online',
        title: 'Welcome Here',
        artist: 'SoundHelix',
        album: 'OnlineAlbum',
        image: const MetasImage.network(
            'https://picsum.photos/seed/welcome/400/400'),
      ),
    ),
  ];
  bool isNext = true;
  AssetsAudioPlayer player = AssetsAudioPlayer.withId('Playing audio');

  final List<StreamSubscription> _subscriptions = [];
  List<dynamic> getRecentlyPlayed() {
    List<dynamic> data = [];
    var box = Hive.box('RecentlyPlayed');
    for (var i = 0; i < box.length; i++) {
      data.add(box.getAt(i));
    }
    return data;
  }

  List<Audio> converLocalSongToAudio(songs) {
    return (songs as List).map((audio) {
      return Audio.network(audio['track'],
          metas: Metas(
            id: audio['id'],
            title: audio['songname'],
            artist: audio['fullname'],
            album: audio['username'],
            image: MetasImage.network(audio['cover']),
          ));
    }).toList();
  }

  void init() async {
    _subscriptions.add(player.playlistAudioFinished.listen((data) async {
      final myAudio = data.playlist.audios[data.playlist.currentIndex];
      var box = Hive.box('RecentlyPlayed');
      await box.put(myAudio.metas.title, {
        "songname": myAudio.metas.title,
        "fullname": myAudio.metas.artist,
        "username": myAudio.metas.album,
        "cover": myAudio.metas.image!.path,
        "track": myAudio.path,
        "id": myAudio.metas.id,
        "created": DateTime.now().toString(),
      });
    }));

    _subscriptions.add(player.audioSessionId.listen((sessionId) {}));
    _subscriptions
        .add(AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    }));
    final recentSongs = getRecentlyPlayed();
    recentSongs.sort((a, b) => b["created"].compareTo(a["created"]));
    if (recentSongs.isNotEmpty) {
      audios.removeAt(0);
    }
    converLocalSongToAudio(recentSongs).forEach((audio) {
      audios.add(audio);
    });
    await openPlayer(newlist: audios);
  }

  void addToFavorite(
      {required String name,
      required String fullname,
      required String username,
      required String cover,
      required String track}) {
    var box = Hive.box('liked');

    box.put(name, {
      "songname": name,
      "fullname": fullname,
      "username": username,
      "cover": cover,
      "track": track
    });
  }

  Future<void> openPlayer(
      {required List<Audio> newlist, int initial = 0}) async {
    await player.open(Playlist(audios: newlist, startIndex: initial),
        showNotification: true,
        autoStart: false,
        headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
        notificationSettings: const NotificationSettings(stopEnabled: false));

    notifyListeners();
  }

  void playSong(List<Audio> newPlaylist, int initial) async {
    if (isNext) {
      isNext = false;
      // Fire WebAudio synchronously inside the click handler so the browser's
      // autoplay policy treats it as a user gesture. Awaits below would
      // otherwise lose the gesture context.
      if (kIsWeb && initial >= 0 && initial < newPlaylist.length) {
        WebAudio.play(newPlaylist[initial].path);
      }
      await player.pause();
      await player.stop();
      audios = newPlaylist;
      await openPlayer(newlist: newPlaylist, initial: initial);
      await player.play();
      isNext = true;
    }
  }

  void webPlayPause() {
    if (kIsWeb) {
      final p = player.isPlaying.value;
      if (p) {
        WebAudio.pause();
      } else {
        WebAudio.resume();
      }
    }
  }

  /// Move to next/previous song in the current playlist on web. assets_audio_player's
  /// next()/previous() only updates its own state — WebAudio is decoupled,
  /// so we wire them here.
  void webNext() {
    if (!kIsWeb) return;
    final pl = player.playlist;
    final cur = player.current.value;
    if (pl == null || cur == null) return;
    final idx = (cur.index + 1) % pl.audios.length;
    WebAudio.play(pl.audios[idx].path);
  }

  void webPrevious() {
    if (!kIsWeb) return;
    final pl = player.playlist;
    final cur = player.current.value;
    if (pl == null || cur == null) return;
    final idx = (cur.index - 1 + pl.audios.length) % pl.audios.length;
    WebAudio.play(pl.audios[idx].path);
  }

  void webSeek(Duration to) {
    if (kIsWeb) WebAudio.seek(to);
  }

  void changeIndex(int newIndex, int oldIndex) {
    player.playlist!.audios
        .insert(newIndex, player.playlist!.audios.removeAt(oldIndex));

    notifyListeners();
  }

  void close() {
    player.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  Audio findByname(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.metas.title == fromPath);
  }

  List<Audio> convertToAudio(List<SongModel> songs) {
    return [
      ...songs.map((audio) {
        return Audio.network(audio.trackid!,
            metas: Metas(
              id: audio.songid,
              title: audio.songname,
              artist: audio.name,
              album: audio.userid,
              image: MetasImage.network(audio.coverImageUrl!),
            ));
      }).toList()
    ];
  }
}
