import 'dart:io';
import 'package:harmonymusic/utils/helper.dart';

class LocalProxy {
  static HttpServer? _server;
  static final Map<String, _ProxyTask> _urlMap = {};

  static Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      printINFO("Local proxy started on port ${_server!.port}");
      _server!.listen((HttpRequest request) async {
        final id = request.uri.pathSegments.isNotEmpty ? request.uri.pathSegments.first : '';
        if (id.endsWith('.mp3')) {
          final realId = id.substring(0, id.length - 4);
          final task = _urlMap[realId];
          if (task == null) {
            request.response.statusCode = HttpStatus.notFound;
            request.response.close();
            return;
          }

          try {
            final client = HttpClient();
            final clientReq = await client.getUrl(Uri.parse(task.url));
            if (task.headers != null) {
              task.headers!.forEach((key, value) {
                clientReq.headers.set(key, value);
              });
            }
            
            // Allow seeking by passing Range header if present
            if (request.headers.value('range') != null) {
              clientReq.headers.set('range', request.headers.value('range')!);
            }

            final clientRes = await clientReq.close();
            
            printINFO("LocalProxy: YouTube returned status ${clientRes.statusCode} for ${task.url.substring(0, 50)}...");
            
            request.response.statusCode = clientRes.statusCode;
            clientRes.headers.forEach((name, values) {
              for (final value in values) {
                request.response.headers.add(name, value);
              }
            });
            
            await clientRes.pipe(request.response);
          } catch (e) {
            printINFO("LocalProxy Error: $e");
            request.response.statusCode = HttpStatus.internalServerError;
            request.response.close();
          }
        } else {
          request.response.statusCode = HttpStatus.notFound;
          request.response.close();
        }
      });
    } catch (e) {
      printINFO("Failed to start local proxy: $e");
    }
  }

  static String addUrl(String url, {Map<String, String>? headers}) {
    if (_server == null) {
      start(); // Attempt to start it if it hasn't been started
      // Give it a small delay or just wait for the next call to succeed, but realistically it should be started in main.
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _urlMap[id] = _ProxyTask(url, headers);
    
    // cleanup old tasks to prevent memory leaks (keep only latest 10)
    if (_urlMap.length > 10) {
      final keys = _urlMap.keys.toList();
      _urlMap.remove(keys.first);
    }
    
    // Defaulting to 8080 isn't ideal but will quickly fail or succeed
    return 'http://127.0.0.1:${_server?.port ?? 8080}/$id.mp3';
  }
}

class _ProxyTask {
  final String url;
  final Map<String, String>? headers;

  _ProxyTask(this.url, this.headers);
}
