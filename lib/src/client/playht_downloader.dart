import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_corelib/flutter_corelib.dart' hide File;

class PlayHTDownloader {
  final Dio _dio;
  final Logger _logger = Logger('PlayHTDownloader');

  PlayHTDownloader(Dio dio) : _dio = dio;

  Future<String?> download(String url) async {
    try {
      _logger.info('Downloading PlayHT audio file from: ${url.yellow}');

      // Download the audio file
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Downloaded PlayHT audio file successfully');

        Directory directory = await getTemporaryDirectory(); // Get the temporary directory and save the file

        await directory.create(recursive: true); // make sure the dir exists
        String filePath = '${directory.path}/temp_playht.mp3';
        File file = File(filePath);

        await file.writeAsBytes(response.data); // data is already in byte array
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
