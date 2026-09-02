import 'dart:io';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:harmonymusic/utils/helper.dart';

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

    // Attempt 1: IOS Client
    // Known to bypass many music streaming restrictions.
    final iosRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'IOS',
      clientVersion: '19.43.2',
      userAgent: 'com.google.ios.youtube/19.43.2 (iPhone16,2; U; CPU iOS 18_1 like Mac OS X;)',
      clientId: '5',
    );
    if (iosRes != null) {
      if (iosRes.playable) return iosRes;
      lastStatusMsg = iosRes.statusMSG;
    }

    // Attempt 2: ANDROID Client
    final androidRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'ANDROID',
      clientVersion: '20.10.38',
      userAgent: 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
      clientId: '3',
    );
    if (androidRes != null) {
      if (androidRes.playable) return androidRes;
      lastStatusMsg = androidRes.statusMSG;
    }

    // Attempt 3: ANDROID_VR Client (Oculus Quest 3)
    final androidVrRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'ANDROID_VR',
      clientVersion: '1.61.48',
      userAgent:
          'com.google.android.apps.youtube.vr.oculus/1.61.48 (Linux; U; Android 12; en_US; Oculus Quest 3; Build/SQ3A.220605.009.A1; Cronet/132.0.6808.3)',
      clientId: '28',
    );
    if (androidVrRes != null) {
      if (androidVrRes.playable) return androidVrRes;
      lastStatusMsg = androidVrRes.statusMSG;
    }

    // Attempt 4: VISIONOS Client
    final visionOsRes = await _fetchInnerTube(
      videoId: cleanId,
      clientName: 'VISIONOS',
      clientVersion: '1.02',
      userAgent:
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15',
      clientId: '101',
    );
    if (visionOsRes != null) {
      if (visionOsRes.playable) return visionOsRes;
      lastStatusMsg = visionOsRes.statusMSG;
    }

    // Attempt 5: youtube_explode_dart (Original Fallback)
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
                  duration: e.duration ?? 0,
                  loudnessDb: e.loudnessDb,
                  url: e.url.toString(),
                  size: e.size.totalBytes,
                ))
            .toList(),
      );
    } catch (e) {
      if (e is SocketException) {
        return StreamProvider(playable: false, statusMSG: "networkError");
      } else if (e is VideoUnplayableException) {
        // Fallback to our lastStatusMsg if youtube_explode throws an unplayable error
        return StreamProvider(playable: false, statusMSG: lastStatusMsg != "Unknown error occurred" ? lastStatusMsg : (e.message.split('\n').firstOrNull ?? "Song is unplayable"));
      } else if (e is VideoRequiresPurchaseException) {
        return StreamProvider(playable: false, statusMSG: "Song requires purchase");
      } else if (e is VideoUnavailableException) {
        return StreamProvider(playable: false, statusMSG: "Song is unavailable");
      } else if (e is YoutubeExplodeException) {
        return StreamProvider(playable: false, statusMSG: e.message);
      } else {
        return StreamProvider(playable: false, statusMSG: lastStatusMsg);
      }
    }
  }

  static Future<StreamProvider?> _fetchInnerTube({
    required String videoId,
    required String clientName,
    required String clientVersion,
    required String userAgent,
    required String clientId,
  }) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.postUrl(
          Uri.parse('https://music.youtube.com/youtubei/v1/player?key=AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'));
      
      request.headers.set('content-type', 'application/json');
      request.headers.set('X-YouTube-Client-Name', clientId);
      request.headers.set('X-YouTube-Client-Version', clientVersion);
      request.headers.set('User-Agent', userAgent);

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
