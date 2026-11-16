import 'package:core/core.dart';

import '../models/referee_api_models.dart';

class RefereeRemoteDataSource {
  RefereeRemoteDataSource({SportoApiClient? apiClient})
      : _apiClient = apiClient ?? SportoApiClient();

  final SportoApiClient _apiClient;

  Future<RefereeProfileResponse> getProfile() async {
    final response = await _get(SportoApiEndpoints.refereeProfile.profile);
    final data = response.data;
    if (data is! Map)
      throw const SportoApiException('Profile response data is invalid.');
    return RefereeProfileResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<RefereeDashboardResponse> getDashboardData() async {
    final response = await _get(SportoApiEndpoints.dashboard.dashboard);
    return _dashboardFromData(response.data);
  }

  Future<RefereeWalletSummary> getWalletData() async {
    final response = await _get(SportoApiEndpoints.dashboard.wallet);
    return _walletFromData(response.data);
  }

  Future<RefereeEarningsPage> listEarningsData({
    String status = 'all',
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _get(
      SportoApiEndpoints.dashboard.earnings,
      queryParameters: {
        'status': status,
        'page': page,
        'per_page': perPage,
      },
    );
    return _earningsPageFromData(response.data);
  }

  Future<RefereeStatistics> getStatisticsData() async {
    final response = await _get(SportoApiEndpoints.dashboard.statistics);
    return _statisticsFromData(response.data);
  }

  Future<RefereeTournamentHistoryPage> listTournamentsData({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _get(
      SportoApiEndpoints.dashboard.tournaments,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return _tournamentsPageFromData(response.data);
  }

  Future<RefereeWalletTransactionsPage> listWalletTransactionsData({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _get(
      SportoApiEndpoints.dashboard.walletTransactions,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return _walletTransactionsPageFromData(response.data);
  }

  /// Loads both pending tournament assignments and booking invitations.
  ///
  /// One failing endpoint is tolerated. When both lists are empty (or both
  /// calls failed) the request is retried once after [retryDelay]. If both
  /// calls still fail, a [SportoApiException] is thrown so callers never treat
  /// a total network failure as an empty inbox.
  Future<RefereeIncomingRequestsBundle> listIncomingRequestsData({
    bool retryOnEmpty = true,
    Duration retryDelay = const Duration(milliseconds: 1500),
  }) async {
    var result = await _loadIncomingRequests();
    final shouldRetry =
        retryOnEmpty && (result.bothFailed || result.bothSucceededAndEmpty);
    if (shouldRetry) {
      await Future<void>.delayed(retryDelay);
      result = await _loadIncomingRequests();
    }
    if (result.bothFailed) {
      throw const SportoApiException(
        'Unable to load referee incoming requests: both match-requests and '
        'booking-requests failed.',
      );
    }
    return RefereeIncomingRequestsBundle(
      matchRequests: result.matchRequests ?? const [],
      bookingRequests: result.bookingRequests ?? const [],
    );
  }

  Future<List<RefereeBankDetails>> listBankDetailsData() async {
    final response = await _get(SportoApiEndpoints.bank.list);
    final data = response.data;
    if (data == null) return const [];
    final list = _listOrPaginatedData(data);
    if (list.isNotEmpty) {
      return list.map(RefereeBankDetails.fromJson).toList();
    }
    if (data is Map && (data.containsKey('id') || data.containsKey('type'))) {
      return [
        RefereeBankDetails.fromJson(Map<String, dynamic>.from(data)),
      ];
    }
    return const [];
  }

  Future<RefereeBankDetails> addBankDetails(
    RefereeBankDetailsRequest request, {
    RefereeBankDetails? fallback,
  }) async {
    final response = await _post(
      SportoApiEndpoints.bank.add,
      request.toJson(),
    );
    return _bankDetailsFromData(
      response.data,
      fallback: fallback,
      errorMessage: 'Bank details response data is invalid.',
    );
  }

  Future<RefereeBankDetails> updateBankDetails(
    Object bankDetailId,
    RefereeBankDetailsRequest request,
  ) async {
    final response = await _put(
      SportoApiEndpoints.bank.update(bankDetailId),
      request.toJson(),
    );
    return _bankDetailsFromData(
      response.data,
      errorMessage: 'Updated bank details response data is invalid.',
    );
  }

  Future<void> setDefaultBank(Object bankDetailId) async {
    await _post(
      SportoApiEndpoints.bank.setDefault(bankDetailId),
      const {},
    );
  }

  Future<void> deleteBankDetails(Object bankDetailId) async {
    await _delete(SportoApiEndpoints.bank.delete(bankDetailId));
  }

  Future<RefereePlayerOfMatch?> awardPlayerOfMatch(
    Object matchId, {
    required int playerUserId,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeMatches.playerOfMatch(matchId),
      {'player_user_id': playerUserId},
    );
    final data = response.data;
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final raw = map['player_of_match'];
    if (raw is Map) {
      return RefereePlayerOfMatch.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
    if (map.containsKey('user_id') || map.containsKey('name')) {
      return RefereePlayerOfMatch.fromJson(map);
    }
    return null;
  }

  Future<RefereeCommentaryPage> getMatchCommentaryData(
    Object matchId, {
    String order = 'desc',
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.commentary(matchId),
      queryParameters: {
        'order': order,
        'page': page,
        'per_page': perPage,
      },
    );
    return _commentaryPageFromData(response.data);
  }

  Future<RefereeMatchGraphsResponse> getMatchGraphsData(
    Object matchId, {
    bool includeSuperOvers = false,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.graphs(matchId),
      queryParameters: {
        'include_super_overs': includeSuperOvers ? 1 : 0,
      },
    );
    return _graphsFromData(response.data);
  }

  Future<RefereeLeaderboardResponse> getMatchLeaderboardData(
    Object matchId,
    String category, {
    int? limit,
    bool includeSuperOvers = false,
    String? qualification,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.leaderboard(matchId, category),
      queryParameters: {
        if (limit != null) 'limit': limit,
        'include_super_overs': includeSuperOvers ? 1 : 0,
        if (qualification != null && qualification.trim().isNotEmpty)
          'qualification': qualification.trim(),
      },
    );
    return _leaderboardFromData(response.data);
  }

  Future<RefereeApplicationResponse?> getApplicationData() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.application,
    );
    return _applicationFromData(response.data);
  }

  Future<void> savePersonal(RefereePersonalRequest request) async {
    await _post(
      SportoApiEndpoints.refereeApplication.personal,
      request.toJson(),
    );
  }

  Future<void> saveAddress(RefereeAddressRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.address,
      request.toJson(),
    );
  }

  Future<void> saveSports(RefereeSportsRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.sports,
      request.toJson(),
    );
  }

  Future<void> saveAvailability(RefereeAvailabilityRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.availability,
      request.toJson(),
    );
  }

  Future<List<RefereeWeekday>> listAvailabilityDays() async {
    final response = await _get(
      SportoApiEndpoints.refereeAvailability.days,
    );
    return _listOrPaginatedData(response.data)
        .map(RefereeWeekday.fromJson)
        .toList();
  }

  Future<RefereeWeeklyAvailability> getWeeklyAvailability({String? day}) async {
    final response = await _get(
      SportoApiEndpoints.refereeAvailability.slots,
      queryParameters: {
        if (day != null && day.trim().isNotEmpty) 'day': day.trim(),
      },
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Weekly availability response data is invalid.',
      );
    }
    return RefereeWeeklyAvailability.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<RefereeAvailabilitySlot> createAvailabilitySlot(
    RefereeAvailabilitySlotRequest request,
  ) async {
    final response = await _post(
      SportoApiEndpoints.refereeAvailability.slots,
      request.toJson(),
    );
    return _slotFromData(response.data);
  }

  Future<RefereeAvailabilitySlot> updateAvailabilitySlot(
    Object slotId,
    RefereeAvailabilitySlotRequest request,
  ) async {
    final response = await _put(
      SportoApiEndpoints.refereeAvailability.slot(slotId),
      request.toJson(),
    );
    return _slotFromData(response.data);
  }

  Future<void> deleteAvailabilitySlot(Object slotId) async {
    await _delete(
      SportoApiEndpoints.refereeAvailability.slot(slotId),
    );
  }

  Future<RefereeAvailabilityClearResult> clearAvailabilityDay(
    Object day,
  ) async {
    final response = await _delete(
      SportoApiEndpoints.refereeAvailability.day(day),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Cleared availability response data is invalid.',
      );
    }
    return RefereeAvailabilityClearResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<RefereeAvailabilityStatusResponse> getAvailabilityStatus() async {
    final response = await _get(SportoApiEndpoints.refereeAvailability.status);
    return _availabilityStatusFromData(response.data);
  }

  Future<RefereeAvailabilityStatusResponse> updateAvailabilityStatus(
    bool isAvailable,
  ) async {
    final response = await _put(
      SportoApiEndpoints.refereeAvailability.status,
      RefereeAvailabilityStatusRequest(isAvailable: isAvailable).toJson(),
    );
    return _availabilityStatusFromData(response.data);
  }

  Future<RefereeAvailabilityDay> toggleAvailabilityDay(
    Object day, {
    required bool isEnabled,
  }) async {
    final response = await _put(
      SportoApiEndpoints.refereeAvailability.day(day),
      RefereeAvailabilityDayRequest(isEnabled: isEnabled).toJson(),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Weekday availability response data is invalid.',
      );
    }
    return RefereeAvailabilityDay.fromJson(Map<String, dynamic>.from(data));
  }

  Future<RefereeAvailabilitySlot> patchAvailabilitySlot(
    Object slotId,
    RefereeAvailabilitySlotPatch patch,
  ) async {
    final response = await _put(
      SportoApiEndpoints.refereeAvailability.slot(slotId),
      patch.toJson(),
    );
    return _slotFromData(response.data);
  }

  Future<RefereeDocument> addDocument(RefereeDocumentRequest request) async {
    final response = await _post(
      SportoApiEndpoints.refereeApplication.documents,
      request.toJson(),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Document response data is invalid.');
    }
    final json = Map<String, dynamic>.from(data);
    return RefereeDocument.fromJson({
      ...json,
      'type': request.type,
    });
  }

  Future<void> deleteDocument(Object documentId) async {
    await _delete(
      SportoApiEndpoints.refereeApplication.document(documentId),
    );
  }

  Future<RefereeApplicationResponse?> reviewApplication() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.review,
    );
    return _applicationFromData(response.data);
  }

  Future<void> submitApplication() async {
    await _post(
      SportoApiEndpoints.refereeApplication.submit,
      const {},
    );
  }

  Future<RefereeApplicationStatusResponse> getApplicationStatus() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.status,
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Application status response data is invalid.',
      );
    }
    return RefereeApplicationStatusResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<SportoApiResponse> listMatchRequests({
    int page = 1,
    int perPage = 20,
  }) {
    return _get(
      SportoApiEndpoints.refereeMatches.matchRequests,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<List<RefereeMatchRequestResponse>> listMatchRequestsData({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await listMatchRequests(page: page, perPage: perPage);
    return _listOrPaginatedData(response.data)
        .map(RefereeMatchRequestResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> acceptMatchRequest(Object requestId) {
    return _post(
      SportoApiEndpoints.refereeMatches.acceptMatchRequest(requestId),
      const {},
    );
  }

  Future<SportoApiResponse> rejectMatchRequest(
    Object requestId, {
    String? reason,
  }) {
    return _post(
      SportoApiEndpoints.refereeMatches.rejectMatchRequest(requestId),
      {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<List<RefereeMatchRequestResponse>> listBookingRequestsData({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeBookings.requests,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return _listOrPaginatedData(response.data)
        .map(RefereeMatchRequestResponse.fromBookingRequestJson)
        .toList();
  }

  Future<RefereeMatchRequestResponse> getBookingRequestData(
    Object assignmentId,
  ) async {
    final response = await _get(
      SportoApiEndpoints.refereeBookings.request(assignmentId),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Booking request response data is invalid.',
      );
    }
    return RefereeMatchRequestResponse.fromBookingRequestJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> acceptBookingRequest(Object assignmentId) async {
    await _post(
      SportoApiEndpoints.refereeBookings.accept(assignmentId),
      const {},
    );
  }

  Future<void> rejectBookingRequest(
    Object assignmentId, {
    String? reason,
  }) async {
    await _post(
      SportoApiEndpoints.refereeBookings.reject(assignmentId),
      {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<List<RefereeMatchResponse>> listBookingsData({
    String filter = 'upcoming',
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeBookings.bookings,
      queryParameters: {
        'filter': filter,
        'page': page,
        'per_page': perPage,
      },
    );
    return _listOrPaginatedData(response.data)
        .map(RefereeMatchResponse.fromBookingJson)
        .toList();
  }

  Future<List<RefereeMatchResponse>> listAllBookingsData({
    int perPage = 50,
  }) async {
    final lists = await Future.wait([
      listBookingsData(filter: 'upcoming', perPage: perPage),
      listBookingsData(filter: 'ongoing', perPage: perPage),
      listBookingsData(filter: 'completed', perPage: perPage),
    ]);
    final seen = <String>{};
    return [
      for (final list in lists)
        for (final item in list)
          if (seen.add('${item.id}')) item,
    ];
  }

  Future<RefereeMatchResponse> getBookingDetails(Object bookingId) async {
    final response = await _get(
      SportoApiEndpoints.refereeBookings.booking(bookingId),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Booking response data is invalid.');
    }
    return RefereeMatchResponse.fromBookingJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<RefereeBookingSessionResponse> getBookingSession(
    Object bookingId,
  ) async {
    final response = await _get(
      SportoApiEndpoints.refereeBookings.session(bookingId),
    );
    return _bookingSessionFromData(response.data);
  }

  Future<RefereeBookingSessionResponse> verifyBookingTossOtp(
    Object bookingId, {
    required String otp,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeBookings.verifyToss(bookingId),
      {'otp': otp.trim()},
    );
    return _bookingSessionFromData(response.data);
  }

  Future<RefereeBookingSessionResponse> verifyBookingStartOtp(
    Object bookingId, {
    required String otp,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeBookings.verifyStart(bookingId),
      {'otp': otp.trim()},
    );
    return _bookingSessionFromData(response.data);
  }

  Future<RefereeBookingSessionResponse> verifyBookingEndOtp(
    Object bookingId, {
    required String otp,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeBookings.verifyEnd(bookingId),
      {'otp': otp.trim()},
    );
    return _bookingSessionFromData(response.data);
  }

  RefereeBookingSessionResponse _bookingSessionFromData(Object? data) {
    if (data is! Map) {
      throw const SportoApiException(
        'Booking session response data is invalid.',
      );
    }
    return RefereeBookingSessionResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<SportoApiResponse> listMyMatches({
    int page = 1,
    int perPage = 20,
  }) {
    return _get(
      SportoApiEndpoints.refereeMatches.matches,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  Future<List<RefereeMatchResponse>> listMyMatchesData({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await listMyMatches(page: page, perPage: perPage);
    return _listOrPaginatedData(response.data)
        .map(RefereeMatchResponse.fromJson)
        .toList();
  }

  Future<SportoApiResponse> showMyMatch(Object matchId) {
    return _get(SportoApiEndpoints.refereeMatches.matchById(matchId));
  }

  Future<RefereeMatchResponse> showMyMatchData(Object matchId) async {
    final response = await showMyMatch(matchId);
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Match response data is invalid.');
    }
    return RefereeMatchResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SportoApiResponse> getMatchToss(Object matchId) {
    return _get(SportoApiEndpoints.refereeMatches.toss(matchId));
  }

  Future<RefereeTossResponse> getMatchTossData(Object matchId) async {
    final response = await getMatchToss(matchId);
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Toss response data is invalid.');
    }
    return RefereeTossResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SportoApiResponse> updateMatchToss(
    Object matchId,
    RefereeTossUpdateRequest request,
  ) {
    return _put(
      SportoApiEndpoints.refereeMatches.toss(matchId),
      request.toJson(),
    );
  }

  Future<RefereeTossResponse?> updateMatchTossData(
    Object matchId,
    RefereeTossUpdateRequest request,
  ) async {
    final response = await updateMatchToss(matchId, request);
    if (response.data is! Map) return null;
    return RefereeTossResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<SportoApiResponse> getMatchScore(Object matchId) {
    return _get(SportoApiEndpoints.refereeMatches.score(matchId));
  }

  Future<RefereeScoreResponse> getMatchScoreData(Object matchId) async {
    final response = await getMatchScore(matchId);
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Score response data is invalid.');
    }
    return RefereeScoreResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SportoApiResponse> updateMatchScore(
    Object matchId,
    RefereeScoreUpdateRequest request,
  ) {
    return _put(
      SportoApiEndpoints.refereeMatches.score(matchId),
      request.toJson(),
    );
  }

  Future<RefereeScoreResponse?> updateMatchScoreData(
    Object matchId,
    RefereeScoreUpdateRequest request,
  ) async {
    final response = await updateMatchScore(matchId, request);
    if (response.data is! Map) return null;
    return RefereeScoreResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<RefereeMatchSessionResponse> getMatchSession(Object matchId) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.session(matchId),
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> getMatchReadiness(Object matchId) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.verify(matchId),
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> verifyMatchTeams(
    Object matchId, {
    bool teamsVerified = true,
    bool groundReady = true,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeMatches.verify(matchId),
      {
        'teams_verified': teamsVerified,
        'ground_ready': groundReady,
      },
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> startMatchSession(
    Object matchId, {
    required String otp,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeMatches.sessionStart(matchId),
      {'otp': otp.trim()},
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> endMatchSession(
    Object matchId, {
    required String otp,
  }) async {
    final response = await _post(
      SportoApiEndpoints.refereeMatches.sessionEnd(matchId),
      {'otp': otp.trim()},
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> withdrawMatchSession(
    Object matchId,
  ) async {
    final response = await _post(
      SportoApiEndpoints.refereeMatches.sessionWithdraw(matchId),
      const {},
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchSessionResponse> updateMatchStatus(
    Object matchId,
    RefereeMatchStatusRequest request,
  ) async {
    final response = await _put(
      SportoApiEndpoints.refereeMatches.status(matchId),
      request.toJson(),
    );
    return _sessionFromData(response.data);
  }

  Future<RefereeMatchResultResponse> getMatchResult(Object matchId) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.result(matchId),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Result response data is invalid.');
    }
    return RefereeMatchResultResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<RefereeScorecardResponse> getMatchScorecard(Object matchId) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.scorecard(matchId),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Scorecard response data is invalid.');
    }
    return RefereeScorecardResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<RefereeScoreEventsPage> listMatchScoreEvents(
    Object matchId, {
    int? innings,
    String? inningsType,
    int? teamId,
    int? playerId,
    String? eventType,
    bool includeReversed = true,
    String order = 'asc',
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _get(
      SportoApiEndpoints.refereeMatches.scoreEvents(matchId),
      queryParameters: {
        if (innings != null) 'innings': innings,
        if (inningsType != null && inningsType.isNotEmpty)
          'innings_type': inningsType,
        if (teamId != null) 'team_id': teamId,
        if (playerId != null) 'player_id': playerId,
        if (eventType != null && eventType.isNotEmpty) 'event_type': eventType,
        'include_reversed': includeReversed ? 1 : 0,
        'order': order,
        'page': page,
        'per_page': perPage,
      },
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Score events response data is invalid.',
      );
    }
    return RefereeScoreEventsPage.fromJson(Map<String, dynamic>.from(data));
  }

  RefereeMatchSessionResponse _sessionFromData(Object? data) {
    if (data is! Map) {
      throw const SportoApiException(
        'Match session response data is invalid.',
      );
    }
    return RefereeMatchSessionResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  RefereeAvailabilityStatusResponse _availabilityStatusFromData(
    Object? data,
  ) {
    if (data is! Map) {
      throw const SportoApiException(
        'Availability status response data is invalid.',
      );
    }
    return RefereeAvailabilityStatusResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  RefereeAvailabilitySlot _slotFromData(Object? data) {
    if (data is! Map) {
      throw const SportoApiException(
        'Availability slot response data is invalid.',
      );
    }
    return RefereeAvailabilitySlot.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  RefereeApplicationResponse? _applicationFromData(Object? data) {
    if (data == null) return null;
    if (data is! Map) {
      throw const SportoApiException(
        'Referee application response data is invalid.',
      );
    }
    return RefereeApplicationResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<SportoApiResponse> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return SportoApiResponse.fromJson(
      await _apiClient.getJson(path, queryParameters: queryParameters),
    );
  }

  Future<SportoApiResponse> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return SportoApiResponse.fromJson(
      await _apiClient.postJson(path, body: body),
    );
  }

  Future<SportoApiResponse> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return SportoApiResponse.fromJson(
      await _apiClient.putJson(path, body: body),
    );
  }

  Future<SportoApiResponse> _delete(String path) async {
    return SportoApiResponse.fromJson(await _apiClient.deleteJson(path));
  }

  List<Map<String, dynamic>> _listOrPaginatedData(Object? data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['data'] ?? map['items'] ?? map['matches'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _mapDataOrThrow(Object? data, String message) {
    if (data is! Map) throw SportoApiException(message);
    return Map<String, dynamic>.from(data);
  }

  RefereeDashboardResponse _dashboardFromData(Object? data) =>
      RefereeDashboardResponse.fromJson(
        _mapDataOrThrow(data, 'Dashboard response data is invalid.'),
      );

  RefereeWalletSummary _walletFromData(Object? data) =>
      RefereeWalletSummary.fromJson(
        _mapDataOrThrow(data, 'Wallet response data is invalid.'),
      );

  RefereeStatistics _statisticsFromData(Object? data) =>
      RefereeStatistics.fromJson(
        _mapDataOrThrow(data, 'Statistics response data is invalid.'),
      );

  RefereeEarningsPage _earningsPageFromData(Object? data) =>
      RefereeEarningsPage.fromJson(
        _mapDataOrThrow(data, 'Earnings response data is invalid.'),
      );

  RefereeTournamentHistoryPage _tournamentsPageFromData(Object? data) =>
      RefereeTournamentHistoryPage.fromJson(
        _mapDataOrThrow(data, 'Tournaments response data is invalid.'),
      );

  RefereeWalletTransactionsPage _walletTransactionsPageFromData(
    Object? data,
  ) =>
      RefereeWalletTransactionsPage.fromJson(
        _mapDataOrThrow(
          data,
          'Wallet transactions response data is invalid.',
        ),
      );

  RefereeCommentaryPage _commentaryPageFromData(Object? data) =>
      RefereeCommentaryPage.fromJson(
        _mapDataOrThrow(data, 'Commentary response data is invalid.'),
      );

  RefereeMatchGraphsResponse _graphsFromData(Object? data) =>
      RefereeMatchGraphsResponse.fromJson(
        _mapDataOrThrow(data, 'Match graphs response data is invalid.'),
      );

  RefereeLeaderboardResponse _leaderboardFromData(Object? data) =>
      RefereeLeaderboardResponse.fromJson(
        _mapDataOrThrow(data, 'Match leaderboard response data is invalid.'),
      );

  RefereeBankDetails _bankDetailsFromData(
    Object? data, {
    RefereeBankDetails? fallback,
    required String errorMessage,
  }) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['bank'] ?? map['bank_detail'] ?? map['data'];
      if (nested is Map && nested.isNotEmpty) {
        return RefereeBankDetails.fromJson(
          Map<String, dynamic>.from(nested),
        );
      }
      if (map.isNotEmpty) return RefereeBankDetails.fromJson(map);
    }
    if (data is List && data.isNotEmpty && data.first is Map) {
      return RefereeBankDetails.fromJson(
        Map<String, dynamic>.from(data.first as Map),
      );
    }
    if (fallback != null) return fallback;
    throw SportoApiException(errorMessage);
  }

  Future<_IncomingListResult> _loadIncomingRequests() async {
    final results = await Future.wait([
      _tryLoadMatchRequests(),
      _tryLoadBookingRequests(),
    ]);
    return _IncomingListResult(
      matchRequests: results[0],
      bookingRequests: results[1],
    );
  }

  Future<List<RefereeMatchRequestResponse>?> _tryLoadMatchRequests() async {
    try {
      final response = await _get(
        SportoApiEndpoints.refereeMatches.matchRequests,
        queryParameters: const {'page': 1, 'per_page': 20},
      );
      return _listOrPaginatedData(response.data)
          .map(RefereeMatchRequestResponse.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<RefereeMatchRequestResponse>?> _tryLoadBookingRequests() async {
    try {
      final response = await _get(
        SportoApiEndpoints.refereeBookings.requests,
        queryParameters: const {'page': 1, 'per_page': 20},
      );
      return _listOrPaginatedData(response.data)
          .map(RefereeMatchRequestResponse.fromBookingRequestJson)
          .toList();
    } catch (_) {
      return null;
    }
  }
}

class _IncomingListResult {
  const _IncomingListResult({
    this.matchRequests,
    this.bookingRequests,
  });

  final List<RefereeMatchRequestResponse>? matchRequests;
  final List<RefereeMatchRequestResponse>? bookingRequests;

  bool get bothFailed => matchRequests == null && bookingRequests == null;

  bool get bothSucceededAndEmpty =>
      matchRequests != null &&
      matchRequests!.isEmpty &&
      bookingRequests != null &&
      bookingRequests!.isEmpty;
}
