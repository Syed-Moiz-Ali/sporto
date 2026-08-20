import 'package:core/core.dart';

import '../models/partner_api_response_models.dart';

class PartnerRemoteDataSource {
  PartnerRemoteDataSource({SportoApiClient? apiClient})
      : _apiClient = apiClient ?? SportoApiClient();

  final SportoApiClient _apiClient;

  Future<SportoApiResponse> getProfile() {
    return _get(SportoApiEndpoints.partnerProfile.profile);
  }

  Future<PartnerProfileResponseData> getProfileData() async {
    final response = await getProfile();
    return PartnerProfileResponseData.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> saveProfile(PartnerProfileRequest request) {
    return _post(
      SportoApiEndpoints.partnerProfile.profile,
      body: request.toJson(),
    );
  }

  Future<PartnerProfileResponseData> saveProfileData(
    PartnerProfileRequest request,
  ) async {
    final response = await saveProfile(request);
    return PartnerProfileResponseData.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> updateProfile(
    PartnerProfileUpdateRequest request,
  ) {
    return _put(
      SportoApiEndpoints.partnerProfile.profile,
      body: request.toJson(),
    );
  }

  Future<PartnerProfileResponseData> updateProfileData(
    PartnerProfileUpdateRequest request,
  ) async {
    final response = await updateProfile(request);
    return PartnerProfileResponseData.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> getAvailableSports() {
    return _get(SportoApiEndpoints.partnerSports.available);
  }

  Future<List<SportMasterResponse>> getAvailableSportsData() async {
    final response = await getAvailableSports();
    return _listData(response.data).map(SportMasterResponse.fromJson).toList();
  }

  Future<SportoApiResponse> getSelectedSports() {
    return _get(SportoApiEndpoints.partnerSports.selected);
  }

  Future<List<PartnerSportResponse>> getSelectedSportsData() async {
    final response = await getSelectedSports();
    return _listData(response.data).map(PartnerSportResponse.fromJson).toList();
  }

  Future<SportoApiResponse> addSports(PartnerAddSportsRequest request) {
    return _post(
      SportoApiEndpoints.partnerSports.selected,
      body: request.toJson(),
    );
  }

  Future<List<PartnerSportResponse>> addSportsData(
    PartnerAddSportsRequest request,
  ) async {
    final response = await addSports(request);
    return _listData(response.data).map(PartnerSportResponse.fromJson).toList();
  }

  Future<SportoApiResponse> updateSport(
    Object partnerSportId,
    PartnerUpdateSportRequest request,
  ) {
    return _put(
      SportoApiEndpoints.partnerSports.byId(partnerSportId),
      body: request.toJson(),
    );
  }

  Future<SportoApiResponse> removeSport(Object partnerSportId) {
    return _delete(SportoApiEndpoints.partnerSports.byId(partnerSportId));
  }

  Future<SportoApiResponse> getDocuments() {
    return _get(SportoApiEndpoints.partnerDocuments.documents);
  }

  Future<List<PartnerDocumentResponse>> getDocumentsData() async {
    final response = await getDocuments();
    return _listData(response.data)
        .map(PartnerDocumentResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> addDocument(PartnerDocumentRequest request) {
    return _post(
      SportoApiEndpoints.partnerDocuments.documents,
      body: request.toJson(),
    );
  }

  Future<PartnerDocumentResponse> addDocumentData(
    PartnerDocumentRequest request,
  ) async {
    final response = await addDocument(request);
    return PartnerDocumentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> removeDocument(Object partnerDocumentId) {
    return _delete(
      SportoApiEndpoints.partnerDocuments.byId(partnerDocumentId),
    );
  }

  Future<SportoApiResponse> getApplication() {
    return _get(SportoApiEndpoints.partnerApplication.application);
  }

  Future<PartnerApplicationStateResponse> getApplicationData() async {
    final response = await getApplication();
    return PartnerApplicationStateResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> submitApplication(
    PartnerApplicationSubmitRequest request,
  ) {
    return _post(
      SportoApiEndpoints.partnerApplication.submit,
      body: request.toJson(),
    );
  }

  Future<PartnerApplicationSubmitResponse> submitApplicationData(
    PartnerApplicationSubmitRequest request,
  ) async {
    final response = await submitApplication(request);
    return PartnerApplicationSubmitResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> getTournamentTypes() {
    return _get(SportoApiEndpoints.partnerTournaments.types);
  }

  Future<List<TournamentTypeResponse>> getTournamentTypesData() async {
    final response = await getTournamentTypes();
    return _listData(response.data)
        .map(TournamentTypeResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> getTournamentSports() {
    return _get(SportoApiEndpoints.partnerTournaments.sports);
  }

  Future<List<SportMasterResponse>> getTournamentSportsData() async {
    final response = await getTournamentSports();
    return _listData(response.data).map(SportMasterResponse.fromJson).toList();
  }

  Future<SportoApiResponse> getTournamentFormats(Object sportId) {
    return _get(SportoApiEndpoints.partnerTournaments.formats(sportId));
  }

  Future<List<SportFormatResponse>> getTournamentFormatsData(
    Object sportId,
  ) async {
    final response = await getTournamentFormats(sportId);
    return _listData(response.data).map(SportFormatResponse.fromJson).toList();
  }

  Future<SportoApiResponse> getTournamentFormConfig({
    required int sportId,
    required int sportFormatId,
  }) {
    return _get(
      SportoApiEndpoints.partnerTournaments.formConfig,
      queryParameters: {
        'sport_id': sportId,
        'sport_format_id': sportFormatId,
      },
    );
  }

  Future<List<TournamentFormConfigFieldResponse>> getTournamentFormConfigData({
    required int sportId,
    required int sportFormatId,
  }) async {
    final response = await getTournamentFormConfig(
      sportId: sportId,
      sportFormatId: sportFormatId,
    );
    return _listData(response.data)
        .map(TournamentFormConfigFieldResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> storeTournamentDraft(
    TournamentDraftRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.drafts,
      fields: request.toJson(),
    );
  }

  Future<PartnerTournamentResponse> storeTournamentDraftData(
    TournamentDraftRequest request,
  ) async {
    final response = await storeTournamentDraft(request);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> listTournaments({
    int? status,
    String? search,
    int page = 1,
    int perPage = 50,
  }) {
    return _get(
      SportoApiEndpoints.partnerTournaments.drafts,
      queryParameters: {
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<List<PartnerTournamentResponse>> listTournamentsData({
    int? status,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await listTournaments(
      status: status,
      search: search,
      page: page,
      perPage: perPage,
    );
    // API may return { data: [...] } paginated or data directly as a list
    final raw = response.data;
    if (raw is Map) {
      // Paginated: { current_page, data: [...], total, ... }
      final inner = raw['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((item) =>
                PartnerTournamentResponse.fromJson(
                    Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return _listData(response.data)
        .map(PartnerTournamentResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> showTournament(Object tournamentId) {
    return _get(SportoApiEndpoints.partnerTournaments.byId(tournamentId));
  }

  Future<PartnerTournamentResponse> showTournamentData(
    Object tournamentId,
  ) async {
    final response = await showTournament(tournamentId);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> updateTournamentDetails(
    Object tournamentId,
    TournamentDetailsRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.byId(tournamentId),
      fields: request.toJson(),
      methodOverride: 'PUT',
    );
  }

  Future<PartnerTournamentResponse> updateTournamentDetailsData(
    Object tournamentId,
    TournamentDetailsRequest request,
  ) async {
    final response = await updateTournamentDetails(tournamentId, request);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> deleteTournament(Object tournamentId) {
    return _delete(SportoApiEndpoints.partnerTournaments.byId(tournamentId));
  }

  Future<SportoApiResponse> updateTournamentRules(
    Object tournamentId,
    TournamentRuleRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.rules(tournamentId),
      fields: {
        'rules': request.rules.map((r) => r.toJson()).toList(),
      },
      methodOverride: 'PUT',
    );
  }

  Future<PartnerTournamentResponse> updateTournamentRulesData(
    Object tournamentId,
    TournamentRuleRequest request,
  ) async {
    final response = await updateTournamentRules(tournamentId, request);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> storeTournamentVenue(
    Object tournamentId,
    TournamentVenueRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.venues(tournamentId),
      fields: request.toJson(),
    );
  }

  Future<PartnerTournamentVenueResponse> storeTournamentVenueData(
    Object tournamentId,
    TournamentVenueRequest request,
  ) async {
    final response = await storeTournamentVenue(tournamentId, request);
    return PartnerTournamentVenueResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> updateTournamentVenue(
    Object tournamentId,
    Object venueId,
    TournamentVenueRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.venueById(tournamentId, venueId),
      fields: request.toJson(),
      methodOverride: 'PUT',
    );
  }

  Future<PartnerTournamentVenueResponse> updateTournamentVenueData(
    Object tournamentId,
    Object venueId,
    TournamentVenueRequest request,
  ) async {
    final response =
        await updateTournamentVenue(tournamentId, venueId, request);
    return PartnerTournamentVenueResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> removeTournamentVenue(
    Object tournamentId,
    Object venueId,
  ) {
    return _delete(
      SportoApiEndpoints.partnerTournaments.venueById(tournamentId, venueId),
    );
  }

  Future<SportoApiResponse> updateTournamentBudget(
    Object tournamentId,
    TournamentBudgetRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.budget(tournamentId),
      fields: {
        'registration_fee': request.registrationFee,
        'currency': request.currency,
        'prizes': request.prizes.map((p) => p.toJson()).toList(),
        'sponsors': request.sponsors.map((s) => s.toJson()).toList(),
      },
      methodOverride: 'PUT',
    );
  }

  Future<PartnerTournamentResponse> updateTournamentBudgetData(
    Object tournamentId,
    TournamentBudgetRequest request,
  ) async {
    final response = await updateTournamentBudget(tournamentId, request);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> reviewTournament(Object tournamentId) {
    return _get(SportoApiEndpoints.partnerTournaments.review(tournamentId));
  }

  Future<PartnerTournamentReviewData> reviewTournamentData(
    Object tournamentId,
  ) async {
    final response = await reviewTournament(tournamentId);
    return PartnerTournamentReviewData.fromJson(_mapData(response.data));
  }


  Future<SportoApiResponse> submitTournament(
    Object tournamentId,
    TournamentSubmitRequest request,
  ) {
    return _postForm(
      SportoApiEndpoints.partnerTournaments.submit(tournamentId),
      fields: request.toJson(),
    );
  }

  Future<PartnerTournamentResponse> submitTournamentData(
    Object tournamentId,
    TournamentSubmitRequest request,
  ) async {
    final response = await submitTournament(tournamentId, request);
    return PartnerTournamentResponse.fromJson(_mapData(response.data));
  }

  Future<SportoApiResponse> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _parse(await _apiClient.getJson(
      path,
      queryParameters: queryParameters,
    ));
  }

  Future<SportoApiResponse> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _parse(await _apiClient.postJson(path, body: body));
  }

  Future<SportoApiResponse> _postForm(
    String path, {
    required Map<String, dynamic> fields,
    String? methodOverride,
  }) async {
    return _parse(await _apiClient.postForm(
      path,
      fields: fields,
      methodOverride: methodOverride,
    ));
  }

  Future<SportoApiResponse> _put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _parse(await _apiClient.putJson(path, body: body));
  }

  Future<SportoApiResponse> _delete(String path) async {
    return _parse(await _apiClient.deleteJson(path));
  }

  SportoApiResponse _parse(Map<String, dynamic> json) {
    return SportoApiResponse.fromJson(json);
  }

  Map<String, dynamic> _mapData(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _listData(Object? data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
