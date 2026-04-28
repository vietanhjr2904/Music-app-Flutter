import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/song_model.dart';
import 'spotify_config.dart';

class SpotifyService {
  static const _tokenUrl = 'https://accounts.spotify.com/api/token';
  static const _searchUrl = 'https://api.spotify.com/v1/search';

  static String? _token;
  static DateTime? _tokenExpiry;

  static Future<String?> _getToken() async {
    if (!SpotifyConfig.isConfigured) return null;
    if (_token != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _token;
    }
    final basic = base64.encode(utf8.encode(
        '${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'));
    final res = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $basic',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _token = data['access_token'] as String?;
    final expiresIn = (data['expires_in'] as int?) ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
    return _token;
  }

  /// Search Spotify, return only tracks with non-null preview_url.
  /// Cached per query in Hive box `spotifyCache` for 6h.
  static Future<List<SongModel>> search(String query, {int limit = 20}) async {
    final cleanQ = query.trim();
    if (cleanQ.isEmpty) return [];
    final cacheKey = 'q:$cleanQ:l:$limit';
    final cache = Hive.box('spotifyCache');
    final cached = cache.get(cacheKey);
    if (cached != null) {
      final at = DateTime.tryParse(cached['at'] ?? '');
      if (at != null &&
          DateTime.now().difference(at) < const Duration(hours: 6)) {
        return (cached['data'] as List)
            .map((e) => SongModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse(_searchUrl).replace(queryParameters: {
      'q': cleanQ,
      'type': 'track',
      'market': SpotifyConfig.market,
      'limit': '$limit',
    });
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (data['tracks']?['items'] as List?) ?? [];

    final songs = <SongModel>[];
    for (final t in items) {
      final preview = t['preview_url'] as String?;
      if (preview == null || preview.isEmpty) continue;
      final artists = (t['artists'] as List?) ?? [];
      final artistName =
          artists.isNotEmpty ? (artists.first['name'] ?? '') : '';
      final images = (t['album']?['images'] as List?) ?? [];
      final cover = images.isNotEmpty ? (images.first['url'] ?? '') : '';
      songs.add(SongModel(
        songid: t['id'] as String?,
        songname: t['name'] as String?,
        userid: artists.isNotEmpty ? artists.first['id'] as String? : null,
        trackid: preview,
        duration: '${((t['duration_ms'] as int?) ?? 0) ~/ 1000}',
        coverImageUrl: cover,
        name: artistName as String?,
      ));
    }

    await cache.put(cacheKey, {
      'at': DateTime.now().toIso8601String(),
      'data': songs.map((s) => {
            'songid': s.songid,
            'songname': s.songname,
            'userid': s.userid,
            'trackid': s.trackid,
            'duration': s.duration,
            'cover_image_url': s.coverImageUrl,
            'first_name': s.name,
            'last_name': '',
          }).toList(),
    });

    return songs;
  }

  /// Concatenated search across multiple queries (for home page).
  static Future<List<SongModel>> searchMany(List<String> queries,
      {int perQuery = 5}) async {
    final all = <SongModel>[];
    final seen = <String>{};
    for (final q in queries) {
      final list = await search(q, limit: perQuery);
      for (final s in list) {
        if (s.songid != null && seen.add(s.songid!)) {
          all.add(s);
        }
      }
    }
    return all;
  }
}
