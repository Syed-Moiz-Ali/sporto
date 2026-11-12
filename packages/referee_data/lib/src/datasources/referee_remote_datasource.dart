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
}
