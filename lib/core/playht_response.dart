// sample json response :   {"id":"ULAdvpSm1P29240xD2","progress":1,"stage":"complete","Url":"https://peregrine-results.s3.amazonaws.com/pigeon/ULAdvpSm1P29240xD2_0.mp3","duration":4.5973,"size":93645}

class PlayHTResponse {
  final String id;
  final double progress;
  final String stage;
  final String url;
  final double duration;
  final int size;

  PlayHTResponse({
    required this.id,
    required this.progress,
    required this.stage,
    required this.url,
    required this.duration,
    required this.size,
  });

  factory PlayHTResponse.fromJson(Map<String, dynamic> json) {
    return PlayHTResponse(
      id: json['id'],
      progress: json['progress'],
      stage: json['stage'],
      url: json['Url'],
      duration: json['duration'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'stage': stage,
      'Url': url,
      'duration': duration,
      'size': size,
    };
  }
}
