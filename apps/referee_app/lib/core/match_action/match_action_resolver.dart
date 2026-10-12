import 'package:referee_data/referee_data.dart';

/// Single decision point for what a referee can do with a match.
/// Replaces the raw-key heuristics (`raw['toss_done']`, `raw['verified']`
/// ...) previously scattered across cards — the backend never sends those
/// keys, so buttons fell back to "Verify Teams" even when the toss was done.
enum MatchAction {
  blocked,
  verify,
  toss,
  startScoring,
  continueScoring,
  viewReport,
}

class MatchActionResult {
  const MatchActionResult._(this.action, {this.blockedReason});

  const MatchActionResult.blocked(String reason)
      : this._(MatchAction.blocked, blockedReason: reason);
  static const verify = MatchActionResult._(MatchAction.verify);
  static const toss = MatchActionResult._(MatchAction.toss);
  static const startScoring = MatchActionResult._(MatchAction.startScoring);
  static const continueScoring =
      MatchActionResult._(MatchAction.continueScoring);
  static const viewReport = MatchActionResult._(MatchAction.viewReport);

  final MatchAction action;
  final String? blockedReason;
}

/// Resolve the primary action for [match] from authoritative list-API fields.
///
/// Order matters: terminal states first, then officiating gate, then the
/// normal verify → toss → score progression.
MatchActionResult resolveMatchAction(RefereeMatchResponse match) {
  if (match.isCompleted) return MatchActionResult.viewReport;
  if (match.isLive) {
    if (!_canOfficiate(match)) {
      return MatchActionResult.blocked(_blockedText(match.blockingCode));
    }
    return MatchActionResult.continueScoring;
  }
  if (!_canOfficiate(match)) {
    return MatchActionResult.blocked(_blockedText(match.blockingCode));
  }
  if (match.isTossCompleted) return MatchActionResult.startScoring;
  // The list API does not expose a "teams verified" flag, so every upcoming
  // match enters through verification, which then leads into the toss.
  return MatchActionResult.verify;
}

bool _canOfficiate(RefereeMatchResponse match) {
  if (match.blockingCode != null && match.blockingCode!.isNotEmpty) {
    return false;
  }
  return match.canOfficiate;
}

/// Human-readable text for backend `blocking_code` values. Falls back to the
/// raw code so unknown future codes are still visible instead of silent.
String _blockedText(String? code) {
  return switch (code) {
    'ASSIGNMENT_NOT_ACCEPTED' => 'Accept this match in Requests first',
    'PARTICIPANTS_NOT_RESOLVED' => 'Teams not decided yet',
    'TOSS_BLOCKED' => 'Toss is blocked for this match',
    null || '' => 'Action unavailable right now',
    _ => code,
  };
}

// ============================================================
// Schedule helpers — countdown + labels from real API fields.
// ============================================================

/// Best-effort scheduled start from list-API fields. Returns null when the
/// backend sent no schedule (referee match detail currently returns
/// `schedule: null` even when the partner side has dates).
DateTime? parseMatchStart(RefereeMatchResponse match) {
  final iso = match.scheduledAt;
  if (iso != null && iso.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(iso.trim());
    if (parsed != null) return parsed;
  }
  final date = match.matchDate;
  if (date == null || date.trim().isEmpty) return null;
  final day = DateTime.tryParse(date.trim().split('T').first);
  if (day == null) return null;
  final time = _parseTimeOfDay(match.startTime);
  if (time == null) return DateTime(day.year, day.month, day.day);
  return DateTime(day.year, day.month, day.day, time.$1, time.$2);
}

(int, int)? _parseTimeOfDay(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final text = value.trim();
  // 24h "14:30" or "14:30:00".
  final h24 = RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$').firstMatch(text);
  if (h24 != null) {
    final h = int.tryParse(h24.group(1)!);
    final m = int.tryParse(h24.group(2)!);
    if (h != null && m != null && h < 24 && m < 60) return (h, m);
  }
  // 12h "02:30 PM".
  final h12 =
      RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*([AaPp])[Mm]?').firstMatch(text);
  if (h12 != null) {
    var h = int.tryParse(h12.group(1)!) ?? 0;
    final m = int.tryParse(h12.group(2)!) ?? 0;
    final pm = h12.group(3)!.toUpperCase() == 'P';
    if (pm && h < 12) h += 12;
    if (!pm && h == 12) h = 0;
    if (h < 24 && m < 60) return (h, m);
  }
  return null;
}

/// "Starts in 2h 15m" / "Starts in 20m" / "Starting now" for future matches.
/// Returns null when [start] is null or already past.
String? countdownText(DateTime? start, {DateTime? now}) {
  if (start == null) return null;
  final diff = start.difference(now ?? DateTime.now());
  if (diff.isNegative) return null;
  if (diff.inMinutes < 1) return 'Starting now';
  if (diff.inHours < 1) return 'Starts in ${diff.inMinutes}m';
  if (diff.inHours < 48) {
    final mins = diff.inMinutes % 60;
    return mins == 0
        ? 'Starts in ${diff.inHours}h'
        : 'Starts in ${diff.inHours}h ${mins}m';
  }
  return 'Starts in ${diff.inDays}d';
}
