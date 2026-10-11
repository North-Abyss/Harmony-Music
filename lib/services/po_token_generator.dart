import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:harmonymusic/utils/helper.dart';

class PoTokenResult {
  final String visitorData;
  final String poToken;
  PoTokenResult(this.visitorData, this.poToken);
}

class PoTokenGenerator {
  static const String _requestKey = "O43z0dpjhgX20SCx4KAo";
  static const String _googleApiKey = "AIzaSyDyT5W0Jh49F30Pqqtyfdf7pDLFKLJoAnw";
  static const String _userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36";

  static Future<String> _makeBotguardServiceRequest(String url, List<dynamic> data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "User-Agent": _userAgent,
        "Accept": "application/json",
        "Content-Type": "application/json+protobuf",
        "x-goog-api-key": _googleApiKey,
        "x-user-agent": "grpc-web-javascript/0.1",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load botguard service: ${response.statusCode}');
    }
    return response.body;
  }

  static String _descramble(String scrambledChallenge) {
    // Ported from ytdlnis descramble logic
    final decodedBytes = base64Decode(scrambledChallenge);
    final output = List<int>.filled(decodedBytes.length, 0);
    for (int i = 0; i < decodedBytes.length; i++) {
      int b = decodedBytes[i] + 97;
      if (b > 255) b -= 256;
      output[i] = b;
    }
    return utf8.decode(output);
  }

  static Map<String, dynamic> _parseChallengeData(String rawChallengeData) {
    final scrambled = jsonDecode(rawChallengeData) as List;
    List challengeData;
    if (scrambled.length > 1 && scrambled[1] is String) {
      final descrambled = _descramble(scrambled[1] as String);
      challengeData = jsonDecode(descrambled) as List;
    } else {
      challengeData = scrambled[1] as List;
    }

    final messageId = challengeData[0].toString();
    final interpreterHash = challengeData[3].toString();
    final program = challengeData[4].toString();
    final globalName = challengeData[5].toString();
    final clientExperimentsStateBlob = challengeData[7].toString();

    var scriptWrappedValue = challengeData[1] != null && challengeData[1] is List 
        ? challengeData[1].firstWhere((e) => e is String, orElse: () => null) 
        : null;
        
    return {
      "messageId": messageId,
      "interpreterJavascript": {
        "privateDoNotAccessOrElseSafeScriptWrappedValue": scriptWrappedValue
      },
      "interpreterHash": interpreterHash,
      "program": program,
      "globalName": globalName,
      "clientExperimentsStateBlob": clientExperimentsStateBlob
    };
  }

  static Map<String, dynamic> _parseIntegrityTokenData(String rawIntegrityTokenData) {
    final integrityTokenData = jsonDecode(rawIntegrityTokenData) as List;
    final tokenStr = integrityTokenData.firstWhere(
      (e) => e is String && e.isNotEmpty,
      orElse: () => null,
    ) as String?;
    final exp = integrityTokenData.firstWhere(
      (e) => e is num,
      orElse: () => 43200,
    ) as num;
    if (tokenStr == null) {
      throw Exception("Could not find integrity token string in response: $rawIntegrityTokenData");
    }
    return {
      "integrityToken": _base64ToU8(tokenStr),
      "expirationTimeInSeconds": exp.toInt()
    };
  }

  static List<int> _base64ToU8(String b64) {
    var mod = b64.replaceAll('-', '+').replaceAll('_', '/').replaceAll('.', '=');
    while (mod.length % 4 != 0) {
      mod += '=';
    }
    return base64Decode(mod);
  }

  static String _stringToU8(String identifier) {
    return "[${utf8.encode(identifier).join(',')}]";
  }

  static String _u8ToBase64(List<dynamic> poTokenU8) {
    final bytes = poTokenU8.map((e) => int.parse(e.toString())).toList();
    return base64UrlEncode(bytes);
  }

  static Future<PoTokenResult?> generateToken(String videoId) async {
    JavascriptRuntime? jsRuntime;
    try {
      final createResponse = await _makeBotguardServiceRequest(
        "https://www.youtube.com/api/jnn/v1/Create", 
        [_requestKey]
      );
      
      final challengeData = _parseChallengeData(createResponse);
      final jsCode = await rootBundle.loadString('assets/js/po_token.js');
      
      jsRuntime = getJavascriptRuntime();
      final rt = jsRuntime;
      
      // Setup JS environment
      rt.evaluate("""
        var globalThis = this;
        var window = this;
        var navigator = { userAgent: '$_userAgent' };
        var document = {
          createElement: function() { return { style: {}, getContext: function() { return {}; } }; },
          documentElement: { style: {} },
          cookie: ""
        };
        var location = { href: "https://www.youtube.com", hostname: "www.youtube.com" };
        
        // flutter_js polyfills setTimeout, but not setInterval
        var _intervals = {};
        var setInterval = function(cb, ms) { 
          if (ms < 10) ms = 10;
          var id = Math.random().toString();
          _intervals[id] = true;
          function loop() {
            if (_intervals[id]) {
              cb();
              setTimeout(loop, ms);
            }
          }
          setTimeout(loop, ms);
          return id;
        };
        var clearInterval = function(id) {
          _intervals[id] = false;
        };
      """);
      
      rt.evaluate(jsCode);
      
      // Inject challenge data
      final challengeJson = jsonEncode(challengeData);
      rt.evaluate("var challengeData = $challengeJson;");
      
      // Run bot guard
      printINFO("Evaluating runBotGuard...");
      final botGuardPromise = rt.evaluate("""
        (function() {
          try {
            return runBotGuard(challengeData).then(function(res) {
              globalThis.webPoSignalOutput = res.webPoSignalOutput;
              return JSON.stringify({ success: res.botguardResponse });
            }).catch(function(err) {
              return JSON.stringify({error: err.toString()});
            });
          } catch (syncErr) {
            return JSON.stringify({error: syncErr.toString()});
          }
        })();
      """);
      
      printINFO("Awaiting botGuardPromise...");
      final botGuardResultStr = await rt.handlePromise(botGuardPromise);
      final rawResult = botGuardResultStr.stringResult;
      printINFO("BotGuard Raw Result: $rawResult");
      
      final botGuardResult = jsonDecode(rawResult);
      if (botGuardResult['error'] != null) {
        throw Exception("BotGuard Error: \${botGuardResult['error']}");
      }
      
      final botguardResponse = botGuardResult['success'];
      
      final itResponse = await _makeBotguardServiceRequest(
        "https://www.youtube.com/api/jnn/v1/GenerateIT",
        [_requestKey, botguardResponse]
      );
      printINFO("GenerateIT response: $itResponse");
      
      final itData = _parseIntegrityTokenData(itResponse);
      final integrityTokenU8 = itData['integrityToken'] as List<int>;
      
      rt.evaluate("var integrityToken = new Uint8Array([${integrityTokenU8.join(',')}]);");
      rt.evaluate("var u8Identifier = new Uint8Array(${_stringToU8(videoId)});");
      
      final poTokenExec = rt.evaluate("""
        (function() {
          try {
            var poTokenU8 = obtainPoToken(globalThis.webPoSignalOutput, integrityToken, u8Identifier);
            var poTokenU8String = "";
            for (var i = 0; i < poTokenU8.length; i++) {
                if (i != 0) poTokenU8String += ",";
                poTokenU8String += poTokenU8[i];
            }
            return JSON.stringify({success: poTokenU8String});
          } catch(e) {
            return JSON.stringify({error: e.toString()});
          }
        })();
      """);
      
      final poTokenResultStr = poTokenExec.stringResult;
      final poTokenMap = jsonDecode(poTokenResultStr);
      if (poTokenMap['error'] != null) {
        throw Exception("PoToken Error: \${poTokenMap['error']}");
      }
      
      final poTokenU8 = (poTokenMap['success'] as String).split(',');
      final poToken = _u8ToBase64(poTokenU8);
      
      printINFO("Generated PoToken: $poToken");
      return PoTokenResult("visitorData_placeholder", poToken);
      
    } catch (e, stack) {
      printINFO("Failed to generate PoToken natively: $e\n$stack");
      return null;
    } finally {
      if (jsRuntime != null) {
        jsRuntime.dispose();
      }
    }
  }
}
