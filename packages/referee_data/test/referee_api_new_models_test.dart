import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';

void main() {
  test('scorecard dismissal objects are rendered as readable text', () {
    final caught = RefereeScorecardBatting.fromJson({
      'player_id': 1,
      'name': 'Batter',
      'dismissal': {
        'wicket_type': 'CAUGHT',
        'bowler_name': 'Bowler One',
        'fielder_name': 'Fielder Two',
      },
    });
    expect(caught.dismissal, 'c Fielder Two b Bowler One');

    final bowled = RefereeScorecardBatting.fromJson({
      'player_id': 2,
      'name': 'Batter Two',
      'dismissal': {'wicket_type': 'BOWLED', 'bowler_name': 'Bowler One'},
    });
    expect(bowled.dismissal, 'b Bowler One');

    final runOut = RefereeScorecardBatting.fromJson({
      'player_id': 3,
      'name': 'Batter Three',
      'dismissal': {'wicket_type': 'RUN_OUT', 'fielder_name': 'Fielder Two'},
    });
    expect(runOut.dismissal, 'run out (Fielder Two)');
  });
  group('dashboard, wallet and statistics', () {
    test('parses wallet summary decimal strings safely', () {
      final wallet = RefereeWalletSummary.fromJson({
        'balance': '12.50',
        'reserved_balance': 0,
        'total_earned': '1,234.00',
        'pending_earnings': null,
        'simulated_unfunded_earnings': '7.5',
        'currency': 'INR',
        'wallet_exists': true,
        'earnings_available': '1',
        'earnings_note': 'Synthetic note',
      });

      expect(wallet.balance, 12.5);
      expect(wallet.reservedBalance, 0);
      expect(wallet.totalEarned, 1234);
      expect(wallet.pendingEarnings, isNull);
      expect(wallet.simulatedUnfundedEarnings, 7.5);
      expect(wallet.currency, 'INR');
      expect(wallet.walletExists, isTrue);
      expect(wallet.earningsAvailable, isTrue);
      expect(wallet.earningsNote, 'Synthetic note');
    });

    test('parses statistics with nested bookings and nullable fields', () {
      final statistics = RefereeStatistics.fromJson({
        'live_matches': 1,
        'upcoming_matches': 2,
        'completed_matches': 3,
        'pending_requests': 4,
        'pending_tournament_requests': 5,
        'pending_booking_requests': 6,
        'bookings': {'confirmed': 7, 'ongoing': 8, 'completed': 9},
        'total_matches': 10,
        'disputes_count': null,
        'rating': '4.25',
      });

      expect(statistics.liveMatches, 1);
      expect(statistics.upcomingMatches, 2);
      expect(statistics.completedMatches, 3);
      expect(statistics.pendingRequests, 4);
      expect(statistics.pendingTournamentRequests, 5);
      expect(statistics.pendingBookingRequests, 6);
      expect(statistics.bookingsConfirmed, 7);
      expect(statistics.bookingsOngoing, 8);
      expect(statistics.bookingsCompleted, 9);
      expect(statistics.totalMatches, 10);
      expect(statistics.disputesCount, isNull);
      expect(statistics.rating, 4.25);
    });

    test('parses dashboard profile, stats, wallet and tiny lists', () {
      final dashboard = RefereeDashboardResponse.fromJson({
        'profile': {
          'id': 10,
          'name': 'Sample Referee',
          'profile_photo_url': null,
          'rating': 4.5,
        },
        'availability': {
          'is_available': true,
          'accepting_matches': true,
          'status_label': 'On',
          'message': 'Ready',
        },
        'stats': {
          'live_matches': 1,
          'upcoming_matches': 2,
          'completed_matches': 3,
          'pending_requests': 4,
          'pending_tournament_requests': 5,
          'pending_booking_requests': 6,
          'bookings': {'confirmed': 7, 'ongoing': 8, 'completed': 9},
          'total_matches': 10,
          'disputes_count': null,
        },
        'wallet': {
          'balance': '5.00',
          'currency': 'INR',
          'wallet_exists': true,
          'earnings_available': true,
        },
        'today_matches': {
          'items': [
            {
              'id': 101,
              'status': 1,
              'status_label': 'Upcoming',
              'tournament': {'id': 1, 'name': 'Sample Cup'},
              'participants': {
                'team_a': {'id': 1, 'name': 'Team Alpha'},
                'team_b': {'id': 2, 'name': 'Team Beta'},
              },
            },
          ],
          'total': 1,
        },
        'today_bookings': {'items': [], 'total': 0},
        'recent_requests': [
          {
            'id': 102,
            'status': 1,
            'status_label': 'Upcoming',
            'participants': {
              'team_a': {'id': 3, 'name': 'Team Gamma'},
              'team_b': {'id': 4, 'name': 'Team Delta'},
            },
          },
        ],
        'recent_booking_requests': [
          {
            'assignment_id': 201,
            'assignment_status': 1,
            'booking': {
              'id': 202,
              'booking_number': 'RB-1',
              'booking_status': 'REQUESTED',
              'venue_name': 'Sample Ground',
              'booking_date': '2026-01-01',
              'start_time': '10:00',
            },
          },
        ],
      });

      expect(dashboard.profile.id, 10);
      expect(dashboard.profile.name, 'Sample Referee');
      expect(dashboard.profile.rating, 4.5);
      expect(dashboard.availability.isAvailable, isTrue);
      expect(dashboard.statistics.totalMatches, 10);
      expect(dashboard.wallet.balance, 5);
      expect(dashboard.todayMatches.total, 1);
      expect(dashboard.todayMatches.items.single.displayTeamA, 'Team Alpha');
      expect(dashboard.todayBookings.isEmpty, isTrue);
      expect(dashboard.recentRequests.single.id, 102);
      expect(dashboard.recentBookingRequests.single.id, 202);
      expect(dashboard.recentBookingRequests.single.isBooking, isTrue);
    });
  });

  group('paginated history and money pages', () {
    test('parses tournament history page', () {
      final page = RefereeTournamentHistoryPage.fromJson({
        'items': [
          {
            'id': 11,
            'name': 'Sample League',
            'code': 'SAMPLE01',
            'status': 7,
            'currency': 'INR',
          },
        ],
        'total': 1,
        'current_page': 1,
        'last_page': 1,
      });

      expect(page.items.single.id, 11);
      expect(page.items.single.name, 'Sample League');
      expect(page.items.single.code, 'SAMPLE01');
      expect(page.items.single.status, 7);
      expect(page.items.single.currency, 'INR');
      expect(page.page, 1);
      expect(page.lastPage, 1);
      expect(page.total, 1);
    });

    test('parses wallet transactions page defensively', () {
      final page = RefereeWalletTransactionsPage.fromJson({
        'items': [
          {
            'id': 9001,
            'reference': 'TXN-1',
            'amount': '123.45',
            'status': 'COMPLETED',
            'status_label': 'Completed',
            'type': 'CREDIT',
            'category': 'EARNING',
            'description': 'Match fee',
            'title': 'Match fee',
            'tournament': {'name': 'Sample Cup'},
            'match_id': 501,
            'created_at': '2026-01-01T10:00:00Z',
            'direction': 'credit',
            'currency': 'INR',
            'payment_method': 'wallet',
          },
        ],
        'total': 1,
        'current_page': 1,
        'last_page': 2,
      });

      final transaction = page.items.single;
      expect(transaction.id, 9001);
      expect(transaction.reference, 'TXN-1');
      expect(transaction.amount, 123.45);
      expect(transaction.statusLabel, 'Completed');
      expect(transaction.type, 'CREDIT');
      expect(transaction.tournamentName, 'Sample Cup');
      expect(transaction.matchId, 501);
      expect(transaction.createdAt, '2026-01-01T10:00:00Z');
      expect(transaction.isCredit, isTrue);
      expect(transaction.isDebit, isFalse);
      expect(page.total, 1);
      expect(page.lastPage, 2);
    });

    test('parses empty wallet transactions page', () {
      final page = RefereeWalletTransactionsPage.fromJson({
        'items': [],
        'total': 0,
        'current_page': 1,
        'last_page': 1,
      });

      expect(page.items, isEmpty);
      expect(page.isEmpty, isTrue);
      expect(page.total, 0);
    });

    test('parses earnings page and fee rows', () {
      final page = RefereeEarningsPage.fromJson({
        'items': [
          {
            'match_id': 501,
            'expected_fee': '400.00',
            'state': 'PAID',
            'paid_at': '2026-01-02T10:00:00Z',
            'tournament': {'name': 'Sample Cup'},
            'match': {'id': 501, 'name': 'Final'},
            'currency': 'INR',
            'type': 'BOOKING',
          },
        ],
        'current_page': 1,
        'last_page': 1,
        'total': 1,
        'total_earned': '400.00',
        'pending_earnings': '0.00',
        'simulated_unfunded_earnings': '0.00',
        'earnings_available': true,
        'currency': 'INR',
        'note': 'Synthetic note',
      });

      final item = page.items.single;
      expect(item.matchId, 501);
      expect(item.expectedFee, 400);
      expect(item.status, 'PAID');
      expect(item.paidAt, '2026-01-02T10:00:00Z');
      expect(item.tournamentName, 'Sample Cup');
      expect(item.matchLabel, 'Final');
      expect(item.currency, 'INR');
      expect(item.type, 'BOOKING');
      expect(page.totalEarned, 400);
      expect(page.earningsAvailable, isTrue);
      expect(page.note, 'Synthetic note');
    });
  });

  group('bank details', () {
    test('parses BANK and UPI rows with display fallbacks', () {
      final bank = RefereeBankDetails.fromJson({
        'id': 1,
        'type': 'BANK',
        'account_holder_name': 'Sample Holder',
        'account_number': '********9012',
        'masked_account_number': '********9012',
        'ifsc_code': 'TEST0001234',
        'bank_name': 'Sample Bank',
        'branch_name': 'Main Branch',
        'upi_id': null,
        'summary': 'Bank account ending 9012',
        'status': 1,
        'status_label': 'Active',
        'is_active': true,
        'verification_status': 1,
        'verification_status_label': 'Pending',
        'is_default': true,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      });
      final upi = RefereeBankDetails.fromJson({
        'id': 2,
        'type': 'UPI',
        'upi_id': 'sample@upi',
        'summary': 'sa***@upi',
        'is_active': true,
        'is_default': false,
      });

      expect(bank.displayName, 'Sample Bank');
      expect(bank.lastFour, '9012');
      expect(bank.isBank, isTrue);
      expect(bank.isUpi, isFalse);
      expect(bank.isActive, isTrue);
      expect(bank.isDefault, isTrue);
      expect(bank.verificationStatusLabel, 'Pending');

      expect(upi.displayName, 'sample@upi');
      expect(upi.lastFour, isNull);
      expect(upi.isUpi, isTrue);
      expect(upi.isDefault, isFalse);
    });

    test('serializes canonical bank and UPI request bodies', () {
      expect(
        RefereeBankDetailsRequest.bankAccount(
          accountNumber: '000011112222',
          accountHolder: 'Sample Holder',
          ifsc: 'TEST0001234',
          bankName: 'Sample Bank',
          branchName: 'Main Branch',
          isDefault: true,
        ).toJson(),
        {
          'type': 'BANK',
          'details': {
            'account_number': '000011112222',
            'account_holder': 'Sample Holder',
            'ifsc': 'TEST0001234',
          },
          'bank_name': 'Sample Bank',
          'branch_name': 'Main Branch',
          'is_default': true,
        },
      );
      expect(
        RefereeBankDetailsRequest.upi(upi: ' sample@upi ').toJson(),
        {
          'type': 'UPI',
          'details': {'upi': 'sample@upi'},
        },
      );
    });
  });

  group('award, commentary, graphs and leaderboard', () {
    test('parses result margin and player of the match', () {
      final result = RefereeMatchResultResponse.fromJson({
        'match_id': 501,
        'match_code': 'SP-501',
        'match_status': 3,
        'status': 'WIN',
        'winner_team_id': 1,
        'winner_team_name': 'Team Alpha',
        'message': 'Team Alpha won',
        'margin': '10 runs',
        'margin_type': 'RUNS',
        'margin_value': 10,
        'player_of_match': {
          'user_id': 77,
          'team_id': 1,
          'name': 'Sample Player',
          'awarded_at': '2026-01-01T00:00:00Z',
          'awarded_by_referee_id': 10,
        },
        'is_walkover': false,
      });

      expect(result.marginType, 'RUNS');
      expect(result.marginValue, 10);
      expect(result.playerOfMatch?.userId, 77);
      expect(result.playerOfMatch?.teamId, 1);
      expect(result.playerOfMatch?.name, 'Sample Player');
      expect(result.playerOfMatch?.isEmpty, isFalse);
      expect(result.hasWinner, isTrue);

      final pending = RefereeMatchResultResponse.fromJson({
        'match_id': 502,
        'status': 'PENDING',
        'player_of_match': null,
      });
      expect(pending.playerOfMatch, isNull);
    });

    test('parses commentary page and meta', () {
      final page = RefereeCommentaryPage.fromJson({
        'match_id': 501,
        'source': 'EVENT_LEDGER',
        'order': 'desc',
        'items': [
          {
            'id': 8001,
            'event_uuid': 'uuid-1',
            'event_sequence': 24,
            'innings_number': 2,
            'innings_type': 'REGULATION',
            'super_over_round': null,
            'team_id': 2,
            'over_number': 1,
            'ball_number': 6,
            'ball_label': '1.6',
            'legal_delivery': true,
            'event_type': 'RUN',
            'runs': 4,
            'batter_runs': 4,
            'extras': 0,
            'wickets': 0,
            'boundary_type': 'FOUR',
            'batter_id': 77,
            'bowler_id': 88,
            'dismissed_player_id': null,
            'text': 'Sample bowler to Sample batter: FOUR!',
            'team_score_after': 55,
            'team_wickets_after': 0,
            'recorded_at': '2026-01-01T00:00:00Z',
          },
        ],
        'meta': {
          'current_page': 1,
          'per_page': 10,
          'last_page': 3,
          'total': 24,
        },
      });

      final item = page.items.single;
      expect(page.matchId, 501);
      expect(page.source, 'EVENT_LEDGER');
      expect(page.order, 'desc');
      expect(item.sequence, 24);
      expect(item.innings, 2);
      expect(item.over, 1);
      expect(item.ball, 6);
      expect(item.ballLabel, '1.6');
      expect(item.legalDelivery, isTrue);
      expect(item.eventType, 'RUN');
      expect(item.runs, 4);
      expect(item.batterRuns, 4);
      expect(item.boundaryType, 'FOUR');
      expect(item.batterId, 77);
      expect(item.bowlerId, 88);
      expect(item.text, contains('FOUR'));
      expect(item.teamScoreAfter, 55);
      expect(item.teamWicketsAfter, 0);
      expect(page.page, 1);
      expect(page.perPage, 10);
      expect(page.lastPage, 3);
      expect(page.total, 24);
    });

    test('parses match graphs series', () {
      final graphs = RefereeMatchGraphsResponse.fromJson({
        'match_id': 501,
        'source': 'EVENT_LEDGER',
        'include_super_overs': false,
        'series': [
          {
            'innings_type': 'REGULATION',
            'super_over_round': null,
            'innings_number': 1,
            'team_id': 1,
            'runs': 51,
            'wickets': 1,
            'legal_balls': 12,
            'manhattan': [
              {
                'over': 1,
                'runs': 26,
                'wickets': 0,
                'legal_balls': 6,
                'boundaries': 4,
              },
            ],
            'worm': [
              {'over': 0, 'runs': 0, 'wickets': 0},
              {'over': 1, 'runs': 26, 'wickets': 0},
            ],
            'insights': {
              'highest_scoring_over': {'over': 1, 'runs': 26},
            },
            'overs_notation': '2.0',
          },
        ],
      });

      final series = graphs.series.single;
      expect(graphs.matchId, 501);
      expect(graphs.includeSuperOvers, isFalse);
      expect(series.inningsNumber, 1);
      expect(series.teamId, 1);
      expect(series.runs, 51);
      expect(series.wickets, 1);
      expect(series.legalBalls, 12);
      expect(series.manhattan.single.runs, 26);
      expect(series.manhattan.single.boundaries, 4);
      expect(series.worm.length, 2);
      expect(series.insights['highest_scoring_over'], isA<Map>());
      expect(series.oversNotation, '2.0');
    });

    test('parses leaderboard page and cricket stats', () {
      final leaderboard = RefereeLeaderboardResponse.fromJson({
        'category': 'MOST_RUNS',
        'metric': 'runs',
        'data_availability': {
          'event_count': 24,
          'active_event_count': 24,
          'reversed_event_count': 0,
          'status': 'COMPLETE',
          'reason': 'LEDGER_VERIFIED',
        },
        'entries': [
          {
            'rank': 1,
            'player_id': 77,
            'name': 'Sample Player',
            'team_id': 1,
            'value': 33,
            'matches_played': 1,
            'runs': 33,
            'balls_faced': 7,
            'wickets': 0,
            'runs_conceded': 25,
            'legal_balls': 6,
            'fours': 3,
            'sixes': 3,
            'dot_balls': 0,
            'catches': 0,
            'stumpings': 0,
            'maidens': 0,
            'highest_score': 33,
            'best_bowling': '0/25',
            'strike_rate': 471.43,
            'batting_average': null,
            'bowling_average': null,
            'economy_rate': 25,
            'mvp_points': 42,
          },
        ],
      });

      final entry = leaderboard.entries.single;
      expect(leaderboard.category, 'MOST_RUNS');
      expect(leaderboard.metric, 'runs');
      expect(leaderboard.dataAvailability.isComplete, isTrue);
      expect(entry.rank, 1);
      expect(entry.playerId, 77);
      expect(entry.name, 'Sample Player');
      expect(entry.teamId, 1);
      expect(entry.value, 33);
      expect(entry.runs, 33);
      expect(entry.ballsFaced, 7);
      expect(entry.bestBowling, '0/25');
      expect(entry.strikeRate, 471.43);
      expect(entry.mvpPoints, 42);
    });
  });

  group('profile and incoming requests', () {
    test('extends profile with totals, wallet and statistics', () {
      final profile = RefereeProfileResponse.fromJson({
        'profile': {
          'name': 'Sample Referee',
          'email': 'referee@example.test',
          'mobile_number': '0000000000',
          'total_matches': 12,
          'rating': 4.75,
          'disputes_count': 1,
        },
        'sports': [
          {'name': 'Cricket'},
        ],
        'experience': {'experience_years': 5},
        'statistics': {
          'live_matches': 1,
          'total_matches': 12,
          'disputes_count': 1,
          'rating': 4.75,
        },
        'wallet': {
          'balance': '10.00',
          'currency': 'INR',
          'wallet_exists': true,
        },
      });

      expect(profile.name, 'Sample Referee');
      expect(profile.email, 'referee@example.test');
      expect(profile.mobile, '0000000000');
      expect(profile.sports, ['Cricket']);
      expect(profile.experienceYears, 5);
      expect(profile.totalMatches, 12);
      expect(profile.rating, 4.75);
      expect(profile.disputesCount, 1);
      expect(profile.statistics?.totalMatches, 12);
      expect(profile.wallet?.balance, 10);
      expect(profile.wallet?.walletExists, isTrue);
    });

    test('builds and copies the incoming requests bundle', () {
      const matchRequest =
          RefereeMatchRequestResponse(id: 1, statusLabel: 'Upcoming');
      const bookingRequest =
          RefereeMatchRequestResponse(id: 2, statusLabel: 'Requested');

      const bundle = RefereeIncomingRequestsBundle(
        matchRequests: [matchRequest],
        bookingRequests: [bookingRequest],
      );

      expect(bundle.requests.length, 2);
      expect(bundle.total, 2);
      expect(bundle.isEmpty, isFalse);

      final empty = bundle.copyWith(
        matchRequests: const [],
        bookingRequests: const [],
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.total, 0);

      expect(const RefereeIncomingRequestsBundle().isEmpty, isTrue);
    });
  });

  group('endpoint constants', () {
    test('exposes canonical dashboard, bank and match analytics paths', () {
      expect(
        SportoApiEndpoints.dashboard.dashboard,
        '/v1/referee/dashboard',
      );
      expect(
        SportoApiEndpoints.dashboard.wallet,
        '/v1/referee/wallet',
      );
      expect(
        SportoApiEndpoints.dashboard.earnings,
        '/v1/referee/earnings',
      );
      expect(
        SportoApiEndpoints.dashboard.statistics,
        '/v1/referee/statistics',
      );
      expect(
        SportoApiEndpoints.dashboard.tournaments,
        '/v1/referee/tournaments',
      );
      expect(
        SportoApiEndpoints.dashboard.walletTransactions,
        '/v1/referee/wallet/transactions',
      );
      expect(
        SportoApiEndpoints.bank.list,
        '/v1/referee/bank/list-bank-details',
      );
      expect(
        SportoApiEndpoints.bank.add,
        '/v1/referee/bank/add-bank-details',
      );
      expect(
        SportoApiEndpoints.bank.update(7),
        '/v1/referee/bank/update-bank-details/7',
      );
      expect(
        SportoApiEndpoints.bank.setDefault(7),
        '/v1/referee/bank/set-default-bank/7',
      );
      expect(
        SportoApiEndpoints.bank.delete(7),
        '/v1/referee/bank/delete-bank-details/7',
      );
      expect(
        SportoApiEndpoints.refereeMatches.playerOfMatch(7),
        '/v1/referee/matches/7/player-of-match',
      );
      expect(
        SportoApiEndpoints.refereeMatches.commentary(7),
        '/v1/referee/matches/7/commentary',
      );
      expect(
        SportoApiEndpoints.refereeMatches.graphs(7),
        '/v1/referee/matches/7/graphs',
      );
      expect(
        SportoApiEndpoints.refereeMatches.leaderboard(7, 'MOST_RUNS'),
        '/v1/referee/matches/7/leaderboards/MOST_RUNS',
      );
    });
  });
}
