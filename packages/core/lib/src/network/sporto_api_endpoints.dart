enum SportoAppRole {
  partner('partner'),
  referee('referee');

  const SportoAppRole(this.path);

  final String path;
}

class SportoApiEndpoints {
  SportoApiEndpoints._();

  static const String apiBaseUrl = 'https://app.spotoapp.in/api';

  static AuthApiEndpoints auth(SportoAppRole role) => AuthApiEndpoints(role);

  static const partnerDashboard = '/v1/partner/dashboard';

  static final CommonApiEndpoints common = CommonApiEndpoints._();
  static final PartnerProfileApiEndpoints partnerProfile =
      PartnerProfileApiEndpoints._();
  static final PartnerSportsApiEndpoints partnerSports =
      PartnerSportsApiEndpoints._();
  static final PartnerDocumentsApiEndpoints partnerDocuments =
      PartnerDocumentsApiEndpoints._();
  static final PartnerApplicationApiEndpoints partnerApplication =
      PartnerApplicationApiEndpoints._();
  static final PartnerRefereeApiEndpoints partnerReferees =
      PartnerRefereeApiEndpoints._();
  static final PartnerTournamentApiEndpoints partnerTournaments =
      PartnerTournamentApiEndpoints._();
  static final RefereeApplicationApiEndpoints refereeApplication =
      RefereeApplicationApiEndpoints._();
  static final RefereeProfileApiEndpoints refereeProfile =
      RefereeProfileApiEndpoints._();
  static final RefereeMatchApiEndpoints refereeMatches =
      RefereeMatchApiEndpoints._();
  static final RefereeAvailabilityApiEndpoints refereeAvailability =
      RefereeAvailabilityApiEndpoints._();
  static final RefereeBookingApiEndpoints refereeBookings =
      RefereeBookingApiEndpoints._();
  static final PartnerRefereeBookingApiEndpoints partnerRefereeBookings =
      PartnerRefereeBookingApiEndpoints._();
}

class RefereeApplicationApiEndpoints {
  RefereeApplicationApiEndpoints._();

  String get application => '/v1/referee/application';
  String get personal => '/v1/referee/application/personal';
  String get address => '/v1/referee/application/address';
  String get sports => '/v1/referee/application/sports';
  String get availability => '/v1/referee/application/availability';
  String get documents => '/v1/referee/application/documents';
  String document(Object documentId) =>
      '/v1/referee/application/documents/$documentId';
  String get review => '/v1/referee/application/review';
  String get submit => '/v1/referee/application/submit';
  String get status => '/v1/referee/application/status';
}

class RefereeProfileApiEndpoints {
  RefereeProfileApiEndpoints._();
  String get profile => '/v1/referee/profile';
}

class RefereeMatchApiEndpoints {
  RefereeMatchApiEndpoints._();

  String get matchRequests => '/v1/referee/match-requests';
  String acceptMatchRequest(Object requestId) =>
      '/v1/referee/match-requests/$requestId/accept';
  String rejectMatchRequest(Object requestId) =>
      '/v1/referee/match-requests/$requestId/reject';
  String get matches => '/v1/referee/matches';
  String matchById(Object matchId) => '/v1/referee/matches/$matchId';
  String toss(Object matchId) => '/v1/referee/matches/$matchId/toss';
  String score(Object matchId) => '/v1/referee/matches/$matchId/score';
  String scoreEvents(Object matchId) =>
      '/v1/referee/matches/$matchId/score/events';
  String scorecard(Object matchId) => '/v1/referee/matches/$matchId/scorecard';
  String session(Object matchId) => '/v1/referee/matches/$matchId/session';
  String verify(Object matchId) => '/v1/referee/matches/$matchId/verify';
  String sessionStart(Object matchId) =>
      '/v1/referee/matches/$matchId/session/start';
  String sessionEnd(Object matchId) =>
      '/v1/referee/matches/$matchId/session/end';
  String sessionWithdraw(Object matchId) =>
      '/v1/referee/matches/$matchId/session/withdraw';
  String status(Object matchId) => '/v1/referee/matches/$matchId/status';
  String result(Object matchId) => '/v1/referee/matches/$matchId/result';
}

class RefereeAvailabilityApiEndpoints {
  RefereeAvailabilityApiEndpoints._();

  String get days => '/v1/referee/availability/days';
  String get slots => '/v1/referee/availability';
  String get status => '/v1/referee/availability/status';
  String slot(Object slotId) => '/v1/referee/availability/$slotId';
  String day(Object day) => '/v1/referee/availability/days/$day';
}

class RefereeBookingApiEndpoints {
  RefereeBookingApiEndpoints._();

