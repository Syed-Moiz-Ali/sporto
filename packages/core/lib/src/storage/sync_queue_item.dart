import 'package:equatable/equatable.dart';

class SyncQueueItem extends Equatable {
  final String actionId;
  final String endpoint;
  final String httpMethod;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final bool isSynced;

  const SyncQueueItem({
    required this.actionId,
    required this.endpoint,
    required this.httpMethod,
    required this.payload,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'actionId': actionId,
        'endpoint': endpoint,
        'httpMethod': httpMethod,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'isSynced': isSynced,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        actionId: json['actionId'] as String,
        endpoint: json['endpoint'] as String,
        httpMethod: json['httpMethod'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isSynced: json['isSynced'] as bool? ?? false,
      );

  SyncQueueItem copyWith({bool? isSynced}) => SyncQueueItem(
        actionId: actionId,
        endpoint: endpoint,
        httpMethod: httpMethod,
        payload: payload,
        timestamp: timestamp,
        isSynced: isSynced ?? this.isSynced,
      );

  @override
  List<Object?> get props => [actionId, endpoint, httpMethod, payload, timestamp, isSynced];
}
