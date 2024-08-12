import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_playht/flutter_playht.dart';
 

class PlayHTRequest {
  final String text;
  final String voice;
  final OutputQuality? quality; // Default: medium
  final OutputFormat? outputFormat; // Default: mp3
  final int? speed; // Default: 1
  final SampleRate? sampleRate;
  final OutputEmotion? emotion;
  final VoiceEngine? voiceEngine;
  final Function(String)? onResult;

  PlayHTRequest({
    required this.text,
    required this.voice,
    this.quality,
    this.outputFormat,
    this.speed,
    this.sampleRate,
    this.emotion,
    this.voiceEngine,
    this.onResult,
  });

  factory PlayHTRequest.fromJson(Map<String, dynamic> json) {
    return PlayHTRequest(
      text: json.getString('text'),
      voice: json.getString('voice'),
      quality: json.getEnum<OutputQuality>('quality', OutputQuality.values),
      outputFormat: json.getEnum<OutputFormat>('output_format', OutputFormat.values),
      speed: json.getInt('speed'),
      sampleRate: json.getEnum<SampleRate>('sample_rate', SampleRate.values),
      emotion: json.getEnum<OutputEmotion>('emotion', OutputEmotion.values),
      voiceEngine: json.getEnum<VoiceEngine>('voice_engine', VoiceEngine.values),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['voice'] = voice;
    if (quality != null) data['quality'] = quality!.name;
    if (outputFormat != null) data['output_format'] = outputFormat!.name;
    if (speed != null) data['speed'] = speed;
    if (sampleRate != null) data['sample_rate'] = sampleRate!.rate; // this gotta be number not string
    if (emotion != null) data['emotion'] = emotion!.name;
    if (voiceEngine != null) data['voice_engine'] = voiceEngine!.networkString;
    return data;
  }
}
