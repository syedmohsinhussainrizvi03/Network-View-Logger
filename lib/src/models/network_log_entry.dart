/// Type of network or SDK activity being logged.
enum NetworkLogType {
  rest,
  graphql,
  sdk,
}

/// A single log entry for REST, GraphQL, or SDK activity.
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    this.url,
    this.method,
    this.requestHeaders,
    this.requestBody,
    this.responseStatusCode,
    this.responseBody,
    this.durationMs,
    this.query,
    this.variables,
    this.operationName,
    this.source,
    this.eventName,
    this.payload,
  })  : assert(
          type != NetworkLogType.sdk ||
              (source != null && eventName != null),
          'SDK entries require source and eventName',
        ),
        assert(
          type == NetworkLogType.sdk || url != null,
          'REST and GraphQL entries require url',
        );

  final String id;
  final DateTime timestamp;
  final NetworkLogType type;

  /// For REST/GraphQL: request URL (including query string).
  final String? url;

  /// For REST/GraphQL: HTTP method.
  final String? method;

  /// For REST/GraphQL: request headers.
  final Map<String, dynamic>? requestHeaders;

  /// For REST/GraphQL: request body (e.g. JSON string or map).
  final dynamic requestBody;

  /// For REST/GraphQL: response HTTP status code.
  final int? responseStatusCode;

  /// For REST/GraphQL: full response body (e.g. JSON).
  final dynamic responseBody;

  /// For REST/GraphQL: duration in milliseconds.
  final int? durationMs;

  /// For GraphQL only: operation document (query/mutation string).
  final String? query;

  /// For GraphQL only: variables map.
  final Map<String, dynamic>? variables;

  /// For GraphQL only: operation name.
  final String? operationName;

  /// For SDK only: e.g. 'amplitude', 'adjust', 'insider'.
  final String? source;

  /// For SDK only: event name.
  final String? eventName;

  /// For SDK only: event payload.
  final Map<String, dynamic>? payload;

  NetworkLogEntry copyWith({
    String? id,
    DateTime? timestamp,
    NetworkLogType? type,
    String? url,
    String? method,
    Map<String, dynamic>? requestHeaders,
    dynamic requestBody,
    int? responseStatusCode,
    dynamic responseBody,
    int? durationMs,
    String? query,
    Map<String, dynamic>? variables,
    String? operationName,
    String? source,
    String? eventName,
    Map<String, dynamic>? payload,
  }) {
    return NetworkLogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      url: url ?? this.url,
      method: method ?? this.method,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      requestBody: requestBody ?? this.requestBody,
      responseStatusCode: responseStatusCode ?? this.responseStatusCode,
      responseBody: responseBody ?? this.responseBody,
      durationMs: durationMs ?? this.durationMs,
      query: query ?? this.query,
      variables: variables ?? this.variables,
      operationName: operationName ?? this.operationName,
      source: source ?? this.source,
      eventName: eventName ?? this.eventName,
      payload: payload ?? this.payload,
    );
  }
}
