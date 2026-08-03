import 'package:hive_flutter/hive_flutter.dart';
import 'sync_queue_item.dart';

class HiveService {
  static const String tournamentsBoxName = 'sporto_tournaments_box';
  static const String matchesBoxName = 'sporto_matches_box';
  static const String pendingSyncBoxName = 'sporto_pending_sync_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(tournamentsBoxName);
    await Hive.openBox(matchesBoxName);
    await Hive.openBox(pendingSyncBoxName);
  }

  static Box get tournamentsBox => Hive.box(tournamentsBoxName);
  static Box get matchesBox => Hive.box(matchesBoxName);
  static Box get pendingSyncBox => Hive.box(pendingSyncBoxName);

  static Future<void> addToSyncQueue(SyncQueueItem item) async {
    await pendingSyncBox.put(item.actionId, item.toJson());
  }

  static List<SyncQueueItem> getPendingSyncItems() {
    return pendingSyncBox.values.map((v) {
      final jsonMap = Map<String, dynamic>.from(v as Map);
      return SyncQueueItem.fromJson(jsonMap);
    }).toList();
  }

  static Future<void> clearSyncItem(String actionId) async {
    await pendingSyncBox.delete(actionId);
  }

  static Future<void> clearAllSyncQueue() async {
    await pendingSyncBox.clear();
  }
}
