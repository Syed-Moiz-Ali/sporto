import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/core/match_action/match_action_resolver.dart';
import 'package:referee_data/referee_data.dart';

void main() {
  RefereeMatchResponse match({
    int id = 1,
    int status = 0,
    String? statusLabel,
    bool canOfficiate = true,
    String? blockingCode,
    Map<String, Object?> toss = const {},
  }) {
    return RefereeMatchResponse(
      id: id,
      status: status,
      statusLabel: statusLabel,
      canOfficiate: canOfficiate,
      blockingCode: blockingCode,
      teamA: const RefereeMatchTeam(id: 1, name: 'A'),
      teamB: const RefereeMatchTeam(id: 2, name: 'B'),
      raw: {
        if (toss.isNotEmpty) 'toss': toss,
      },
    );
  }

  group('resolveMatchAction', () {
    test('blocked when assignment not accepted', () {
      final result = resolveMatchAction(match(
        canOfficiate: false,
        blockingCode: 'ASSIGNMENT_NOT_ACCEPTED',
      ));
      expect(result.action, MatchAction.blocked);
      expect(result.blockedReason, contains('Requests'));
    });

    test('blocked when participants unresolved', () {
      final result = resolveMatchAction(match(
        canOfficiate: false,
        blockingCode: 'PARTICIPANTS_NOT_RESOLVED',
      ));
      expect(result.action, MatchAction.blocked);
    });

    test('completed match goes to report regardless of officiate flag', () {
      final result = resolveMatchAction(match(
        status: 3,
        statusLabel: 'Completed',
        canOfficiate: false,
        blockingCode: 'ASSIGNMENT_NOT_ACCEPTED',
      ));
      expect(result.action, MatchAction.viewReport);
    });

    test('live officiable match continues scoring', () {
      final result = resolveMatchAction(
        match(status: 2, statusLabel: 'Live'),
      );
      expect(result.action, MatchAction.continueScoring);
    });

    test('toss completed routes to start scoring', () {
      final result = resolveMatchAction(match(
        toss: const {'state': 'TOSS_COMPLETED', 'is_completed': true},
      ));
      expect(result.action, MatchAction.startScoring);
    });

    test('upcoming without toss flag routes to verify', () {
      final result = resolveMatchAction(match(statusLabel: 'Scheduled'));
      expect(result.action, MatchAction.verify);
    });
  });

  group('countdownText', () {
    test('returns null for null or past start', () {
      expect(countdownText(null), isNull);
      expect(
        countdownText(DateTime.now().subtract(const Duration(minutes: 1))),
        isNull,
      );
    });

    test('formats minutes, hours and days', () {
      final now = DateTime.now();
      expect(
        countdownText(now.add(const Duration(minutes: 20)), now: now),
        'Starts in 20m',
      );
      expect(
        countdownText(now.add(const Duration(hours: 2, minutes: 5)), now: now),
        'Starts in 2h 5m',
      );
      expect(
        countdownText(now.add(const Duration(days: 3)), now: now),
        'Starts in 3d',
      );
    });
  });
}
