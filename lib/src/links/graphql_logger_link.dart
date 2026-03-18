import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';

import '../models/network_log_entry.dart';
import '../network_log_store.dart';

/// GraphQL [Link] that logs operations and responses to [NetworkLogStore].
///
/// Use with [Link.concat]:
/// ```dart
/// final link = Link.concat(
///   GraphQLLoggerLink(NetworkLogger.store, endpointUrl: 'https://api.example.com/graphql'),
///   HttpLink('https://api.example.com/graphql'),
/// );
/// ```
class GraphQLLoggerLink extends Link {
  GraphQLLoggerLink(
    this._store, {
    this.endpointUrl,
  });

  final NetworkLogStore _store;
  final String? endpointUrl;

  @override
  Stream<Response> request(
    Request request, [
    NextLink? forward,
  ]) async* {
    if (forward == null) {
      yield* Stream.error(
        StateError('GraphQLLoggerLink must be chained with a terminating link (e.g. HttpLink)'),
      );
      return;
    }

    final start = DateTime.now();
    final op = request.operation;
    final queryString = gql_lang.printNode(op.document);
    final url = endpointUrl;

    await for (final response in forward(request)) {
      if (_store.enabled) {
        final durationMs = DateTime.now().difference(start).inMilliseconds;
        final entry = NetworkLogEntry(
          id: 'gql_${DateTime.now().microsecondsSinceEpoch}',
          timestamp: DateTime.now(),
          type: NetworkLogType.graphql,
          url: url,
          method: 'POST',
          requestHeaders: null,
          requestBody: {
            'query': queryString,
            'variables': request.variables,
            'operationName': op.operationName,
          },
          responseStatusCode: _statusFromResponse(response),
          responseBody: _responseBody(response),
          durationMs: durationMs,
          query: queryString,
          variables: request.variables.isNotEmpty ? request.variables : null,
          operationName: op.operationName,
        );
        _store.add(entry);
      }
      yield response;
    }
  }

  int? _statusFromResponse(Response response) {
    try {
      final ctx = response.context.entry<HttpLinkResponseContext>();
      return ctx?.statusCode;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _responseBody(Response response) {
    final map = <String, dynamic>{};
    if (response.data != null) map['data'] = response.data;
    if (response.errors != null && response.errors!.isNotEmpty) {
      map['errors'] = response.errors!
          .map((e) => {
                'message': e.message,
                'locations': e.locations,
                'path': e.path,
              })
          .toList();
    }
    if (response.response.isNotEmpty) {
      map['raw'] = response.response;
    }
    return map;
  }
}
