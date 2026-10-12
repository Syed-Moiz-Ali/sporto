import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/application/live_scoring/live_scoring_bloc.dart';
import 'package:referee_data/referee_data.dart';

Map<String, dynamic> _scoreResponse({
  required int matchStatus,
  required Map<String, dynamic> runtime,
  Map<String, dynamic>? score,
  List<String> allowedActions = const [],
}) {
  return {
    'match': {'id': 4003, 'status': matchStatus, 'match_number': 1},
    'teams': [
      {
        'id': 2101,
        'team_name': 'Team 1',
        'players': [
          {'user_id': 1, 'name': 'A1'},
          {'user_id': 2, 'name': 'A2'},
        ],
      },
      {
        'id': 2104,
        'team_name': 'Team 4',
        'players': [
          {'user_id': 11, 'name': 'B1'},
          {'user_id': 12, 'name': 'B2'},
          {'user_id': 13, 'name': 'B3'},
        ],
      },
    ],
    'scoring': {
      'enabled': true,
      'allowed_actions': allowedActions,
      'runtime': runtime,
      'score': score ??
          {
            'teams': {
              '2101': {'score': 100, 'wickets': 0, 'legal_balls': 120, 'overs': '20.0'},
              '2104': {'score': 40, 'wickets': 2, 'legal_balls': 30, 'overs': '5.0'},
            },
          },
    },
    'result': {'status': 'UNRESOLVED', 'winner_team_id': null},
  };
}

LiveScoringBloc _bloc() {
  const teamA = ScoringTeam(id: '2101', name: 'Team 1', bowlers: []);
  const teamB = ScoringTeam(id: '2104', name: 'Team 4', bowlers: []);
  return LiveScoringBloc(
    teamA: teamA,
    teamB: teamB,
    firstBattingTeamId: '2104',
  );
}

Future<LiveScoringState> _apply(
  LiveScoringBloc bloc,
  Map<String, dynamic> json,
) async {
  final response = RefereeScoreResponse.fromJson(json);
  bloc.add(ApplyServerScoreEvent(response));
  await Future<void>.delayed(Duration.zero);
  return bloc.state;
}

