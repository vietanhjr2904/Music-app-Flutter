import '../models/song_model.dart';
import 'mock_data.dart';

/// Backend offline — returns a deterministic mock song for any given name.
class GetOneSong {
  Future<SongModel> getSongs(String name) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = name.hashCode.abs() % 30;
    return mockSong(idx, seedPrefix: 'onesong');
  }
}
