import 'models/network_log_entry.dart';
import 'network_log_store.dart';

/// Logs an SDK/analytics event (e.g. Insider, Adjust, Amplitude) to [store].
///
/// Call this from your analytics facade whenever you forward an event to a
/// third-party SDK so that network logger can display it.
void logSdkEvent(
  NetworkLogStore store,
  String source,
  String eventName, [
  Map<String, dynamic>? payload,
]) {
  if (!store.enabled) return;

  final entry = NetworkLogEntry(
    id: 'sdk_${DateTime.now().microsecondsSinceEpoch}',
    timestamp: DateTime.now(),
    type: NetworkLogType.sdk,
    source: source,
    eventName: eventName,
    payload: payload,
  );

  store.add(entry);
}
