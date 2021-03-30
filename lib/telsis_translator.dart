import 'package:args/args.dart';
import 'package:telsis_translator_flutter/src/langs/language.dart';
import 'package:telsis_translator_flutter/subcipher.dart';
//import 'package:translator/translator.dart';
import 'package:telsis_translator_flutter/translator.dart';
import 'package:diacritic/diacritic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

/// This package is based on the 'Telsis language translator'
/// Python app by Vivian Ng with source code
/// at https://github.com/vivian-ng/telsis_translator.
///
/// This package uses a modified version of the 'translator'
/// Dart package by Gabriel N. Pacheco available
/// at https://pub.dev/packages/translator with source
/// code at https://github.com/gabrielpacheco23/google-translator.

class TelsisTranslator {
  final translator = GoogleTranslator();
  var text;
  var srclang;
  var tgtlang;
  var result;
  Map<String, String> results = {
    'src_text': '',
    'tamil_text': '',
    'tamil_script': '',
    'tamil_sound': '',
    'tgt_text': '',
  };

  int current_name_number = 0;
  String name_code = '';
  Map<String, String> names_converted = {};

  TelsisTranslator(String this.text, String this.srclang, String this.tgtlang);

  String tamil2telsis(String tamil_string) {
    /// Convert tamil string of unaccented characters to Telsis
    /// using a substitution cipher.
    String converted_text = '';
    bool literal_flag = false;
    String c = '';
    String tchar = '';

    tamil_string.runes.forEach((int rune) {
      c = new String.fromCharCode(rune);
      if (c == '\\') {
        // escape character, flip literal flag
        literal_flag = !literal_flag;
        tchar = '';
      } else if (!subcipher.cipher_table.containsKey(c)) {
        // character not in cipher table
        tchar = c; // copy character without substitution
      } else {
        // character in cipher table
        if (literal_flag) {
          // part of name
          tchar = c; // just copy character, no substitution
        } else {
          // not part of name
          tchar = subcipher
              .substitute(c); // substitution character using cipher table
        }
      }
      if (tchar != '') {
        // character successfully copied/substituted
        converted_text = converted_text + tchar; // append to text string
      } else {
        // character not properly copied/substituted
        //converted_text = converted_text + '?';
        converted_text = converted_text + ''; // append nothing to text string
      }
    });

    return converted_text;
  }

  String replace_names(String textstring) {
    /// Replace name codes with actual literal values.
    for (var name_code in names_converted.keys) {
      textstring = textstring.replaceAll(name_code, names_converted[name_code]);
    }
    return textstring;
  }

  String telsis2tamil(String telsis_string) {
    /// Convert Telsis to tamil string of unaccented characters
    /// using a substitution cipher.
    String converted_text = tamil2telsis(telsis_string);
    return converted_text;
  }

  String preprocess_source_text(String text) {
    /// Preprocesses the source text to replace all names with
    /// a code: xxx1, xxx2, xxx3, ...
    bool literal_flag = false;
    String processed_text = '';
    String c = '';
    String name = '';

    text.runes.forEach((int rune) {
      c = new String.fromCharCode(rune);
      if (!literal_flag) {
        if (c != '\\') {
          // just copy, not part of name
          processed_text = processed_text + c;
        } else {
          // start of new name
          literal_flag = true;
          current_name_number++; // increment the number to append behind XXX
          name = '';
        }
      } else {
        if (c != '\\') {
          // copy and also part of name
          name = name + c;
          processed_text = processed_text + c;
        } else {
          // end of name
          literal_flag = false;
          name_code = 'xxx' + current_name_number.toString();
          names_converted[name_code] = name; // add name and code to dictionary
          name = '';
        }
      }
    });
    // Replace names with their corresponding name codes
    for (String name_code in names_converted.keys) {
      processed_text =
          processed_text.replaceAll(names_converted[name_code], name_code);
    }
    return processed_text;
  }

