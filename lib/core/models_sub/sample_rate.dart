// ignore_for_file: constant_identifier_names

class SampleRate {
  final int rate;
  final String description;

  const SampleRate._(this.rate, this.description);

  static const SampleRate _8000 = SampleRate._(8000, "8000 Hz");
  static const SampleRate _16000 = SampleRate._(16000, "16000 Hz");
  static const SampleRate _32000 = SampleRate._(32000, "32000 Hz");
  static const SampleRate _44100 = SampleRate._(44100, "44100 Hz");
  static const SampleRate _48000 = SampleRate._(48000, "48000 Hz");

  static List<SampleRate> get values => [_8000, _16000, _32000, _44100, _48000];

  @override
  String toString() => '$rate Hz';
}
