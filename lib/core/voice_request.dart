import 'package:flutter_playht/core/flutter_playht_internal.dart';

class VoiceRequest {
  final String input;
  final String? companionId;
  final String? downloadPath;
  final ResponseType? outputType;
  final OutputEmotion? emotion;
  final OutputQuality? quality;
  final Function(String)? onResult;

  VoiceRequest._({
    required this.input,
    this.companionId,
    this.downloadPath,
    this.outputType,
    this.emotion,
    this.quality = OutputQuality.premium,
    this.onResult,
  });
}
