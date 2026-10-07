import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

void main() {
  test('live empty registration and nested rounds responses parse safely', () {
    expect(workflowList([], TournamentRegistration.fromJson), isEmpty);
    expect(
        workflowList(
            {'tournament_id': 351, 'tournament_type': 'KNOCKOUT', 'rounds': []},
            TournamentRound.fromJson),
        isEmpty);
  });

  test('documented registration roster uses tournament players', () {
    final registration = TournamentRegistration.fromJson({
      'id': 9,
      'team': {'name': 'Test team'},
      'status': 1,
      'registration_players': [
        {
          'user_id': 12,
          'user': {'name': 'Captain'}
        }
      ],
    });
    expect(registration.name, 'Test team');
    expect(registration.players.single.userId, 12);
    expect(registration.players.single.name, 'Captain');
  });

  test('allocation request keeps scheduling separate from physical venue', () {
    const request = TournamentAllocationRequest(
        venueId: 455, date: '2026-10-12', startTime: '09:00', capacity: 8);
    expect(request.toJson(), {
      'tournament_venue_id': 455,
      'date': '2026-10-12',
      'start_time': '09:00',
      'daily_match_capacity': 8
    });
    final allocation = TournamentRoundAllocation.fromJson(
        {'allocation_id': 7, ...request.toJson()});
    expect(allocation.id, 7);
    expect(allocation.venueId, 455);
  });

  test('schedule version and scheduled matches remain typed', () {
    final schedule = TournamentSchedule.fromJson({
      'version_id': 123,
      'status': 'DRAFT',
      'matches': [
        {
          'match_id': 44,
          'match_number': 1,
          'scheduled_start_at': '2026-10-12T09:00:00'
        }
      ]
    });
    expect(schedule.versionId, 123);
    expect(schedule.matches.single.id, 44);
    expect(schedule.matches.single.startAt, '2026-10-12T09:00:00');
  });
}
