import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:network_log_viewer/network_log_viewer.dart';

const String _graphqlEndpoint = 'https://countries.trevorblades.com/graphql';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkLogger.init(
    enableConsolePrint: true,
    maxEntries: 100,
  );
  runApp(const NetworkLoggerExampleApp());
}

class NetworkLoggerExampleApp extends StatelessWidget {
  const NetworkLoggerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetworkLogger Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String _status = 'Tap the buttons below to generate logs.';

  late final GraphQLClient _graphqlClient = GraphQLClient(
    link: Link.concat(
      NetworkLogger.graphqlLoggerLink(endpointUrl: _graphqlEndpoint),
      HttpLink(_graphqlEndpoint),
    ),
    cache: GraphQLCache(),
  );

  Future<void> _makeRestRequest() async {
    setState(() => _status = 'Sending REST request...');
    final dio = Dio(BaseOptions(baseUrl: 'https://httpbin.org'));
    dio.interceptors.add(NetworkLogger.dioInterceptor);
    try {
      await dio.get('/get');
      if (mounted) {
        setState(() => _status = 'REST request completed. Open logs to see it.');
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'Request failed: $e');
    }
  }

  Future<void> _runGraphQLQuery() async {
    setState(() => _status = 'Sending GraphQL query...');
    try {
      await _graphqlClient.query(
        QueryOptions(
          document: gql(r'''
            query GetCountries {
              countries {
                code
                name
              }
            }
          '''),
          operationName: 'GetCountries',
        ),
      );
      if (mounted) {
        setState(() => _status = 'GraphQL query completed. Open logs to see the dynamic query and response.');
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'GraphQL failed: $e');
    }
  }

  void _logSdkEvent() {
    NetworkLogger.logSdkEvent(
      'amplitude',
      'button_click',
      {'screen': 'example', 'button': 'log_sdk'},
    );
    setState(() => _status = 'SDK event logged. Open logs to see it.');
  }

  void _openLogViewer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NetworkLogger.buildLogViewer(title: 'Network Logs'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NetworkLogger Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _makeRestRequest,
                icon: const Icon(Icons.http),
                label: const Text('Send REST request'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _runGraphQLQuery,
                icon: const Icon(Icons.account_tree),
                label: const Text('Run GraphQL query'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _logSdkEvent,
                icon: const Icon(Icons.analytics),
                label: const Text('Log SDK event'),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _openLogViewer,
                icon: const Icon(Icons.list_alt),
                label: const Text('Open network logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
