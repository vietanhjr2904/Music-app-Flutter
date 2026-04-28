import '../models/song_model.dart';
import '../models/user.dart';

/// Vietnamese mock catalog. Audio URLs are placeholder streams (SoundHelix)
/// because we don't have rights to real Vietnamese tracks; titles, artists,
/// covers and moods are Vietnamese so the UI feels localized.

const mockFirstNames = [
  'Sơn', 'Mỹ', 'Hà', 'Đức', 'Bích', 'Quang', 'Hoàng',
  'Thu', 'Bảo', 'Phương', 'Trọng', 'Hồng', 'Minh', 'Tuấn',
];

const mockLastNames = [
  'Tùng', 'Tâm', 'Anh', 'Phúc', 'Phương', 'Lê', 'Trần',
  'Nguyễn', 'Phạm', 'Đặng', 'Vũ', 'Bùi', 'Đỗ', 'Hồ',
];

/// (Tên bài, ca sĩ, chủ đề/mood)
const List<Map<String, String>> vietnameseSongs = [
  {'title': 'Chúng Ta Của Hiện Tại', 'artist': 'Sơn Tùng M-TP', 'mood': 'buon'},
  {'title': 'Hãy Trao Cho Anh', 'artist': 'Sơn Tùng M-TP', 'mood': 'vui'},
  {'title': 'Em Của Ngày Hôm Qua', 'artist': 'Sơn Tùng M-TP', 'mood': 'buon'},
  {'title': 'Lạc Trôi', 'artist': 'Sơn Tùng M-TP', 'mood': 'buon'},
  {'title': 'Nắng Ấm Xa Dần', 'artist': 'Sơn Tùng M-TP', 'mood': 'buon'},
  {'title': 'Đừng Như Thói Quen', 'artist': 'Jaykii', 'mood': 'buon'},
  {'title': 'Người Lạ Ơi', 'artist': 'Karik & Orange', 'mood': 'buon'},
  {'title': 'Hồng Nhan', 'artist': 'Jack', 'mood': 'buon'},
  {'title': 'Sóng Gió', 'artist': 'Jack & K-ICM', 'mood': 'vui'},
  {'title': 'Bạc Phận', 'artist': 'Jack & K-ICM', 'mood': 'buon'},
  {'title': 'Anh Thanh Niên', 'artist': 'HuyR', 'mood': 'vui'},
  {'title': 'Hai Phút Hơn', 'artist': 'Pháo', 'mood': 'vui'},
  {'title': 'Bao Giờ Lấy Chồng', 'artist': 'Bích Phương', 'mood': 'vui'},
  {'title': 'Đi Đu Đưa Đi', 'artist': 'Bích Phương', 'mood': 'vui'},
  {'title': 'Bùa Yêu', 'artist': 'Bích Phương', 'mood': 'vui'},
  {'title': 'Em Gái Mưa', 'artist': 'Hương Tràm', 'mood': 'buon'},
  {'title': 'Duyên Mình Lỡ', 'artist': 'Hương Tràm', 'mood': 'buon'},
  {'title': 'Cô Gái M52', 'artist': 'Huy ft. Tùng Viu', 'mood': 'vui'},
  {'title': 'Để Mị Nói Cho Mà Nghe', 'artist': 'Hoàng Thùy Linh', 'mood': 'vui'},
  {'title': 'See Tình', 'artist': 'Hoàng Thùy Linh', 'mood': 'vui'},
  {'title': 'Gặp Nhưng Không Ở Lại', 'artist': 'Hiền Hồ', 'mood': 'buon'},
  {'title': 'Nơi Này Có Anh', 'artist': 'Sơn Tùng M-TP', 'mood': 'lang_man'},
  {'title': 'Có Chàng Trai Viết Lên Cây', 'artist': 'Phan Mạnh Quỳnh', 'mood': 'lang_man'},
  {'title': 'Vợ Người Ta', 'artist': 'Phan Mạnh Quỳnh', 'mood': 'buon'},
  {'title': 'Đi Để Trở Về', 'artist': 'Soobin Hoàng Sơn', 'mood': 'vui'},
  {'title': 'Phía Sau Một Cô Gái', 'artist': 'Soobin Hoàng Sơn', 'mood': 'lang_man'},
  {'title': 'Tháng Tư Là Lời Nói Dối', 'artist': 'Hà Anh Tuấn', 'mood': 'buon'},
  {'title': 'Tránh Duyên', 'artist': 'Hoàng Duyên', 'mood': 'buon'},
  {'title': 'Em Bé', 'artist': 'AMEE', 'mood': 'vui'},
  {'title': 'Yêu Là Cùng Nhau Đi Tới', 'artist': 'Erik', 'mood': 'lang_man'},
];