  String get requests => '/v1/referee/bookings/requests';
  String request(Object assignmentId) =>
      '/v1/referee/bookings/requests/$assignmentId';
  String accept(Object assignmentId) =>
      '/v1/referee/bookings/requests/$assignmentId/accept';
  String reject(Object assignmentId) =>
      '/v1/referee/bookings/requests/$assignmentId/reject';
  String get bookings => '/v1/referee/bookings';
  String booking(Object bookingId) => '/v1/referee/bookings/$bookingId';
  String session(Object bookingId) => '/v1/referee/bookings/$bookingId/session';
  String verifyToss(Object bookingId) =>
      '/v1/referee/bookings/$bookingId/session/toss/verify';
  String verifyStart(Object bookingId) =>
      '/v1/referee/bookings/$bookingId/session/start/verify';
  String verifyEnd(Object bookingId) =>
      '/v1/referee/bookings/$bookingId/session/end/verify';
}

class PartnerRefereeBookingApiEndpoints {
  PartnerRefereeBookingApiEndpoints._();

  String get bookings => '/v1/partner/referee-bookings';
  String get quote => '/v1/partner/referee-bookings/quote';
  String get discoverReferees => '/v1/partner/referee-bookings/referees';
  String referee(Object refereeId) =>
      '/v1/partner/referee-bookings/referees/$refereeId';
  String get lastAssigned => '/v1/partner/referee-bookings/last-assigned';
  String booking(Object bookingId) => '/v1/partner/referee-bookings/$bookingId';
  String cancel(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/cancel';
  String initiatePayment(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/payment/initiate';
  String verifyPayment(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/payment/verify';
  String payments(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/payments';
  String sessionOtp(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/session/otp';
  String assignMatch(Object bookingId) =>
      '/v1/partner/referee-bookings/$bookingId/assign-match';
}

class CommonApiEndpoints {
  CommonApiEndpoints._();

  String get upload => '/v1/common/upload';
}

class AuthApiEndpoints {
  const AuthApiEndpoints(this.role);

  final SportoAppRole role;

  String get sendOtp => '/v1/${role.path}/send-otp';
  String get verifyOtp => '/v1/${role.path}/verify-otp';
  String get logout => '/v1/${role.path}/logout';
}

class PartnerProfileApiEndpoints {
  PartnerProfileApiEndpoints._();

  String get profile => '/v1/partner/profile';
}

class PartnerSportsApiEndpoints {
  PartnerSportsApiEndpoints._();

  String get available => '/v1/partner/sports/available';
  String get selected => '/v1/partner/sports';
  String byId(Object partnerSportId) => '/v1/partner/sports/$partnerSportId';
}

class PartnerDocumentsApiEndpoints {
  PartnerDocumentsApiEndpoints._();

  String get documents => '/v1/partner/documents';
  String byId(Object partnerDocumentId) =>
      '/v1/partner/documents/$partnerDocumentId';
}

class PartnerApplicationApiEndpoints {
  PartnerApplicationApiEndpoints._();

  String get application => '/v1/partner/application';
  String get submit => '/v1/partner/submit';
}

class PartnerRefereeApiEndpoints {
  PartnerRefereeApiEndpoints._();

  String get referees => '/v1/partner/referees';
}

class PartnerTournamentApiEndpoints {
  PartnerTournamentApiEndpoints._();

  String get types => '/v1/partner/tournaments/types';
  String get sports => '/v1/partner/tournaments/sports';
  String formats(Object sportId) =>
      '/v1/partner/tournaments/sports/$sportId/formats';
  String get formConfig => '/v1/partner/tournaments/form-config';
  String get prizeCategories => '/v1/partner/tournaments/prize-categories';
  String get drafts => '/v1/partner/tournaments/';
  String byId(Object tournamentId) => '/v1/partner/tournaments/$tournamentId';
  String rules(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/rules';
  String venues(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/venues';
  String venueById(Object tournamentId, Object venueId) =>
      '/v1/partner/tournaments/$tournamentId/venues/$venueId';
  String budget(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/budget';
  String review(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/review';
  String submit(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/submit';
  String matches(Object tournamentId) =>
      '/v1/partner/tournaments/$tournamentId/matches';
  String matchById(Object tournamentId, Object matchId) =>
      '/v1/partner/tournaments/$tournamentId/matches/$matchId';
  // NOTE: Postman still lists `/tournaments/{id}/matches/referees`, but the
  // live backend currently routes that through `{matchId}` and returns 500.
  // Backend-provided working route for eligible/listable referees:
  // `/v1/partner/referees`.
  String eligibleReferees(Object tournamentId) => '/v1/partner/referees';
  String matchReferees(Object tournamentId, Object matchId) =>
      '/v1/partner/tournaments/$tournamentId/matches/$matchId/referees';
  String matchRefereeAssignment(
    Object tournamentId,
    Object matchId,
    Object assignmentId,
  ) =>
      '/v1/partner/tournaments/$tournamentId/matches/$matchId/referees/$assignmentId';
  String matchSessionOtp(Object tournamentId, Object matchId) =>
      '/v1/partner/tournaments/$tournamentId/matches/$matchId/session/otp';
}
