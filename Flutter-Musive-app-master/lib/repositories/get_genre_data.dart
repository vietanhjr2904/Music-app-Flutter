import '../api/youtube_service.dart';
import '../models/song_model.dart';
import '../models/user.dart';
import 'mock_data.dart';

const _genreQueries = {
  'pop': 'pop Việt Nam hay nhất',
  'rap': 'rap Việt hay nhất',
  'rock': 'rock Việt Nam',
  'ballad': 'ballad Việt hay nhất',
  'bolero': 'bolero Việt hay nhất',
  'edm': 'edm Việt Nam remix',
  'indie': 'indie Việt Nam',
  'love': 'nhạc Việt lãng mạn',
  'sad': 'nhạc Việt buồn hay nhất',
  'happy': 'nhạc Việt vui sôi động',
};

class GenreRepository {
  Future<List<User>> getUsers(String tag) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockUsers(20, seedPrefix: '${tag}_artist');
  }

  Future<List<SongModel>> getSongs(String tag) async {
    final q = _genreQueries[tag.toLowerCase()] ?? '$tag Việt Nam';
    final result = await YouTubeService.search(q, limit: 15);
    if (result.isNotEmpty) return result;
    return mockSongs(20, seedPrefix: '${tag}_song');
  }
}
