int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList()
    : const [];

class PartnerBookingPrice {
  const PartnerBookingPrice({
    this.refereeFee,
    this.platformFee,
    this.totalAmount,
    this.currency,
    this.bookingType,
    this.bookingDate,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.durationMinutes,
    this.timezone,
    this.pricingSnapshot = const {},
  });

  final String? refereeFee;
  final String? platformFee;
  final String? totalAmount;
  final String? currency;
  final String? bookingType;
  final String? bookingDate;
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final int? durationMinutes;
  final String? timezone;
  final Map<String, dynamic> pricingSnapshot;

  factory PartnerBookingPrice.fromJson(Map<String, dynamic> json) =>
      PartnerBookingPrice(
        refereeFee: _text(json['referee_fee']),
        platformFee: _text(json['platform_fee']),
        totalAmount: _text(json['total_amount']),
        currency: _text(json['currency']),
        bookingType: _text(json['booking_type']),
        bookingDate: _text(json['booking_date']),
        scheduledStartAt: _text(json['scheduled_start_at']),
        scheduledEndAt: _text(json['scheduled_end_at']),
        durationMinutes: _int(json['duration_minutes']),
        timezone: _text(json['timezone']),
        pricingSnapshot: _map(json['pricing_snapshot']),
      );
}

class PartnerAvailableRefereeSport {
  const PartnerAvailableRefereeSport({required this.id, required this.name});

  final int id;
  final String name;

  factory PartnerAvailableRefereeSport.fromJson(Map<String, dynamic> json) =>
      PartnerAvailableRefereeSport(
        id: _int(json['id']) ?? 0,
        name: _text(json['name']) ?? 'Sport',
      );
}

class PartnerAvailableReferee {
  const PartnerAvailableReferee({
    required this.refereeId,
    required this.displayName,
    this.profilePhoto,
    this.sports = const [],
    this.experienceYears,
    this.preferredCity,
    this.distanceKm,
    this.locationBasis,
    this.available = false,
    this.price = const PartnerBookingPrice(),
    this.unitAmount,
    this.rateScope,
    this.reviewsCount,
    this.ratingAverage,
    this.matchesHandledCount,
    this.eligibilityExplanation,
    this.lastAssignedAt,
  });

  final int refereeId;
  final String displayName;
  final String? profilePhoto;
  final List<PartnerAvailableRefereeSport> sports;
  final int? experienceYears;
  final String? preferredCity;
  final double? distanceKm;
  final String? locationBasis;
  final bool available;
  final PartnerBookingPrice price;
  final String? unitAmount;
  final String? rateScope;
  final int? reviewsCount;
  final double? ratingAverage;
  final int? matchesHandledCount;
  final String? eligibilityExplanation;
  final String? lastAssignedAt;

  factory PartnerAvailableReferee.fromJson(Map<String, dynamic> json) =>
      PartnerAvailableReferee(
        refereeId: _int(json['referee_id'] ?? json['id']) ?? 0,
        displayName: _text(json['display_name'] ?? json['name']) ?? 'Referee',
        profilePhoto: _text(json['profile_photo'] ?? json['profile_photo_url']),
        sports: _list(json['sports'])
            .map(PartnerAvailableRefereeSport.fromJson)
            .toList(),
        experienceYears: _int(json['experience_years']),
        preferredCity: _text(json['preferred_city']),
        distanceKm: _double(json['distance_km']),
        locationBasis: _text(json['location_basis']),
        available: json['available'] == true,
        price: PartnerBookingPrice.fromJson(_map(json['price'])),
        unitAmount: _text(json['unit_amount']),
        rateScope: _text(json['rate_scope']),
        reviewsCount: _int(json['reviews_count']),
        ratingAverage: _double(json['rating_average']),
        matchesHandledCount: _int(json['matches_handled_count']),
        eligibilityExplanation: _text(json['eligibility_explanation']),
        lastAssignedAt: _text(json['last_assigned_at']),
      );
}

class PartnerAvailableRefereesPage {
  const PartnerAvailableRefereesPage({
    this.currentPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.items = const [],
  });

  final int currentPage;
  final int perPage;
  final int total;
  final List<PartnerAvailableReferee> items;

  factory PartnerAvailableRefereesPage.fromJson(Map<String, dynamic> json) =>
      PartnerAvailableRefereesPage(
        currentPage: _int(json['current_page']) ?? 1,
        perPage: _int(json['per_page']) ?? 20,
        total: _int(json['total']) ?? 0,
        items:
            _list(json['data']).map(PartnerAvailableReferee.fromJson).toList(),
      );
}

class PartnerBookingQuote {
  const PartnerBookingQuote({
    this.refereeFee,
    this.platformFee,
    this.totalAmount,
    this.currency,
    this.durationMinutes,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.timezone,
    this.bookingDate,
    this.bookingType,
    this.eligibleRefereesCount,
    this.pricingSnapshot = const {},
  });

