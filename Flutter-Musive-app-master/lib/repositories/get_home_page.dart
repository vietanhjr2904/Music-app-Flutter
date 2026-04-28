import '../api/youtube_service.dart';
import '../models/song_model.dart';
import '../models/user.dart';
import 'mock_data.dart';

const _homeQueries = [
  'Sơn Tùng MTP',
  'Bích Phương',
  'Hoàng Thùy Linh',
  'Jack J97',
  'Hà Anh Tuấn',
  'Đen Vâu',
];

class GetHomePage {
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockUsers(26);
  }

  Future<List<SongModel>> getSongs() async {
    final result = await YouTubeService.searchMany(_homeQueries, perQuery: 3);
    if (result.isNotEmpty) return result;
    return mockSongs(30);
  }
}
