import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

const oldPlan = VenueRoundPlan(
    id: 9,
    roundId: 416,
    date: '2026-10-10',
    startTime: '08:00',
    endTime: '09:00',
    capacity: 5,
    isPrimary: true);
const venue = PlannedTournamentVenue(
    id: 468,
    name: 'main',
    location: 'Hyderabad',
    groundType: 'Turf',
    capacity: 5,
    isPrimary: true,
    allocations: [oldPlan]);

class _Api extends PartnerRemoteDataSource {
  final writes = <({String path, Map<String, dynamic>? body})>[];
  @override
  Future<List<PlannedTournamentVenue>> getPlannedVenues(Object id) async =>
      [venue];
  @override
  Future<Map<String, dynamic>> tournamentWorkflow(
      Object tournamentId, String resource,
      {String method = 'GET', Map<String, dynamic>? body}) async {
    writes.add((path: resource, body: body));
    return {'success': true};
  }
}

void main() {
  test('venue-only edit does not resubmit unchanged allocations', () async {
    final api = _Api();
    await api.savePlannedVenue(357, venue);
    expect(api.writes.length, 1);
    expect(api.writes.single.path, 'venues/468');
    expect(api.writes.single.body!.containsKey('round_allocations'), isFalse);
  });
  test('schedule edit targets existing allocation ID', () async {
    final api = _Api();
    const changed = VenueRoundPlan(
        id: 9,
        roundId: 416,
        date: '2026-10-10',
        startTime: '08:30',
        endTime: '09:30',
        capacity: 5,
        isPrimary: true);
    await api.savePlannedVenue(357, venue.withAllocations([changed]));
    expect(api.writes.last.path, 'rounds/416/allocations/9');
    expect(api.writes.last.body!['tournament_venue_id'], 468);
    expect(api.writes.last.body!['is_primary_for_round'], isTrue);
  });
  test('allocation parser retains ID and round-primary', () {
    final plan = VenueRoundPlan.fromJson({
      'id': 9,
      'tournament_round_id': 416,
      'date': '2026-10-10T00:00:00Z',
      'start_time': '2026-10-09T08:00:00Z',
      'daily_match_capacity': 5,
      'is_primary_for_round': true
    });
    expect(plan.id, 9);
    expect(plan.isPrimary, isTrue);
  });
}
