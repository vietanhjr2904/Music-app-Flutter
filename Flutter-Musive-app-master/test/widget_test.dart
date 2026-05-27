import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ======================================================
/// MODEL SONG
/// ======================================================

class Song {

  final String title;
  final String artist;
  final String url;

  Song({
    required this.title,
    required this.artist,
    required this.url,
  });

}

/// ======================================================
/// 1. HÀM CHUYỂN ĐỔI THỜI GIAN
/// ======================================================

String formatDuration(int seconds) {

  final minutes = seconds ~/ 60;
  final remainSeconds = seconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainSeconds.toString().padLeft(2, '0')}';

}

/// ======================================================
/// 2. PLAYLIST
/// ======================================================

class Playlist {

  List<Song> songs = [];

  void addSong(Song song) {
    songs.add(song);
  }

  void removeSong(Song song) {
    songs.remove(song);
  }

}

/// ======================================================
/// 3. SEARCH SONG
/// ======================================================

List<Song> searchSong(List<Song> songs, String keyword) {

  return songs.where((song) {

    return song.title
        .toLowerCase()
        .contains(keyword.toLowerCase());

  }).toList();

}

/// ======================================================
/// 4. STATE MANAGEMENT (RIVERPOD MOCK)
/// ======================================================

class MusicState {

  bool isPlaying = false;

  void play() {
    isPlaying = true;
  }

  void pause() {
    isPlaying = false;
  }

}

/// ======================================================
/// MAIN TEST
/// ======================================================

void main() {

  /// ======================================================
  /// UNIT TEST 1
  /// HÀM CHUYỂN ĐỔI THỜI GIAN
  /// ======================================================

  test('Chuyen doi thoi gian bai hat', () {

    String result = formatDuration(125);

    expect(result, '02:05');

  });

  /// ======================================================
  /// UNIT TEST 2
  /// PLAYLIST
  /// ======================================================

  test('Them bai hat vao playlist', () {

    Playlist playlist = Playlist();

    Song song = Song(
      title: 'Faded',
      artist: 'Alan Walker',
      url: 'audio.mp3',
    );

    playlist.addSong(song);

    expect(playlist.songs.length, 1);

  });

  /// ======================================================
  /// UNIT TEST 3
  /// TÌM KIẾM BÀI HÁT
  /// ======================================================

  test('Tim kiem bai hat', () {

    List<Song> songs = [

      Song(
        title: 'Faded',
        artist: 'Alan Walker',
        url: 'audio.mp3',
      ),

      Song(
        title: 'Believer',
        artist: 'Imagine Dragons',
        url: 'audio2.mp3',
      ),

    ];

    var result = searchSong(songs, 'faded');

    expect(result.length, 1);

    expect(result[0].title, 'Faded');

  });

  /// ======================================================
  /// UNIT TEST 4
  /// RIVERPOD STATE
  /// ======================================================

  test('Cap nhat trang thai phat nhac', () {

    MusicState state = MusicState();

    state.play();

    expect(state.isPlaying, true);

    state.pause();

    expect(state.isPlaying, false);

  });

  /// ======================================================
  /// UNIT TEST 5
  /// URL AUDIO
  /// ======================================================

  test('Kiem tra URL audio', () {

    Song song = Song(
      title: 'Alone',
      artist: 'Alan Walker',
      url: 'https://audio.com/song.mp3',
    );

    expect(song.url.startsWith('https'), true);

  });

  /// ======================================================
  /// WIDGET TEST 1
  /// MUSIC CARD
  /// ======================================================

  testWidgets('Hien thi Music Card',
          (WidgetTester tester) async {

        await tester.pumpWidget(

          MaterialApp(

            home: Scaffold(

              body: Card(

                child: ListTile(

                  title: const Text('Faded'),

                  subtitle: const Text('Alan Walker'),

                  leading: const Icon(Icons.music_note),

                ),

              ),

            ),

          ),

        );

        expect(find.text('Faded'), findsOneWidget);

        expect(find.text('Alan Walker'), findsOneWidget);

        expect(find.byIcon(Icons.music_note), findsOneWidget);

      });

  /// ======================================================
  /// WIDGET TEST 2
  /// CUSTOM PLAYER WIDGET
  /// ======================================================

  testWidgets('Hien thi Player Widget',
          (WidgetTester tester) async {

        await tester.pumpWidget(

          MaterialApp(

            home: Scaffold(

              body: Column(

                children: [

                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {},
                  ),

                  Slider(
                    value: 0.5,
                    onChanged: (value) {},
                  ),

                ],

              ),

            ),

          ),

        );

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        expect(find.byType(Slider), findsOneWidget);

      });

}