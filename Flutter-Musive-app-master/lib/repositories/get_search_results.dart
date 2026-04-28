import '../api/youtube_service.dart';
import '../models/song_model.dart';
import '../models/user.dart';
import 'mock_data.dart';

const _moodQueries = {
  'buồn': 'nhạc Việt buồn hay nhất',
  'vui': 'nhạc Việt vui sôi động',
  'lãng mạn': 'nhạc Việt lãng mạn',
  'ballad': 'ballad Việt hay nhất',
  'rap': 'rap Việt hay nhất',
  'bolero': 'bolero Việt hay nhất',
};

class SearchRepository {
  Future<List<User>> getUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = mockUsers(26);
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((u) => (u.name ?? '').toLowerCase().contains(q) ||
            (u.username ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<List<SongModel>> getSongs(String query) async {
    final q = query.toLowerCase().trim();
    String ytQuery = query.trim();
    for (final entry in _moodQueries.entries) {
      if (q.contains(entry.key)) {
        ytQuery = entry.value;
        break;
      }
    }
    if (ytQuery.isEmpty) ytQuery = 'nhạc Việt hay nhất';
    final result = await YouTubeService.search(ytQuery, limit: 15);
    if (result.isNotEmpty) return result;
    return mockSearch(query);
  }
}
