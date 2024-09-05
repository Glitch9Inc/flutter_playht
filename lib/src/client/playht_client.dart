import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart' hide File;
import 'package:flutter_playht/src/client/playht_event_listener.dart';
import 'package:flutter_playht/src/stream_audio/stream_audio_player.dart';
import '../../flutter_playht.dart' hide ResponseType;

class PlayHTClient {
  final Dio _dio;
  final Logger _logger = Logger('PlayHT');

  PlayHTClient(ClientSettings settings) : _dio = createDio(settings);

  static Dio createDio(ClientSettings clientSettings) {
    var dio = Dio(BaseOptions(
      connectTimeout: clientSettings.connectTimeout,
      receiveTimeout: clientSettings.receiveTimeout,
      sendTimeout: clientSettings.sendTimeout,
      maxRedirects: clientSettings.maxRedirects,
    ));

    dio.interceptors.add(DioLoggingInterceptor());
    return dio;
  }

  late final Map<String, String> sseHeaders = {
    'AUTHORIZATION': PlayHT.secret,
    'X-USER-ID': PlayHT.userId,
    'accept': 'text/event-stream',
    'content-type': 'application/json',
  };

  late final Map<String, String> streamHeaders = {
    'AUTHORIZATION': PlayHT.secret,
    'X-USER-ID': PlayHT.userId,
    'accept': 'undefined',
    'content-type': 'application/json',
  };

  final List<CancelToken> _cancelTokens = [];
  late final PlayHTEventHandler _eventHandler = PlayHTEventHandler(_dio);

  Future<String?> request(
    PlayHTRequest req, {
    bool playOnResponse = false,
    CancelToken? cancelToken,
  }) async {
    const url = 'https://api.play.ht/api/v2/tts';
    final map = req.toJson();
    String body = JsonHttpConverter.encode(map);
    final completer = Completer<String?>();

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      var response = await _dio.post<ResponseBody>(
        url,
        data: body,
        options: Options(
          headers: sseHeaders,
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) throw Exception('Response data is null');
        final stream = response.data!.stream;

        stream.listen(
          (data) {
            final String event = String.fromCharCodes(data);
            _eventHandler.handleSseEvent(event, completer);
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
    } finally {
      _cancelTokens.remove(dioCancelToken);
    }

    return completer.future;
  }

  Future<PlayHTResponse?> requestStream(
    PlayHTRequest req, {
    bool playOnResponse = false,
    CancelToken? cancelToken,
  }) async {
    const url = 'https://api.play.ht/api/v2/tts/stream';
    final map = req.toJson();
    String body = JsonHttpConverter.encode(map);
    HttpRequestTimer timer = HttpRequestTimer(5, requestName: 'PlayHTStreamRequest', logger: _logger);
    timer.start();

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      var response = await _dio.post<ResponseBody>(
        url,
        data: body,
        options: Options(
          headers: streamHeaders,
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        _logger.info('Stream: ${response.data!.stream}');
        StreamAudioPlayer player = StreamAudioPlayer(audioStream: response.data!.stream);
        await player.play();
      } else {
        _logger.severe('Failed to request TTS: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error occurred: $e');
    } finally {
      timer.dispose();
      _cancelTokens.remove(dioCancelToken);
    }

    return null;
  }

  Future<void> listVoices({CancelToken? cancelToken}) async {
    String url = 'https://api.play.ht/api/v2/voices';

    CancelToken dioCancelToken = cancelToken ?? CancelToken();
    _cancelTokens.add(dioCancelToken);

    try {
      var response = await _dio.get(url, options: Options(headers: sseHeaders));

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
    } catch (e) {
      _logger.severe('Error occurred: $e');
    } finally {
      _cancelTokens.remove(dioCancelToken);
    }
  }

  void cancelAllRequests() {
    for (var token in _cancelTokens) {
      token.cancel();
    }
    _cancelTokens.clear();
  }
}
