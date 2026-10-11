import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';

void main() {
  test('parses the populated referee application response', () {
    final application = RefereeApplicationResponse.fromJson({
      'application_number': 'REF-V2PJIK0I',
      'application_status': 2,
      'submitted_at': '2026-08-23 14:15:03',
      'personal_information': {
        'first_name': 'Sujith',
        'last_name': 'Reddy',
        'email': 'sujith@example.com',
        'mobile_number': '9700000201',
        'date_of_birth': '1999-08-21',
        'gender': 'male',
      },
      'address': {
        'address_line_1': 'Test address',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500001',
        'country': 'India',
      },
      'sports': {
        'sport_ids': [1, 2],
        'experience_years': 4,
        'highest_qualification': 'State Level',
      },
      'availability': {
        'availability': ['monday', 'saturday'],
        'preferred_city': 'Hyderabad',
        'travel_radius': 25,
        'emergency_contact_name': 'Contact',
        'emergency_contact_number': '9700000202',
      },
      'documents': [
        {'id': 2, 'type': 2, 'file_url': 'https://example.com/id.png'},
      ],
      'timeline': [
        {
          'status': 2,
          'reason': 'Application submitted for review.',
          'date': '2026-08-23 14:15:03',
        },
      ],
    });

    expect(application.applicationNumber, 'REF-V2PJIK0I');
    expect(application.isPendingReview, isTrue);
    expect(application.sports.sportIds, [1, 2]);
    expect(application.availability.days, ['monday', 'saturday']);
    expect(application.documents.single.type, 2);
    expect(application.timeline.single.status, 2);
  });

  test('serializes request bodies with backend field names', () {
    const request = RefereeAvailabilityRequest(
      availability: ['monday'],
      preferredCity: 'Hyderabad',
      travelRadius: 25,
      emergencyContactName: 'Contact',
      emergencyContactNumber: '9700000202',
    );

    expect(request.toJson(), {
      'availability': ['monday'],
      'preferred_city': 'Hyderabad',
      'travel_radius': 25,
      'emergency_contact_name': 'Contact',
      'emergency_contact_number': '9700000202',
    });
  });

  test('parses match-request item with nested assignment and schedule', () {
    final request = RefereeMatchRequestResponse.fromJson({
      'id': 3998,
      'match_number': 2,
      'status': 1,
      'can_officiate': false,
      'blocking_code': 'ASSIGNMENT_NOT_ACCEPTED',
      'blocking_reason': 'Accept this match assignment before officiating.',
      'tournament': {'id': 368, 'name': 'QA Toss Score'},
      'round': {'id': 443, 'name': 'Semi-Final'},
      'participants': {
        'team_a': {'id': 2092, 'name': 'Team 2'},
        'team_b': {'id': 2093, 'name': 'Team 3'},
      },
      'schedule': {
        'date': '2026-10-19',
        'start_time': '10:15',
        'end_time': '11:15',
        'venue': {'id': 493, 'name': 'QA Ground', 'location': 'Hyderabad'},
      },
      'assignment': {
        'id': 2400,
        'status': 1,
        'role': 'Main Referee',
        'assigned_at': '2026-10-11T09:39:44+00:00',
      },
      'toss': {'enabled': true, 'state': 'TOSS_PENDING', 'next_action': 'CALL'},
    });

    expect(request.id, 3998);
    expect(request.assignmentId, 2400);
    expect(request.assignmentStatus, 1);
    expect(request.canOfficiate, isFalse);
    expect(request.blockingCode, 'ASSIGNMENT_NOT_ACCEPTED');
    expect(request.displayTeamA, 'Team 2');
    expect(request.displayVenue, 'QA Ground');
    expect(request.displaySchedule, contains('10:15'));
    expect(request.tossState, 'TOSS_PENDING');
    expect(request.isTossCompleted, isFalse);
  });

  test('parses accepted match list item as officiable', () {
    final match = RefereeMatchResponse.fromJson({
      'id': 3997,
      'status': 1,
      'can_officiate': true,
      'participants': {
        'team_a': {'id': 2091, 'name': 'Team 1'},
        'team_b': {'id': 2094, 'name': 'Team 4'},
      },
      'schedule': {
        'date': '2026-10-19',
        'start_time': '09:00',
        'venue': {'name': 'QA Ground'},
      },
      'assignment': {'id': 2399, 'status': 2, 'role': 'Main Referee'},
      'toss': {
        'enabled': true,
        'state': 'TOSS_COMPLETED',
        'is_completed': true,
      },
    });

    expect(match.id, 3997);
    expect(match.assignmentId, 2399);
    expect(match.canOfficiate, isTrue);
    expect(match.blockingCode, isNull);
    expect(match.isTossCompleted, isTrue);
  });

  test('parses toss state with top-level normalized fields', () {
    final toss = RefereeTossResponse.fromJson({
      'sport': {'id': 1, 'name': 'Cricket'},
      'format': {'id': 1, 'name': 'T20'},
      'teams': [
        {
          'id': 2092,
          'name': 'Team 2',
          'members': [
            {'user_id': 12168, 'name': 'Captain', 'is_captain': true},
          ],
        },
      ],
      'toss': {
        'enabled': true,
        'method': 'coin',
        'state': 'TOSS_COMPLETED',
        'is_started': true,
        'is_result_decided': true,
        'is_completed': true,
        'next_action': null,
        'allowed_actions': <String>[],
        'winner_team_id': 2092,
        'decision': 'BAT_FIRST',
        'starting_setup': null,
        'runtime': {
          'calling_team_id': 2092,
          'called_side': 'HEADS',
          'landed_side': 'HEADS',
          'winner_team_id': 2092,
          'decision': 'BAT_FIRST',
          'is_completed': true,
          'next_action': null,
          'allowed_actions': <String>[],
        },
      },
    });

    expect(toss.toss.state, 'TOSS_COMPLETED');
    expect(toss.toss.isCompleted, isTrue);
    expect(toss.toss.isStarted, isTrue);
    expect(toss.toss.isStartingSetupPending, isFalse);
    expect(toss.toss.allowedActions, isEmpty);
    expect(toss.toss.runtime.winnerTeamId, 2092);
    expect(toss.teams.single.members.single.userId, 12168);
  });

  test('parses toss state awaiting starting setup', () {
    final toss = RefereeTossStateResponse.fromJson({
      'enabled': true,
      'state': 'STARTING_SETUP_PENDING',
      'is_started': true,
      'is_result_decided': true,
      'is_completed': false,
      'next_action': 'SET_STARTING_PLAYERS',
      'allowed_actions': ['SET_STARTING_PLAYERS'],
      'starting_roles': [
        {'key': 'STRIKER', 'label': 'Striker', 'is_opponent': false},
      ],
      'runtime': {
        'winner_team_id': 2092,
        'decision': 'BAT_FIRST',
        'allowed_actions': ['SET_STARTING_PLAYERS'],
        'batting_team': {'id': 2092, 'name': 'Team 2'},
        'bowling_team': {'id': 2093, 'name': 'Team 3'},
        'starting_setup': {'STRIKER': 12168},
      },
    });

    expect(toss.isStartingSetupPending, isTrue);
    expect(toss.isCompleted, isFalse);
    expect(toss.allowedActions, ['SET_STARTING_PLAYERS']);
    expect(toss.startingRoles.single.key, 'STRIKER');
    expect(toss.runtime.battingTeamId, 2092);
    expect(toss.runtime.bowlingTeamId, 2093);
    expect(toss.runtime.startingUserId('STRIKER'), 12168);
    expect(toss.runtime.startingUserId('NON_STRIKER'), isNull);
  });

  test('parses score state allowed actions and runtime', () {
    final score = RefereeScoreResponse.fromJson({
      'match': {'id': 3997, 'status': 2, 'match_number': 1},
      'tournament': {'id': 368, 'name': 'QA Toss Score'},
      'schedule': {
        'venue': {'id': 493, 'name': 'QA Ground', 'location': 'Hyderabad'},
      },
      'teams': [
        {
          'id': 2091,
          'team_name': 'Team 1',
          'players': [
            {'user_id': 12157, 'name': 'Player 1'},
          ],
        },
      ],
      'scoring': {
        'enabled': true,
        'method': 'BALL_BY_BALL',
        'period_type': 'INNINGS',
        'periods_count': 2,
        'current_period': 1,
        'allowed_actions': [
          'ADD_EVENT',
          'SET_BATTERS',
          'SET_BOWLER',
          'END_PERIOD',
        ],
        'next_action': null,
        'available_events': [
          {
            'code': 'RUN',
            'label': 'Run',
            'type': 'POINT',
            'value': 1,
            'requires_player': true,
            'variable_value': true,
            'allowed_values': [0, 1, 2, 3, 4, 6],
          },
        ],
        'runtime': {
          'state': 'LIVE',
          'current_batting_team_id': 2091,
          'current_striker': {'user_id': 12157, 'name': 'Player 1'},
        },
        'score': {
          'teams': {
            '2091': {'score': 7},
          },
        },
      },
    });

    expect(score.statusText, 'LIVE');
    expect(score.isReadOnly, isFalse);
    expect(score.isLive, isTrue);
    expect(score.scoring.runtimeState, 'LIVE');
    expect(score.scoring.runtime.state, 'LIVE');
    expect(score.scoring.runtime.currentBattingTeamId, 2091);
    expect(score.scoring.runtime.currentStriker.userId, 12157);
    expect(score.scoring.runtime.currentStriker.name, 'Player 1');
    expect(score.scoring.runtime.currentBowler.isEmpty, isTrue);
    expect(score.scoring.allowedActions, contains('ADD_EVENT'));
    expect(score.scoring.availableEvents.single.code, 'RUN');
    expect(score.scoring.teamScore(2091), 7);
    expect(score.scoring.teamScore('2094'), 0);
    expect(score.tournamentName, 'QA Toss Score');
    expect(score.venueName, 'QA Ground');
    expect(score.venueLocation, 'Hyderabad');
  });

  test('maps completed match status to read-only', () {
    final score = RefereeScoreResponse.fromJson({
      'match': {'id': 3997, 'status': 3, 'winner_team_id': 2091},
      'teams': const [],
      'scoring': {'enabled': true, 'runtime': {}, 'score': {}},
      'result': {'status': 'WIN', 'winner_team_id': 2091},
    });

    expect(score.statusText, 'COMPLETED');
    expect(score.isReadOnly, isTrue);
    expect(score.winnerTeamId, 2091);
    expect(score.resultStatus, 'WIN');
  });

  test('parses v2 runtime flags, events and team totals', () {
    final score = RefereeScoreResponse.fromJson({
      'match': {'id': 4001, 'status': 2, 'match_number': 1},
      'teams': [
        {
          'id': 2098,
          'team_name': 'Team 3',
          'players': [
            {'user_id': 12250, 'name': 'A'},
            {'user_id': 12252, 'name': 'B'},
          ],
        },
        {
          'id': 2097,
          'team_name': 'Team 2',
          'players': [
            {'user_id': 12239, 'name': 'C'},
          ],
        },
      ],
      'scoring': {
        'enabled': true,
        'allowed_actions': ['SET_BOWLER', 'UNDO_LAST'],
        'next_action': 'SET_BOWLER',
        'runtime': {
          'state': 'LIVE',
          'current_over': 1,
          'current_ball': 0,
          'current_inning': 1,
          'current_batting_team_id': 2098,
          'current_bowling_team_id': 2097,
          'awaiting_batter': false,
          'awaiting_bowler': true,
          'innings_complete': false,
          'is_super_over': false,
          'dismissed_batters': [12251],
          'current_striker': {'user_id': 12250, 'name': 'A'},
          'current_non_striker': {'user_id': 12252, 'name': 'B'},
          'current_bowler': {'user_id': null, 'name': null},
          'last_event': {
            'type': 'OVER_COMPLETE',
            'sequence': 18,
            'data': {'over': 1},
          },
          'events': [
            {
              'type': 'BALL_RECORDED',
              'sequence': 17,
              'data': {
                'event_code': 'RUN',
                'delivery_runs': 1,
                'over_number': 0,
                'ball_in_over': 5,
                'legal_delivery': true,
              },
            },
            {
              'type': 'OVER_COMPLETE',
              'sequence': 18,
              'data': {'over': 1},
            },
          ],
        },
        'score': {
          'teams': {
            '2097': {
              'score': 0,
              'wickets': 0,
              'legal_balls': 0,
              'overs': '0.0',
              'extras': {'wide': 0},
            },
            '2098': {
              'score': 7,
              'wickets': 1,
              'legal_balls': 6,
              'overs': '1.0',
              'extras': {'wide': 1, 'no_ball': 1, 'total': 2},
            },
          },
        },
      },
    });

    expect(score.scoring.runtime.awaitingBowler, isTrue);
    expect(score.scoring.runtime.awaitingBatter, isFalse);
    expect(score.scoring.runtime.dismissedBatters, [12251]);
    expect(score.scoring.runtime.lastEvent?.type, 'OVER_COMPLETE');
    expect(score.scoring.runtime.events.length, 2);
    expect(score.scoring.runtime.events.first.type, 'BALL_RECORDED');
    expect(score.scoring.runtime.events.first.eventCode, 'RUN');
    expect(score.scoring.runtime.events.first.isLegalDelivery, isTrue);
    expect(score.scoring.runtime.events.first.ballInOver, 5);

    final totals = score.scoring.teamTotals(2098);
    expect(totals.score, 7);
    expect(totals.wickets, 1);
    expect(totals.legalBalls, 6);
    expect(totals.overs, '1.0');
    expect(totals.scoreText, '7/1');
    expect(totals.extras['wide'], 1);
  });

  test('serializes START_SUPER_OVER and wicket_type payloads', () {
    expect(
      RefereeScoreUpdateRequest.startSuperOver().toJson(),
      {'action': 'START_SUPER_OVER'},
    );
    expect(
      RefereeScoreUpdateRequest.addEvent(
        eventCode: 'WICKET',
        teamId: 5,
        playerId: 9,
        wicketType: 'BOWLED',
      ).toJson(),
      {
        'action': 'ADD_EVENT',
        'event_code': 'WICKET',
        'team_id': 5,
        'player_id': 9,
        'wicket_type': 'BOWLED',
      },
    );
  });
}
