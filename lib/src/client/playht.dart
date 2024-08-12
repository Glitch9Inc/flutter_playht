import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_playht/src/client/dio_logging_intercepter.dart';
import 'package:flutter_playht/src/models/playht_text_stream.dart';
import '../models/playht_response.dart';
import '../stream_audio/stream_audio_player.dart';
import '../models/playht_request.dart';

class PlayHT {
  // needs to be singleton
  static PlayHT? _instance;
  static PlayHT get instance {
    _instance ??= PlayHT._(); // _instance가 null일 경우에만 새 인스턴스 생성
    return _instance!;
  }

  late final Map<String, String> headers = {
    'AUTHORIZATION': secret,
    'X-USER-ID': userId,
    'accept': 'text/event-stream',
    'content-type': 'application/json',
  };

  late final Map<String, String> streamHeaders = {
    'AUTHORIZATION': secret,
    'X-USER-ID': userId,
    'accept': 'undefined',
    'content-type': 'application/json',
  };

  final Dio _dio = Dio();
  final Logger _logger = Logger('PlayHT');

  late String userId;
  late String secret;
  late bool showLogs;
  static const timeoutDuration = Duration(seconds: 120);

  PlayHT._() {
    _dio.interceptors.add(DioLoggingInterceptor());
  }

  // needs to be initialized
  void init(String userId, String secret, bool showLogs) {
    this.userId = userId;
    this.secret = secret;
    this.showLogs = showLogs;
  }

  /// PlayHT의 모든 보이스모델의 리스트를 가져옵니다.
  Future<void> listVoices() async {
    String url = 'https://api.play.ht/api/v2/voices';
    var response = await _dio.get(url, options: Options(headers: headers));

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data == null) {
        _logger.severe('Response data is null');
        return;
      }

      String res = response.data.toString();
      List<String> resList = res.split('}, {');
      for (String r in resList) {
        _logger.info(r);
      }
    } else {
      throw Exception('Failed to load voices: ${response.statusCode}');
    }
  }

  Future<String?> request(PlayHTRequest req, bool playOnResponse) async {
    const url = 'https://api.play.ht/api/v2/tts';
    final map = req.toJson();
    String body = _encodeBody(map);
    final completer = Completer<String?>();

    try {
      var response = await _dio
          .post<ResponseBody>(
            url,
            data: body,
            options: Options(
              headers: headers,
              responseType: ResponseType.stream,
            ),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) throw Exception('Response data is null');
        final stream = response.data!.stream;

        stream.listen(
          (data) {
            final String event = String.fromCharCodes(data);
            handleSseEvent(event, completer);
          },
          onError: (error) {
            _logger.severe('Error in SSE stream: $error');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
          onDone: () {
            _logger.shout('SSE stream closed');
          },
          cancelOnError: true,
        );
      } else {
        completer.complete(null);
      }
    } catch (e) {
      _logger.severe('Error occurred: $e');
      completer.complete(null);
    }

    return completer.future;
  }

  String _parseSseEvent(String event) {
    final jsonStartIndex = event.indexOf('data: ');
    if (jsonStartIndex == -1) {
      return event;
    }

    event = event.substring(jsonStartIndex).replaceFirst('data: ', '');
    if (event.contains('data: ')) return _parseSseEvent(event);
    return event;
  }

  Future<void> handleSseEvent(String event, Completer<String?> completer) async {
    if (event.isEmpty) {
      _logger.warning('Received empty event');
      return;
    }

    event = _parseSseEvent(event);

    try {
      //_logger.info('SSE Event: $event');
      PlayHTTextStream stream = PlayHTTextStream.fromJson(jsonDecode(event));
      _logger.info('SSE Stage: ${stream.stage}');

      if (stream.stage == 'complete') {
        String? url = stream.url;
        if (url == null) {
          throw Exception('Failed to get TTS url');
        } else {
          _logger.info('TTS url: $url');
          String? filePath = await _downloadAndPlayAudio(url);
          completer.complete(filePath);
        }
      }
    } catch (e) {
      _logger.severe('Failed to parse SSE event: $e');
    }
  }

  Future<PlayHTResponse?> requestStream(PlayHTRequest req, bool playOnResponse) async {
    const url = 'https://api.play.ht/api/v2/tts/stream';
    final map = req.toJson();
    String body = _encodeBody(map);

    const checkInterval = Duration(seconds: 5);

    bool requestCompleted = false;

    Timer timer = Timer.periodic(checkInterval, (timer) {
      if (requestCompleted) {
        timer.cancel();
      } else {
        _logger.info("Stream request is still in progress...");
      }
    });

    try {
      var response = await _dio
          .post<ResponseBody>(
            url,
            data: body,
            options: Options(
              headers: streamHeaders,
              responseType: ResponseType.stream,
            ),
          )
          .timeout(timeoutDuration);

      requestCompleted = true;
      timer.cancel();

      if (response.statusCode == 200) {
        _logger.info('Stream: ${response.data!.stream}');
        StreamAudioPlayer player = StreamAudioPlayer(audioStream: response.data!.stream);
        await player.play();
      } else {
        _logger.severe('Failed to request TTS: ${response.statusCode}');
      }
    } catch (e) {
      requestCompleted = true;
      timer.cancel();
      _logger.severe('Error occurred: $e');
    }

    return null;
  }

  Timer startTimer() {
    // 5초마다 Get Text-To-Speech Job Data
    Timer timer = Timer.periodic(const Duration(seconds: 5), (Timer t) async {
      await _getTextToSpeechJobData();
    });
    return timer;
  }

  Future<void> _getTextToSpeechJobData() async {
    _logger.info('Getting TTS job data');
    const url = 'https://api.play.ht/api/v2/tts/id';
    try {
      var response = await _dio.get(url, options: Options(headers: headers)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        _logger.info('SpeechJobData: ${response.data}');
      } else {
        _logger.severe('Failed to get TTS job data: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error occurred: $e');
    }
  }

  String _encodeBody(Map<String, dynamic>? body) {
    String encodedBody = "";
    if (body != null) {
      encodedBody = JsonHttpConverter.encode(body);
    }
    //_logger.info(encodedBody);
    return encodedBody;
  }

  Future<String?> _downloadAndPlayAudio(String url) async {
    try {
      _logger.info('Downloading playht audio file from: $url');

      // Download the audio file
      final response = await _dio
          .get(
            url,
            options: Options(
              responseType: ResponseType.bytes,
            ),
          )
          .timeout(const Duration(seconds: 120));
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Downloaded playht audio file successfully');
        _logger.info('Response data length: ${response.data}');
        // Get the temporary directory and save the file
        io.Directory directory = await getTemporaryDirectory();
        // make sure the dir exists
        await directory.create(recursive: true);
        String filePath = '${directory.path}/temp_playht.mp3';
        io.File file = io.File(filePath);

        // Uint8List bytes = utf8.encode(response.data);
        // shit is already in byte array
        await file.writeAsBytes(response.data);
        return filePath;
      } else {
        _logger.severe('Failed to download audio file: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Failed to download and play audio: $e');
    }

    return null;
  }
}
