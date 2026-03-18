import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models/network_log_entry.dart';

/// In-memory store for network log entries with optional console printing.
class NetworkLogStore {
  NetworkLogStore({
    this.maxEntries = 100,
    this.enabled = true,
    this.enableConsolePrint = false,
  });

  static const int _consoleBodyTruncate = 200;

  final int maxEntries;
  bool enabled;
  bool enableConsolePrint;

  final List<NetworkLogEntry> _entries = [];
  final StreamController<NetworkLogEntry> _streamController =
      StreamController<NetworkLogEntry>.broadcast();

  /// Unmodifiable list of current log entries (newest last).
  List<NetworkLogEntry> get entries =>
      List.unmodifiable(_entries);

  /// Stream of new log entries as they are added.
  Stream<NetworkLogEntry> get stream => _streamController.stream;

  /// Adds a log entry and optionally prints a summary to the console.
  void add(NetworkLogEntry entry) {
    if (!enabled) return;

    while (_entries.length >= maxEntries) {
      _entries.removeAt(0);
    }
    _entries.add(entry);
    _streamController.add(entry);

    if (enableConsolePrint && kDebugMode) {
      _printEntry(entry);
    }
  }

  void _printEntry(NetworkLogEntry entry) {
    final buffer = StringBuffer();
    buffer.writeln('━━━ NetworkLogger [${entry.type.name.toUpperCase()}] ━━━');
    buffer.writeln('  id: ${entry.id}');
    buffer.writeln('  time: ${entry.timestamp.toIso8601String()}');

    switch (entry.type) {
      case NetworkLogType.rest:
      case NetworkLogType.graphql:
        buffer.writeln('  url: ${entry.url}');
        buffer.writeln('  method: ${entry.method}');
        if (entry.responseStatusCode != null) {
          buffer.writeln('  status: ${entry.responseStatusCode}');
        }
        if (entry.durationMs != null) {
          buffer.writeln('  duration: ${entry.durationMs}ms');
        }
        if (entry.type == NetworkLogType.graphql) {
          buffer.writeln('  operation: ${entry.operationName ?? "(unnamed)"}');
          if (entry.query != null) {
            final q = entry.query!.length > _consoleBodyTruncate
                ? '${entry.query!.substring(0, _consoleBodyTruncate)}...'
                : entry.query;
            buffer.writeln('  query: $q');
          }
        }
        if (entry.requestBody != null) {
          final bodyStr = _bodyToString(entry.requestBody);
          final truncated = bodyStr.length > _consoleBodyTruncate
              ? '${bodyStr.substring(0, _consoleBodyTruncate)}...'
              : bodyStr;
          buffer.writeln('  request: $truncated');
        }
        if (entry.responseBody != null) {
          final bodyStr = _bodyToString(entry.responseBody);
          final truncated = bodyStr.length > _consoleBodyTruncate
              ? '${bodyStr.substring(0, _consoleBodyTruncate)}...'
              : bodyStr;
          buffer.writeln('  response: $truncated');
        }
        break;
      case NetworkLogType.sdk:
        buffer.writeln('  source: ${entry.source}');
        buffer.writeln('  event: ${entry.eventName}');
        if (entry.payload != null && entry.payload!.isNotEmpty) {
          buffer.writeln('  payload: ${entry.payload}');
        }
        break;
    }

    debugPrint(buffer.toString());
  }

  static String _bodyToString(dynamic body) {
    if (body == null) return '';
    if (body is String) return body;
    return body.toString();
  }

  /// Clears all stored entries.
  void clear() {
    _entries.clear();
  }

  /// Closes the stream controller. Call when disposing the store.
  void dispose() {
    _streamController.close();
  }
}
