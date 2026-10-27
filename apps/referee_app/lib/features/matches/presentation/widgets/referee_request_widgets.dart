import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Shared gradient-filled text used across the redesigned referee screens.
class RefereeGradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const RefereeGradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: style,
      ),
    );
  }
}

// =============================================================================
// Request value helpers (raw-API tolerant, with design fallbacks)
// =============================================================================
String requestSport(RefereeMatchResponse request) {
  final rawSport = request.raw['sport'] ?? request.raw['sport_name'];
  if (rawSport is Map) {
    final name = rawSport['name']?.toString();
    if (name != null && name.trim().isNotEmpty) return name;
  }
  final direct = request.raw['sport_name']?.toString();
  if (direct != null && direct.trim().isNotEmpty) return direct;
  return 'Cricket';
}

String requestCode(RefereeMatchResponse request) {
  for (final value in [
    request.matchNumber,
    request.raw['match_code'],
    request.raw['fixture_code'],
    request.raw['code'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return 'SP-${request.id}';
}

String requestSourceLabel(RefereeMatchResponse request) {
  final raw = [
    request.raw['booked_by_type'],
    request.raw['booking_source'],
    request.raw['source'],
    request.raw['created_by'],
  ]
      .whereType<Object>()
      .map((value) => value.toString().toLowerCase())
      .join(' ');
  return raw.contains('partner') ? 'by Partner' : 'by User';
}

String requestCustomerName(RefereeMatchResponse request) {
  for (final value in [
    request.raw['booked_by'],
    request.raw['customer_name'],
    request.raw['user_name'],
    request.raw['booked_by_name'],
    request.raw['player_name'],
    request.raw['requester_name'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return 'User';
}

num? _numberValue(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

int requestFeeValue(RefereeMatchResponse request) {
  for (final value in [
    request.raw['fee'],
    request.raw['expected_earnings'],
    request.raw['amount'],
    request.raw['price'],
    request.raw['payment_amount'],
  ]) {
    final number = _numberValue(value);
    if (number != null && number > 0) return number.round();
  }
  return 1500;
}

String requestFeeText(RefereeMatchResponse request) =>
    '₹${requestFeeValue(request)}';

double requestDurationHours(RefereeMatchResponse request) {
  for (final key in ['duration_hours', 'duration', 'hours']) {
    final number = _numberValue(request.raw[key]);
    if (number != null && number > 0) return number.toDouble();
  }
  return 2;
}

String requestDurationText(RefereeMatchResponse request) {
  final hours = requestDurationHours(request);
  final whole = hours.floor();
  final minutes = ((hours - whole) * 60).round();
  if (whole == 0) return '$minutes min';
  if (minutes == 0) return '$whole hr 0 min';
  return '$whole hr $minutes min';
}

String requestDistanceText(RefereeMatchResponse request) {
  final number =
      _numberValue(request.raw['distance_km'] ?? request.raw['distance']);
  final value = number == null ? 8.4 : number.toDouble();
  return '${value.toStringAsFixed(1)} km';
}

DateTime? requestDateTime(RefereeMatchResponse request) {
  final candidates = [
    request.scheduledAt,
    (request.matchDate != null && request.startTime != null)
        ? '${request.matchDate} ${request.startTime}'
        : null,
    request.matchDate,
  ];
  for (final value in candidates) {
    if (value == null || value.trim().isEmpty) continue;
    final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (parsed != null) return parsed.toLocal();
  }
  return null;
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
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

String requestDateText(RefereeMatchResponse request) {
  final date = requestDateTime(request);
  if (date == null) return request.matchDate?.trim() ?? 'Date not set';
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
}

String _time12(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
}

String requestClockText(RefereeMatchResponse request) {
  final date = requestDateTime(request);
  if (date == null) return request.startTime?.trim() ?? '14:20';
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String requestStartTimeText(RefereeMatchResponse request) {
  final date = requestDateTime(request);
  if (date == null) return request.startTime?.trim() ?? '5:00 PM';
  return _time12(date);
}

String requestEndTimeText(RefereeMatchResponse request) {
  final date = requestDateTime(request);
  if (date == null) return request.startTime?.trim() ?? '7:00 PM';
  return _time12(date
      .add(Duration(minutes: (requestDurationHours(request) * 60).round())));
}

String requestTimeRangeText(RefereeMatchResponse request) =>
    '${requestStartTimeText(request)} – ${requestEndTimeText(request)}';

String requestScheduleText(RefereeMatchResponse request) {
  final date = requestDateTime(request);
  if (date == null) return request.displaySchedule;
  return 'Today, ${_time12(date)}';
}

String requestVenueTitle(RefereeMatchResponse request) =>
    request.venueName?.trim().isNotEmpty == true
        ? request.venueName!.trim()
        : 'KPHB Indoor Stadium';

String requestLocationText(RefereeMatchResponse request) =>
    request.location?.trim().isNotEmpty == true
        ? request.location!.trim()
        : 'ABC Sports Arena, Madhapur, Hyderabad';

String requestStatusText(RefereeMatchResponse request) {
  final raw = request.raw['booking_status']?.toString();
  if (raw != null && raw.trim().isNotEmpty) return raw;
  return 'Request Received';
}

// =============================================================================
// Shared request card (Incoming Requests — Home + list screen)
// =============================================================================
class RefereeRequestCard extends StatelessWidget {
  final double scale;
  final RefereeMatchRequestResponse request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isProcessing;

  const RefereeRequestCard({
    super.key,
    required this.scale,
    required this.request,
    this.onTap,
    this.onAccept,
    this.onDecline,
    this.isProcessing = false,
  });

  static const _blueGradient = LinearGradient(
    colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
  );
  static const _pinkGradient = LinearGradient(
    colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
  );
  static const _goldGradient = LinearGradient(
    colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
  );
  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
  );

  @override
  Widget build(BuildContext context) {
    final isPartner = requestSourceLabel(request) == 'by Partner';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * scale),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xE61C2026),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x0A00D816),
                    Color(0x144FBAF0),
                    Color(0x0AFEBD38),
                  ],
                  stops: [0.0, 0.54, 1.0],
                ),
                border: Border.all(
                  color: const Color(0x1AFEBD38),
                  width: 0.6,
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(10 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            requestSport(request),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2BB673),
                            ),
                          ),
                        ),
                        _dot(scale),
                        Flexible(
                          child: Text(
                            requestCode(request),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
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
                                    ? const [
                                        Color(0x1AFF58DD),
                                        Color(0x1ADC65AC)
                                      ]
                                    : const [
                                        Color(0x1A7AD3FF),
                                        Color(0x1A4FBAF0)
                                      ],
                              ),
                            ),
                            child: RefereeGradientText(
                              requestSourceLabel(request),
                              gradient:
                                  isPartner ? _pinkGradient : _blueGradient,
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
                        RefereeGradientText(
                          requestClockText(request),
                          gradient: _goldGradient,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scale),
                    RefereeGradientText(
                      requestCustomerName(request),
                      gradient: _blueGradient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      request.displayTournament,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Row(
                      children: [
                        RefereeGradientText(
                          requestDateText(request),
                          gradient: _goldGradient,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                          child: Container(
                            width: 2 * scale,
                            height: 2 * scale,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFEBD38),
                            ),
                          ),
                        ),
                        Flexible(
                          child: RefereeGradientText(
                            requestTimeRangeText(request),
                            gradient: _goldGradient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * scale),
                    Container(
                        height: 0.5 * scale, color: const Color(0x33FFFFFF)),
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SportoSvgIcon(
                                SportoRefereeBookingIcons.pinGreenSmall,
                                size: 16 * scale,
                              ),
                              SizedBox(width: 2 * scale),
                              Expanded(
                                child: Text(
                                  requestLocationText(request),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA0A0A0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4 * scale),
                        RefereeDistancePill(
                            scale: scale, label: requestDistanceText(request)),
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    Container(
                        height: 0.5 * scale, color: const Color(0x33FFFFFF)),
                    SizedBox(height: 8 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: RefereeGradientText(
                            requestFeeText(request),
                            gradient: _orangeGradient,
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _RequestActionButton(
                          scale: scale,
                          width: 87,
                          height: 30,
                          radius: 14,
                          label: 'Accept',
                          labelColor: const Color(0xFF0E0C08),
                          fontWeight: FontWeight.w700,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF4B41A), Color(0xFFF4B41A)],
                          ),
                          onTap: isProcessing ? null : onAccept,
                        ),
                        SizedBox(width: 10 * scale),
                        _RequestActionButton(
                          scale: scale,
                          width: 89,
                          height: 30,
                          radius: 14,
                          label: 'Decline',
                          labelColor: const Color(0xFFA0A0A0),
                          fontWeight: FontWeight.w500,
                          gradient: const LinearGradient(
                            colors: [Color(0x1AFFFFFF), Color(0x1AFFFFFF)],
                          ),
                          onTap: isProcessing ? null : onDecline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      child: Container(
        width: 2 * scale,
        height: 2 * scale,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFA0A0A0),
        ),
      ),
    );
  }
}

class RefereeDistancePill extends StatelessWidget {
  final double scale;
  final String label;

  const RefereeDistancePill({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23 * scale,
      padding:
          EdgeInsets.fromLTRB(4 * scale, 3.5 * scale, 3 * scale, 3 * scale),
      decoration: BoxDecoration(
        color: const Color(0x1AF4B41A),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0x33F4B41A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SportoSvgIcon(
            SportoRefereeBookingIcons.pinGreenSmall,
            size: 16 * scale,
          ),
          SizedBox(width: 1 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(width: 2 * scale),
          SportoSvgIcon(
            SportoHomeRedesignIcons.navigation,
            size: 17 * scale,
          ),
        ],
      ),
    );
  }
}

class _RequestActionButton extends StatelessWidget {
  final double scale;
  final double width;
  final double height;
  final double radius;
  final String label;
  final Color labelColor;
  final FontWeight fontWeight;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _RequestActionButton({
    required this.scale,
    required this.width,
    required this.height,
    required this.radius,
    required this.label,
    required this.labelColor,
    required this.fontWeight,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius * scale),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: fontWeight,
                color: labelColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
