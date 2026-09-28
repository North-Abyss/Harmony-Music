import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

class SyncedLyricsService {
  static Future<Map<String, dynamic>?> getSyncedLyrics(
      MediaItem song, int durInSec, {bool forceReload = false}) async {
    final lyricsBox = await Hive.openBox("lyrics");
    // check if lyrics available in local database
    if (!forceReload && lyricsBox.containsKey(song.id)) {
      return Map<String, dynamic>.from(await lyricsBox.get(song.id));
    }

    final dur = song.duration?.inSeconds ?? durInSec;
    
    // Attempt 1: Exact match using GET (requires valid duration)
    if (dur > 0 && dur <= 3600) {
      final getUrl =
          'https://lrclib.net/api/get?artist_name=${song.artist?.replaceAll(" ", "+")}&track_name=${song.title.replaceAll(" ", "+")}&album_name=${song.album?.replaceAll(" ", "+")}&duration=$dur';
      try {
        final response = (await Dio().get(getUrl)).data;
        if (response["syncedLyrics"] != null) {
          printINFO("Synced Available (Exact Match)");
          final lyricsData = {
            "synced": response["syncedLyrics"],
            "plainLyrics": response["plainLyrics"] ?? ""
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
        'https://lrclib.net/api/search?q=${song.title.replaceAll(" ", "+")}+${song.artist?.replaceAll(" ", "+")}';
    try {
      final response = (await Dio().get(searchUrl)).data as List;
      if (response.isNotEmpty) {
        final firstMatch = response.first;
        if (firstMatch["syncedLyrics"] != null || firstMatch["plainLyrics"] != null) {
          printINFO("Synced Available (Search Match)");
          final lyricsData = {
            "synced": firstMatch["syncedLyrics"] ?? "",
            "plainLyrics": firstMatch["plainLyrics"] ?? ""
          };
          await lyricsBox.put(song.id, lyricsData);
          await lyricsBox.close();
          return lyricsData;
        }
      }
    } on DioException catch (e) {
      printERROR(e.response);
    } finally {
      if (lyricsBox.isOpen) await lyricsBox.close();
    }
    
    return null;
  }
}
