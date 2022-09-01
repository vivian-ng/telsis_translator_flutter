library google_transl;

import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import './tokens/google_token_gen.dart';
import './langs/language.dart';

part './model/translation.dart';

///
/// This library is a Dart implementation of Google Translate API
///
/// [author] Gabriel N. Pacheco.
///
class GoogleTranslator {
  var _baseUrl = 'translate.googleapis.com'; // faster than translate.google.com
  final _path = '/translate_a/single';
  final _tokenProvider = GoogleTokenGenerator();
  final _languageList = LanguageList();
  final ClientType client;

  GoogleTranslator({this.client = ClientType.siteGT});

  /// Translates texts from specified language to another
  Future<Translation> translate(String sourceText,
      {String from = 'auto', String to = 'en'}) async {
    for (var each in [from, to]) {
      if (!LanguageList.contains(each)) {
        throw LanguageNotSupportedException(each);
      }
    }

    final parameters = {
      'client': client == ClientType.siteGT ? 't' : 'gtx',
      'sl': from,
      'tl': to,
      'hl': to,
      'dt': 't',
      'ie': 'UTF-8',
      'oe': 'UTF-8',
      'otf': '1',
      'ssel': '0',
      'tsel': '0',
      'kc': '7',
      'tk': _tokenProvider.generateToken(sourceText),
      'q': sourceText
    };

    var url = Uri.https(_baseUrl, _path, parameters);
    //print(url);
    final data = await http.get(Uri.parse(url.toString() + '&dt=rm'));

    if (data.statusCode != 200) {
      throw http.ClientException('Error ${data.statusCode}: ${data.body}', url);
    }

    final jsonData = jsonDecode(data.body);
    //print(data.body);
    //print(jsonData[0][1][2]);
    //print(jsonData);
    //final sb = StringBuffer();

    //for (var c = 0; c < jsonData[0].length; c++) {
    //  sb.write(jsonData[0][c][0]);
    //}
    String sb = '';
    if (jsonData[0][0][0] != null) {
      sb = jsonData[0][0][0];
    }
    //final sb2 = StringBuffer();

    //for (var c = 1; c < jsonData[0].length; c++) {
    // sb2.write(jsonData[0][c][2]);
    //}
    String sb2 = '';
    if (jsonData[0][1][2] != null) {
      sb2 = jsonData[0][1][2];
    }
    //final sb2 = jsonData[0][1][2].toString();

    if (from == 'auto' && from != to) {
      from = jsonData[2] ?? from;
      if (from == to) {
        from = 'auto';
      }
    }

    final translated = sb.toString();
    final sound = sb2.toString();
    return _Translation(
      translated,
      sound,
      source: sourceText,
      sourceLanguage: _languageList[from],
      targetLanguage: _languageList[to],
    );
  }

  /// Translates and prints directly
  void translateAndPrint(String text,
      {String from = 'auto', String to = 'en'}) {
    translate(text, from: from, to: to).then(print);
  }

  /// Sets base URL for countries that default URL doesn't work
  void set baseUrl(String url) => _baseUrl = url;
}

enum ClientType {
  siteGT, // t
  extensionGT, // gtx (blocking ip sometimes)
}
