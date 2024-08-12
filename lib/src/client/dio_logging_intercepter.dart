import 'package:dio/dio.dart' as dio;
import 'package:flutter_corelib/flutter_corelib.dart';

class DioLoggingInterceptor extends dio.Interceptor {
  final Logger _logger = Logger('Dio');

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    _logger.info('Request [${options.method}] => PATH: ${options.path}');
    _logger.info('Headers: ${options.headers}');
    _logger.info('Request Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    _logger.info('Response [${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger.info('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    _logger.severe('Error [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger.severe('Error Message: ${err.message}');
    super.onError(err, handler);
  }
}