  final String? refereeFee;
  final String? platformFee;
  final String? totalAmount;
  final String? currency;
  final int? durationMinutes;
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final String? timezone;
  final String? bookingDate;
  final String? bookingType;
  final int? eligibleRefereesCount;
  final Map<String, dynamic> pricingSnapshot;

  factory PartnerBookingQuote.fromJson(Map<String, dynamic> json) =>
      PartnerBookingQuote(
        refereeFee: _text(json['referee_fee']),
        platformFee: _text(json['platform_fee']),
        totalAmount: _text(json['total_amount']),
        currency: _text(json['currency']),
        durationMinutes: _int(json['duration_minutes']),
        scheduledStartAt: _text(json['scheduled_start_at']),
        scheduledEndAt: _text(json['scheduled_end_at']),
        timezone: _text(json['timezone']),
        bookingDate: _text(json['booking_date']),
        bookingType: _text(json['booking_type']),
        eligibleRefereesCount: _int(json['eligible_referees_count']),
        pricingSnapshot: _map(json['pricing_snapshot']),
      );
}

class PartnerBooking {
  const PartnerBooking({
    required this.id,
    this.uuid,
    this.bookingNumber,
    this.bookingSource,
    this.bookingMethod,
    this.partnerProfileId,
    this.totalAmount,
    this.currency,
    this.paymentStatus,
    this.bookingStatus,
    this.displayStatus,
    this.cancellationReason,
    this.raw = const {},
  });

  final int id;
  final String? uuid;
  final String? bookingNumber;
  final String? bookingSource;
  final String? bookingMethod;
  final int? partnerProfileId;
  final String? totalAmount;
  final String? currency;
  final String? paymentStatus;
  final String? bookingStatus;
  final String? displayStatus;
  final String? cancellationReason;
  final Map<String, dynamic> raw;

  bool get isPendingPayment =>
      (bookingStatus ?? displayStatus) == 'PENDING_PAYMENT';

  factory PartnerBooking.fromJson(Map<String, dynamic> json) => PartnerBooking(
        id: _int(json['id'] ?? json['booking_id']) ?? 0,
        uuid: _text(json['uuid']),
        bookingNumber: _text(json['booking_number']),
        bookingSource: _text(json['booking_source']),
        bookingMethod: _text(json['booking_method']),
        partnerProfileId: _int(json['partner_profile_id']),
        totalAmount: _text(json['total_amount']),
        currency: _text(json['currency']),
        paymentStatus: _text(json['payment_status']),
        bookingStatus: _text(json['booking_status']),
        displayStatus: _text(json['display_status']),
        cancellationReason: _text(json['cancellation_reason']),
        raw: Map<String, dynamic>.from(json),
      );
}

class PartnerBookingCounts {
  const PartnerBookingCounts({
    this.all = 0,
    this.upcoming = 0,
    this.ongoing = 0,
    this.completed = 0,
    this.cancelled = 0,
  });

  final int all;
  final int upcoming;
  final int ongoing;
  final int completed;
  final int cancelled;

  factory PartnerBookingCounts.fromJson(Map<String, dynamic> json) =>
      PartnerBookingCounts(
        all: _int(json['all']) ?? 0,
        upcoming: _int(json['upcoming']) ?? 0,
        ongoing: _int(json['ongoing']) ?? 0,
        completed: _int(json['completed']) ?? 0,
        cancelled: _int(json['cancelled']) ?? 0,
      );
}

class PartnerBookingPage {
  const PartnerBookingPage({
    this.currentPage = 1,
    this.total = 0,
    this.items = const [],
    this.counts = const PartnerBookingCounts(),
  });

  final int currentPage;
  final int total;
  final List<PartnerBooking> items;
  final PartnerBookingCounts counts;

  factory PartnerBookingPage.fromJson(Map<String, dynamic> json) =>
      PartnerBookingPage(
        currentPage: _int(json['current_page']) ?? 1,
        total: _int(json['total']) ?? 0,
        items: _list(json['data']).map(PartnerBooking.fromJson).toList(),
        counts: PartnerBookingCounts.fromJson(_map(json['counts'])),
      );
}

class PartnerBookingPayment {
  const PartnerBookingPayment({
    this.id,
    this.paymentStatus,
    this.gatewayPaymentId,
    this.gatewayTransactionId,
  });

  final int? id;
  final String? paymentStatus;
  final String? gatewayPaymentId;
  final String? gatewayTransactionId;

  factory PartnerBookingPayment.fromJson(Map<String, dynamic> json) =>
      PartnerBookingPayment(
        id: _int(json['id']),
        paymentStatus: _text(json['payment_status']),
        gatewayPaymentId: _text(json['gateway_payment_id']),
        gatewayTransactionId: _text(json['gateway_transaction_id']),
      );
}

