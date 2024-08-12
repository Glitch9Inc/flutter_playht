enum VoiceEngine {
  PlayHT1_0,
  PlayHT2_0,
  PlayHT2_0_turbo,
}

extension VoiceEngineExt on VoiceEngine {
  String get networkString {
    switch (this) {
      case VoiceEngine.PlayHT1_0:
        return 'PlayHT1.0';
      case VoiceEngine.PlayHT2_0:
        return 'PlayHT2.0';
      case VoiceEngine.PlayHT2_0_turbo:
        return 'PlayHT2.0-turbo';
    }
  }
}
