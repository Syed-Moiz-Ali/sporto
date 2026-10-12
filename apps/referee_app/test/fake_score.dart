import 'package:referee_data/referee_data.dart';

/// Deterministic GET /score payloads for widget tests. Mirrors the real
/// backend contract (authoritative `score.teams` + `runtime`, real
/// `user_id` player ids, validated `allowed_values`).
RefereeScoreResponse fakeLiveScoreResponse({
  int matchId = 101,
  int battingTeamId = 1,
  int bowlingTeamId = 2,
  int runs = 28,
  int wickets = 1,
  int legalBalls = 13,
  String overs = '2.1',
  int? oversPerInnings,
  String strikerName = 'Rahul',
  String bowlerName = 'Amit',
  int currentOver = 2,
  int currentBall = 1,
  bool includeSecondTeam = false,
}) {
  return RefereeScoreResponse.fromJson({
    'match': {'id': matchId, 'status': 2},
    'teams': [
      {'id': battingTeamId, 'team_name': 'Batting Side', 'players': []},
      {'id': bowlingTeamId, 'team_name': 'Bowling Side', 'players': []},
    ],
    'scoring': {
      'enabled': true,
      'method': 'BALL_BY_BALL',
      if (oversPerInnings != null) 'overs_per_innings': oversPerInnings,
      'allowed_actions': ['ADD_EVENT', 'UNDO_LAST'],
      'score': {
        'teams': {
          '$battingTeamId': {
            'score': runs,
            'wickets': wickets,
            'legal_balls': legalBalls,
            'overs': overs,
          },
          if (includeSecondTeam)
            '$bowlingTeamId': {
              'score': 0,
              'wickets': 0,
              'legal_balls': 0,
              'overs': '0.0',
            },
        },
      },
      'runtime': {
        'state': 'LIVE',
        'current_over': currentOver,
        'current_ball': currentBall,
        'current_striker': {'user_id': 11, 'name': strikerName},
        'current_bowler': {'user_id': 22, 'name': bowlerName},
      },
    },
  });
}

RefereeScoreResponse fakeCompletedScoreResponse({
  int matchId = 103,
  int teamAId = 5,
  int teamBId = 6,
  String teamAName = 'Team A',
  String teamBName = 'Team B',
  int teamAScore = 90,
  int teamAWickets = 2,
  int teamBScore = 85,
  int teamBWickets = 3,
  int? winnerTeamId,
}) {
  return RefereeScoreResponse.fromJson({
    'match': {
      'id': matchId,
      'status': 3,
      'winner_team_id': winnerTeamId ?? teamAId,
    },
    'teams': [
      {'id': teamAId, 'team_name': teamAName, 'players': []},
      {'id': teamBId, 'team_name': teamBName, 'players': []},
    ],
    'scoring': {
      'enabled': true,
      'method': 'BALL_BY_BALL',
      'allowed_actions': const [],
      'score': {
        'teams': {
          '$teamAId': {'score': teamAScore, 'wickets': teamAWickets},
          '$teamBId': {'score': teamBScore, 'wickets': teamBWickets},
        },
      },
      'runtime': const {},
    },
  });
}
