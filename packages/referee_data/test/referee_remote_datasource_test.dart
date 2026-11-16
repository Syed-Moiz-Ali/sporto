import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';

const _matchRequestJson = <String, dynamic>{
  'id': 301,
  'status': 1,
  'status_label': 'Upcoming',
  'participants': {
    'team_a': {'id': 11, 'name': 'Team Alpha'},
    'team_b': {'id': 12, 'name': 'Team Beta'},
  },
};

const _bookingRequestJson = <String, dynamic>{
  'assignment_id': 401,
  'assignment_status': 1,
  'booking': {
    'id': 402,
    'booking_number': 'RB-2',
    'booking_status': 'REQUESTED',
    'venue_name': 'Sample Ground',
  },
};

Map<String, dynamic> _envelope(Object? data) => <String, dynamic>{
      'success': true,
      'message': 'ok',
      'data': data,
    };

Map<String, dynamic> _matchRequestsPage(List<Object?> items) =>
    _envelope(<String, dynamic>{'items': items, 'total': items.length});

Map<String, dynamic> _bookingRequestsPage(List<Object?> items) =>
    _envelope(<String, dynamic>{'data': items, 'total': items.length});

void main() {
  group('listIncomingRequestsData', () {
    test('combines pending match and booking requests', () async {
      final client = _FakeApiClient((path, query) async {
        if (path == SportoApiEndpoints.refereeMatches.matchRequests) {
          return _matchRequestsPage([_matchRequestJson]);
        }
        if (path == SportoApiEndpoints.refereeBookings.requests) {
          return _bookingRequestsPage([_bookingRequestJson]);
        }
        throw StateError('Unexpected path: $path');
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      final bundle = await datasource.listIncomingRequestsData(
        retryDelay: Duration.zero,
      );

      expect(bundle.matchRequests.single.id, 301);
      expect(bundle.bookingRequests.single.id, 402);
      expect(bundle.total, 2);
      expect(bundle.requests.length, 2);
      expect(bundle.isEmpty, isFalse);
      expect(
          client.callsFor(SportoApiEndpoints.refereeMatches.matchRequests), 1);
      expect(client.callsFor(SportoApiEndpoints.refereeBookings.requests), 1);
    });

    test('tolerates one failing endpoint without retrying', () async {
      final client = _FakeApiClient((path, query) async {
        if (path == SportoApiEndpoints.refereeMatches.matchRequests) {
          return _matchRequestsPage([_matchRequestJson]);
        }
        throw const SportoApiException('Booking endpoint unavailable.');
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      final bundle = await datasource.listIncomingRequestsData(
        retryDelay: Duration.zero,
      );

      expect(bundle.matchRequests.single.id, 301);
      expect(bundle.bookingRequests, isEmpty);
      expect(bundle.total, 1);
      expect(client.callsFor(SportoApiEndpoints.refereeBookings.requests), 1);
    });

    test('retries once when both lists are empty', () async {
      final attempts = <String, int>{};
      final client = _FakeApiClient((path, query) async {
        final count = (attempts[path] ?? 0) + 1;
        attempts[path] = count;
        if (path == SportoApiEndpoints.refereeMatches.matchRequests) {
          return _matchRequestsPage(
            count == 1 ? const [] : [_matchRequestJson],
          );
        }
        if (path == SportoApiEndpoints.refereeBookings.requests) {
          return _bookingRequestsPage(
            count == 1 ? const [] : [_bookingRequestJson],
          );
        }
        throw StateError('Unexpected path: $path');
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      final bundle = await datasource.listIncomingRequestsData(
        retryDelay: Duration.zero,
      );

      expect(bundle.total, 2);
      expect(
          client.callsFor(SportoApiEndpoints.refereeMatches.matchRequests), 2);
      expect(client.callsFor(SportoApiEndpoints.refereeBookings.requests), 2);
    });

    test('throws when both endpoints still fail after the retry', () async {
      final client = _FakeApiClient((path, query) async {
        throw const SportoApiException('Endpoint unavailable.');
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      await expectLater(
        datasource.listIncomingRequestsData(retryDelay: Duration.zero),
        throwsA(
          isA<SportoApiException>().having(
            (error) => error.message,
            'message',
            contains('both match-requests and booking-requests failed'),
          ),
        ),
      );
      expect(
          client.callsFor(SportoApiEndpoints.refereeMatches.matchRequests), 2);
      expect(client.callsFor(SportoApiEndpoints.refereeBookings.requests), 2);
    });
  });

  group('bank writes', () {
    test('posts the canonical body and parses created details', () async {
      final client = _FakeApiClient(
        (path, query) async => throw StateError('Unexpected GET $path'),
        postHandler: (path, body) async {
          expect(path, SportoApiEndpoints.bank.add);
          expect(body, {
            'type': 'BANK',
            'details': {
              'account_number': '000011112222',
              'account_holder': 'Sample Holder',
              'ifsc': 'TEST0001234',
            },
            'bank_name': 'Sample Bank',
            'is_default': true,
          });
          return _envelope(<String, dynamic>{
            'id': 1,
            'type': 'BANK',
            'bank_name': 'Sample Bank',
            'masked_account_number': '********9012',
            'is_default': true,
          });
        },
      );
      final datasource = RefereeRemoteDataSource(apiClient: client);

      final created = await datasource.addBankDetails(
        RefereeBankDetailsRequest.bankAccount(
          accountNumber: '000011112222',
          accountHolder: 'Sample Holder',
          ifsc: 'TEST0001234',
          bankName: 'Sample Bank',
          isDefault: true,
        ),
      );

      expect(created.id, 1);
      expect(created.displayName, 'Sample Bank');
      expect(created.lastFour, '9012');
      expect(created.isDefault, isTrue);
      expect(client.postCalls, [SportoApiEndpoints.bank.add]);
    });

    test('returns the fallback when the response has no data', () async {
      final client = _FakeApiClient(
        (path, query) async => throw StateError('Unexpected GET $path'),
        postHandler: (path, body) async => _envelope(null),
      );
      final datasource = RefereeRemoteDataSource(apiClient: client);
      const fallback = RefereeBankDetails(
        id: 7,
        type: 'UPI',
        upiId: 'sample@upi',
      );

      final created = await datasource.addBankDetails(
        RefereeBankDetailsRequest.upi(upi: 'sample@upi'),
        fallback: fallback,
      );

      expect(created.id, 7);
      expect(created.isUpi, isTrue);
      expect(created.displayName, 'sample@upi');
    });
  });

  group('listBankDetailsData', () {
    test('returns an empty list for data: []', () async {
      final client = _FakeApiClient((path, query) async {
        expect(path, SportoApiEndpoints.bank.list);
        return _envelope(const []);
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      expect(await datasource.listBankDetailsData(), isEmpty);
    });

    test('parses saved BANK rows nested under data.data', () async {
      final client = _FakeApiClient((path, query) async {
        expect(path, SportoApiEndpoints.bank.list);
        return _envelope(<String, dynamic>{
          'data': [
            {
              'id': 1,
              'type': 'BANK',
              'bank_name': 'Sample Bank',
              'masked_account_number': '********9012',
              'is_active': true,
              'is_default': true,
            },
          ],
        });
      });
      final datasource = RefereeRemoteDataSource(apiClient: client);

      final rows = await datasource.listBankDetailsData();
      expect(rows.single.displayName, 'Sample Bank');
      expect(rows.single.lastFour, '9012');
      expect(rows.single.isDefault, isTrue);
    });
  });
}

typedef _GetHandler = Future<Map<String, dynamic>> Function(
  String path,
  Map<String, dynamic>? queryParameters,
);

typedef _PostHandler = Future<Map<String, dynamic>> Function(
  String path,
  Map<String, dynamic>? body,
);

class _FakeApiClient extends SportoApiClient {
  _FakeApiClient(this._handler, {_PostHandler? postHandler})
      : _postHandler = postHandler,
        super(baseUrl: 'https://example.test');

  final _GetHandler _handler;
  final _PostHandler? _postHandler;
  final List<String> calls = [];
  final List<String> postCalls = [];

  int callsFor(String path) => calls.where((call) => call == path).length;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    calls.add(path);
    return _handler(path, queryParameters);
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) {
    postCalls.add(path);
    final handler = _postHandler;
    if (handler == null) throw StateError('Unexpected POST $path');
    return handler(path, body);
  }
}
