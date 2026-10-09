import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

void main() {
  test('round remains available until combined capacity meets required matches', () {
    final partial = TournamentRound.fromJson({'id': 403, 'name': 'Round of 32', 'expected_match_count': 16, 'venue_summary': {'configured_capacity': 10}});
    expect(partial.remainingCapacity(), 6);
    expect(partial.capacityComplete, isFalse);
    final full = TournamentRound.fromJson({'id': 403, 'name': 'Round of 32', 'expected_match_count': 16, 'venue_summary': {'configured_capacity': 32}});
    expect(full.capacityComplete, isTrue);
    expect(full.remainingCapacity(editingCapacity: 32), 16);
  });
  test('create payload includes team limits for automatic backend rounds', () {
    const request = TournamentPlanningRequest(
        name: 'Test',
        sportId: 1,
        formatId: 1,
        typeId: 1,
        minimumTeams: 2,
        maximumTeams: 128,
        registrationEnd: '2026-10-15T18:00:00+05:30',
        startAt: '2026-10-17T09:00:00+05:30');
    expect(request.toJson()['maximum_teams'], 128);
    expect(request.toJson()['minimum_teams'], 2);
    expect(request.toJson().containsKey('rounds'), isFalse);
  });
  test('live venue response normalizes timestamps and sends nested allocations',
      () {
    final venue = PlannedTournamentVenue.fromJson({
      'id': 460,
      'venue_name': 'Main Stadium',
      'location': 'Downtown Sports Complex',
      'ground_type': 'Turf',
      'daily_match_capacity': 5,
      'is_primary': true,
      'round_allocations': [
        {
          'id': 1,
          'round_id': 402,
          'date': '2026-10-17T00:00:00.000000Z',
          'start_time': '2026-10-08T09:00:00.000000Z',
          'end_time': '2026-10-08T18:00:00.000000Z',
          'daily_match_capacity': 3,
          'priority': 1,
          'is_primary_for_round': true
        }
      ]
    });
    expect(venue.id, 460);
    expect(venue.allocations.single.date, '2026-10-17');
    expect(venue.allocations.single.startTime, '09:00');
    expect(venue.allocations.single.endTime, '18:00');
    expect(venue.toJson().containsKey('round_id'), isFalse);
    expect(
        (venue.toJson()['round_allocations'] as List).single['round_id'], 402);
  });
  test('zero required matches stays backend authoritative', () {
    final round = TournamentRound.fromJson({
      'id': 402,
      'name': 'Round of 128',
      'match_count': 0,
      'expected_match_count': 0,
      'venue_summary': {
        'configured_venues': 1,
        'configured_capacity': 3,
        'required_matches': 0,
        'capacity_shortfall': 0,
        'is_capacity_sufficient': true
      }
    });
    expect(round.venueSummary.configuredVenues, 1);
    expect(round.venueSummary.capacity, 3);
    expect(round.venueSummary.requiredMatches, 0);
  });
}
