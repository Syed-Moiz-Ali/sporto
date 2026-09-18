import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

void main() {
  group('PartnerTournamentMatchResponse live API parsing', () {
    test('parses live matches payload with nested stage, round, group, teams, and schedule', () {
      final json = {
        'id': 95,
        'match_number': 1,
        'stage': {
          'id': 26,
          'name': 'League Stage',
          'code': null,
        },
        'round': {
          'id': 12,
          'name': 'Matchday 1',
          'code': null,
        },
        'group': {
          'id': 3,
          'name': 'Group A',
          'code': null,
        },
        'team_a': {
          'id': 4,
          'name': 'Pro Lions',
          'logo_url':
              'https://pub-c94d45e28dfa4bf08b2cd5d22adb73e6.r2.dev/users/profile/06e47ea1-8d78-46b5-bb3a-01d6d0c75b50.jpg',
        },
        'team_b': {
          'id': 7,
          'name': 'Team 03',
          'logo_url': null,
        },
        'schedule': {
          'date': null,
          'start_time': null,
          'end_time': null,
          'venue': null,
          'schedule_status': 'needs_review',
        },
        'status': 'scheduled',
        'result': null,
      };

      final match = PartnerTournamentMatchResponse.fromJson(json);

      expect(match.id, 95);
      expect(match.matchNumber, '1');
      expect(match.status, 'scheduled');
      expect(match.result, isNull);

      // Stage
      expect(match.stage, isNotNull);
      expect(match.stage!.id, 26);
      expect(match.stage!.name, 'League Stage');
      expect(match.stage!.code, isNull);
      expect(match.stageName, 'League Stage');

      // Round
      expect(match.round, isNotNull);
      expect(match.round!.id, 12);
      expect(match.round!.name, 'Matchday 1');
      expect(match.displayRound, 'Matchday 1');

      // Group
      expect(match.group, isNotNull);
      expect(match.group!.id, 3);
      expect(match.group!.name, 'Group A');
      expect(match.groupName, 'Group A');

      // Teams
      expect(match.teamA, isNotNull);
      expect(match.teamA!.id, 4);
      expect(match.teamA!.name, 'Pro Lions');
      expect(match.teamA!.logoUrl, contains('users/profile/06e47ea1'));
      expect(match.displayTeamA, 'Pro Lions');
      expect(match.displayTeamALogo, contains('users/profile/06e47ea1'));

      expect(match.teamB, isNotNull);
      expect(match.teamB!.id, 7);
      expect(match.teamB!.name, 'Team 03');
      expect(match.teamB!.logoUrl, isNull);
      expect(match.displayTeamB, 'Team 03');
      expect(match.displayTeamBLogo, isNull);

      // Schedule & Status
      expect(match.schedule, isNotNull);
      expect(match.schedule!.scheduleStatus, 'needs_review');
      expect(match.isNeedsReview, isTrue);
      expect(match.isLive, isFalse);
      expect(match.isCompleted, isFalse);
      expect(match.displayVenue, 'Venue not set');
      expect(match.displayTime, '');
    });

    test('parses scheduled match with complete date and venue', () {
      final json = {
        'id': 96,
        'match_number': 2,
        'stage': {'id': 26, 'name': 'League Stage', 'code': null},
        'round': {'id': 12, 'name': 'Matchday 1', 'code': null},
        'group': {'id': 3, 'name': 'Group A', 'code': null},
        'team_a': {'id': 5, 'name': 'Team 01', 'logo_url': null},
        'team_b': {'id': 6, 'name': 'Team 02', 'logo_url': null},
        'schedule': {
          'date': '2026-08-15',
          'start_time': '10:00 AM',
          'end_time': '01:00 PM',
          'venue': 'Ground A',
          'schedule_status': 'confirmed',
        },
        'status': 'live',
        'result': null,
      };

      final match = PartnerTournamentMatchResponse.fromJson(json);

      expect(match.id, 96);
      expect(match.displayTeamA, 'Team 01');
      expect(match.displayTeamB, 'Team 02');
      expect(match.displayRound, 'Matchday 1');
      expect(match.displayVenue, 'Ground A');
      expect(match.displayTime, '2026-08-15, 10:00 AM');
      expect(match.isLive, isTrue);
      expect(match.isNeedsReview, isFalse);
    });
  });
}
