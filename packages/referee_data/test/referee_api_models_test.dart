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

  test('parses weekly availability weekdays, slots and clear result', () {
    final weekdays = [
      RefereeWeekday.fromJson({'code': 'MONDAY', 'label': 'Monday'}),
      RefereeWeekday.fromJson({'code': 'SUNDAY', 'label': 'Sunday'}),
    ];
    expect(weekdays.first.code, 'MONDAY');
    expect(weekdays.last.label, 'Sunday');

    final weekly = RefereeWeeklyAvailability.fromJson({
      'timezone': 'Asia/Kolkata',
      'slots': [
        {
          'id': 7,
          'day': 'MONDAY',
          'start_time': '06:30',
          'end_time': '11:30',
          'timezone': 'Asia/Kolkata',
        },
      ],
    });

    expect(weekly.timezone, 'Asia/Kolkata');
    expect(weekly.isEmpty, isFalse);
    expect(weekly.slots.single.id, 7);
    expect(weekly.slots.single.day, 'MONDAY');
    expect(weekly.slots.single.startTime, '06:30');
    expect(weekly.slots.single.endTime, '11:30');

    final cleared = RefereeAvailabilityClearResult.fromJson({
      'day': 'MONDAY',
      'deleted_slots': 2,
    });
    expect(cleared.day, 'MONDAY');
    expect(cleared.deletedSlots, 2);
  });

  test('serializes weekly availability slot request body', () {
    const request = RefereeAvailabilitySlotRequest(
      day: 'MONDAY',
      startTime: '06:00',
      endTime: '11:00',
    );

    expect(request.toJson(), {
      'day': 'MONDAY',
      'start_time': '06:00',
      'end_time': '11:00',
    });
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

  test('parses match session and readiness payload', () {
    final session = RefereeMatchSessionResponse.fromJson({
      'match_id': 4065,
      'match_code': 'SP-4065',
      'session_status': 'STARTED',
      'started_at': '2026-11-08T09:21:49+00:00',
      'ended_at': null,
      'started_via': 'otp',
      'otp_verified': true,
      'teams_verified': true,
      'ground_ready': true,
      'verified_at': '2026-11-08T09:20:10+00:00',
      'status': 'normal',
      'status_label': 'Normal',
      'toss_otp_verified': true,
      'toss_otp_issued': false,
      'start_otp_issued': false,
      'end_otp_issued': true,
      'final_submission': {
        'status': 'AWAITING_END_OTP',
        'next_action': 'VERIFY_END_OTP',
      },
      'can_correct_score': true,
    });

    expect(session.matchId, 4065);
    expect(session.isStarted, isTrue);
    expect(session.isVerified, isTrue);
    expect(session.otpVerified, isTrue);
    expect(session.isDelayed, isFalse);
    expect(session.endOtpIssued, isTrue);
    expect(session.finalSubmissionStatus, 'AWAITING_END_OTP');
    expect(session.canCorrectScore, isTrue);
  });

  test('parses match result payload', () {
    final result = RefereeMatchResultResponse.fromJson({
      'match_id': 4065,
      'match_code': 'SP-4065',
      'match_status': 3,
      'status': 'WIN',
      'winner_team_id': 2170,
      'winner_team_name': 'Demo T395 Team 1',
      'message': 'Demo T395 Team 1 won',
      'margin': null,
      'is_walkover': false,
    });

    expect(result.status, 'WIN');
    expect(result.hasWinner, isTrue);
    expect(result.winnerTeamName, 'Demo T395 Team 1');
  });

  test('parses scorecard summary, availability and innings', () {
    final scorecard = RefereeScorecardResponse.fromJson({
      'match': {
        'id': 4065,
        'tournament_id': 395,
        'status': 3,
        'winner_team_id': 2170,
        'teams': [
          {'id': 2170, 'name': 'Demo T395 Team 1'},
          {'id': 2173, 'name': 'Demo T395 Team 4'},
        ],
      },
      'data_availability': {
        'event_count': 17,
        'active_event_count': 17,
        'reversed_event_count': 0,
        'status': 'COMPLETE',
        'reason': 'LEDGER_VERIFIED',
        'message': 'Ledger reconciles with the live team totals.',
      },
      'team_totals': {
        '2170': {
          'score': 14,
          'wickets': 0,
          'legal_balls': 3,
          'overs': '0.3',
        },
      },
      'match_code': 'SP-4065',
      'winner_team_name': 'Demo T395 Team 1',
      'player_of_match': null,
      'result': {'winner_team_id': 2170, 'message': 'Demo T395 Team 1 won'},
      'innings': [
        {
          'innings_number': 1,
          'batting_team_id': 2173,
          'batting_team_name': 'Demo T395 Team 4',
          'totals': {'runs': 13, 'wickets': 10, 'overs': '2.1'},
          'batting': [
            {
              'player_id': 12721,
              'name': 'Demo Captain T395 Team 4',
              'runs': 10,
              'balls_faced': 2,
            },
          ],
          'bowling': [
            {
              'player_id': 12688,
              'name': 'Demo Captain T395 Team 1',
              'wickets': 2,
              'runs_conceded': 4,
            },
          ],
        },
      ],
      'super_overs': [],
    });

    expect(scorecard.match.id, 4065);
    expect(scorecard.dataAvailability.isComplete, isTrue);
    expect(scorecard.teamTotals['2170']?.runs, 14);
    expect(scorecard.innings.single.totals.scoreText, '13/10');
    expect(scorecard.innings.single.batting.single.runs, 10);
    expect(scorecard.innings.single.bowling.single.wickets, 2);
  });

  test('parses score events ledger page', () {
    final page = RefereeScoreEventsPage.fromJson({
      'current_page': 1,
      'per_page': 10,
      'last_page': 2,
      'total': 17,
      'items': [
        {
          'id': 2159,
          'event_uuid': '290296b3-bad7-4c1c-a3de-897abfcabbd1',
          'event_sequence': 1,
          'event_type': 'RUN',
          'event_category': 'DELIVERY',
          'tournament_match_id': 4065,
          'team_id': 2173,
          'player_id': 12721,
          'score_value': 4,
          'innings_number': 1,
          'innings_type': 'REGULATION',
          'over_number': 0,
          'ball_number': 1,
          'is_legal_delivery': true,
          'is_reversed': false,
          'event_data': {
            'runs_source': 'BAT',
            'fielder_user_id': 12699,
            'dismissed_user_id': 12711,
          },
        },
      ],
    });

    expect(page.total, 17);
    expect(page.items.single.eventType, 'RUN');
    expect(page.items.single.scoreValue, 4);
    expect(page.items.single.isLegalDelivery, isTrue);
    expect(page.items.single.isWicket, isFalse);
    expect(page.items.single.runsSource, 'BAT');
    expect(page.items.single.fielderUserId, 12699);
    expect(page.items.single.eventDismissedUserId, 12711);
  });

  test('parses availability status and seven-day overview', () {
    final status = RefereeAvailabilityStatusResponse.fromJson({
      'is_available': true,
      'accepting_matches': true,
      'status_label': 'On',
      'message': 'Ready for your next match',
    });
    expect(status.isAvailable, isTrue);
    expect(status.statusLabel, 'On');

    final weekly = RefereeWeeklyAvailability.fromJson({
      'timezone': 'Asia/Kolkata',
      'slots': [],
      'days': [
        {
          'day': 'MONDAY',
          'label': 'Monday',
          'is_enabled': true,
          'has_enabled_slots': false,
          'has_configured_hours': false,
          'has_available_hours': false,
          'status_label': 'Not Available',
          'slots': [],
        },
      ],
    });
    expect(weekly.days.single.day, 'MONDAY');
    expect(weekly.days.single.isEnabled, isTrue);
  });

  test('maps an independent booking request into the request card model', () {
    final request = RefereeMatchRequestResponse.fromBookingRequestJson({
      'assignment_id': 501,
      'assignment_status': 1,
      'booking_source': 'USER',
      'request_type': 'REFEREE_BOOKING',
      'booked_by': {'display_name': 'Rahul Kumar'},
      'booking': {
        'id': 101,
        'booking_number': 'RB-3F3C751B',
        'sport_name': 'Cricket',
        'venue_name': 'Community sports ground',
        'city': 'Hyderabad',
        'booking_date': '2026-11-02',
        'start_time': '10:00',
        'scheduled_start_at': '2026-11-02T04:30:00+00:00',
        'duration_minutes': 120,
        'referee_fee': '400.00',
        'booking_status': 'REQUESTED',
        'display_status': 'PENDING_PAYMENT',
      },
    });

    expect(request.isBooking, isTrue);
    expect(request.assignmentId, 501);
    expect(request.venueName, 'Community sports ground');
    expect(request.raw['booked_by'], 'Rahul Kumar');
    expect(request.raw['fee'], '400.00');
    expect(request.raw['duration_hours'], 2.0);
  });

  test('serializes toss OTP and score ledger fields', () {
    expect(
      RefereeTossUpdateRequest.call(
        calledSide: 'HEADS',
        callingTeamId: 2170,
        otp: '769259',
      ).toJson(),
      {
        'action': 'CALL',
        'called_side': 'HEADS',
        'calling_team_id': 2170,
        'otp': '769259',
      },
    );
    expect(
      RefereeScoreUpdateRequest.addEvent(
        eventCode: 'RUN',
        teamId: 2173,
        playerId: 12721,
        value: 4,
        eventUuid: 'uuid-1',
        runsSource: 'BAT',
        fielderUserId: 12688,
      ).toJson(),
      {
        'action': 'ADD_EVENT',
        'event_code': 'RUN',
        'team_id': 2173,
        'player_id': 12721,
        'value': 4,
        'event_uuid': 'uuid-1',
        'runs_source': 'BAT',
        'fielder_user_id': 12688,
      },
    );
    expect(
      RefereeScoreUpdateRequest.undoLast(reason: 'Wrong delivery').toJson(),
      {'action': 'UNDO_LAST', 'reason': 'Wrong delivery'},
    );
  });

  test('parses final submission pending End OTP', () {
    final score = RefereeScoreResponse.fromJson({
      'match': {'id': 4065, 'status': 2},
      'teams': const [],
      'scoring': {
        'enabled': true,
        'runtime': {},
        'score': {},
        'final_submission': {
          'status': 'AWAITING_END_OTP',
          'next_action': 'VERIFY_END_OTP',
        },
      },
      'progression': {'status': 'PENDING_END_OTP'},
      'recorded_event': {
        'id': 2159,
        'event_uuid': 'uuid-1',
        'replayed': false,
      },
    });

    expect(score.isAwaitingEndOtp, isTrue);
    expect(score.isPendingEndOtp, isTrue);
    expect(score.finalSubmissionNextAction, 'VERIFY_END_OTP');
    expect(score.recordedEvent['event_uuid'], 'uuid-1');
  });

  test('parses referee booking session and completion state', () {
    final session = RefereeBookingSessionResponse.fromJson({
      'booking_id': 2,
      'booking_source': 'PARTNER',
      'booked_by_user_id': 12447,
      'referee_id': 12419,
      'match_id': 4203,
      'booking_status': 'COMPLETED',
      'payment_status': 'SUCCESS',
      'referee_fee': '400.00',
      'platform_fee': '0.40',
      'total_amount': '400.40',
      'currency': 'INR',
      'session_status': 'ENDED',
      'toss_verified_at': '2026-11-09T05:50:39+00:00',
      'started_at': '2026-11-09T05:54:55+00:00',
      'ended_at': '2026-11-09T05:55:30+00:00',
      'earning_status': 'SIMULATED_UNFUNDED',
      'earning_wallet_transaction_id': null,
    });

    expect(session.bookingId, 2);
    expect(session.matchId, 4203);
    expect(session.refereeId, 12419);
    expect(session.isCompleted, isTrue);
    expect(session.isEnded, isTrue);
    expect(session.earningStatus, 'SIMULATED_UNFUNDED');
  });
}
