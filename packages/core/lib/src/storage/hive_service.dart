import 'package:hive_flutter/hive_flutter.dart';
import 'sync_queue_item.dart';

class HiveService {
  static const String tournamentsBoxName = 'sporto_tournaments_box';
  static const String matchesBoxName = 'sporto_matches_box';
  static const String pendingSyncBoxName = 'sporto_pending_sync_box';
  static const String authSessionBoxName = 'sporto_auth_session_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(tournamentsBoxName);
    await Hive.openBox(matchesBoxName);
    await Hive.openBox(pendingSyncBoxName);
    await Hive.openBox(authSessionBoxName);
  }

  static Box get tournamentsBox => Hive.box(tournamentsBoxName);
  static Box get matchesBox => Hive.box(matchesBoxName);
  static Box get pendingSyncBox => Hive.box(pendingSyncBoxName);
  static Box get authSessionBox => Hive.box(authSessionBoxName);

  static Future<void> addToSyncQueue(SyncQueueItem item) async {
    await pendingSyncBox.put(item.actionId, item.toJson());
  }

  static List<SyncQueueItem> getPendingSyncItems() {
    final items = <SyncQueueItem>[];
    final corruptKeys = <dynamic>[];

    for (final entry in pendingSyncBox.toMap().entries) {
      try {
        final key = entry.key.toString();
        final value = entry.value;
        if (!_isSyncQueueEntry(key, value)) {
          continue;
        }
        if (value is! Map) {
          corruptKeys.add(entry.key);
          continue;
        }
        items.add(SyncQueueItem.fromJson(Map<String, dynamic>.from(value)));
      } catch (_) {
        // Unparseable / stale entries can't ever sync — drop them so they
        // don't crash startup (ConnectivityBloc reads this queue eagerly).
        corruptKeys.add(entry.key);
      }
    }

    if (corruptKeys.isNotEmpty) {
      pendingSyncBox.deleteAll(corruptKeys);
    }

    return items;
  }

  static bool _isSyncQueueEntry(String key, Object? value) {
    if (key.startsWith('sync-')) return true;
    if (value is Map) {
      return value.containsKey('actionId') &&
          value.containsKey('endpoint') &&
          value.containsKey('httpMethod') &&
          value.containsKey('payload');
    }
    return false;
  }

  static Future<void> clearSyncItem(String actionId) async {
    await pendingSyncBox.delete(actionId);
  }

  static Future<void> clearAllSyncQueue() async {
    await pendingSyncBox.clear();
  }
}