/// Unique artist names extracted from the song catalog (deduped, in order).
final List<String> _uniqueArtists = () {
  final seen = <String>{};
  final out = <String>[];
  for (final s in vietnameseSongs) {
    final a = s['artist'] ?? '';
    if (a.isNotEmpty && seen.add(a)) out.add(a);
  }
  return out;
}();

User mockUser(int i, {String seedPrefix = 'avatar'}) {
  final artist = _uniqueArtists[i % _uniqueArtists.length];
  final parts = artist.split(' ');
  return User.fromJson({
    'avatar': 'https://picsum.photos/seed/$seedPrefix$i/200/200',
    'username': 'artist_${i % _uniqueArtists.length}',
    'first_name': parts.isNotEmpty ? parts.first : mockFirstNames[i % mockFirstNames.length],
    'last_name': parts.length > 1
        ? parts.sublist(1).join(' ')
        : mockLastNames[i % mockLastNames.length],
  });
}

SongModel mockSong(int i, {String seedPrefix = 'cover'}) {
  final s = vietnameseSongs[i % vietnameseSongs.length];
  final trackNumber = (i % 16) + 1;
  // Append unique fragment so each song has a unique URL — prevents
  // firstWhere() in current_playing_song from returning the wrong metadata
  // when multiple songs share the same underlying SoundHelix mp3.
  return SongModel.fromJson({
    'songid': 'song_${seedPrefix}_$i',
    'songname': s['title'],
    'userid': 'user_${i % 26}',
    'trackid':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$trackNumber.mp3#${seedPrefix}_$i',
    'duration': '${180 + (i * 7) % 120}',
    'cover_image_url': 'https://picsum.photos/seed/$seedPrefix$i/400/400',
    'first_name': s['artist'],
    'last_name': '',
  });
}

List<User> mockUsers(int count, {String seedPrefix = 'avatar'}) =>
    List.generate(count, (i) => mockUser(i, seedPrefix: seedPrefix));

List<SongModel> mockSongs(int count, {String seedPrefix = 'cover'}) =>
    List.generate(count, (i) => mockSong(i, seedPrefix: seedPrefix));

List<SongModel> mockSongsByMood(String mood) {
  final result = <SongModel>[];
  for (var i = 0; i < vietnameseSongs.length; i++) {
    if (vietnameseSongs[i]['mood'] == mood) {
      result.add(mockSong(i));
    }
  }
  return result;
}

List<SongModel> mockSearch(String query) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) return mockSongs(15);
  final result = <SongModel>[];
  for (var i = 0; i < vietnameseSongs.length; i++) {
    final s = vietnameseSongs[i];
    final hay = '${s['title']} ${s['artist']} ${s['mood']}'.toLowerCase();
    final moodMatch = (q.contains('buồn') && s['mood'] == 'buon') ||
        (q.contains('vui') && s['mood'] == 'vui') ||
        (q.contains('lãng mạn') && s['mood'] == 'lang_man');
    if (hay.contains(q) || moodMatch) {
      result.add(mockSong(i));
    }
  }
  return result;
}
