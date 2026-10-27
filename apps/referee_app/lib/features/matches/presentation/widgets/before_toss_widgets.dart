import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import 'referee_request_widgets.dart';

/// Display model shared by the pre-toss "Match Details" and "Start Match"
/// screens. Keeps raw API mapping in one place so both screens stay visually
/// identical to the exported before_toss Figma package.
class BeforeTossMatch {
  const BeforeTossMatch({
    required this.tournament,
    required this.venue,
    required this.location,
    required this.teamA,
    required this.teamB,
    required this.sport,
    required this.code,
    required this.sourceLabel,
    required this.dateText,
    required this.startTimeText,
    required this.durationText,
    this.expectedOtp,
    this.matchId,
  });

  final String tournament;
  final String venue;
  final String location;
  final String teamA;
  final String teamB;
  final String sport;
  final String code;
  final String sourceLabel;
  final String dateText;
  final String startTimeText;
  final String durationText;
  final String? expectedOtp;
  final String? matchId;

  factory BeforeTossMatch.fromResponse(RefereeMatchResponse match) {
    return BeforeTossMatch(
      tournament: match.displayTournament,
      venue: match.venueName?.trim().isNotEmpty == true
          ? match.venueName!.trim()
          : match.displayVenue,
      location: match.location?.trim().isNotEmpty == true
          ? match.location!.trim()
          : match.displayVenue,
      teamA: match.displayTeamA,
      teamB: match.displayTeamB,
      sport: requestSport(match),
      code: requestCode(match),
      sourceLabel: requestSourceLabel(match),
      dateText: requestDateText(match),
      startTimeText: requestStartTimeText(match),
      durationText: requestDurationText(match),
      expectedOtp: _extractOtp(match.raw),
      matchId: '${match.id}',
    );
  }

  factory BeforeTossMatch.fromEntity(CricketMatchEntity match) {
    final scheduled = match.scheduledTime;
    return BeforeTossMatch(
      tournament: match.tournamentName,
      venue: match.venue,
      location: match.venue,
      teamA: match.teamA.name,
      teamB: match.teamB.name,
      sport: 'Cricket',
      code: 'SP-${match.id}',
      sourceLabel: 'by Partner',
      dateText: _dateText(scheduled),
      startTimeText: _timeText(scheduled),
      durationText: '2 hr 0 min',
      expectedOtp: null,
      matchId: match.id,
    );
  }

  static String? _extractOtp(Map<String, dynamic> raw) {
    const keys = [
      'match_otp',
      'session_otp',
      'start_otp',
      'start_session_otp',
      'otp',
    ];
    for (final key in keys) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    for (final nestedKey in [
      'match',
      'booking',
      'assignment',
      'session',
      'score',
    ]) {
      final nested = raw[nestedKey];
      if (nested is Map) {
        final found = _extractOtp(Map<String, dynamic>.from(nested));
        if (found != null) return found;
      }
    }
    return null;
  }

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
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

