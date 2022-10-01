import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
//import 'package:desktop_window/desktop_window.dart';
import 'package:window_size/window_size.dart';
import 'package:telsis_translator_flutter/telsis_translator.dart';
import 'package:telsis_translator_flutter/src/langs/language.dart';
import 'dart:async';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Telsis Language Translator");
    //setWindowMinSize(Size(480, 320));
    //setWindowMaxSize(Size(1024, 800));
    getWindowInfo().then((windowInfo) {
      setWindowFrame(Rect.fromCenter(
        center: windowInfo.frame.center,
        width: 640,
        height: 640,
      ));
    });
  }
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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String _translatedText = '';
  String _telsisText = '';
  String _srclang = 'Telsis';
  String _tgtlang = 'English';
  String _srctext = '';
  String srctext = '';
  String srclang = 'telsis';
  String tgtlang = 'en';
  late Map<String, String> languages;
  late Map<String, String> reverseLanguages;
  List<String> languageNames = [];
  final errorMessages = {
    1: 'Language not supported',
    2: 'Either source or output language must be defined',
    3: 'Source and output language cannot be the same',
    4: 'This is a Telsis language translator',
    5: 'Source text must not be empty',
  };
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  void _onChanged(dynamic val) {
    // Uncomment below to print debug console output
    //debugPrint(val.toString());
  }

  Future _translate() async {
    int returncode = 0;
    FocusScope.of(context).unfocus();
    srclang = reverseLanguages[_srclang]!;
    tgtlang = reverseLanguages[_tgtlang]!;
    srctext = _srctext;
    if (srctext == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text(errorMessages[5]!), // empty source text
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
      return;
    }
    TelsisTranslator translator = TelsisTranslator(srctext, srclang, tgtlang);
    returncode =
        await translator.translate(srctext, src: srclang, tgt: tgtlang);
    setState(() {
      if (returncode == 0) {
        _translatedText = translator.results['tgt_text']!;
        if (tgtlang == 'telsis') {
          _telsisText = translator.results['tgt_text']!.replaceAll('\\', '');
        } else {
          _telsisText = translator.results['src_text']!.replaceAll('\\', '');
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Error"),
                  content: Text(errorMessages[returncode]!),
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
    languages = _languages();
    languages.remove('Automatic');
    reverseLanguages = _reverseLanguages();
    languageNames.addAll(languages.values);
    languageNames.remove('Automatic');
//    var languageDropdownItems = languages.values
//        .map((language) => DropdownMenuItem(
//              value: language,
//              child: Text(language),
//            ))
//        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              autofocus: true,
                              focusNode: myFocusNode,
                            )),
                        items: languageNames,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Source language",
                          ),
                        ),
                        onChanged: (data) {
                          _srclang = data.toString();
                          _onChanged(_srclang);
                        },
                        selectedItem: "Telsis",
                      ),
                      DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              autofocus: true,
                              focusNode: myFocusNode,
                            )),
                        items: languageNames,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Target language",
                          ),
                        ),
                        onChanged: (data) {
                          _tgtlang = data.toString();
                          _onChanged(_tgtlang);
                        },
                        selectedItem: "English",
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Text to translate',
                          labelText: 'Source text',
                        ),
                        onChanged: (String? data) {
                          _srctext = data.toString();
                          _onChanged(_srctext);
                        },
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        initialValue: '',
                        //onChanged: _onChanged,
                        maxLines: null,
                        style: new TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: _translate,
                          icon: Icon(
                            Icons.translate,
                            color: Colors.indigo[50],
                            size: 24.0,
                          ),
                          label: Text(
                            'Translate',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ), // This trailing comma makes auto-formatting nicer for build methods.
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: SelectableText(
                          _translatedText,
                          style: new TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: SelectableText(
                          _telsisText,
                          style: new TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'TelsisTyped',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationIcon: Image.asset(
                                  "assets/icon/TelsisTranslatorIcon.png",
                                  scale: 4),
                              applicationName: 'Telsis Translator',
                              applicationVersion: '0.2.1',
                              applicationLegalese: '©2022 Vivian Ng',
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: SelectableText(
                                        'Translates to and from the Telsis language used in the Violet Evergarden anime series\n\nSource code:\nhttps://github.com/vivian-ng/telsis_translator_flutter'))
                              ],
                            );
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.indigo[50],
                            size: 24.0,
                          ),
                          label: Text(
                            'About',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ), // This trailing comma makes auto-formatting nicer for build methods.
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
