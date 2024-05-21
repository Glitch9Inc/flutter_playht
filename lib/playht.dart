import 'dart:convert';

import 'core/playht_response.dart';
import 'core/voice_request.dart';

const String ENDPOINT_V2 = "https://api.play.ht/api/v2/tts";
const String ENDPOINT_STREAM = "https://api.play.ht/api/v2/tts/stream";

class PlayHT {
  // needs user Id and Secret
  late String userId;
  late String secret;
  late bool showLogs;

  // needs to be singleton
  static PlayHT? _instance;
  static PlayHT get instance {
    _instance ??= PlayHT._(); // _instance가 null일 경우에만 새 인스턴스 생성
    return _instance!;
  }

  PlayHT._();

  get http => null;

  // needs to be initialized
  void init(String userId, String secret, bool showLogs) {
    this.userId = userId;
    this.secret = secret;
    this.showLogs = showLogs;
  }

  /// PlayHT의 모든 보이스모델의 리스트를 가져옵니다.
  Future<void> listVoices() async {
    var url = Uri.parse('https://api.play.ht/api/v2/voices');
    var response =
        await http.get(url, headers: {'Authorization': 'Bearer $secret', 'X-USER-ID': userId});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
    } else {
      throw Exception('Failed to load voices');
    }
  }

  Future<PlayHTResponse> request(VoiceRequest req) async {
    var url = Uri.parse(ENDPOINT_V2);
    var response =
        await http.post(url, headers: {'Authorization': 'Bearer $secret', 'X-USER-ID': userId});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return PlayHTResponse.fromJson(data);
    } else {
      throw Exception('Failed to load voices');
    }
  }
}