class PartnerBookingPaymentResult {
  const PartnerBookingPaymentResult({
    this.mode,
    this.payment = const PartnerBookingPayment(),
    this.bookingStatus,
  });

  final String? mode;
  final PartnerBookingPayment payment;
  final String? bookingStatus;

  factory PartnerBookingPaymentResult.fromJson(Map<String, dynamic> json) =>
      PartnerBookingPaymentResult(
        mode: _text(json['mode']),
        payment: PartnerBookingPayment.fromJson(_map(json['payment'])),
        bookingStatus: _text(_map(json['booking'])['booking_status']),
      );
}

class PartnerBookingPaymentPage {
  const PartnerBookingPaymentPage({
    this.currentPage = 1,
    this.total = 0,
    this.items = const [],
  });

  final int currentPage;
  final int total;
  final List<PartnerBookingPayment> items;

  factory PartnerBookingPaymentPage.fromJson(Map<String, dynamic> json) =>
      PartnerBookingPaymentPage(
        currentPage: _int(json['current_page']) ?? 1,
        total: _int(json['total']) ?? 0,
        items: _list(json['data']).map(PartnerBookingPayment.fromJson).toList(),
      );
}

class PartnerBookingSessionOtp {
  const PartnerBookingSessionOtp({
    required this.otp,
    this.expiresInSeconds,
    this.bookingId,
    this.phase,
    this.expiresAt,
    this.delivery,
  });

  final String otp;
  final int? expiresInSeconds;
  final int? bookingId;
  final String? phase;
  final String? expiresAt;
  final String? delivery;

  factory PartnerBookingSessionOtp.fromJson(Map<String, dynamic> json) =>
      PartnerBookingSessionOtp(
        otp: _text(json['otp']) ?? '',
        expiresInSeconds: _int(json['expires_in_seconds']),
        bookingId: _int(json['booking_id']),
        phase: _text(json['phase']),
        expiresAt: _text(json['expires_at']),
        delivery: _text(json['delivery']),
      );
}

class PartnerBookingQuoteRequest {
  const PartnerBookingQuoteRequest({
    required this.sportId,
    required this.bookingMethod,
    required this.bookingType,
    required this.bookingDate,
    required this.startTime,
    required this.durationMinutes,
    required this.venueName,
    required this.city,
    this.timezone = 'Asia/Kolkata',
    this.refereeId,
  });

  final int sportId;
  final String bookingMethod;
  final String bookingType;
  final String bookingDate;
  final String startTime;
  final int durationMinutes;
  final String venueName;
  final String city;
  final String timezone;
  final int? refereeId;

  Map<String, dynamic> toJson() => {
        'sport_id': sportId,
        'booking_method': bookingMethod,
        'booking_type': bookingType,
        'booking_date': bookingDate,
        'start_time': startTime,
        'duration_minutes': durationMinutes,
        'venue_name': venueName,
        'city': city,
        'timezone': timezone,
        if (refereeId != null) 'referee_id': refereeId,
      };
}

class PartnerBookingCreateRequest extends PartnerBookingQuoteRequest {
  const PartnerBookingCreateRequest({
    required super.sportId,
    required super.bookingMethod,
    required super.bookingType,
    required super.bookingDate,
    required super.startTime,
    required super.durationMinutes,
    required super.venueName,
    required super.city,
    super.timezone,
    super.refereeId,
  });
}

class PartnerBookingCancelRequest {
  const PartnerBookingCancelRequest({required this.reason});

  final String reason;

  Map<String, dynamic> toJson() => {'reason': reason};
}

class PartnerBookingPaymentInitiateRequest {
  const PartnerBookingPaymentInitiateRequest({
    required this.idempotencyKey,
    this.paymentMethod = 'MOCK_EXTERNAL',
  });

  final String idempotencyKey;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
        'idempotency_key': idempotencyKey,
        'payment_method': paymentMethod,
      };
}

class PartnerAssignMatchRequest {
  const PartnerAssignMatchRequest({
    this.matchId,
    this.sportFormatId,
    this.teamIds = const [],
  });

  final int? matchId;
  final int? sportFormatId;
  final List<int> teamIds;

  Map<String, dynamic> toJson() => {
        if (matchId != null) 'match_id': matchId,
        if (sportFormatId != null) 'sport_format_id': sportFormatId,
        if (teamIds.isNotEmpty) 'team_ids': teamIds,
      };
}

class PartnerBookingPaymentVerifyRequest {
  const PartnerBookingPaymentVerifyRequest({
    required this.paymentId,
    required this.transactionId,
  });

  final String paymentId;
  final String transactionId;

  Map<String, dynamic> toJson() => {
        'payment_id': paymentId,
        'transaction_id': transactionId,
      };
}
