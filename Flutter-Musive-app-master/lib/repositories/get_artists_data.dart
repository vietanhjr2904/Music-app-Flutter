import '../models/song_model.dart';
import '../models/user_model.dart';
import 'mock_data.dart';

/// Backend offline — returns mock artist profile and their songs.
class GetArtistsData {
  Future<UserModel> getUserData(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final i = _idIndex(id);
    return UserModel.fromJson({
      'id': id,
      'username': 'user_$i',
      'first_name': mockFirstNames[i % mockFirstNames.length],
      'last_name': mockLastNames[i % mockLastNames.length],
      'email': 'artist$i@musive.local',
      'city': 'Unknown',
      'avatar': 'https://picsum.photos/seed/artist$i/400/400',
    });
  }

  Future<List<SongModel>> getSongs(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockSongs(12, seedPrefix: 'artist${_idIndex(id)}_song');
  }

  int _idIndex(String id) {
    final match = RegExp(r'\d+').firstMatch(id);
    return match == null ? 0 : int.parse(match.group(0)!) % 26;
  }
}
