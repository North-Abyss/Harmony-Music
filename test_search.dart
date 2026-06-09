import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final _headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'accept': '*/*',
    'content-type': 'application/json',
    'origin': 'https://music.youtube.com/',
  };
  
  final _context = {
    'context': {
      'client': {
        "clientName": "WEB_REMIX",
        "clientVersion": "1.20231214.00.00",
        "hl": "en"
      },
      'user': {}
    },
    'query': 'alan walker'
  };

  final dio = Dio();
  final response = await dio.post(
    "https://music.youtube.com/youtubei/v1/search?prettyPrint=false&alt=json&key=AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30",
    options: Options(headers: _headers),
    data: _context
  );
  
  final contents = response.data['contents'];
  final tabs = contents['tabbedSearchResultsRenderer']['tabs'];
  final tab = tabs[0]['tabRenderer']['content'];
  final sections = tab['sectionListRenderer']['contents'];
  print('Found \${sections.length} sections');
  for (int i=0; i < sections.length; i++) {
    final sec = sections[i];
    if (sec.containsKey('musicShelfRenderer')) {
      print('Section \$i: musicShelfRenderer');
    } else if (sec.containsKey('musicCardShelfRenderer')) {
      print('Section \$i: musicCardShelfRenderer');
    } else if (sec.containsKey('itemSectionRenderer')) {
      print('Section \$i: itemSectionRenderer');
    } else {
      print('Section \$i: \${sec.keys}');
    }
  }
}
