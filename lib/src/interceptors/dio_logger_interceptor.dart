import 'package:dio/dio.dart';

import '../models/network_log_entry.dart';
import '../network_log_store.dart';

const String _keyStartTime = 'networklogger_start_time';

/// Dio interceptor that logs REST requests and responses to [NetworkLogStore].
class DioLoggerInterceptor extends Interceptor {
  DioLoggerInterceptor(this._store);

  final NetworkLogStore _store;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_keyStartTime] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      responseBody: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logResponse(
      requestOptions: err.requestOptions,
      statusCode: err.response?.statusCode,
      responseBody: err.response?.data ?? err.message,
    );
    handler.next(err);
  }

  void _logResponse({
    required RequestOptions requestOptions,
    required int? statusCode,
    required dynamic responseBody,
  }) {
    if (!_store.enabled) return;

    final start = requestOptions.extra[_keyStartTime] as DateTime?;
    final durationMs = start != null
        ? DateTime.now().difference(start).inMilliseconds
        : null;

    final entry = NetworkLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: NetworkLogType.rest,
      url: requestOptions.uri.toString(),
      method: requestOptions.method,
      requestHeaders: requestOptions.headers.isEmpty
          ? null
          : Map<String, dynamic>.from(requestOptions.headers),
      requestBody: requestOptions.data,
      responseStatusCode: statusCode,
      responseBody: responseBody,
      durationMs: durationMs,
    );

    _store.add(entry);
  }

  static String _generateId() {
    return 'rest_${DateTime.now().microsecondsSinceEpoch}';
  }
}
