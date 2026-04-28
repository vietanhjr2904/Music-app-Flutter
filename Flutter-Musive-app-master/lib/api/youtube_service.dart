import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_model.dart';

/// Search YouTube for Vietnamese music and resolve audio-only stream URLs.
///
/// Note: Stream URLs from YouTube expire after a few hours. We cache only
/// video metadata (id, title, channel, thumbnail) and resolve the stream
/// URL per session.
class YouTubeService {
  static final YoutubeExplode _yt = YoutubeExplode();

  /// On web YouTube googlevideo.com URLs are blocked by CORS, so we skip
  /// entirely and let callers fall back to mock data.
  static bool get isAvailable => !kIsWeb;

  /// Resolve playable audio stream URL for a video id. Returns null on failure.
  static Future<String?> resolveAudioUrl(String videoId) async {
    if (kIsWeb) return null;
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      return audio.url.toString();
    } catch (e) {
      debugPrint('[YouTubeService] resolve $videoId failed: $e');
      return null;
    }
  }

  /// Search and return up to [limit] songs with resolved audio URLs.
  /// Resolution is sequential to avoid YouTube rate-limit; for speed the
  /// metadata is cached for 12h.
  static Future<List<SongModel>> search(String query, {int limit = 15}) async {
    if (kIsWeb) return [];
    final cleanQ = query.trim();
    if (cleanQ.isEmpty) return [];

    final cache = Hive.box('ytCache');
    final cacheKey = 'q:$cleanQ:l:$limit';
    List<Map<String, dynamic>> meta = [];
    final cached = cache.get(cacheKey);
    if (cached != null) {
      final at = DateTime.tryParse(cached['at'] ?? '');
      if (at != null &&
          DateTime.now().difference(at) < const Duration(hours: 12)) {
        meta = (cached['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    if (meta.isEmpty) {
      try {
        final results =
            await _yt.search.search('$cleanQ official audio');
        const junkWords = [
          'liên khúc',
          'lien khuc',
          'tổng hợp',
          'tong hop',
          'playlist',
          'mix ',
          ' mix',
          'top ',
          'reaction',
          'react',
          'tiktok',
          '1 hour',
          '1 giờ',
          'cover',
          'karaoke',
        ];
        for (final v in results) {
          if (v.duration == null ||
              v.duration!.inMinutes > 8 ||
              v.duration!.inSeconds < 60) {
            continue;
          }
          final lower = v.title.toLowerCase();
          if (junkWords.any(lower.contains)) continue;
          meta.add({
            'id': v.id.value,
            'title': v.title,
            'author': v.author,
            'thumb': v.thumbnails.highResUrl,
            'duration': v.duration!.inSeconds,
          });
          if (meta.length >= limit) break;
        }
        await cache.put(cacheKey, {
          'at': DateTime.now().toIso8601String(),
          'data': meta,
        });
      } catch (e) {
        debugPrint('[YouTubeService] search "$cleanQ" failed: $e');
        return [];
      }
    }

    final songs = <SongModel>[];
    for (final m in meta) {
      final url = await resolveAudioUrl(m['id'] as String);
      if (url == null) continue;
      songs.add(SongModel(
        songid: m['id'] as String?,
        songname: m['title'] as String?,
        userid: m['author'] as String?,
        trackid: url,
        duration: '${m['duration']}',
        coverImageUrl: m['thumb'] as String?,
        name: m['author'] as String?,
      ));
    }
    return songs;
  }

  /// Search several queries and merge unique results.
  static Future<List<SongModel>> searchMany(List<String> queries,
      {int perQuery = 4}) async {
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
