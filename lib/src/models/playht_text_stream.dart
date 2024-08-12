//data: {"id":"9FiMEGdXcfH1Z5RsfL","progress":0,"stage":"queued"}
//event: completed
//data: {"id":"9FiMEGdXcfH1Z5RsfL","progress":1,"stage":"complete","url":"https://peregrine-results.s3.amazonaws.com/pigeon/9FiMEGdXcfH1Z5RsfL_0.mp3","duration":1.8987,"size":39885}

import 'package:flutter_corelib/flutter_corelib.dart';

class PlayHTTextStream {
  final String id;
  final double progress;
  final String stage;
  final String? url;
  final double? duration;
  final double? stageProgress;
  final int? size;

  PlayHTTextStream(
      {required this.id,
      required this.progress,
      required this.stage,
      this.stageProgress,
      this.url,
      this.duration,
      this.size});

  factory PlayHTTextStream.fromJson(Map<String, dynamic> json) {
    return PlayHTTextStream(
      id: json.getString('id'),
      progress: json.getDouble('progress'),
      //stageProgress: json.getDouble('stageProgress'),
      stage: json.getString('stage'),
      url: json.getString('url'),
      //duration: json.getDouble('duration'),
      //size: json.getInt('size'),
    );
  }
}
