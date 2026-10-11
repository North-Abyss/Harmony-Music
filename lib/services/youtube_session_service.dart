import 'dart:convert';
import 'dart:io';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

class YoutubeSession {
  final String cookieHeader;
  final String visitorData;
  final int signatureTimestamp;
  final DateTime createdAt;

  YoutubeSession({
    required this.cookieHeader,
    required this.visitorData,
    required this.signatureTimestamp,
    required this.createdAt,
  });

  bool get isExpired =>
      DateTime.now().difference(createdAt) > const Duration(hours: 6);
}

class YoutubeSessionService {
  static YoutubeSession? _cachedSession;
  static Future<YoutubeSession>? _inFlightFetch;

  static const String fallbackVisitorId =
      "CgtUUlRLdlFpWnpwTSiO2cTQBjIKCgJJThIEGgAgXGLfAgrcAjE4LllUPXliZjFrdFhkbFVKempIRVRvMWV0ZGdJQmVCQ29rMW1vTFdGeXAteUh4VlZfV2N5Z1FqMnJqYVBuZTh4enFUSnhXREsyTDlYWDM0d3ZvWDY2QmQ5aXJuZFJFN2lsVFFyanBPZnFvTWV4bGFmYjBSd2RxVVFBeDY1X3BUcGx3VDF4NWItaGxXZC01NGdrZ1ZZbmpBN0w0eFVfQVo0YlhQaWFTckN3QkdWeGMzNmY0Z1k3QmFZakpheUtmakpCMzVXX3QxenNXZVB4aXZPRGIwS19kZGtXTkMwc29QSTZGTUluTjVlRWpOZGVMLVRHM3NIaTQtT1VVaEpaRXhoNzRXTU1HNFF5Y2ZPTUkzQS1Nc2hlby0tSXprWXFEaW1mYVExUEFFZlRaZ3VFMkNXN0lxdGY2ellhejB2QmUtaEdwdENDREJydmJNak5IMU1FUmh1d2xza2F3QQ%3D%3D";

  static const String chromeUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36";
  static const String visionOsUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15";

  /// Returns the current active YouTube session with cookies, visitorData, and STS.
  static Future<YoutubeSession> getSession({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSession != null && !_cachedSession!.isExpired) {
      return _cachedSession!;
    }

    if (_inFlightFetch != null) {
      return _inFlightFetch!;
    }

    _inFlightFetch = _fetchFreshSession();
    try {
      final session = await _inFlightFetch!;
      _cachedSession = session;
      return session;
    } finally {
      _inFlightFetch = null;
    }
  }

  static Future<YoutubeSession> _fetchFreshSession() async {
    String? visitorData;
    int sts = 20732;

    // 1. Try to read existing visitorId from AppPrefs Box
    try {
      if (Hive.isBoxOpen('AppPrefs')) {
        final box = Hive.box('AppPrefs');
        if (box.containsKey('visitorId')) {
          final vData = box.get('visitorId');
          if (vData != null && vData is Map && vData['id'] != null) {
            visitorData = vData['id'].toString();
          }
        }
      }
    } catch (_) {}

    final client = HttpClient();
    final Map<String, String> cookieMap = {
      'SOCS': 'CAI',
      'PREF': 'hl=en&tz=UTC',
    };

    try {
      printINFO("YoutubeSessionService: Initializing session with YouTube...");
      // Fetch music.youtube.com which reliably returns 200 without bot rate-limiting
      final req = await client.getUrl(Uri.parse("https://music.youtube.com/"));
      req.headers.set('User-Agent', chromeUserAgent);
      req.headers.set('Accept-Language', 'en-US,en;q=0.9');
      req.headers.set('Sec-Fetch-Mode', 'navigate');
      req.cookies.add(Cookie('SOCS', 'CAI'));
      req.cookies.add(Cookie('PREF', 'hl=en&tz=UTC'));

      final res = await req.close();
      for (final cookie in res.cookies) {
        cookieMap[cookie.name] = cookie.value;
      }

      if (res.statusCode == 200) {
        final bodyHtml = await utf8.decodeStream(res);
        final reg = RegExp(r'ytcfg\.set\s*\(\s*({.+?})\s*\)\s*;');
        final matches = reg.firstMatch(bodyHtml);
        if (matches != null) {
          try {
            final ytcfg = json.decode(matches.group(1).toString());
            final vFromPage = ytcfg['VISITOR_DATA']?.toString();
            if (vFromPage != null && vFromPage.isNotEmpty) {
              visitorData = vFromPage;
              if (Hive.isBoxOpen('AppPrefs')) {
                Hive.box('AppPrefs').put('visitorId', {
                  'id': visitorData,
                  'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2592000
                });
              }
            }
            final stsVal = ytcfg['STS'] ?? ytcfg['signatureTimestamp'];
            if (stsVal != null) {
              sts = int.tryParse(stsVal.toString()) ?? sts;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      printINFO("YoutubeSessionService network fetch notice: $e");
    } finally {
      client.close();
    }

    visitorData ??= fallbackVisitorId;

    final cookieHeader = cookieMap.entries
        .map((e) => "${e.key}=${e.value}")
        .join("; ");

    printINFO(
        "YoutubeSessionService: Session initialized (Visitor: ${visitorData.isNotEmpty ? 'Active' : 'Fallback'}, STS: $sts, Cookies: ${cookieMap.length})");

    return YoutubeSession(
      cookieHeader: cookieHeader,
      visitorData: visitorData,
      signatureTimestamp: sts,
      createdAt: DateTime.now(),
    );
  }

  static void invalidate() {
    _cachedSession = null;
  }
}
