import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_playht/src/client/playht_downloader.dart';

import '../models/playht_text_stream.dart';

class PlayHTEventHandler {
  final Logger _logger = Logger('PlayHTEventHandler');
  late final PlayHTDownloader _downloader;

  PlayHTEventHandler(Dio dio) {
    _downloader = PlayHTDownloader(dio);
  }

  Future<void> handleSseEvent(String event, Completer<String?> completer, {FilePath? downloadPath}) async {
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
          String? filePath = await _downloader.download(url, downloadPath: downloadPath);
          completer.complete(filePath);
        }
      }
    } catch (e) {
      _logger.severe('Failed to parse SSE event: $e');
    }
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
}
