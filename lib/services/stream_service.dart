import 'dart:io';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

class StreamProvider {
  final bool playable;
  final List<Audio>? audioFormats;
  final String statusMSG;
  final Map<String, String>? streamHeaders;

  StreamProvider({
    required this.playable,
    this.audioFormats,
    this.statusMSG = "",
    this.streamHeaders,
  });

  static Future<StreamProvider> fetch(String videoId) async {
    // 1. Strip MPED prefix if present
    String cleanId = videoId;
    if (cleanId.startsWith("MPED")) {
      cleanId = cleanId.substring(4);
    }
    
    String lastStatusMsg = "Unknown error occurred";
    final appPrefsBox = Hive.box('AppPrefs');
    final visitorData = appPrefsBox.get("visitorId");
    final visitorId = visitorData != null ? visitorData['id'] : '';

    // Attempt 1: TV_EMBEDDED Client
    // Currently the most reliable bypass for bot detection (yt-dlp recommended)
    final tvRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'TVHTML5_SIMPLY_EMBEDDED_PLAYER',
      clientVersion: '2.0',
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
      clientId: '85',
      visitorId: visitorId,
    );
    if (tvRes != null) {
      if (tvRes.playable) return tvRes;
      lastStatusMsg = tvRes.statusMSG;
    }

