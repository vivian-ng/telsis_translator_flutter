part of google_transl;

/// Translation returned from GoogleTranslator.translate method, containing the translated text, the source text, the translated language and the source language
abstract class Translation {
  final String text;
  final String source;
  final Language targetLanguage;
  final Language sourceLanguage;
  final String sound;

  Translation._(this.text, this.sound, this.source, this.sourceLanguage,
      this.targetLanguage);

  String operator +(other);

  @override
  String toString() => text;
}

class _Translation extends Translation {
  final String text;
  final String source;
  final Language sourceLanguage;
  final Language targetLanguage;
  final String sound;

  _Translation(
    this.text,
    this.sound, {
    this.sourceLanguage,
    this.targetLanguage,
    this.source,
  }) : super._(text, sound, source, sourceLanguage, targetLanguage);

  String operator +(other) => this.toString() + other.toString();
}
