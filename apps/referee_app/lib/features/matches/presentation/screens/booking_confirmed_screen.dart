import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/referee_request_widgets.dart';

/// Figma `07_BOOKING_CONFIRMED`.
class BookingConfirmedScreen extends StatefulWidget {
  final RefereeMatchRequestResponse? request;
  final String? requestId;

  const BookingConfirmedScreen({
    super.key,
    this.request,
    this.requestId,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late Future<RefereeMatchRequestResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.value(widget.request);
    if (widget.request == null && widget.requestId != null) {
      _future = _load();
    }
  }

  Future<RefereeMatchRequestResponse?> _load() async {
    final requests = await DependencyInjector.instance.refereeRemoteDataSource
        .listMatchRequestsData();
    for (final request in requests) {
      if ('${request.assignmentId ?? request.id}' == '${widget.requestId}') {
        return request;
      }
    }
    return null;
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
            SizedBox(
              height: 44 * scale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.go(AppRouter.homePath),
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
            ),
            Expanded(
              child: FutureBuilder<RefereeMatchRequestResponse?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2BB673),
                      ),
                    );
                  }
                  final request = snapshot.data;
                  if (request == null) {
                    return Center(
                      child: Text(
                        'Booking confirmed',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    );
                  }
                  return _ConfirmedBody(scale: scale, request: request);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedBody extends StatelessWidget {
  final double scale;
  final RefereeMatchRequestResponse request;

  const _ConfirmedBody({required this.scale, required this.request});

  static const _pinkGradient = LinearGradient(
    colors: [Color(0x1AFF58DD), Color(0x1ADC65AC)],
  );
  static const _pinkText = LinearGradient(
    colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
  );
  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        0,
        20 * scale,
        40 * scale,
      ),
      child: Column(
        children: [
          // Success card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 24 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30 * scale),
              color: const Color(0x052BB673),
              gradient: const LinearGradient(
                colors: [Color(0x032BB673), Color(0x0A2BB673)],
                stops: [0.0, 0.52],
              ),
              border: Border.all(color: const Color(0x332BB673), width: 0.8),
            ),
            child: Column(
              children: [
                Container(
                  width: 76 * scale,
                  height: 76 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFBFF0A8),
                        Color(0xFF84DC6F),
                        Color(0xFF16B704),
                        Color(0xFF13B601),
                      ],
                      stops: [0.14, 0.28, 0.53, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0FFFFFFF),
                        blurRadius: 30 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SportoSvgIcon(
                      SportoRefereeBookingIcons.check,
                      size: 34 * scale,
                    ),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'BOOKING CONFIRMED',
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Booking confirmed. It is now in your Upcoming bookings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),

          // Sport / code / by
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 12 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              gradient: _pinkGradient,
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
                      gradient: const LinearGradient(
                        colors: [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
                      ),
                    ),
                    child: RefereeGradientText(
                      requestSourceLabel(request),
                      gradient: const LinearGradient(
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
              ],
            ),
          ),
          SizedBox(height: 10 * scale),

          // Booked by
          Container(
            width: double.infinity,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booked by',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    RefereeGradientText(
                      requestCustomerName(request),
                      gradient: _pinkText,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),

          // Tournament / venue / location / date-time-duration
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
              color: const Color(0x0F2BB673),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelValue(
                  label: 'Tournament',
                  value: request.displayTournament,
                ),
                SizedBox(height: 7 * scale),
                _labelValue(
                  label: 'Venue',
                  value: requestVenueTitle(request),
                ),
                SizedBox(height: 7 * scale),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _labelValue(
                        label: 'Location',
                        value: requestLocationText(request),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Container(
                      height: 27 * scale,
                      padding: EdgeInsets.fromLTRB(
                        4 * scale,
                        4 * scale,
                        4 * scale,
                        4 * scale,
                      ),
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
                            requestDistanceText(request),
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
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    _dateChunk(
                      label: 'Date',
                      value: requestDateText(request),
                    ),
                    Container(
                      width: 0.5 * scale,
                      height: 29 * scale,
                      color: const Color(0x33FFFFFF),
                    ),
                    _dateChunk(
                      label: 'Time',
                      value: requestTimeRangeText(request),
                    ),
                    Container(
                      width: 0.5 * scale,
                      height: 29 * scale,
                      color: const Color(0x33FFFFFF),
                    ),
                    _dateChunk(
                      label: 'Duration',
                      value: requestDurationText(request)
                          .replaceFirst(' hr ', ' Hours ')
                          .replaceFirst('0 min', ''),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * scale),

          // Fee
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale,
              vertical: 12 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14 * scale),
              gradient: const LinearGradient(
                colors: [Color(0x0AFF9364), Color(0x0AF25F33)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Fee',
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
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),

          // View Upcoming
          SizedBox(
            width: 270 * scale,
            height: 48 * scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(
                  color: const Color(0xFFED7B00),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go(AppRouter.homePath),
                  borderRadius: BorderRadius.circular(16 * scale),
                  child: Center(
                    child: RefereeGradientText(
                      'View Upcoming',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                      ),
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelValue({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA0A0A0),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ],
    );
  }

  Widget _dateChunk({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 1 * scale),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
