import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gql_link/gql_link.dart';

import 'src/interceptors/dio_logger_interceptor.dart';
import 'src/links/graphql_logger_link.dart';
import 'src/network_log_store.dart';

export 'src/models/network_log_entry.dart';
export 'src/network_log_store.dart';
export 'src/widget/network_log_viewer.dart';
import 'src/sdk_logger.dart' as sdk_logger;
import 'src/widget/network_log_viewer.dart';

/// Network logger for REST, GraphQL, and SDK events.
///
/// Call [NetworkLogger.init] early (e.g. in main()), then add the Dio
/// interceptor and/or GraphQL link to your clients. Use [logSdkEvent] for
/// analytics (Insider, Adjust, Amplitude, etc.).
class NetworkLogger {
  NetworkLogger._();

  static NetworkLogStore? _store;
  static DioLoggerInterceptor? _dioInterceptor;

  /// Initializes the logger. Call once before using [store], [dioInterceptor], etc.
  static void init({
    bool enableConsolePrint = false,
    int maxEntries = 100,
    bool enabled = true,
  }) {
    _store = NetworkLogStore(
      maxEntries: maxEntries,
      enabled: enabled,
      enableConsolePrint: enableConsolePrint,
    );
    _dioInterceptor = null;
  }

  /// The shared log store. [init] must have been called.
  static NetworkLogStore get store {
    final s = _store;
    if (s == null) {
      throw StateError(
        'NetworkLogger.init() must be called before using NetworkLogger.store',
      );
    }
    return s;
  }

  /// Dio interceptor that logs REST requests and responses to [store].
  static Interceptor get dioInterceptor {
    _dioInterceptor ??= DioLoggerInterceptor(store);
    return _dioInterceptor!;
  }

  /// GraphQL Link that logs operations and responses to [store].
  ///
  /// Pass [endpointUrl] so logs include the GraphQL endpoint URL.
  /// Use with [Link.concat]:
  /// ```dart
  /// final link = Link.concat(
  ///   NetworkLogger.graphqlLoggerLink(endpointUrl: 'https://api.example.com/graphql'),
  ///   HttpLink('https://api.example.com/graphql'),
  /// );
  /// ```
  static Link graphqlLoggerLink({String? endpointUrl}) {
    return GraphQLLoggerLink(store, endpointUrl: endpointUrl);
  }

  /// Logs an SDK/analytics event (e.g. Insider, Adjust, Amplitude) to [store].
  static void logSdkEvent(
    String source,
    String eventName, [
    Map<String, dynamic>? payload,
  ]) {
    logSdkEventTo(store, source, eventName, payload);
  }

  /// Convenience: log an SDK event to a specific [store].
  static void logSdkEventTo(
    NetworkLogStore store,
    String source,
    String eventName, [
    Map<String, dynamic>? payload,
  ]) {
    sdk_logger.logSdkEvent(store, source, eventName, payload);
  }

  /// Builds a full-screen log viewer widget. Use in a route or overlay.
  static Widget buildLogViewer({String title = 'Network Logs'}) {
    return NetworkLogViewer(store: store, title: title);
  }
}

