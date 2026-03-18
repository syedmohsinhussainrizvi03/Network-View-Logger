import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/network_log_entry.dart';
import '../network_log_store.dart';

/// A widget that displays network log entries from [store].
///
/// Use as overlay or full-screen debug page to inspect REST, GraphQL, and SDK logs.
class NetworkLogViewer extends StatefulWidget {
  const NetworkLogViewer({
    super.key,
    required this.store,
    this.title = 'Network Logs',
  });

  final NetworkLogStore store;
  final String title;

  @override
  State<NetworkLogViewer> createState() => _NetworkLogViewerState();
}

class _NetworkLogViewerState extends State<NetworkLogViewer> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.appBarTheme.iconTheme ?? theme.iconTheme,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.store.clear();
              setState(() => _expandedId = null);
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: StreamBuilder<NetworkLogEntry>(
        stream: widget.store.stream,
        builder: (context, snapshot) {
          final entries = widget.store.entries.reversed.toList();
          if (entries.isEmpty) {
            return const Center(
              child: Text('No logs yet. Make requests or log SDK events.'),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _LogTile(
                entry: entry,
                isExpanded: _expandedId == entry.id,
                onTap: () {
                  setState(() {
                    _expandedId =
                        _expandedId == entry.id ? null : entry.id;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.entry,
    required this.isExpanded,
    required this.onTap,
  });

  final NetworkLogEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _TypeChip(type: entry.type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subtitle,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(entry.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (entry.type != NetworkLogType.sdk &&
                            entry.responseStatusCode != null)
                          Text(
                            '${entry.responseStatusCode}'
                            '${entry.durationMs != null ? " • ${entry.durationMs}ms" : ""}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _colorForStatus(entry.responseStatusCode!),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            if (isExpanded) _ExpandedContent(entry: entry),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    switch (entry.type) {
      case NetworkLogType.rest:
      case NetworkLogType.graphql:
        return entry.url ?? '';
      case NetworkLogType.sdk:
        return '${entry.source ?? ""} • ${entry.eventName ?? ""}';
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final NetworkLogType type;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case NetworkLogType.rest:
        color = Colors.blue;
        break;
      case NetworkLogType.graphql:
        color = Colors.purple;
        break;
      case NetworkLogType.sdk:
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          if (entry.type == NetworkLogType.graphql && entry.query != null) ...[
            _Section(title: 'Query', body: entry.query!),
            if (entry.variables != null && entry.variables!.isNotEmpty)
              _Section(
                title: 'Variables',
                body: _prettyJson(entry.variables!),
              ),
          ],
          if (entry.requestBody != null)
            _Section(
              title: 'Request',
              body: _bodyString(entry.requestBody),
            ),
          if (entry.requestHeaders != null &&
              entry.requestHeaders!.isNotEmpty)
            _Section(
              title: 'Request Headers',
              body: _prettyJson(Map<String, dynamic>.from(entry.requestHeaders!)),
            ),
          if (entry.responseBody != null)
            _Section(
              title: 'Response',
              body: _bodyString(entry.responseBody),
            ),
          if (entry.type == NetworkLogType.sdk &&
              entry.payload != null &&
              entry.payload!.isNotEmpty)
            _Section(
              title: 'Payload',
              body: _prettyJson(entry.payload!),
            ),
        ],
      ),
    );
  }

  static String _bodyString(dynamic body) {
    if (body is String) return body;
    if (body is Map || body is List) return _prettyJson(body as dynamic);
    return body.toString();
  }

  static String _prettyJson(dynamic map) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(map);
    } catch (_) {
      return map.toString();
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: body));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text('Copied $title')),
                    );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime t) {
  return '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.'
      '${(t.millisecond ~/ 100)}';
}

Color _colorForStatus(int status) {
  if (status >= 200 && status < 300) return Colors.green;
  if (status >= 400) return Colors.red;
  return Colors.orange;
}
