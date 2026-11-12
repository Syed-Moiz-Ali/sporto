import 'dart:math';

import 'package:partner_data/partner_data.dart';

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

  Future<Booking> createBooking({
    required int sportId,
    required String bookingMethod,
    required String bookingType,
    required String bookingDate,
    required String startTime,
    required int durationMinutes,
    required String venueName,
    required String city,
    int? refereeId,
  });
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
        price: 2750,
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
        price: 2750,
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
        price: 2750,
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
      Location(
          id: 'l1', venue: 'KPHB Indoor Stadium', area: 'Kompally, Hyderabad'),
      Location(
          id: 'l2', venue: 'Kompally Turf Arena', area: 'Kompally, Hyderabad'),
      Location(
          id: 'l3', venue: 'Kondapur Sports Park', area: 'Kondapur, Hyderabad'),
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

  @override
  Future<Booking> createBooking({
    required int sportId,
    required String bookingMethod,
    required String bookingType,
    required String bookingDate,
    required String startTime,
    required int durationMinutes,
    required String venueName,
    required String city,
    int? refereeId,
  }) async {
    await _delay();
    return Booking(
      id: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      status: BookingStatus.upcoming,
      refereeName: refereeId == null ? 'Awaiting referee' : 'Assigned Referee',
      sport: 'Cricket',
      level: 3,
      durationLabel: '${(durationMinutes / 60).toStringAsFixed(0)} Hours',
      dateLabel: bookingDate,
      timeLabel: startTime,
      price: 400,
      venue: venueName,
    );
  }
}

/// Real partner-booking repository backed by the partner booking APIs.
class ApiBookingRepository implements BookingRepository {
  ApiBookingRepository({required this.remote});

  final PartnerRemoteDataSource remote;

  @override
  Future<List<Booking>> fetchBookings() async {
    final page = await remote.listPartnerBookings(filter: 'all', perPage: 50);
    return page.items.map(_toBooking).toList();
  }

  @override
  Future<List<Sport>> fetchSports() async {
    try {
      final sports = await remote.getTournamentSportsData();
      if (sports.isNotEmpty) {
        return sports
            .map((sport) => Sport(id: '${sport.id}', name: sport.name))
            .toList();
      }
    } catch (_) {}
    return const [
      Sport(id: '1', name: 'Cricket'),
      Sport(id: '2', name: 'Football'),
    ];
  }

  @override
  Future<List<Location>> searchLocations(String query) async {
    const all = [
      Location(
        id: 'l1',
        venue: 'KPHB Indoor Stadium',
        area: 'Kompally, Hyderabad',
      ),
      Location(
        id: 'l2',
        venue: 'Kompally Turf Arena',
        area: 'Kompally, Hyderabad',
      ),
      Location(
        id: 'l3',
        venue: 'Kondapur Sports Park',
        area: 'Kondapur, Hyderabad',
      ),
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
    try {
      final page = await remote.listLastAssignedReferees(perPage: 50);
      if (page.items.isNotEmpty) {
        return page.items
            .map((ref) => Referee(
                  id: '${ref.refereeId}',
                  name: ref.displayName,
                  sport:
                      ref.sports.isNotEmpty ? ref.sports.first.name : 'Cricket',
                  level: 3,
                  rating: ref.ratingAverage ?? 0,
                  matches: ref.matchesHandledCount ?? 0,
                  pricePerMatch: double.tryParse(ref.unitAmount ?? '') ?? 0,
                  distanceKm: ref.distanceKm,
                ))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<Booking> confirmBooking(Booking draft) async => draft;

  @override
  Future<void> payBooking(String bookingId, Payment method) async {
    final initiate = await remote.initiatePartnerBookingPayment(
      bookingId,
      PartnerBookingPaymentInitiateRequest(
        idempotencyKey:
            'partner-pay-$bookingId-${DateTime.now().millisecondsSinceEpoch}',
        paymentMethod: method.id == 'wallet' ? 'MOCK_WALLET' : 'MOCK_EXTERNAL',
      ),
    );
    final payment = initiate.payment;
    await remote.verifyPartnerBookingPayment(
      bookingId,
      PartnerBookingPaymentVerifyRequest(
        paymentId: payment.gatewayPaymentId ?? '${payment.id ?? ''}',
        transactionId: payment.gatewayTransactionId ?? '${payment.id ?? ''}',
      ),
    );
  }

  @override
  Future<void> submitReview(String bookingId, Rating rating) async {}

  Booking _toBooking(PartnerBooking booking) {
    final raw = booking.raw;
    final status = _status(booking);
    return Booking(
      id: '${booking.id}',
      status: status,
      refereeName: raw['referee_name']?.toString() ??
          raw['selected_referee_name']?.toString() ??
          'Awaiting referee',
      sport: raw['sport_name']?.toString() ?? 'Cricket',
      level: 3,
      durationLabel: '${raw['duration_minutes'] ?? 120} min',
      dateLabel: raw['booking_date']?.toString() ?? '',
      timeLabel: raw['start_time']?.toString() ?? '',
      price: double.tryParse(booking.totalAmount ?? '') ?? 0,
      venue: raw['venue_name']?.toString() ?? 'Venue',
    );
  }

  @override
  Future<Booking> createBooking({
    required int sportId,
    required String bookingMethod,
    required String bookingType,
    required String bookingDate,
    required String startTime,
    required int durationMinutes,
    required String venueName,
    required String city,
    int? refereeId,
  }) async {
    final booking = await remote.createPartnerBooking(
      PartnerBookingCreateRequest(
        sportId: sportId,
        bookingMethod: bookingMethod,
        bookingType: bookingType,
        bookingDate: bookingDate,
        startTime: startTime,
        durationMinutes: durationMinutes,
        venueName: venueName,
        city: city,
        refereeId: refereeId,
      ),
    );
    return _toBooking(booking);
  }

  BookingStatus _status(PartnerBooking booking) {
    switch (booking.bookingStatus) {
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'ONGOING':
      case 'STARTED':
        return BookingStatus.ongoing;
      default:
        return BookingStatus.upcoming;
    }
  }
}
