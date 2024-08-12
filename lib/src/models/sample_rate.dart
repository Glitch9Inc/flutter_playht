// ignore_for_file: constant_identifier_names

enum SampleRate {
  Hz_8000,
  Hz_16000,
  Hz_32000,
  Hz_44100,
  Hz_48000,
}

extension SampleRateExtension on SampleRate {
  int get rate {
    switch (this) {
      case SampleRate.Hz_8000:
        return 8000;
      case SampleRate.Hz_16000:
        return 16000;
      case SampleRate.Hz_32000:
        return 32000;
      case SampleRate.Hz_44100:
        return 44100;
      case SampleRate.Hz_48000:
        return 48000;
    }
  }

  String get networkString {
    switch (this) {
      case SampleRate.Hz_8000:
        return '8000';
      case SampleRate.Hz_16000:
        return '16000';
      case SampleRate.Hz_32000:
        return '32000';
      case SampleRate.Hz_44100:
        return '44100';
      case SampleRate.Hz_48000:
        return '48000';
    }
  }
}
