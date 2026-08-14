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
  static final PartnerTournamentApiEndpoints partnerTournaments =
      PartnerTournamentApiEndpoints._();
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

class PartnerTournamentApiEndpoints {
  PartnerTournamentApiEndpoints._();

  String get types => '/v1/partner/tournaments/types';
  String get sports => '/v1/partner/tournaments/sports';
  String formats(Object sportId) =>
      '/v1/partner/tournaments/sports/$sportId/formats';
  String get formConfig => '/v1/partner/tournaments/form-config';
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
}
