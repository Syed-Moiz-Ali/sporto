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
  static final RefereeMatchApiEndpoints refereeMatches =
      RefereeMatchApiEndpoints._();
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

class RefereeMatchApiEndpoints {
  RefereeMatchApiEndpoints._();

  String get matchRequests => '/v1/referee/match-requests';
  String acceptMatchRequest(Object requestId) =>
      '/v1/referee/match-requests/$requestId/accept';
  String rejectMatchRequest(Object requestId) =>
      '/v1/referee/match-requests/$requestId/reject';
  String get matches => '/v1/referee/matches';
  String matchById(Object matchId) => '/v1/referee/matches/$matchId';
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
}
