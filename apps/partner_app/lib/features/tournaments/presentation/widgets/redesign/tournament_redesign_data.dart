import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

enum TournamentListTab {
  applications,
  approved,
  draft,
  live,
  upcoming,
  completed,
  rejected,
}

extension TournamentListTabX on TournamentListTab {
  String get label => switch (this) {
        TournamentListTab.applications => 'Applications',
        TournamentListTab.approved => 'Approved',
        TournamentListTab.draft => 'Draft',
        TournamentListTab.live => 'Live',
        TournamentListTab.upcoming => 'Upcoming',
        TournamentListTab.completed => 'Completed',
        TournamentListTab.rejected => 'Rejected',
      };

  Color color(SportoTournamentTokens t) => switch (this) {
        TournamentListTab.applications => t.underReview,
        TournamentListTab.approved => t.green,
        TournamentListTab.draft => t.draft,
        TournamentListTab.live => t.live,
        TournamentListTab.upcoming => t.upcoming,
        TournamentListTab.completed => t.completed,
        TournamentListTab.rejected => t.red,
      };
}

bool tournamentMatchesTab(
  PartnerTournamentResponse tournament,
  TournamentListTab tab,
) {
  final approval = tournament.approvalStatus;
  return switch (tab) {
    TournamentListTab.applications => approval == 2,
    TournamentListTab.approved => approval == 4,
    TournamentListTab.draft => tournament.status == 1 && approval != 2,
    TournamentListTab.live => tournament.status == 6,
    TournamentListTab.upcoming =>
      tournament.status >= 2 && tournament.status <= 5,
    TournamentListTab.completed => tournament.status == 7,
    TournamentListTab.rejected =>
      approval == 5 || tournament.status == 8 || tournament.status == 9,
  };
}

int tournamentCountFor(
  List<PartnerTournamentResponse> tournaments,
  TournamentListTab tab,
) =>
    tournaments.where((t) => tournamentMatchesTab(t, tab)).length;

bool _hasChangesRequested(PartnerTournamentResponse t) {
  if (t.approvalStatus != 2) return false;
  final text = '${t.description ?? ''}'.toLowerCase();
  return text.contains('change') || text.contains('revision');
}

String tournamentStatusLabel(PartnerTournamentResponse t) {
  final approval = t.approvalStatus;
  if (_hasChangesRequested(t)) return 'Changes Requested';
  if (approval == 2) return 'Under Review';
  if (approval == 5) return 'Rejected';
  return switch (t.status) {
    1 => 'Draft',
    2 => 'Upcoming',
    3 => 'Registration Open',
    4 => 'Registration Closed',
    5 => 'Check In',
    6 => 'Live Now',
    7 => 'Completed',
    8 => 'Cancelled',
    9 => 'Archived',
    _ => t.workflowStatus.label,
  };
}

Color tournamentStatusColor(
  PartnerTournamentResponse t,
  SportoTournamentTokens tokens,
) {
  final approval = t.approvalStatus;
  if (_hasChangesRequested(t)) return tokens.changesRequested;
  if (approval == 2) return tokens.underReview;
  if (approval == 5) return tokens.red;
  return switch (t.status) {
    1 => tokens.draft,
    2 || 3 || 4 || 5 => tokens.upcoming,
    6 => tokens.live,
    7 => tokens.completed,
    8 => tokens.red,
    9 => tokens.dim,
    _ => tokens.muted,
  };
}

String formatTournamentDate(String? raw, {String fallback = '--'}) {
  if (raw == null || raw.isEmpty) return fallback;
  try {
    final dt = DateTime.parse(raw).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${hour.toString().padLeft(2, '0')}:$minute $period';
  } catch (_) {
    return raw;
  }
}

String formatTournamentDay(String? raw, {String fallback = '--'}) {
  if (raw == null || raw.isEmpty) return fallback;
  try {
    final dt = DateTime.parse(raw).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return raw;
  }
}

String tournamentCode(PartnerTournamentResponse tournament) {
  final code = tournament.code?.trim();
  if (code != null && code.isNotEmpty) return code;
  return 'TA-2026-${tournament.id.toString().padLeft(4, '0')}';
}