  static String _dateText(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

  static String _timeText(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

// =============================================================================
// Header
// =============================================================================
class BeforeTossHeader extends StatelessWidget {
  final double scale;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const BeforeTossHeader({
    super.key,
    required this.scale,
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(10 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1F000000),
                      blurRadius: 4 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
                ),
                child: Center(
                  child: SportoSvgIcon(
                    SportoRefereeBookingIcons.back,
                    width: 6 * scale,
                    height: 12 * scale,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 1 * scale),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
                        height: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Sport / code / source / status card
// =============================================================================
class BeforeTossSportCard extends StatelessWidget {
  final double scale;
  final BeforeTossMatch match;

  const BeforeTossSportCard({
    super.key,
    required this.scale,
    required this.match,
  });

  static const _blueGradient = LinearGradient(
    colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
  );
  static const _pinkTextGradient = LinearGradient(
    colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
  );

  @override
  Widget build(BuildContext context) {
    final isPartner = match.sourceLabel == 'by Partner';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: LinearGradient(
          colors: isPartner
              ? const [Color(0x1AFF58DD), Color(0x1ADC65AC)]
              : const [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              match.sport,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2BB673),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            child: Container(
              width: 2 * scale,
              height: 2 * scale,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFA0A0A0),
              ),
            ),
          ),
          Flexible(
            child: Text(
              match.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6 * scale,
                vertical: 2 * scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * scale),
                gradient: LinearGradient(
                  colors: isPartner
                      ? const [Color(0x1AFF58DD), Color(0x1ADC65AC)]
                      : const [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
                ),
              ),
              child: RefereeGradientText(
                match.sourceLabel,
                gradient: isPartner ? _pinkTextGradient : _blueGradient,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * scale),
                gradient: const LinearGradient(
                  colors: [Color(0x1AFF9364), Color(0x1AF25F33)],
                ),
              ),
              child: RefereeGradientText(
                'Upcoming',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tournament / venue / teams (+ optional booking location)
// =============================================================================
class BeforeTossMatchTicket extends StatelessWidget {
  final double scale;
  final BeforeTossMatch match;
  final bool includeLocation;

  const BeforeTossMatchTicket({
    super.key,
    required this.scale,
    required this.match,
    this.includeLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final ticket = _TicketCard(scale: scale, match: match);
    if (!includeLocation) return ticket;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 6 * scale),
      decoration: BoxDecoration(
        color: const Color(0x0F2BB673),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0x332BB673), width: 0.5),
      ),
      child: Column(
        children: [
          ticket,
          SizedBox(height: 6 * scale),
          _BookingLocationCard(scale: scale, location: match.location),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final double scale;
  final BeforeTossMatch match;

  const _TicketCard({required this.scale, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x0F7AD3FF), Color(0x0F4FBAF0)],
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0x3364C6F7), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.tournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            match.venue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.teamA,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF4B41A),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.teamB,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF4B41A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingLocationCard extends StatelessWidget {
  final double scale;
  final String location;

  const _BookingLocationCard({required this.scale, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Location',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: [
                    SportoSvgIcon(
                      SportoRefereeBookingIcons.pinGreenSmall,
                      size: 18 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 4 * scale),
          Container(
            width: 30 * scale,
            height: 30 * scale,
            decoration: BoxDecoration(
              color: const Color(0x14F4B41A),
              borderRadius: BorderRadius.circular(10 * scale),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: 3 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Center(
              child: SportoSvgIcon(
                SportoHomeRedesignIcons.navigation,
                size: 16 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Booking details
// =============================================================================
class BeforeTossBookingDetails extends StatelessWidget {
  final double scale;
  final BeforeTossMatch match;

  const BeforeTossBookingDetails({
    super.key,
    required this.scale,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: const LinearGradient(
          colors: [Color(0x0FFFD572), Color(0x0FFEBD38)],
        ),
        border: Border.all(color: const Color(0x80FFD572), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              _column(match.dateText, 'Date'),
              _column(match.startTimeText, 'Start Time'),
              _column(match.durationText, 'Duration'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _column(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          RefereeGradientText(
            value,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Final checklist
// =============================================================================
class BeforeTossChecklist extends StatelessWidget {
  final double scale;
  final bool team1Checked;
  final bool team2Checked;
  final bool tossChecked;

  const BeforeTossChecklist({
    super.key,
    required this.scale,
    this.team1Checked = true,
    this.team2Checked = true,
    this.tossChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final Checklist',
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA0A0A0),
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * scale),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1C2026), Color(0xFF12161C)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Team 1', team1Checked),
              SizedBox(height: 16 * scale),
              _row('Team 2', team2Checked),
              SizedBox(height: 16 * scale),
              _row('Toss', tossChecked),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, bool checked) {
    return SizedBox(
      height: 18 * scale,
      child: Row(
        children: [
          Container(
            width: 16 * scale,
            height: 16 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? const Color(0xFF2BB673) : Colors.transparent,
              border: checked
                  ? null
                  : Border.all(color: const Color(0xFF666666), width: 1),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 11 * scale,
                    color: const Color(0xFF090C10),
                  )
                : null,
          ),
          SizedBox(width: 8 * scale),
          if (checked)
            RefereeGradientText(
              label,
              gradient: const LinearGradient(
                colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
              ),
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFFFFFF),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Primary orange/gold CTA
// =============================================================================
class BeforeTossPrimaryButton extends StatelessWidget {
  final double scale;
  final String label;
  final VoidCallback? onTap;

  const BeforeTossPrimaryButton({
    super.key,
    required this.scale,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x59ED7B00),
            blurRadius: 30 * scale,
            offset: Offset(2 * scale, 10 * scale),
          ),
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
