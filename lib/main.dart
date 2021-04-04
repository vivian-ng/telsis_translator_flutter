import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:telsis_translator_flutter/telsis_translator.dart';
import 'package:telsis_translator_flutter/src/langs/language.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telsis Translator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Telsis Translator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _translatedText = '';
  String _telsisText = '';
  Map<String, String> languages;
  Map<String, String> reverseLanguages;
  List<String> languageNames = [];
  final errorMessages = {
    1: 'Language not supported',
    2: 'Either source or output language must be defined',
    3: 'Source and output language cannot be the same',
    4: 'This is a Telsis language translator'
  };

  Future _translate() async {
    int returncode = 0;
    FocusScope.of(context).unfocus();
    String srclang =
        reverseLanguages[_formKey.currentState.fields['source_language'].value];
    String tgtlang =
        reverseLanguages[_formKey.currentState.fields['target_language'].value];
    String srctext = _formKey.currentState.fields['source_text'].value;
    TelsisTranslator translator = TelsisTranslator(srctext, srclang, tgtlang);
    returncode =
        await translator.translate(srctext, src: srclang, tgt: tgtlang);
    setState(() {
      if (returncode == 0) {
        _translatedText = translator.results['tgt_text'];
        if (tgtlang == 'telsis') {
          _telsisText = translator.results['tgt_text'];
        } else {
          _telsisText = translator.results['src_text'];
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text(errorMessages[returncode]),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    TextButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      }
    });
    return;
  }

  Map<String, String> _languages() {
    LanguageList languageList = LanguageList();
    return languageList.getLanguages();
  }

  Map<String, String> _reverseLanguages() {
    var orig = _languages();
    return orig.map((k, v) => MapEntry(v, k));
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(Size(640, 480));
    }
    languages = _languages();
    reverseLanguages = _reverseLanguages();
    languageNames.addAll(languages.values);
    languageNames.remove('Automatic');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormBuilder(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FormBuilderSearchableDropdown(
                        name: 'source_language',
                        autoFocusSearchBox: true,
                        decoration: InputDecoration(
                          labelText: 'Source Language',
                        ),
                        items: languageNames,
                        //items: languageitems,
                        initialValue: 'Telsis',
                      ),
                      FormBuilderSearchableDropdown(
                        name: 'target_language',
                        autoFocusSearchBox: true,
                        decoration: InputDecoration(
                          labelText: 'Target Language',
                        ),
                        items: languageNames,
                        //items: languageitems,
                        initialValue: 'English',
                      ),
                      FormBuilderTextField(
                        name: 'source_text',
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: new TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: _translate,
                          child: Text(
                            'Translate',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ), // This trailing comma makes auto-formatting nicer for build methods.
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _translatedText,
                          style: new TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _telsisText,
                          style: new TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'TelsisTyped',
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
