import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart' hide File;
import '../models/playht_response.dart';
import '../models/playht_request.dart';
import 'playht_client.dart';

class PlayHT {
  // needs to be singleton
  static PlayHT? _instance;
  static PlayHT get instance {
    _instance ??= PlayHT._(); // _instance가 null일 경우에만 새 인스턴스 생성
    return _instance!;
  }

  // settings
  LogSettings _logSettings = LogSettings();
  ClientSettings _clientSettings = ClientSettings();

  // static getters
  static LogSettings get logSettings => instance._logSettings;
  static ClientSettings get clientSettings => instance._clientSettings;

  String _userId = '';
  String _secret = '';

  static String get userId => instance._userId;
  static String get secret => instance._secret;

  late final PlayHTClient _client; // late로 선언하여 생성자를 모두 실행한 후 초기화

  PlayHT._() {
    _client = PlayHTClient(_clientSettings); // PlayHTClient를 생성자 내부에서 초기화
  }

  // must be called before using PlayHT
  void init(
    String userId,
    String secret, {
    LogSettings? logSettings,
    ClientSettings? clientSettings,
  }) {
    _userId = userId;
    _secret = secret;
    if (logSettings != null) _logSettings = logSettings;
    if (clientSettings != null) _clientSettings = clientSettings;
  }

  /// PlayHT에 TTS 요청을 보내고, SSE이벤트를 통해 음성 파일의 URL을 받습니다.
  Future<String?> request(PlayHTRequest req,
          {bool playOnResponse = false, FilePath? downloadPath, CancelToken? cancelToken}) async =>
      await _client.request(req, playOnResponse: playOnResponse, downloadPath: downloadPath, cancelToken: cancelToken);

  /// PlayHT에 TTS 요청을 보내고, 스트림으로 음성 데이터(bytes)를 받습니다.
  Future<PlayHTResponse?> requestStream(PlayHTRequest req,
          {bool playOnResponse = false, CancelToken? cancelToken}) async =>
      await _client.requestStream(req, playOnResponse: playOnResponse, cancelToken: cancelToken);

  /// PlayHT의 모든 보이스모델의 리스트를 가져옵니다.
  Future<void> listVoices({CancelToken? cancelToken}) async => await _client.listVoices(cancelToken: cancelToken);

  /// 진행중인 모든 요청을 취소합니다.
  void cancelAllRequests() => _client.cancelAllRequests();
}