    // Attempt 2: WEB_EMBEDDED Client
    final webRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'WEB_EMBEDDED',
      clientVersion: '1.20240104.01.00',
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      clientId: '56',
      visitorId: visitorId,
    );
    if (webRes != null) {
      if (webRes.playable) return webRes;
      lastStatusMsg = webRes.statusMSG;
    }

    // Attempt 3: ANDROID Client
    final androidRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'ANDROID',
      clientVersion: '20.10.38',
      userAgent: 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
      clientId: '3',
      visitorId: visitorId,
    );
    if (androidRes != null) {
      if (androidRes.playable) return androidRes;
      lastStatusMsg = androidRes.statusMSG;
    }

    // Attempt 4: youtube_explode_dart (Upgraded to v3)
    final yt = YoutubeExplode();
    try {
      final res = await yt.videos.streamsClient.getManifest(cleanId);
      final audio = res.audioOnly;
      return StreamProvider(
        playable: true,
        statusMSG: "OK",
        audioFormats: audio
            .map((e) => Audio(
                  itag: e.tag,
                  audioCodec:
                      e.audioCodec.contains('mp') ? Codec.mp4a : Codec.opus,
                  bitrate: e.bitrate.bitsPerSecond,
                  duration: 0,
                  loudnessDb: 0.0,
                  url: e.url.toString(),
                  size: e.size.totalBytes,
                ))
            .toList(),
        streamHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Referer': 'https://www.youtube.com/',
        },
      );
    } catch (e) {
      printINFO("YoutubeExplode Error: $e");
      lastStatusMsg = "YT_Explode: ${e.toString().split('\\n').first}";
    }

    // Attempt 5: Piped API Fallback
    try {
      final piped = appPrefsBox.get('piped');
      final pipedUrl = (piped != null && piped['instApiUrl'] != null && piped['instApiUrl'].isNotEmpty) 
          ? piped['instApiUrl'] 
          : "https://pipedapi.kavin.rocks";
      
      final request = await HttpClient().getUrl(Uri.parse('$pipedUrl/streams/$cleanId'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bodyString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(bodyString);
        final audioStreams = data['audioStreams'] as List;
        if (audioStreams.isNotEmpty) {
           return StreamProvider(
             playable: true,
             statusMSG: "OK",
             audioFormats: audioStreams.map((e) => Audio(
                itag: int.tryParse(e['itag'].toString()) ?? 0,
                audioCodec: e['codec'].toString().contains('mp') ? Codec.mp4a : Codec.opus,
                bitrate: e['bitrate'] ?? 0,
                duration: 0,
                loudnessDb: 0.0,
                url: e['url'] ?? '',
                size: e['contentLength'] ?? 0,
             )).toList(),
             streamHeaders: null,
           );
        }
      } else {
        printINFO("Piped HTTP Error: ${response.statusCode}");
      }
    } catch(e) {
      printINFO("Piped API Error: $e");
    }

    return StreamProvider(playable: false, statusMSG: lastStatusMsg);

  }

  static Future<StreamProvider?> _fetchInnerTube({
    required String videoId,
    required String clientName,
    required String clientVersion,
    required String userAgent,
    required String clientId,
    required String visitorId,
  }) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.postUrl(
          Uri.parse('https://music.youtube.com/youtubei/v1/player?key=AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'));
      
      request.headers.set('content-type', 'application/json');
      request.headers.set('X-YouTube-Client-Name', clientId);
      request.headers.set('X-YouTube-Client-Version', clientVersion);
      request.headers.set('User-Agent', userAgent);
      if (visitorId.isNotEmpty) {
        request.headers.set('X-Goog-Visitor-Id', visitorId);
      }

      final payload = {
        'context': {
          'client': {
            'clientName': clientName,
            'clientVersion': clientVersion,
            'userAgent': userAgent,
            'hl': 'en',
            'gl': 'US',
          },
          'user': {}
        },
        'videoId': videoId,
        'contentCheckOk': true,
        'racyCheckOk': true,
      };

      request.write(jsonEncode(payload));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bodyString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(bodyString);

        final streamingData = data['streamingData'];
        if (streamingData != null) {
          final adaptiveFormats = streamingData['adaptiveFormats'] as List?;
          if (adaptiveFormats != null && adaptiveFormats.isNotEmpty) {
            final audioFormats = adaptiveFormats
                .where((f) => f['mimeType'].toString().contains('audio') && f['url'] != null && f['url'].toString().isNotEmpty)
                .map((e) {
              return Audio(
                itag: e['itag'] ?? 0,
                audioCodec: e['mimeType'].toString().contains('mp4a')
                    ? Codec.mp4a
                    : Codec.opus,
                bitrate: e['bitrate'] ?? e['averageBitrate'] ?? 0,
                duration: int.tryParse(e['approxDurationMs']?.toString() ?? '0') ?? 0,
                loudnessDb: (e['loudnessDb'] as num?)?.toDouble() ?? 0.0,
                url: e['url'] ?? '',
                size: int.tryParse(e['contentLength']?.toString() ?? '0') ?? 0,
              );
            }).toList();

            if (audioFormats.isNotEmpty) {
              printINFO('InnerTube fetched ${audioFormats.length} streams successfully via $clientName');
              return StreamProvider(
                playable: true,
                statusMSG: "OK",
                audioFormats: audioFormats,
                streamHeaders: {
                  'User-Agent': userAgent,
                },
              );
            } else {
              printINFO('InnerTube $clientName returned streamingData but no formats with direct URLs.');
              return StreamProvider(playable: false, statusMSG: "No direct streams available");
            }
          }
        } else {
          final playability = data['playabilityStatus'];
          final reason = playability?['reason'] ?? playability?['status'] ?? "Unknown error";
          printINFO('InnerTube $clientName returned no streamingData. Playability: $reason');
          return StreamProvider(playable: false, statusMSG: reason.toString());
        }
      } else {
        printINFO('InnerTube $clientName HTTP Error: ${response.statusCode}');
        return StreamProvider(playable: false, statusMSG: "HTTP ${response.statusCode}");
      }
    } catch (e) {
      printINFO('InnerTube $clientName Exception: $e');
      return StreamProvider(playable: false, statusMSG: "Connection error");
    }
    return null;
  }

  Audio? get highestQualityAudio =>
      audioFormats?.lastWhere((item) => item.itag == 251 || item.itag == 140,
          orElse: () => audioFormats!.first);

  Audio? get highestBitrateMp4aAudio =>
      audioFormats?.lastWhere((item) => item.itag == 140 || item.itag == 139,
          orElse: () => audioFormats!.first);

  Audio? get highestBitrateOpusAudio =>
      audioFormats?.lastWhere((item) => item.itag == 251 || item.itag == 250,
          orElse: () => audioFormats!.first);

  Audio? get lowQualityAudio =>
      audioFormats?.lastWhere((item) => item.itag == 249 || item.itag == 139,
          orElse: () => audioFormats!.first);

  Map<String, dynamic> get hmStreamingData {
    return {
      "playable": playable,
      "statusMSG": statusMSG,
      "lowQualityAudio": lowQualityAudio?.toJson(),
      "highQualityAudio": highestQualityAudio?.toJson(),
      if (streamHeaders != null) "streamHeaders": streamHeaders,
    };
  }
}

class Audio {
  final int itag;
  final Codec audioCodec;
  final int bitrate;
  final int duration;
  final int size;
  final double loudnessDb;
  final String url;
  Audio({
    required this.itag,
    required this.audioCodec,
    required this.bitrate,
    required this.duration,
    required this.loudnessDb,
    required this.url,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        "itag": itag,
        "audioCodec": audioCodec.toString(),
        "bitrate": bitrate,
        "loudnessDb": loudnessDb,
        "url": url,
        "approxDurationMs": duration,
        "size": size
      };

  factory Audio.fromJson(json) => Audio(
      audioCodec: (json["audioCodec"] as String).contains("mp4a")
          ? Codec.mp4a
          : Codec.opus,
      itag: json['itag'],
      duration: json["approxDurationMs"] ?? 0,
      bitrate: json["bitrate"] ?? 0,
      loudnessDb: (json['loudnessDb'])?.toDouble() ?? 0.0,
      url: json['url'],
      size: json["size"] ?? 0);
}

enum Codec { mp4a, opus }