String tournamentVenueLabel(PartnerTournamentResponse tournament) {
  if (tournament.tournamentVenues.isEmpty) return 'Venue not set';
  final venue = tournament.tournamentVenues.first;
  return venue.venueName;
}

String tournamentLocationLabel(PartnerTournamentResponse tournament) {
  if (tournament.tournamentVenues.isEmpty) return '';
  return tournament.tournamentVenues.first.location ?? '';
}

String tournamentSportLabel(PartnerTournamentResponse tournament) =>
    tournament.sport?.name ?? 'Sport';

String formatCurrency(String? raw, {String fallback = '₹0'}) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final numeric = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
  if (numeric == null) return raw;
  return '₹${_groupThousands(numeric.round())}';
}

String formatCurrencyValue(num value) => '₹${_groupThousands(value.round())}';

String _groupThousands(int value) {
  final text = value.abs().toString();
  if (text.length <= 3) return value < 0 ? '-$text' : text;
  final last3 = text.substring(text.length - 3);
  var rest = text.substring(0, text.length - 3);
  final chunks = <String>[];
  while (rest.length > 2) {
    chunks.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) chunks.insert(0, rest);
  final joined = '${chunks.join(',')},$last3';
  return value < 0 ? '-$joined' : joined;
}

class DemoLeaderboardEntry {
  const DemoLeaderboardEntry(
    this.name,
    this.team,
    this.subtitle,
    this.value,
  );

  final String name;
  final String team;
  final String subtitle;
  final String value;
}

class DemoStatTab {
  const DemoStatTab(this.label, this.unit, this.entries);

  final String label;
  final String unit;
  final List<DemoLeaderboardEntry> entries;
}

const demoBattingTabs = <DemoStatTab>[
  DemoStatTab('Most Runs', 'runs', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '6 inns · 132.76 sr', '40'),
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '6 inns · 132.76 sr', '38'),
    DemoLeaderboardEntry(
        'Amit Sen', 'Hyd Highlanders', '6 inns · 132.76 sr', '35'),
    DemoLeaderboardEntry(
        'Ritik P', 'Hyd Highlanders', '6 inns · 132.76 sr', '34'),
    DemoLeaderboardEntry(
        'Pavan K', 'Hyd Highlanders', '6 inns · 132.76 sr', '30'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '6 inns · 132.76 sr', '25'),
  ]),
  DemoStatTab('Most Sixes', 'sixes', [
    DemoLeaderboardEntry(
        'Amit Sen', 'Hyd Highlanders', '6 inns · 18 sixes', '18'),
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '6 inns · 15 sixes', '15'),
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '6 inns · 12 sixes', '12'),
    DemoLeaderboardEntry(
        'Pavan K', 'Hyd Highlanders', '6 inns · 10 sixes', '10'),
    DemoLeaderboardEntry('Ritik P', 'Hyd Highlanders', '6 inns · 8 sixes', '8'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '6 inns · 7 sixes', '7'),
  ]),
  DemoStatTab('Most Fours', 'fours', [
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '6 inns · 21 fours', '21'),
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '6 inns · 19 fours', '19'),
    DemoLeaderboardEntry(
        'Ritik P', 'Hyd Highlanders', '6 inns · 17 fours', '17'),
    DemoLeaderboardEntry(
        'Amit Sen', 'Hyd Highlanders', '6 inns · 16 fours', '16'),
    DemoLeaderboardEntry(
        'Pavan K', 'Hyd Highlanders', '6 inns · 14 fours', '14'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '6 inns · 11 fours', '11'),
  ]),
  DemoStatTab('Highest Individual Score', 'runs', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '50 balls', '80*'),
    DemoLeaderboardEntry('Kunal Kumar', 'Hyd Highlanders', '50 balls', '60'),
    DemoLeaderboardEntry('Amit Sen', 'Hyd Highlanders', '48 balls', '54'),
    DemoLeaderboardEntry('Ritik P', 'Hyd Highlanders', '47 balls', '50'),
    DemoLeaderboardEntry('Pavan K', 'Hyd Highlanders', '45 balls', '48'),
    DemoLeaderboardEntry('Mayur Sinha', 'Hyd Highlanders', '40 balls', '30'),
  ]),
  DemoStatTab('Best Strike Rate', 'sr', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '132.76 sr', '132.76'),
    DemoLeaderboardEntry('Amit Sen', 'Hyd Highlanders', '128.40 sr', '128.40'),
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '124.18 sr', '124.18'),
    DemoLeaderboardEntry('Ritik P', 'Hyd Highlanders', '119.05 sr', '119.05'),
    DemoLeaderboardEntry('Pavan K', 'Hyd Highlanders', '112.50 sr', '112.50'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '108.20 sr', '108.20'),
  ]),
];

