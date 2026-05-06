import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicAPI {
  static Future<Map<String, dynamic>> search(String keyword) async {
    final url = Uri.parse(
        "https://beta.nhaccuatui.com/api/search/all?key=$keyword");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final songs = data['data']['song'] ?? [];

      return {
        "songs": songs.map((e) {
          return {
            "title": e['title'],
            "artist": e['artist'],
            "thumbnail": e['thumbnail'],
            "track": e['streaming'], // link mp3
            "id": e['key']
          };
        }).toList(),
        "artists": []
      };
    } else {
      throw Exception("API lỗi");
    }
  }

  /// TOP / TRENDING
  static Future<Map<String, dynamic>> getTop(String type) async {
    final url = Uri.parse(
        "https://beta.nhaccuatui.com/api/chart/home");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final songs = data['data']['song'] ?? [];

      return {
        "song": songs.map((e) {
          return {
            "title": e['title'],
            "artist": e['artist'],
            "thumbnail": e['thumbnail'],
            "track": e['streaming'],
            "id": e['key']
          };
        }).toList()
      };
    } else {
      throw Exception("API lỗi");
    }
  }
}