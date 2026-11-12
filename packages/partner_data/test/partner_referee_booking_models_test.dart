import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

void main() {
  test('parses booking quote', () {
    final quote = PartnerBookingQuote.fromJson({
      'referee_fee': '400.00',
      'platform_fee': '40.00',
      'total_amount': '440.00',
      'currency': 'INR',
      'duration_minutes': 120,
      'scheduled_start_at': '2026-11-02T04:30:00.000000Z',
      'scheduled_end_at': '2026-11-02T06:30:00.000000Z',
      'timezone': 'Asia/Kolkata',
      'booking_date': '2026-11-02',
      'booking_type': 'HOURLY',
      'eligible_referees_count': 1,
    });

    expect(quote.totalAmount, '440.00');
    expect(quote.currency, 'INR');
    expect(quote.durationMinutes, 120);
    expect(quote.eligibleRefereesCount, 1);
  });

  test('parses created booking and payment states', () {
    final booking = PartnerBooking.fromJson({
      'id': 101,
      'uuid': '9a31a5eb-b31c-4b53-a55e-fa28f41334c1',
      'booking_number': 'RB-9A31A5EB',
      'booking_source': 'PARTNER',
      'booking_method': 'QUICK',
      'partner_profile_id': 1,
      'total_amount': '440.00',
      'currency': 'INR',
      'payment_status': 'PENDING',
      'booking_status': 'PENDING_PAYMENT',
      'display_status': 'PENDING_PAYMENT',
    });

    expect(booking.id, 101);
    expect(booking.isPendingPayment, isTrue);
    expect(booking.bookingMethod, 'QUICK');
    expect(booking.totalAmount, '440.00');
  });

  test('parses discover referees page', () {
    final page = PartnerAvailableRefereesPage.fromJson({
      'current_page': 1,
      'per_page': 20,
      'total': 1,
      'data': [
        {
          'referee_id': 10,
          'display_name': 'Rahul Sharma',
          'profile_photo': null,
          'sports': [
            {'id': 1, 'name': 'Cricket'},
          ],
          'experience_years': 5,
          'preferred_city': 'Hyderabad',
          'distance_km': null,
          'location_basis': 'CITY_MATCH',
          'available': true,
          'reviews_count': 0,
          'rating_average': null,
          'matches_handled_count': 64,
          'unit_amount': '200.00',
          'rate_scope': 'SPORT',
          'eligibility_explanation': 'Approved and available.',
          'price': {
            'referee_fee': '400.00',
            'platform_fee': '40.00',
            'total_amount': '440.00',
            'currency': 'INR',
          },
        },
      ],
    });

    expect(page.total, 1);
    expect(page.items.single.refereeId, 10);
    expect(page.items.single.sports.single.name, 'Cricket');
    expect(page.items.single.available, isTrue);
    expect(page.items.single.price.totalAmount, '440.00');
    expect(page.items.single.matchesHandledCount, 64);
    expect(page.items.single.eligibilityExplanation, 'Approved and available.');
  });

  test('parses booking list with counts', () {
    final page = PartnerBookingPage.fromJson({
      'current_page': 1,
      'total': 0,
      'data': [],
      'counts': {
        'all': 0,
        'upcoming': 0,
        'ongoing': 0,
        'completed': 0,
        'cancelled': 0,
      },
    });

    expect(page.items, isEmpty);
    expect(page.counts.all, 0);
  });

  test('parses payment verify result and session OTP', () {
    final result = PartnerBookingPaymentResult.fromJson({
      'mode': 'SIMULATED_DB_ONLY',
      'payment': {'payment_status': 'SUCCESS'},
      'booking': {'booking_status': 'SEARCHING'},
    });

    expect(result.mode, 'SIMULATED_DB_ONLY');
    expect(result.payment.paymentStatus, 'SUCCESS');
    expect(result.bookingStatus, 'SEARCHING');

    final otp = PartnerBookingSessionOtp.fromJson({
      'booking_id': 2,
      'phase': 'toss',
      'otp': '492817',
      'expires_at': '2026-11-09T06:00:31+00:00',
      'delivery': 'Booking owner shares this OTP with the confirmed referee.',
    });
    expect(otp.otp, '492817');
    expect(otp.bookingId, 2);
    expect(otp.phase, 'toss');
    expect(otp.expiresAt, '2026-11-09T06:00:31+00:00');
    expect(otp.delivery, contains('confirmed referee'));
  });

  test('serializes quote and payment requests', () {
    const request = PartnerBookingQuoteRequest(
      sportId: 1,
      bookingMethod: 'QUICK',
      bookingType: 'HOURLY',
      bookingDate: '2026-11-02',
      startTime: '10:00',
      durationMinutes: 120,
      venueName: 'Partner Arena',
      city: 'Hyderabad',
    );

    expect(request.toJson(), {
      'sport_id': 1,
      'booking_method': 'QUICK',
      'booking_type': 'HOURLY',
      'booking_date': '2026-11-02',
      'start_time': '10:00',
      'duration_minutes': 120,
      'venue_name': 'Partner Arena',
      'city': 'Hyderabad',
      'timezone': 'Asia/Kolkata',
    });

    expect(
      const PartnerBookingPaymentInitiateRequest(
        idempotencyKey: 'partner-pay-101',
      ).toJson(),
      {
        'idempotency_key': 'partner-pay-101',
        'payment_method': 'MOCK_EXTERNAL',
      },
    );
  });

  test('serializes assign-match request', () {
    expect(
      const PartnerAssignMatchRequest(
        sportFormatId: 1,
        teamIds: [2175, 2176],
      ).toJson(),
      {
        'sport_format_id': 1,
        'team_ids': [2175, 2176],
      },
    );
    expect(
      const PartnerAssignMatchRequest(matchId: 4203).toJson(),
      {'match_id': 4203},
    );
  });
}
