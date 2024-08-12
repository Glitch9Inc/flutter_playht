import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

class StreamAudioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Stream<Uint8List> audioStream;
  StreamSubscription<Uint8List>? _subscription;
  final List<int> _audioBuffer = [];

  StreamAudioPlayer({required this.audioStream});

  void _startListeningToStream() {
    _subscription = audioStream.listen((data) {
      _audioBuffer.addAll(data);
    }, onDone: () async {
      final buffer = Uint8List.fromList(_audioBuffer);
      if (buffer.isEmpty) {
        print('Empty buffer');
        return;
      }
      await _audioPlayer.setAudioSource(PlayHTStreamAudioSource(buffer));
      _audioPlayer.play();
    });
  }

  Future<void> play() async {
    _startListeningToStream();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _subscription?.cancel();
  }

  void dispose() {
    _audioPlayer.dispose();
    _subscription?.cancel();
  }
}

class PlayHTStreamAudioSource extends StreamAudioSource {
  final Uint8List audioData;

  PlayHTStreamAudioSource(this.audioData);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: audioData.length,
      contentLength: audioData.length,
      offset: start ?? 0,
      stream: Stream.fromIterable([audioData.sublist(start ?? 0, end)]),
      contentType: 'audio/mpeg',
    );
  }
}