  Future tamil2lang(String source_text, String tgt_lang) async {
    /// Converts romanized Tamil to Tamil script, then uses
    /// the Tamil script for translation into the target language.
    // Create query string to send for conversion to Tamil script
    var endpointUrl = 'https://inputtools.google.com/request';
    Map<String, String> queryParams = {
      'text': source_text,
      'itc': 'ta-t-i0-und'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    var tamil_script = '';
    var tamil_script_url = endpointUrl + '?' + queryString;
    // Send query to Google's inputtools for conversion to Tamil script
    var data = await http.get(Uri.parse(tamil_script_url), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });
    if (data.statusCode != 200) {
      throw http.ClientException(
          'Error ${data.statusCode}: ${data.body}', tamil_script_url as Uri);
    }

    var tamil_res = jsonDecode(data.body);

    // Extract Tamil script results from JSON response
    if (tamil_res[0] == 'SUCCESS') {
      List tamil_res_list = [];
      for (var c = 0; c < tamil_res[1].length; c++) {
        tamil_res_list.add(tamil_res[1][c][1][0]);
      }
      tamil_script = tamil_res_list.join(',');
    }
    results['tamil_text'] = source_text;
    results['tamil_script'] = tamil_script;
    results['tamil_sound'] = '';

    // Use Google Translate to translate Tamil script to target language
    var translation =
        await translator.translate(tamil_script, from: 'ta', to: tgt_lang);
    results['tgt_text'] = translation.text;
    return translation.text;
  }

  Future lang2tamil(String source_text, String src_lang) async {
    /// Translate from real world language to Tamil.
    // Use Google Translate to translate to Tamil
    var translation =
        await translator.translate(source_text, from: src_lang, to: 'ta');
    results['src_text'] = source_text;
    results['tamil_script'] = translation.text;
    results['tamil_sound'] = translation.sound;
    // results in unaccented characters
    results['tamil_text'] = removeDiacritics(translation.sound);

    return results['tamil_text'];
  }

  Future lang2telsis(String source_text, String src_lang) async {
    /// Translates from real world language to Telsis language.
    source_text = preprocess_source_text(source_text);
    await lang2tamil(source_text, src_lang);
    var tgt_text = tamil2telsis(results['tamil_text']);
    results['tgt_text'] = replace_names(tgt_text);
  }

  Future telsis2lang(String source_text, String tgt_lang) async {
    /// Translates from Telsis language to real world language.
    await tamil2lang(telsis2tamil(source_text),
        tgt_lang); // convert from Telsis to Tamil, then translate to target language
    results['src_text'] = source_text;
  }

  Future translate(String sourcetext,
      {String src = '', String tgt = ''}) async {
    /// Translates the given text based on given source and
    /// target languages.
    /// Source and target languages are optional.

    text = sourcetext;
    srclang = src;
    tgtlang = tgt;
    print('Text = ' + text + '\nSource = ' + srclang + '\nTarget = ' + tgtlang);
    // Check if specified languages are supported
    if (srclang != '' && srclang != 'telsis') {
      if (!LanguageList.contains(srclang)) {
        print('Language not supported');
        return 1;
      }
    }
    if (tgtlang != '' && tgtlang != 'telsis') {
      if (!LanguageList.contains(tgtlang)) {
        print('Language not supported');
        return 1;
      }
    }
    // Check whether to translate from or to Telsis
    if (srclang == '' && tgtlang == '') {
      // Source and target languages not defined
      print('Either source or output language must be defined!');
      return 2;
    } else if (srclang == tgtlang) {
      // Source and target languages are the same
      print('Source and output language cannot be the same!');
      return 3;
    } else if (tgtlang == 'telsis') {
      // Translate to Telsis language
      if (srclang == '') {
        srclang = 'auto';
      }
      await lang2telsis(text, srclang);
      print(results['tgt_text']);
    } else if (srclang == 'telsis') {
      // Translate from Telsis language
      if (tgtlang == '') {
        tgtlang = 'en';
      }
      await telsis2lang(text, tgtlang);
      print(results['tgt_text']);
    } else if (srclang != '' && tgtlang == '') {
      // Translate to Telsis language from given source language
      await lang2telsis(text, srclang);
      print(results['tgt_text']);
    } else if (srclang == '' && tgtlang != '') {
      // Translate from Telsis language to given target language
      await telsis2lang(text, tgtlang);
      print(results['tgt_text']);
    } else {
      // Trying to translate from real world language to another real world language
      print('This is a Telsis language translator.');
      return 4;
    }

    return 0;
  }
}
