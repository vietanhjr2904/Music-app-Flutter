import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

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
    final hasInternet = await _hasInternet();

    if (!hasInternet) {
      throw Exception('NO_INTERNET');
    }

    try {
      final result = await YouTubeService.searchMany(
        _homeQueries,
        perQuery: 3,
      ).timeout(const Duration(seconds: 12));

      if (result.isNotEmpty) {
        return result;
      }

      return mockSongs(30);
    } catch (e) {
      final stillHasInternet = await _hasInternet();

      if (!stillHasInternet) {
        throw Exception('NO_INTERNET');
      }

      return mockSongs(30);
    }
  }

  Future<bool> _hasInternet() async {
    if (kIsWeb) return true;

    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