const demoBowlingTabs = <DemoStatTab>[
  DemoStatTab('Most Wickets', 'wkts', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '45 runs · 8.4 ovr', '14'),
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '45 runs · 8.4 ovr', '10'),
    DemoLeaderboardEntry(
        'Amit Sen', 'Hyd Highlanders', '45 runs · 8.4 ovr', '9'),
    DemoLeaderboardEntry(
        'Ritik P', 'Hyd Highlanders', '45 runs · 8.4 ovr', '8'),
    DemoLeaderboardEntry(
        'Pavan K', 'Hyd Highlanders', '45 runs · 8.4 ovr', '7'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '45 runs · 8.4 ovr', '6'),
  ]),
  DemoStatTab('Best Economy Rate', 'eco', [
    DemoLeaderboardEntry(
        'Amit Sen', 'Hyd Highlanders', '8.4 overs · 14 runs', '1.67'),
    DemoLeaderboardEntry(
        'Kunal Kumar', 'Hyd Highlanders', '8.4 overs · 18 runs', '2.14'),
    DemoLeaderboardEntry(
        'Ritik P', 'Hyd Highlanders', '8.4 overs · 21 runs', '2.50'),
    DemoLeaderboardEntry(
        'Pavan K', 'Hyd Highlanders', '8.4 overs · 24 runs', '2.86'),
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '8.4 overs · 27 runs', '3.21'),
    DemoLeaderboardEntry(
        'Mayur Sinha', 'Hyd Highlanders', '8.4 overs · 30 runs', '3.57'),
  ]),
  DemoStatTab('Best Bowling Figures', 'figures', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '8.4 overs', '5/18'),
    DemoLeaderboardEntry('Kunal Kumar', 'Hyd Highlanders', '8.4 overs', '4/21'),
    DemoLeaderboardEntry('Amit Sen', 'Hyd Highlanders', '8.4 overs', '4/24'),
    DemoLeaderboardEntry('Ritik P', 'Hyd Highlanders', '8.4 overs', '3/18'),
    DemoLeaderboardEntry('Pavan K', 'Hyd Highlanders', '8.4 overs', '3/22'),
    DemoLeaderboardEntry('Mayur Sinha', 'Hyd Highlanders', '8.4 overs', '2/19'),
  ]),
];

const demoOverallTabs = <DemoStatTab>[
  DemoStatTab('Most Valuable Player', 'pts', [
    DemoLeaderboardEntry(
        'Shravan Prajapati', 'Hyd Highlanders', '6 matches', '322'),
    DemoLeaderboardEntry('Kunal Kumar', 'Hyd Highlanders', '5 matches', '307'),
    DemoLeaderboardEntry('Amit Sen', 'Hyd Highlanders', '6 matches', '276'),
    DemoLeaderboardEntry('Ritik P', 'Hyd Highlanders', '6 matches', '248'),
    DemoLeaderboardEntry('Pavan K', 'Hyd Highlanders', '6 matches', '245'),
    DemoLeaderboardEntry('Mayur Sinha', 'Hyd Highlanders', '4 matches', '240'),
  ]),
];

class DemoTransaction {
  const DemoTransaction(this.title, this.date, this.code, this.amount,
      {this.positive = true});

  final String title;
  final String date;
  final String code;
  final String amount;
  final bool positive;
}

