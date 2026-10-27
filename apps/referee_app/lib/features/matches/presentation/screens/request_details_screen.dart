import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/referee_request_widgets.dart';

/// Figma `05_Incoming_Requests_Details` — request detail page.
class RequestDetailsScreen extends StatefulWidget {
  final RefereeMatchRequestResponse? request;
  final String? requestId;

  const RequestDetailsScreen({
    super.key,
    this.request,
    this.requestId,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late Future<RefereeMatchRequestResponse?> _future;
  bool _declining = false;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = Future.value(widget.request);
    if (widget.request == null && widget.requestId != null) {
      _future = _load();
    }
  }

  Future<RefereeMatchRequestResponse?> _load() async {
    final requests = await _remote.listMatchRequestsData();
    final id = widget.requestId;
    for (final request in requests) {
      if ('${request.assignmentId ?? request.id}' == '$id') return request;
    }
    return null;
  }

  Future<void> _accept(RefereeMatchRequestResponse request) async {
    await context.push(
      '${AppRouter.acceptBookingRoute}?requestId=${request.assignmentId ?? request.id}',
      extra: request,
    );
  }

  Future<void> _decline(RefereeMatchRequestResponse request) async {
    setState(() => _declining = true);
    try {
      await _remote.rejectMatchRequest(request.assignmentId ?? request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request declined.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to decline request: $error')),
      );
    } finally {
      if (mounted) setState(() => _declining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailsHeader(scale: scale),
            Expanded(
              child: FutureBuilder<RefereeMatchRequestResponse?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF4B41A),
                      ),
                    );
                  }
                  final request = snapshot.data;
                  if (request == null) {
                    return Center(
                      child: Text(
                        'Request not found',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    );
                  }
                  return _DetailsBody(
                    scale: scale,
                    request: request,
                    declining: _declining,
                    onAccept: () => _accept(request),
                    onDecline: () => _decline(request),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  final double scale;

  const _DetailsHeader({required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(10 * scale),
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
            Text(
              'Request Details',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final double scale;
  final RefereeMatchRequestResponse request;
  final bool declining;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _DetailsBody({
    required this.scale,
    required this.request,
    required this.declining,
    required this.onAccept,
    required this.onDecline,
  });

  static const _pinkGradient = LinearGradient(
    colors: [Color(0x1AFF58DD), Color(0x1ADC65AC)],
  );
  static const _blueGradient = LinearGradient(
    colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
  );
  static const _pinkTextGradient = LinearGradient(
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        6 * scale,
        20 * scale,
        40 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport / code / by / time
          Container(
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
                    requestSport(request),
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
                    requestCode(request),
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
                      horizontal: 4 * scale,
                      vertical: 4 * scale,
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
                      requestSourceLabel(request),
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
                SizedBox(width: 10 * scale),
                RefereeGradientText(
                  requestClockText(request),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                  ),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18 * scale),

          // Booked by
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              gradient: _pinkGradient,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10 * scale),
                  child: SportoAssetIcon(
                    SportoRefereeBookingIcons.avatarReferee,
                    size: 40 * scale,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Booked by',
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6 * scale,
                              vertical: 2 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1A2BB673),
                              borderRadius: BorderRadius.circular(10 * scale),
                            ),
                            child: Text(
                              requestStatusText(request),
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2BB673),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2 * scale),
                      RefereeGradientText(
                        requestCustomerName(request),
                        gradient: _pinkTextGradient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),

          // Tournament / venue / location
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              color: const Color(0x801C2026),
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
              border: Border.all(color: const Color(0x1AFEBD38), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayTournament,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 10 * scale),
                Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
                SizedBox(height: 10 * scale),
                Text(
                  requestVenueTitle(request),
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: [
                    SportoSvgIcon(
                      SportoRefereeBookingIcons.pinGreenSmall,
                      size: 16 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Expanded(
                      child: Text(
                        requestLocationText(request),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    _DetailDistancePill(
                      scale: scale,
                      label: requestDistanceText(request),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),

          // Booking details
          Container(
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
                    _detailColumn(
                      value: requestDateText(request),
                      label: 'Date',
                    ),
                    _detailColumn(
                      value: requestStartTimeText(request),
                      label: 'Start Time',
                    ),
                    _detailColumn(
                      value: requestDurationText(request),
                      label: 'Duration',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),

          // Status + earnings
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: const Color(0x661C2026),
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Booking Status',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                    Text(
                      requestStatusText(request),
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2BB673),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * scale),
                Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
                SizedBox(height: 8 * scale),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Expected Earnings',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    RefereeGradientText(
                      requestFeeText(request),
                      gradient: _orangeGradient,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),

          _InfoCard(
            scale: scale,
            title: 'Referee Responsibilities',
            body:
                'Conduct the booked referee service at the venue. Start and finish the session with OTPs provided by the user.',
          ),
          SizedBox(height: 10 * scale),
          _InfoCard(
            scale: scale,
            centered: true,
            body:
                'Payment is released to your SPOTO Wallet within 24 hours of partner confirmation. Cancellations inside 4 hours of match time may affect your referee rating.',
          ),
          SizedBox(height: 20 * scale),

          SizedBox(
            width: double.infinity,
            height: 44 * scale,
            child: _SolidButton(
              scale: scale,
              label: 'Accept',
              background: const Color(0xFFF4B41A),
              textColor: const Color(0xFF0E0C08),
              fontWeight: FontWeight.w700,
              onTap: onAccept,
            ),
          ),
          SizedBox(height: 16 * scale),
          SizedBox(
            width: double.infinity,
            height: 44 * scale,
            child: _SolidButton(
              scale: scale,
              label: 'Decline',
              background: const Color(0x1AFFFFFF),
              textColor: const Color(0xFFA0A0A0),
              fontWeight: FontWeight.w500,
              onTap: declining ? null : onDecline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailColumn({required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          RefereeGradientText(
            value,
            gradient: _goldGradient,
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

class _DetailDistancePill extends StatelessWidget {
  final double scale;
  final String label;

  const _DetailDistancePill({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31 * scale,
      padding: EdgeInsets.fromLTRB(6 * scale, 4 * scale, 6 * scale, 4 * scale),
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

class _InfoCard extends StatelessWidget {
  final double scale;
  final String? title;
  final String body;
  final bool centered;

  const _InfoCard({
    required this.scale,
    this.title,
    required this.body,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: const Color(0x661C2026),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA0A0A0),
              ),
            ),
            SizedBox(height: 6 * scale),
          ],
          Text(
            body,
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: (centered ? 11 : 13) * scale,
              fontWeight: FontWeight.w500,
              color:
                  centered ? const Color(0xFFA0A0A0) : const Color(0xFFFFFFFF),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  final double scale;
  final String label;
  final Color background;
  final Color textColor;
  final FontWeight fontWeight;
  final VoidCallback? onTap;

  const _SolidButton({
    required this.scale,
    required this.label,
    required this.background,
    required this.textColor,
    required this.fontWeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
