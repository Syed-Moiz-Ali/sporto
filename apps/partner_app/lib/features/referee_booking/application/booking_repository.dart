import 'dart:math';

import 'booking_models.dart';

/// Repository contract for the referee-booking flow.
///
/// The mock implementation below returns hardcoded data with a random delay so
/// loading states can be exercised. A real API implementation can replace it
/// without changing the bloc or the screens.
abstract class BookingRepository {
  Future<List<Booking>> fetchBookings();
  Future<List<Sport>> fetchSports();
  Future<List<Location>> searchLocations(String query);
  Future<List<Referee>> fetchReferees();
  Future<Booking> confirmBooking(Booking draft);
  Future<void> payBooking(String bookingId, Payment method);
  Future<void> submitReview(String bookingId, Rating rating);
}

/// In-memory mock. No network calls.
class MockBookingRepository implements BookingRepository {
  final Duration minDelay;
  final Duration maxDelay;
  final Random _random;

  MockBookingRepository({
    this.minDelay = const Duration(milliseconds: 100),
    this.maxDelay = const Duration(milliseconds: 500),
    int? seed,
  }) : _random = Random(seed);

  /// No artificial delay (used by golden tests).
  MockBookingRepository.instant({int? seed})
      : minDelay = Duration.zero,
        maxDelay = Duration.zero,
        _random = Random(seed);

  Future<void> _delay() async {
    if (maxDelay == Duration.zero) return;
    final lo = minDelay.inMilliseconds;
    final hi = maxDelay.inMilliseconds;
    final ms = lo + _random.nextInt((hi - lo).clamp(1, 1 << 30));
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  @override
  Future<List<Booking>> fetchBookings() async {
    await _delay();
    return const [
      Booking(
        id: 'REF-71858723',
        status: BookingStatus.upcoming,
        refereeName: 'Suresh Reddy',
        sport: 'Cricket',
        level: 3,
        durationLabel: 'Full Day',
        dateLabel: '13 Oct 2026',
        timeLabel: '5:00 PM',
        price: 1800,
      ),
      Booking(
        id: 'REF-71910900',
        status: BookingStatus.ongoing,
        refereeName: 'Vijay Mohan',
        sport: 'Cricket',
        level: 3,
        durationLabel: 'Full Day',
        dateLabel: '13 Oct 2026',
        timeLabel: '5:00 PM',
        price: 1800,
      ),
      Booking(
        id: 'REF-71200455',
        status: BookingStatus.completed,
        refereeName: 'Ravi Kumar',
        sport: 'Cricket',
        level: 2,
        durationLabel: '2 Hours',
        dateLabel: '12 Oct 2026',
        timeLabel: '7:00 PM',
        price: 1500,
      ),
    ];
  }

  @override
  Future<List<Sport>> fetchSports() async {
    await _delay();
    return const [
      Sport(id: 'cricket', name: 'Cricket'),
      Sport(id: 'football', name: 'Football'),
      Sport(id: 'badminton', name: 'Badminton'),
      Sport(id: 'basketball', name: 'Basketball'),
      Sport(id: 'volleyball', name: 'Volleyball'),
    ];
  }

  @override
  Future<List<Location>> searchLocations(String query) async {
    await _delay();
    const all = [
      Location(id: 'l1', venue: 'KPHB Indoor Stadium', area: 'Kompally, Hyderabad'),
      Location(id: 'l2', venue: 'Kompally Turf Arena', area: 'Kompally, Hyderabad'),
      Location(id: 'l3', venue: 'Kondapur Sports Park', area: 'Kondapur, Hyderabad'),
    ];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((l) =>
            l.venue.toLowerCase().contains(q) ||
            l.area.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Referee>> fetchReferees() async {
    await _delay();
    return const [
      Referee(
        id: 'r1',
        name: 'Suresh Reddy',
        sport: 'Cricket',
        level: 3,
        rating: 4.8,
        matches: 34,
        pricePerMatch: 1800,
        distanceKm: 3.6,
      ),
      Referee(
        id: 'r2',
        name: 'Vijay Mohan',
        sport: 'Cricket',
        level: 3,
        rating: 4.6,
        matches: 28,
        pricePerMatch: 1800,
        distanceKm: 4.2,
      ),
    ];
  }

  @override
  Future<Booking> confirmBooking(Booking draft) async {
    await _delay();
    return draft;
  }

  @override
  Future<void> payBooking(String bookingId, Payment method) async {
    await _delay();
  }

  @override
  Future<void> submitReview(String bookingId, Rating rating) async {
    await _delay();
  }
}
