import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/referee_request_widgets.dart';

/// Figma `06_Incoming_Requests_Details` — accept booking confirmation step.
class AcceptBookingScreen extends StatefulWidget {
  final RefereeMatchRequestResponse? request;
  final String? requestId;

  const AcceptBookingScreen({
    super.key,
    this.request,
    this.requestId,
  });

  @override
  State<AcceptBookingScreen> createState() => _AcceptBookingScreenState();
}

class _AcceptBookingScreenState extends State<AcceptBookingScreen> {
  late Future<RefereeMatchRequestResponse?> _future;
  bool _submitting = false;

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
    for (final request in requests) {
      if ('${request.assignmentId ?? request.id}' == '${widget.requestId}') {
        return request;
      }
    }
    return null;
  }

  Future<void> _confirm(RefereeMatchRequestResponse request) async {
    setState(() => _submitting = true);
    try {
      await _remote.acceptMatchRequest(request.assignmentId ?? request.id);
      if (!mounted) return;
      context.pushReplacement(
        '${AppRouter.bookingConfirmedRoute}?requestId=${request.assignmentId ?? request.id}',
        extra: request,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to accept booking: $error')),
      );
      setState(() => _submitting = false);
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
            _AcceptHeader(scale: scale),
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
                  return _AcceptBody(
                    scale: scale,
                    request: request,
                    submitting: _submitting,
                    onConfirm: () => _confirm(request),
                    onCancel: () => context.pop(),
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

class _AcceptHeader extends StatelessWidget {
  final double scale;

  const _AcceptHeader({required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
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
        ),
      ),
    );
  }
}

class _AcceptBody extends StatelessWidget {
  final double scale;
  final RefereeMatchRequestResponse request;
  final bool submitting;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _AcceptBody({
    required this.scale,
    required this.request,
    required this.submitting,
    required this.onConfirm,
    required this.onCancel,
  });

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
        children: [
          RefereeGradientText(
            'ACCEPT BOOKING?',
            gradient: const LinearGradient(
              colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
            ),
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'You are accepting:',
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          SizedBox(height: 20 * scale),

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
                      gradient: isPartner
                          ? const LinearGradient(
                              colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
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
          SizedBox(height: 10 * scale),

          // Tournament summary
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              color: const Color(0x0F2BB673),
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
                SizedBox(height: 2 * scale),
                Text(
                  requestVenueTitle(request),
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
                SizedBox(height: 2 * scale),
                RefereeGradientText(
                  '${requestDateText(request)} · ${requestTimeRangeText(request)}',
                  gradient: _goldGradient,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6 * scale),
                RefereeGradientText(
                  requestFeeText(request),
                  gradient: _orangeGradient,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),

          // Location
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              color: const Color(0x0F2BB673),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requestVenueTitle(request),
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
                      SportoRefereeBookingIcons.pinGreen,
                      size: 18 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Expanded(
                      child: Text(
                        requestLocationText(request),
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),

          _ActionButton(
            scale: scale,
            label: submitting ? 'Accepting…' : 'Confirm Accept',
            background: const Color(0xFFF4B41A),
            textColor: const Color(0xFF0E0C08),
            fontWeight: FontWeight.w700,
            onTap: submitting ? null : onConfirm,
          ),
          SizedBox(height: 16 * scale),
          _ActionButton(
            scale: scale,
            label: 'Cancel',
            background: const Color(0x1AFFFFFF),
            textColor: const Color(0xFFA0A0A0),
            fontWeight: FontWeight.w500,
            onTap: submitting ? null : onCancel,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double scale;
  final String label;
  final Color background;
  final Color textColor;
  final FontWeight fontWeight;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.scale,
    required this.label,
    required this.background,
    required this.textColor,
    required this.fontWeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44 * scale,
      child: Container(
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
      ),
    );
  }
}
