# Telsis language translator with Flutter UI

This application is based on the [Telsis language translator](https://github.com/vivian-ng/telsis_translator) written in Python 3. It has been rewritten in Dart with a UI written in Flutter. The application translates to and from the Telsis language, the language used in the world setting of Violet Evergarden. The language is created by translating the source text into Tamil, converting the Tamil script into unaccented English alphabet characters, using a substitution cipher to swap the characters, and finally representing the results in the Telsis alphabet. The [References](#references) section contains more information about decoding the language and the original script from which the Python 3 translator was built on.

The advantage of using Flutter for the UI is that the application can easily be built to run on many platforms. For example, this is the application running on an Android emulator.
![](screenshots/onAndroidEmulator.png)


And the same application running natively in Linux.
![](screenshots/onLinux.png)
## Usage
Either the source or target language must be specified in order for the translator to work. They must also not be the same. The application will also refuse to translate from one real world language to another real world language, so it cannot be used as a free translation app.

If Telsis is specified as the source language, the translator will attempt to translate the source text into the given target language, which defaults to English if not specified. If a source language other than Telsis is specified, the translator will attempt to translate the source text into Telsis.

If Telsis is specified as the target language, the translator will attempt to translate the source text into Telsis, guessing the source language if it is not specified. If a target language other than Telsis is specified, the translator will assume the source text is in the Telsis language and attempt to translate the source text into the given target language.

![](screenshots/fromJAtoTEL.png)


![](screenshots/fromTELtoJA.png)


Names can be enclosed in backslashes so that they appear correctly in translated text. A backslash is also used as an escape character. If the use of backslash can result in such characters, leave a space after the backslash.

Note: Punctuation is sometimes not handled properly, so it is best to avoid using punctuation marks in the source text.

## Requirements
The UI was written in Flutter and uses the following packages:

[flutter_form_builder](https://pub.dev/packages/flutter_form_builder)

[diacritic](https://pub.dev/packages/diacritic)

[http](https://pub.dev/packages/http)


A modified version of [translator](https://pub.dev/packages/translator)
by [Gabriel Pacheco](https://github.com/gabrielpacheco23) is also used by the application. The package was modified to allow use of Tamil script in the conversion process.

## References
- Original [Python script](https://repl.it/@ValkrenDarklock/NunkishTrans) by Valkren, which translates Telsis into English
- [Reddit post](https://www.reddit.com/r/anime/comments/88bbob/violet_evergarden_alphabet_and_language_part_2/) on decoding the Telsis language

## License
MIT License; see [LICENSE](LICENSE) file for more information.

The [Telsis language font](fonts/TelsisTyped.otf) is for use with my programs and not for distribution.


Copyright (c) 2021 Vivian Ng
