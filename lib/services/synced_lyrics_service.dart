import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

class SyncedLyricsService {
  static String _sanitize(String input) {
    // Replace the replacement character and try to fix malformed strings
    String cleaned = input.replaceAll('\uFFFD', '');
    // Safely rebuild the string using valid Unicode Runes to drop unpaired UTF-16 surrogates
    return String.fromCharCodes(cleaned.runes);
  }

  static Future<Map<String, dynamic>?> getSyncedLyrics(
      MediaItem song, int durInSec, {bool forceReload = false}) async {
    final lyricsBox = await Hive.openBox("lyrics");
    // check if lyrics available in local database
    if (!forceReload && lyricsBox.containsKey(song.id)) {
      final cached = Map<String, dynamic>.from(await lyricsBox.get(song.id));
      return {
        "synced": _sanitize(cached["synced"] ?? ""),
        "plainLyrics": _sanitize(cached["plainLyrics"] ?? "")
      };
    }

    final dur = song.duration?.inSeconds ?? durInSec;
    final encodedArtist = Uri.encodeComponent(song.artist ?? '');
    final encodedTitle = Uri.encodeComponent(song.title);
    final encodedAlbum = Uri.encodeComponent(song.album ?? '');
    
    // Attempt 1: Exact match using GET (requires valid duration)
    if (dur > 0 && dur <= 3600) {
      final getUrl =
          'https://lrclib.net/api/get?artist_name=$encodedArtist&track_name=$encodedTitle&album_name=$encodedAlbum&duration=$dur';
      try {
        final response = (await Dio().get(getUrl)).data;
        if (response is Map && response["syncedLyrics"] != null) {
          printINFO("Synced Available (Exact Match)");
          final lyricsData = {
            "synced": _sanitize(response["syncedLyrics"]),
            "plainLyrics": _sanitize(response["plainLyrics"] ?? "")
          };
          await lyricsBox.put(song.id, lyricsData);
          await lyricsBox.close();
          return lyricsData;
        }
      } catch (e) {
        printERROR("Exact match failed, falling back to search...");
      }
    }

    // Attempt 2: Fuzzy match using SEARCH
    final searchUrl = 
        'https://lrclib.net/api/search?q=$encodedTitle+$encodedArtist';
    try {
      final response = (await Dio().get(searchUrl)).data;
      if (response is List && response.isNotEmpty) {
        final firstMatch = response.first;
        if (firstMatch["syncedLyrics"] != null || firstMatch["plainLyrics"] != null) {
          printINFO("Synced Available (Search Match)");
          final lyricsData = {
            "synced": _sanitize(firstMatch["syncedLyrics"] ?? ""),
            "plainLyrics": _sanitize(firstMatch["plainLyrics"] ?? "")
          };
          await lyricsBox.put(song.id, lyricsData);
          await lyricsBox.close();
          return lyricsData;
        }
      }
    } catch (e) {
      printERROR("LRCLib search failed: $e");
    }

    // Attempt 3: api.lyrics.ovh Fallback (Plain Lyrics only)
    printINFO("Falling back to lyrics.ovh...");
    final ovhUrl = 'https://api.lyrics.ovh/v1/$encodedArtist/$encodedTitle';
    try {
      final response = (await Dio().get(ovhUrl)).data;
      if (response is Map && response["lyrics"] != null) {
        printINFO("Plain Lyrics Available (OVH Match)");
        final lyricsData = {
          "synced": "",
          "plainLyrics": _sanitize(response["lyrics"])
        };
        await lyricsBox.put(song.id, lyricsData);
        await lyricsBox.close();
        return lyricsData;
      }
    } catch (e) {
      printERROR("Lyrics.ovh failed: $e");
    } finally {
      if (lyricsBox.isOpen) await lyricsBox.close();
    }
    
    return null;
  }
}