const demoIncomeTransactions = <DemoTransaction>[
  DemoTransaction(
      'Registration Revenue', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹40,000'),
  DemoTransaction(
      'Registration Revenue', '16 Jul 2026, 10:45 am', 'SP-441878', '+₹18,804'),
  DemoTransaction(
      'Registration Revenue', '16 Jul 2026, 10:45 am', 'SP-441879', '+₹12,000'),
  DemoTransaction(
      'Registration Revenue', '16 Jul 2026, 10:45 am', 'SP-441880', '+₹9,500'),
];

const demoSponsorshipTransactions = <DemoTransaction>[
  DemoTransaction(
      'Best Batsman', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹5,000'),
  DemoTransaction(
      'Best Bowler', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹42,000'),
  DemoTransaction('Winner', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹50,000'),
  DemoTransaction(
      'Runner-up', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹20,000'),
  DemoTransaction(
      'Best Bowler', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹42,000'),
  DemoTransaction(
      '3rd Place', '16 Jul 2026, 10:45 am', 'SP-441877', '+₹42,000'),
];

const demoExpenseTransactions = <DemoTransaction>[
  DemoTransaction(
      'Referee Booking', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹9,500',
      positive: false),
  DemoTransaction(
      'SPOTO Platform Fee', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹2,800',
      positive: false),
  DemoTransaction(
      'Prize Money', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹12,000',
      positive: false),
  DemoTransaction(
      'GST on Platform Fee', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹504',
      positive: false),
];

const demoPrizeTransactions = <DemoTransaction>[
  DemoTransaction('Winner', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹50,000',
      positive: false),
  DemoTransaction('Runner-up', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹20,000',
      positive: false),
  DemoTransaction('3rd Place', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹10,000',
      positive: false),
  DemoTransaction('4th Place', '16 Jul 2026, 10:45 am', 'SP-441877', '-₹50,000',
      positive: false),
];

class DemoSettlement {
  const DemoSettlement(this.title, this.subtitle, this.amount,
      {this.status = 'Paid'});

  final String title;
  final String subtitle;
  final String amount;
  final String status;
}

const demoSettlements = <DemoSettlement>[
  DemoSettlement('Status', 'Utr-5640 · Tnx000125', '+₹5,000'),
  DemoSettlement('Best Bowler', 'SP-441877', '+₹42,000'),
  DemoSettlement('Winner', 'SP-441877', '+₹50,000'),
  DemoSettlement('Runner-up', 'SP-441877', '+₹20,000'),
];

class DemoProfitRow {
  const DemoProfitRow(this.label, this.amount, {this.emphasis = false});

  final String label;
  final String amount;
  final bool emphasis;
}

const demoProfitRows = <DemoProfitRow>[
  DemoProfitRow('Income From Registration', '+₹42,000', emphasis: true),
  DemoProfitRow('Income from sponsorship', '+₹4,200'),
  DemoProfitRow('Referee Booking', '-₹4,200'),
  DemoProfitRow('Prize money paid by Partner', '-₹9,500'),
  DemoProfitRow('SPOTO platform fee', '-₹2,800'),
  DemoProfitRow('GST on platform fee', '-₹504'),
  DemoProfitRow('Total applicable income', '+₹18,804', emphasis: true),
  DemoProfitRow('Total applicable expense', '-₹18,804', emphasis: true),
  DemoProfitRow('Net Profit / Loss', '+₹23,196', emphasis: true),
];

class DemoInnings {
  const DemoInnings(
      this.opponent, this.round, this.runs, this.fours, this.sixes);

  final String opponent;
  final String round;
  final String runs;
  final String fours;
  final String sixes;
}

const demoInnings = <DemoInnings>[
  DemoInnings('Delhi Warriors', 'Semi-final 2 · SPT-20481', '9 (15)', '2', '4'),
  DemoInnings(
      'Malkajgiri Mustangs', 'Semi-final 2 · SPT-20481', '9 (15)', '2', '4'),
  DemoInnings('Uppal Uhlans', 'Semi-final 2 · SPT-20481', '9 (15)', '2', '4'),
  DemoInnings('LB Nagar Lions', 'Semi-final 2 · SPT-20481', '9 (15)', '2', '4'),
  DemoInnings(
      'Malkajgiri Mustangs', 'Semi-final 2 · SPT-20481', '9 (15)', '2', '4'),
];

class DemoTeamRank {
  const DemoTeamRank(this.rank, this.name, this.captain, this.label,
      {this.color});

  final int rank;
  final String name;
  final String captain;
  final String label;
  final Color? color;
}