void main() {
  test('mid-innings wicket -> scoring step with replacement picker', () async {
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      _scoreResponse(
        matchStatus: 2,
        allowedActions: ['SET_BATTERS', 'UNDO_LAST'],
        runtime: {
          'state': 'LIVE',
          'current_over': 3,
          'current_ball': 2,
          'current_inning': 2,
          'current_batting_team_id': 2104,
          'current_bowling_team_id': 2101,
          'awaiting_batter': true,
          'awaiting_bowler': false,
          'innings_complete': false,
          'current_striker': {'user_id': null},
          'current_non_striker': {'user_id': 12, 'name': 'B2'},
          'current_bowler': {'user_id': 1, 'name': 'A1'},
          'dismissed_batters': [11],
          'last_event': {
            'type': 'WICKET_RECORDED',
            'data': {'dismissed_user_id': 11},
          },
        },
      ),
    );

    expect(state.step, LiveScoringStep.scoring);
    expect(state.awaitingReplacement, isTrue);
    expect(state.strikerId, isNull);
    expect(state.nonStrikerId, '12');
    expect(state.firstInnings, isNotNull);
  });

  test('innings 1 all out -> innings break with first innings filled', () async {
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      _scoreResponse(
        matchStatus: 2,
        allowedActions: ['END_PERIOD', 'UNDO_LAST'],
        runtime: {
          'state': 'LIVE',
          'current_over': 9,
          'current_ball': 3,
          'current_inning': 1,
          'current_batting_team_id': 2104,
          'current_bowling_team_id': 2101,
          'awaiting_batter': true,
          'awaiting_bowler': false,
          'innings_complete': true,
          'current_striker': {'user_id': null},
          'current_non_striker': {'user_id': 12},
          'current_bowler': {'user_id': 1},
          'last_event': {
            'type': 'INNINGS_COMPLETE',
            'data': {'reason': 'ALL_OUT'},
          },
        },
        score: {
          'teams': {
            '2101': {'score': 0, 'wickets': 0},
            '2104': {'score': 40, 'wickets': 10},
          },
        },
      ),
    );

    expect(state.step, LiveScoringStep.inningsBreak);
    expect(state.firstInnings, isNotNull);
    expect(state.firstInnings!.runs, 40);
  });

  test('innings 2 finished -> final result with both innings filled', () async {
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      _scoreResponse(
        matchStatus: 2,
        allowedActions: ['COMPLETE', 'UNDO_LAST'],
        runtime: {
          'state': 'LIVE',
          'current_over': 19,
          'current_ball': 6,
          'current_inning': 2,
          'current_batting_team_id': 2104,
          'current_bowling_team_id': 2101,
          'awaiting_batter': true,
          'innings_complete': true,
          'current_striker': {'user_id': null},
          'current_non_striker': {'user_id': 12},
          'current_bowler': {'user_id': 1},
          'last_event': {
            'type': 'INNINGS_COMPLETE',
            'data': {'reason': 'TARGET_REACHED'},
          },
        },
        score: {
          'teams': {
            '2101': {'score': 100, 'wickets': 5},
            '2104': {'score': 101, 'wickets': 3},
          },
        },
      ),
    );

    expect(state.step, LiveScoringStep.finalResult);
    expect(state.firstInnings, isNotNull);
    expect(state.secondInnings, isNotNull);
    expect(state.firstInnings!.runs, 100);
    expect(state.secondInnings!.runs, 101);
  });

  test('completed match -> result submitted with both innings filled', () async {
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      _scoreResponse(
        matchStatus: 3,
        allowedActions: const [],
        runtime: {
          'state': 'LIVE',
          'current_inning': 2,
          'awaiting_batter': true,
          'innings_complete': true,
          'current_batting_team_id': 2104,
          'current_bowling_team_id': 2101,
          'current_non_striker': {'user_id': 12},
          'current_striker': {'user_id': null},
          'current_bowler': {'user_id': 1},
          'last_event': {
            'type': 'MATCH_COMPLETED',
            'data': {'winner_team_id': 2101, 'result_status': 'WIN'},
          },
        },
        score: {
          'teams': {
            '2101': {'score': 100, 'wickets': 5},
            '2104': {'score': 90, 'wickets': 8},
          },
        },
      ),
    );

    expect(state.step, LiveScoringStep.resultSubmitted);
    expect(state.firstInnings, isNotNull);
    expect(state.secondInnings, isNotNull);
  });

  test('innings 2 start ignores innings 1 deliveries (bowlers selectable)',
      () async {
    // Regression: over numbers restart every innings, and the backend event
    // stream covers the whole match — innings 1's over 0 balls must not leak
    // into innings 2, otherwise the UI locks all bowlers ("over started").
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      _scoreResponse(
        matchStatus: 2,
        allowedActions: ['SET_BATTERS', 'SET_BOWLER'],
        runtime: {
          'state': 'LIVE',
          'current_over': 0,
          'current_ball': 0,
          'current_inning': 2,
          'current_batting_team_id': 2101,
          'current_bowling_team_id': 2104,
          'awaiting_batter': true,
          'awaiting_bowler': true,
          'innings_complete': false,
          'current_striker': {'user_id': null},
          'current_non_striker': {'user_id': null},
          'current_bowler': {'user_id': null},
          'dismissed_batters': <int>[],
          'last_event': {
            'type': 'INNINGS_STARTED',
            'data': {'inning': 2},
          },
          'events': [
            {
              'type': 'INNINGS_STARTED',
              'sequence': 1,
              'data': {'inning': 1},
            },
            {
              'type': 'BALL_RECORDED',
              'sequence': 2,
              'data': {
                'event_code': 'RUN',
                'delivery_runs': 4,
                'over_number': 0,
                'ball_in_over': 1,
                'legal_delivery': true,
                'bowler_user_id': 1,
              },
            },
            {
              'type': 'INNINGS_COMPLETE',
              'sequence': 3,
              'data': {'reason': 'ALL_OUT'},
            },
            {
              'type': 'INNINGS_CHANGED',
              'sequence': 4,
              'data': {'new_inning': 2},
            },
            {
              'type': 'INNINGS_STARTED',
              'sequence': 5,
              'data': {'inning': 2},
            },
          ],
        },
        score: {
          'teams': {
            '2101': {'score': 0, 'wickets': 0, 'legal_balls': 0, 'overs': '0.0'},
            '2104': {'score': 40, 'wickets': 10, 'legal_balls': 30, 'overs': '5.0'},
          },
        },
      ),
    );

    expect(state.step, LiveScoringStep.selectBowler);
    expect(state.currentOverDeliveries, isEmpty);
    expect(state.previousBowlerId, isNull);
    expect(state.openersConfigured, isFalse);
  });

  test('real completed 4003-like payload -> result submitted', () async {
    // Mirrors the live GET /score for match 4003 after COMPLETE:
    // status 3, no is_super_over key, batting 2101 / bowling 2104, inning 2,
    // awaiting_batter true with null striker.
    final bloc = _bloc();
    final state = await _apply(
      bloc,
      {
        'match': {'id': 4003, 'status': 3, 'match_number': 1},
        'teams': [
          {
            'id': 2101,
            'team_name': 'Team 1',
            'players': [
              {'user_id': 1, 'name': 'A1'},
              {'user_id': 2, 'name': 'A2'},
            ],
          },
          {
            'id': 2104,
            'team_name': 'Team 4',
            'players': [
              {'user_id': 11, 'name': 'B1'},
              {'user_id': 12, 'name': 'B2'},
            ],
          },
        ],
        'scoring': {
          'enabled': true,
          'allowed_actions': <String>[],
          'runtime': {
            'state': 'LIVE',
            'current_over': 1,
            'current_ball': 5,
            'current_batting_team_id': 2101,
            'current_bowling_team_id': 2104,
            'current_inning': 2,
            'awaiting_batter': true,
            'awaiting_bowler': false,
            'innings_complete': true,
            'current_striker': {'user_id': null},
            'current_non_striker': {'user_id': 12278},
            'current_bowler': {'user_id': 12307},
            'dismissed_batters': [12180, 12185],
            'last_event': {
              'type': 'MATCH_COMPLETED',
              'data': {'winner_team_id': 2104, 'result_status': 'WIN'},
            },
          },
          'score': {
            'teams': {
              '2101': {'score': 0, 'wickets': 10, 'legal_balls': 11, 'overs': '1.5'},
              '2104': {'score': 120, 'wickets': 10, 'legal_balls': 41, 'overs': '6.5'},
            },
          },
        },
        'result': {'status': 'WIN', 'winner_team_id': 2104},
      },
    );

    expect(state.step, LiveScoringStep.resultSubmitted);
    expect(state.firstInnings, isNotNull);
    expect(state.secondInnings, isNotNull);
    expect(state.firstInnings!.runs, 120);
    expect(state.secondInnings!.runs, 0);
  });
}
