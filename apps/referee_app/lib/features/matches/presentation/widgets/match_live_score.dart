import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';

import '../../../../core/di/dependency_injector.dart';

/// Fetches the authoritative `GET /score` for a LIVE match and exposes it to
/// [builder]. No static fallback scores — while loading or on error the
/// builder receives `null` and the call site renders a loading shimmer or
/// hides the score row.
///
/// Only use for live matches; pending matches have no score yet and completed
/// matches should use the read-only result view.
class MatchLiveScore extends StatefulWidget {
  /// Test-only override for the score fetch (avoids network in widget tests).
  /// Production code must leave this null.
  static Future<RefereeScoreResponse?> Function(int matchId)?
      debugFetchOverride;

  final int matchId;
  final Widget Function(
    BuildContext context,
    RefereeScoreResponse? score,
    bool isLoading,
  ) builder;

  const MatchLiveScore({
    super.key,
    required this.matchId,
    required this.builder,
  });

  @override
  State<MatchLiveScore> createState() => _MatchLiveScoreState();
}

class _MatchLiveScoreState extends State<MatchLiveScore> {
  late Future<RefereeScoreResponse?> _future;

  @override
  void initState() {
    super.initState();
    final override = MatchLiveScore.debugFetchOverride;
    _future = override != null ? override(widget.matchId) : _load();
  }

  Future<RefereeScoreResponse?> _load() async {
    try {
      return await DependencyInjector.instance.refereeRemoteDataSource
          .getMatchScoreData(widget.matchId);
    } catch (_) {
      return null;
    }
  }

  @override
  void didUpdateWidget(MatchLiveScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) {
      _future = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RefereeScoreResponse?>(
      future: _future,
      builder: (context, snapshot) {
        final loading =
            snapshot.connectionState == ConnectionState.waiting;
        return widget.builder(context, snapshot.data, loading);
      },
    );
  }
}

/// Real `runs/wickets` for [teamId] from an authoritative score payload.
/// Returns null when the team has not batted yet (score map empty).
String? liveTeamScore(RefereeScoreResponse? score, Object teamId) {
  if (score == null) return null;
  final teams = score.scoring.score['teams'];
  if (teams is! Map || !teams.keys.map((k) => '$k').contains('$teamId')) {
    return null;
  }
  return score.scoring.teamTotals(teamId).scoreText;
}

/// Real "Over - X.Y" text from runtime. Returns null before the first ball.
String? liveOversText(RefereeScoreResponse? score) {
  final runtime = score?.scoring.runtime;
  if (runtime == null) return null;
  final over = runtime.currentOver;
  final ball = runtime.currentBall;
  if (over == null || ball == null) return null;
  if (over == 0 && ball == 0) return null;
  final oversPerInnings = score?.scoring.oversPerInnings;
  final total = oversPerInnings != null && oversPerInnings > 0
      ? '/$oversPerInnings'
      : '';
  return 'Over - $over.$ball$total';
}
